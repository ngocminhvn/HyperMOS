#!/usr/bin/env python3
"""Collect ROM reference files and write their source map; never patch the ROM."""
import argparse, csv, hashlib, json, shutil, zipfile
from pathlib import Path
from datetime import datetime, timezone

p=argparse.ArgumentParser()
p.add_argument('--images',type=Path,required=True)
p.add_argument('--targets',type=Path,required=True)
p.add_argument('--output',type=Path,required=True)
p.add_argument('--source-url',default='')
a=p.parse_args()
root=a.images.resolve(); out=a.output.resolve()
(out/'pack-meta').mkdir(parents=True,exist_ok=True)
targets=sorted({s.strip() for s in a.targets.read_text().splitlines() if s.strip() and not s.startswith('#')})
rows=[]; zips={}
for target in targets:
    rel=Path(target)
    if rel.is_absolute() or '..' in rel.parts or len(rel.parts)<3:
        raise SystemExit('Unsafe target: '+target)
    part=rel.parts[1]; rest=Path(*rel.parts[2:])
    bases=[root/part/rest,root/part/part/rest]
    if rest.parts[0]==part: bases.append(root/part/Path(*rest.parts[1:]))
    if part=='vendor' and rest.parts[0]=='odm_dlkm':
        bases.append(root/'odm_dlkm'/Path(*rest.parts[1:]))
    source=next((q for q in bases if q.is_file() and not q.is_symlink()),None)
    mode='exact' if source else 'missing'
    if source is None and rest.suffix=='.apk':
        for q in bases:
            opts=list(q.parent.glob('*.apk')) if q.parent.is_dir() else []
            if len(opts)==1 and not opts[0].is_symlink():
                source=opts[0]; mode='apk-name-fallback'; break
    inner=None
    if source is None:
        for i,seg in enumerate(rest.parts):
            if seg.lower() not in ('powerkeeper','powerkeeperzk') or i>=len(rest.parts)-1: continue
            apk_rest=Path(*rest.parts[:i])/(seg+'.apk')
            for q in [root/part/apk_rest,root/part/part/apk_rest]:
                if not q.is_file():
                    matches=list(q.parent.glob('*.apk')) if q.parent.is_dir() else []
                    q=matches[0] if len(matches)==1 else q
                if not q.is_file() or q.is_symlink(): continue
                if q not in zips:
                    try: zips[q]=zipfile.ZipFile(q)
                    except zipfile.BadZipFile: zips[q]=None
                member='/'.join(rest.parts[i+1:])
                if zips[q] and member in zips[q].NameToInfo:
                    source=q; inner=member; mode='apk-member'; break
            if source: break
    dst=(out/rel).resolve()
    if not dst.is_relative_to(out): raise SystemExit('Unsafe output path')
    row={'target':target,'source':'','partition':part,'status':'MISSING','match':mode,'size':'','sha256':''}
    if source:
        dst.parent.mkdir(parents=True,exist_ok=True)
        if inner:
            with zips[source].open(inner) as src, dst.open('wb') as f: shutil.copyfileobj(src,f)
        else: shutil.copy2(source,dst)
        digest=hashlib.file_digest(dst.open('rb'),'sha256').hexdigest()
        row.update(source=str(source.relative_to(root))+('!/'+inner if inner else ''),
                   status='FOUND',size=dst.stat().st_size,sha256=digest)
    rows.append(row)
for z in zips.values():
    if z:z.close()
columns=list(rows[0]) if rows else []
for file in [out/'map.tsv',out/'pack-meta'/'INDEX.tsv']:
    with file.open('w',newline='',encoding='utf-8') as f:
        w=csv.DictWriter(f,fieldnames=columns,delimiter='\t');w.writeheader();w.writerows(rows)
found=sum(r['status']=='FOUND' for r in rows)
summary={'created':datetime.now(timezone.utc).isoformat(),'source_url':a.source_url,
         'requested':len(rows),'found':found,'missing':len(rows)-found,'items':rows}
(out/'map.json').write_text(json.dumps(summary,indent=2,ensure_ascii=False)+'\n')
meta=out/'pack-meta'
(meta/'manifest.json').write_text(json.dumps({k:v for k,v in summary.items() if k!='items'},indent=2)+'\n')
parts=sorted(x.name for x in root.iterdir() if x.is_dir())
(meta/'partitions.txt').write_text('\n'.join(parts)+'\n')
(meta/'partition-info.json').write_text(json.dumps({'extracted_partitions':parts},indent=2)+'\n')
(meta/'SHA256SUMS.txt').write_text(''.join(r['sha256']+'  '+r['target']+'\n' for r in rows if r['status']=='FOUND'))
(meta/'DEX-REFERENCES.tsv').write_text('target\tsource\tsha256\n'+''.join(
    r['target']+'\t'+r['source']+'\t'+r['sha256']+'\n' for r in rows
    if r['status']=='FOUND' and Path(r['target']).suffix in ('.jar','.dex','.odex','.vdex')))
(meta/'APK-PERMISSIONS.txt').write_text(
    'APK permission inspection is not performed; inspect original APKs with aapt.\n')
(meta/'HOW-TO-EXTRACT.txt').write_text(
    'map.tsv maps output paths to source ROM paths. !/ denotes an APK ZIP entry.\n')
(meta/'PORT-NOTES.md').write_text(
    '# Read-only ROM dump\n\nNot flashable. Review MISSING rows before comparing ROMs.\n')
print(f'[DUMP] requested={len(rows)} found={found} missing={len(rows)-found}')
if found==0: raise SystemExit('No requested files matched the source ROM')
