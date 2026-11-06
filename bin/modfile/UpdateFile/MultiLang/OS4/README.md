# HyperOS 4 (OS4) Vietnamese source

Only the upstream Qualcomm SDK 37 Vietnamese resources are used:

https://github.com/ingbrzy/Xiaomi.eu-HyperOS-4.0-XML-Global/tree/master/qcom-sdk37/Vietnamese/main

Run **Actions > Sync HyperOS 4 Vietnamese XML** to fetch and validate those
XML files into `OS4/Vietnamese/main/<APK>/res/values-vi*/`. The workflow
always uploads a review artifact. Publishing to the Git repository is an
explicit opt-in because the upstream repository does not currently declare
a redistribution license. Confirm permission before publishing a full copy.

The sync is **source staging only**. It neither recompiles Xiaomi system APKs
nor enables RROs or makes the ROM multilingual by itself. OS4 compilation,
overlayable policies, resource IDs, language selection, and signature
compatibility require independent verification before integration into ROM
packaging. In particular, never feed the OS3 `Nothings.*.apk` overlays into
an OS4 build.
