# TNM historical performance profile import

On the Android 16 HAOTIAN \`main\` build, this module now **exits without
modifying the ROM**. PowerKeeper follows the pinned original ZKOS DEX
(adapted for TNM build identifiers), and the Xiaomi ROM's CPU/powerhint,
vendor/ODM thermal XML, KGSL permissions, and thermal protection nodes stay
as originally supplied.

The earlier RYU/TNM archive was an independent, build-time profile overlay
that changed thermal behavior beyond ZKOS. It is no longer installed on
HAOTIAN Android 16 main. The related \`TNM_REF_DIR\`, \`tnm-perfhook-access.rc\`,
and \`tnm-thermalctl\` support remains as historical source but is not activated
by this module for that target. The old cross-partition profile verification
is deliberately skipped for the same target. Other update modules are unchanged.

**Scope limitation:** Original ZKOS vendor/ODM thermal XML files were not
provided; retaining stock Xiaomi XML prevents adding unverified RYU/TNM thermal
profiles but does not prove bit-for-bit identity with ZKOS thermal partitions.
There is no runtime thermal or battery test yet.
