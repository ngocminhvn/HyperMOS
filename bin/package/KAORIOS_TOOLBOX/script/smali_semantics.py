"""Fail-closed CFG comparison for small, owned smali bridge methods.

Debug directives and label spelling are irrelevant. Register aliases, invoke
ranges and move/const/goto encodings are normalized; branch and exception edges
remain part of the comparison. This is intentionally not a general optimizer.
Unknown directives/opcodes fail closed rather than silently losing semantics.
"""
from __future__ import annotations

import re


def method(text: str, descriptor: str) -> str:
    matches = list(re.finditer(
        r"(?m)^\.method[^\r\n]* " + re.escape(descriptor) + r"[ \t]*\r?$", text))
    if len(matches) != 1:
        raise ValueError(f"expected one bridge method: {descriptor}")
    end = re.search(r"(?m)^\.end method[ \t]*\r?$", text[matches[0].end():])
    if end is None:
        raise ValueError(f"unterminated bridge method: {descriptor}")
    return text[matches[0].start():matches[0].end() + end.end()]


def parse(body: str, parameters: int):
    directives = re.findall(r"(?m)^\s*\.(locals|registers)\s+(\d+)\s*$", body)
    if len(directives) != 1:
        raise ValueError("expected one register directive")
    kind, count = directives[0]
    total = int(count) + (parameters if kind == "locals" else 0)
    base = total - parameters
    if base < 0:
        raise ValueError("not enough parameter registers")

    def register(token):
        index = int(token[1:]) + (base if token[0] == "p" else 0)
        if index < 0 or index >= total:
            raise ValueError(f"out of bounds register: {token}")
        return f"p{index - base}" if index >= base else f"v{index}"

    code, labels, catches = [], {}, []
    for raw in body.splitlines():
        # Preserve literals containing '#', register names, or ':labels'.
        pieces = re.split(r'("(?:\\.|[^"\\])*")', raw)
        line = ""
        for i, piece in enumerate(pieces):
            if i % 2:
                line += piece
            else:
                line += piece.split("#", 1)[0]
                if "#" in piece:
                    break
        line = line.strip()
        if not line:
            continue
        if line.startswith(":"):
            if not re.fullmatch(r":[\w]+", line) or line in labels:
                raise ValueError(f"invalid/duplicate label: {line}")
            labels[line] = len(code)
            continue
        if line.startswith(".catch"):
            match = re.fullmatch(r"\.(catchall|catch \S+)\s+\{(:\w+)\s+\.\.\s+(:\w+)\}\s+(:\w+)", line)
            if match is None:
                raise ValueError(f"invalid catch: {line}")
            catches.append(match.groups())
            continue
        if line.startswith("."):
            if not re.match(r"\.(method |end method$|locals |registers |line |prologue$|epilogue$|local |end local |restart local |param |end param$)", line):
                raise ValueError(f"unsupported bridge directive: {line}")
            continue
        op, _, args = line.partition(" ")
        if not re.fullmatch(r"(?:move(?:-object|-result(?:-object)?|-exception)?(?:/from16|/16)?|const(?:/4|/16|/high16)?|const-string(?:/jumbo)?|invoke-(?:static|virtual|direct)(?:/range)?|[is]get-object|sput-object|new-instance|(?:rem|div)-int|if-(?:eqz|nez|lt|gt|ne|eq)|goto(?:/16|/32)?|return(?:-object|-void)?|nop)", op):
            raise ValueError(f"unsupported bridge opcode: {op}")
        if op.startswith("invoke-") and op.endswith("/range"):
            match = re.match(r"\{([pv]\d+)\s*\.\.\s*([pv]\d+)\}", args)
            if match is None:
                raise ValueError("invalid invoke range")
            first, last = match.groups()
            a = int(first[1:]) + (base if first[0] == "p" else 0)
            b = int(last[1:]) + (base if last[0] == "p" else 0)
            if b < a or b >= total:
                raise ValueError("invalid invoke range bounds")
            args = "{" + ", ".join(f"v{i}" for i in range(a, b + 1)) + "}" + args[match.end():]
        if op.startswith(("move", "goto", "const", "invoke-")):
            op = op.split("/", 1)[0]
        if op == "const":
            reg, literal = args.split(",", 1)
            args = f"{reg}, {int(literal.strip(), 0)}"
        pieces = re.split(r'("(?:\\.|[^"\\])*")', args)
        for i in range(0, len(pieces), 2):
            # Do not rewrite field/method names that happen to contain v0/p0.
            pieces[i] = re.sub(r"(?<![\w/;>])([pv]\d+)(?![\w/:;(])", lambda m: register(m[1]), pieces[i])
            pieces[i] = re.sub(r"\s+", " ", pieces[i])
            pieces[i] = re.sub(r"\s*,\s*", ", ", pieces[i])
        code.append((op, "".join(pieces).strip()))
    if not code:
        raise ValueError("empty bridge method")
    return code, labels, catches


