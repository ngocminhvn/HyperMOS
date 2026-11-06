# Optional Vietnamese translation RRO APKs

Place only reviewed, signed Android 16-compatible RRO APK files here.

Each RRO needs:
- a distinct APK filename (must not collide with an existing file in product/overlay);
- a unique overlay application package name;
- the exact targetPackage, and targetName if the target exposes an overlayable group;
- only resources that exist in the matching HyperOS 3 target package;
- successful validation on the real device (overlay enabled, valid idmap).

Do not put resource XML files here expecting them to be compiled by the ROM
build. Do not copy random APKs from a different HyperOS version. This directory
is intentionally empty until packages are separately reviewed and tested.

See ../README.md for the Vietnamese Translation Audit workflow.
