# EliteRomLite v4.05 HAOTIAN — static Linux installer crypto trace

**Source:** [GitHub Actions #38856269819](https://github.com/ngocminhvn/HyperMOS/actions/runs/38856269819), artifact `EliteRomLite-HAOTIAN-installer-analysis`. Inspect the `linux_mac_fastboot_install_or_update.sh` executable (despite the `.sh` name, it is ELF64 x86-64 PIE).

**SHA-256:** `1d5f605b89f04716eb1dbcb716e2e12dd3851693e058bc5e4aaa3dbe553548bc`

**Method:** Read the ELF header, program headers, PT_DYNAMIC, `DT_JMPREL` and x86-64 `R_X86_64_JUMP_SLOT` relocations directly, match CET `endbr64; jmp [rip+disp32]` PLT stubs to GOT slots, then scan the largest file-backed executable PT_LOAD region for common direct call/jump encodings. This is **static analysis only**: installer was not run; no encrypted ROM bytes were decrypted.

## Verified evidence

- ELF section-header count: **0**; entry virtual address: `0xac0454`.
- Dynamic JUMP_SLOT imports: **59**. Confirmed PLT stubs mapping to those GOT slots: **59**.
- The main executable PT_LOAD region has RWX permissions (the first 512 KiB has approximately 7.4 bits/byte of entropy).
- Of the 59 imports, **14** use OpenSSL-family names, including PBKDF2 and AES-256-CBC.

| OpenSSL function | GOT virtual address | PLT stub virtual address |
|---|---|---|
| `EVP_aes_256_cbc` | `0xd010f8` | `0x70c40e` |
| `PKCS5_PBKDF2_HMAC` | `0xd01200` | `0x70c558` |
| `EVP_DecryptInit_ex` | `0xd01078` | `0x70c36e` |
| `EVP_DecryptUpdate` | `0xd010f0` | `0x70c404` |
| `EVP_DecryptFinal_ex` | `0xd01098` | `0x70c396` |
| `EVP_sha256` | `0xd01208` | `0x70c562` |
| `EVP_md5` | `0xd01190` | `0x70c4cc` |

## Caller/reference evidence

Byte-pattern scans of file offsets `0x350`–`0x758daa` for known import linkages:

- `call rel32` (`E8`) directly to verified PLT stubs: **0 matches**
- `call [rip+disp32]` (`FF 15`) directly to GOT import slots: **0 matches**
- `jmp [rip+disp32]` (`FF 25`) to GOT import slots, after excluding PLT stubs: **0 matches**
- Plaintext `custom.img`, `Salted__`, `firmware-update`, `openssl enc`: **0 matches each**.

These counts **do not prove** the OpenSSL imports are unused. Indirect calls, data-driven dispatch, packing and obfuscated control flow are not covered by these basic scans.

## Current conclusion

ELF imports give credible evidence that the Linux installer **can use** AES-256-CBC and PBKDF2. Direct static call-site search does **not** recover a call graph connecting `PKCS5_PBKDF2_HMAC` or `EVP_DecryptInit_ex` to `custom.img`. Source of key/passphrase, KDF parameters (including iterations), salt handling, or output-partition writes therefore **remain unverified**. `Salted__` in the separate `custom.img` only identifies a common encrypted-file envelope, not the actual cipher/key parameters.

For reproducibility use `bin/dump/trace_eliterom_crypto.py` (read-only) against the Linux ELF. The `trace-eliterom-crypto.yml` workflow downloads the prior 15 MB GitHub artifact, **not the 7.5 GiB ROM**, and uploads JSON+Markdown reports. GitHub retains that installer artifact only temporarily; the source run may expire on October 23, 2026.

**No installer execution, USB operation, flashing, password guessing, or decryption was performed.**


## Second-stage loader structure (confirmed by run #38859562859)

The new [static loader analysis](https://github.com/ngocminhvn/HyperMOS/actions/runs/38859562859)
ran successfully on the exact original 7,711,996-byte Linux ELF, alongside
inspection of the original Windows installer. **Eight synthetic parser tests
passed**; the real-file SHA-256 was verified before analysis.

- The Linux ELF has **no section headers**.
- **7,703,130 file-backed bytes** belong to one RWX (read-write-execute) PT_LOAD.
- In 512 KiB executable-data windows, **six** have measured Shannon entropy
  greater than **7.99 bits/byte**; this is consistent with compressed,
  encrypted or heavily transformed program content, not proof of any exact
  packer or of a ROM decryption key.
- Verified entry VA: \`0xac0454\`. Direct initial edges:
  \`call rel32\` at \`0xac0458\` goes to \`0xcde021\`;
  \`jmp rel32\` at \`0xac0462\` goes to \`0xdd72e5\`.
  These are **control-flow starting points**, not confirmed crypto callers.
- Dynamic imports include \`fopen\`, \`fread\`, \`fwrite\`, \`getenv\`,
  \`system\`, \`popen\`, and the OpenSSL functions above. Import coexistence
  does not establish a file→PBKDF2→AES→flash execution path.
- No plaintext occurrences of \`custom.img\`, \`Salted__\`, or
  \`firmware-update\` were detected in the Linux ELF.
- The Windows executable has a section explicitly named \`.themida\`,
  further supporting protected installation logic.

[Runner-produced report artifact](https://github.com/ngocminhvn/HyperMOS/actions/runs/38859562859/artifacts/12028378428)
contains \`loader-analysis.json\`, \`loader-analysis.md\`,
\`crypto-trace.json\` and \`crypto-trace.md\`.

**Bottom line:** This is stronger evidence that the installer logic is
protected or obfuscated. It does **not** identify the key, confirm the precise
AES/KDF invocation parameters or decrypt the encrypted \`custom.img\`.
No ROM was flashed, and neither the Linux nor Windows installer was executed.