def graph(body: str, parameters: int):
    code, labels, catches = parse(body, parameters)

    def target(label, allow_end=False):
        if label not in labels or labels[label] > len(code) or (not allow_end and labels[label] == len(code)):
            raise ValueError(f"undefined/non-executable target: {label}")
        return labels[label]

    handlers = [[] for _ in code]
    for kind, start, end, handler in catches:
        a, b, h = target(start), target(end, True), target(handler)
        if a >= b or code[h][0] != "move-exception":
            raise ValueError("invalid catch range/handler entry")
        for index in range(a, b):
            handlers[index].append((kind, h))
    nodes = []
    for i, (op, args) in enumerate(code):
        edges = []
        if op.startswith("if-") or op == "goto":
            label = args.rsplit(", ", 1)[-1]
            edges.append(("branch", target(label)))
            args = args[:args.rfind(label)] + "TARGET"
        if not op.startswith("return") and op != "goto":
            if i + 1 >= len(code):
                raise ValueError("bridge falls off method end")
            edges.append(("next", i + 1))
        # Catch directive order for disjoint ranges is irrelevant; priority for
        # overlapping handlers is retained. Even nonthrowing range endpoints
        # are checked so protection cannot silently shrink across a policy call.
        edges.extend(("exception:" + kind, h) for kind, h in handlers[i])
        nodes.append((op + " " + args, edges))

    # Number instructions by ordered graph traversal, rather than label names
    # or physical layout. This also accepts relocated exception-handler blocks.
    order, ids = [], {}
    pending = [0]
    while pending:
        index = pending.pop()
        if index in ids:
            continue
        ids[index] = len(order)
        order.append(index)
        pending.extend(dest for _, dest in reversed(nodes[index][1]))
    if len(order) != len(code):
        raise ValueError("unreachable bridge instructions")
    return tuple((nodes[i][0], tuple((kind, ids[dest]) for kind, dest in nodes[i][1])) for i in order)


def equivalent(actual: str, expected: str, parameters: int, descriptor: str) -> None:
    if graph(actual, parameters) != graph(expected, parameters):
        raise ValueError(f"caller bridge control flow or operands changed: {descriptor}")


def verify_prefix(body: str, block: str, parameters: int) -> None:
    """Compare an injected prefix, treating the stock entry as an opaque exit.

    OEM instructions are outside this parser's scope. Every branch inside the
    prefix must resolve inside it or to its exact stock boundary, never deeper
    into the cache/provider body. Co-located debug/try labels are harmless.
    """
    directive = re.search(r"(?m)^\s*\.(?:locals|registers)\s+\d+\s*$", body)
    if directive is None:
        raise ValueError("missing prefix register directive")
    header = ".method public prefix()V\n" + directive[0].strip() + "\n"
    expected = header + block + "return-void\n.end method\n"
    count = len(parse(expected, parameters)[0]) - 1
    lines, definitions, used = [], set(), 0
    for raw in body.splitlines():
        line = raw.strip()
        if not line or line.startswith((".", "#")):
            continue
        if line.startswith(":"):
            if line in definitions:
                raise ValueError("duplicate prefix label")
            definitions.add(line)
        elif used == count:
            break
        else:
            used += 1
        lines.append(line)
    else:
        raise ValueError("stock body missing after prefix")
    # Detect duplicate definitions beyond the prefix as well.
    all_labels = re.findall(r"(?m)^\s*(:\w+)\s*$", body)
    if len(all_labels) != len(set(all_labels)):
        raise ValueError("duplicate method label")
    actual = header + "\n".join(lines) + "\nreturn-void\n.end method\n"
    equivalent(actual, expected, parameters, "Settings caller prefix")
