# ROM build tool compatibility

Checked on 2026-10-05 using Ubuntu/WSL and OpenJDK 17, matching the major Java version in `.github/workflows/build.yml`.

The filenames are part of the build interface. `apke.jar` is REAndroid APKEditor, not Apktool. COREPATCH, Kaorios and several framework mods call `baksmaliv2.jar d --api <sdk>` and `smaliv2.jar a --api <sdk>` directly.

## Supplied update candidates

| Candidate | SHA-256 | Decision |
| --- | --- | --- |
| APKEditor 1.4.9 / ARSCLib 1.3.9 | `a9cd40df818845456be6d696de6110c89edf4b0a0580cb83438ed6b25a366e67` | Installed as `apke.jar`; host checks passed |
| baksmali 3.0.10 fat JAR | `37ae4a41a8886e15c20b8362fa4250f96bbdb55e1a608199ad8b5dff068b588f` | Do not install with the supplied smali candidate |
| smali 3.0.10 fat JAR | `32fa0e88a6c397b3922201adf5f3e534fbaed5a663c71d0c558c3ddce0af844a` | Rejected for Android 15–17 builds |

The hashes match [APKEditor V1.4.9](https://github.com/REAndroid/APKEditor/releases/tag/V1.4.9) and [baksmali/smali v3.0.10](https://github.com/baksmali/smali/releases/tag/v3.0.10) release assets. Matching release hashes does not establish build compatibility.

## smali/baksmali results

A fixture containing the HyperMOS Settings caller bridge and both NameValueCache hooks was assembled and disassembled with the existing CLI arguments. Both Kaorios hook verifiers and the bridge guard/exception verifier were run on the disassembled results.

| Android / API | Existing 2.5.2 pair | Supplied 3.0.10 pair |
| --- | --- | --- |
| 13 / 33 | PASS | PASS |
| 14 / 34 | PASS | PASS |
| 15 / 35 | PASS | FAIL: generated DEX cannot be read by supplied baksmali |
| 16 / 36 | PASS | FAIL: smali assembly rejects selected DEX version |
| 17 / 37 | PASS | FAIL: smali assembly rejects selected DEX version |

API 35 fails during disassembly with `DexUtil$InvalidFile: DEX entry ... exceeds container_size`. APIs 36 and 37 fail during assembly with `IllegalArgumentException: dexVersion must be within [0, 999]`.

Reproduction with a smali input directory:

```sh
java -jar update/smaliv2.jar a --api 36 input-smali -o output.dex
java -jar update/smaliv2.jar a --api 35 input-smali -o output.dex
java -jar update/baksmaliv2.jar d --api 35 output.dex -o output-smali
```

The real pinned Kaorios driver (334 classes) was also decoded by both versions. The new decoder changes debug-line output; a successful decode alone does not make the new assembler deployable.

Keep the existing `baksmaliv2.jar` and `smaliv2.jar` together. Do not work around these errors by lowering the ROM SDK/API argument. The other tools without supplied replacements remain unchanged.

## APKEditor results

The supplied APKEditor 1.4.9 was tested with the arguments used in the ROM scripts:

| Input / mode | Validation | Result |
| --- | --- | --- |
| InstallerX Revived 26.09 / raw | Decode with `d -t raw -f -no-dex-debug`; edit a smali string; rebuild with `b -t raw -f`; decode output using APKEditor 1.3.9 | PASS |
| InstallerX Revived 26.09 / XML | Decode with `d -t xml -f -no-dex-debug`; edit smali and change manifest package to `com.miui.packageinstaller`; rebuild with `b -t xml -f`; decode output using 1.3.9 | PASS |
| GooglePackageInstaller / default | Decode with `d -i`; rebuild with `b -f -i`; decode output using 1.3.9 | PASS |

Rebuilt archives passed ZIP integrity checks and retained their DEX entry sets. InstallerX output contained the edited smali string, XML output retained the changed package name, and original `assets/` and `lib/` entry bytes were preserved. The existing InstallerX signing step still uses the unchanged `apksigner.jar` and signing key.

Only `apke.jar` was replaced. The candidate folder is not a tool search path and must not be copied wholesale into `bin/apktool`.

These are host compatibility checks, not a full Xiaomi ROM build or an on-device boot test.
