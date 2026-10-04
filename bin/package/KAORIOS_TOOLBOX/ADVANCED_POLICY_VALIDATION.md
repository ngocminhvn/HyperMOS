# AdvancedPolicy SELinux validation

HyperMOS validates the extracted Android 16 SELinux policy in read-only mode after the ROM build step and before packing.

The validator:

- resolves the SettingsProvider SELinux domain from the ROM's own `seapp_contexts`;
- runs `check-advanced-policy-sepolicy.py` against the extracted images;
- requires a unique `kaorios_advanced_policy` service-context mapping;
- requires the checker to report the service type and required Binder/service-manager paths as present;
- enumerates the split CIL inputs and verifies the current policy compiles with `secilc`;
- reports any `precompiled_sepolicy*` artifacts found, without modifying them.

For Android 16 this check is fail-closed: if the policy is missing, ambiguous, or does not compile, the GitHub Actions build stops before `Pack ROM`.

This validation does not add or modify SELinux allow rules. It only verifies policy already present in the extracted ROM tree.

Relevant files:

- `script/validate-advanced-policy-sepolicy.py` — build validator
- `script/check-advanced-policy-sepolicy.py` — read-only structural checker
- `.github/workflows/build.yml` — installs `secilc` and runs the Android 16 validation step
