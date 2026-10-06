#!/usr/bin/env bash
# Kaorios Toolbox build-time feature switches for HyperMOS.
# Accepted boolean values: true/false, 1/0, yes/no, on/off.
# Environment variables override these defaults in CI.

KAORIOS_MASTER="${KAORIOS_MASTER:-true}"

# framework.jar call-site hooks.
KAORIOS_ENABLE_ACTIVITY_THREAD="${KAORIOS_ENABLE_ACTIVITY_THREAD:-true}"
KAORIOS_ENABLE_INSTRUMENTATION="${KAORIOS_ENABLE_INSTRUMENTATION:-true}"
KAORIOS_ENABLE_KEYBOX="${KAORIOS_ENABLE_KEYBOX:-true}"
KAORIOS_ENABLE_SYSTEM_FEATURE_SPOOF="${KAORIOS_ENABLE_SYSTEM_FEATURE_SPOOF:-true}"

# services.jar hooks.
KAORIOS_ENABLE_SYSTEM_SERVER="${KAORIOS_ENABLE_SYSTEM_SERVER:-true}"
KAORIOS_ENABLE_HIDDEN_APP="${KAORIOS_ENABLE_HIDDEN_APP:-true}"
KAORIOS_ENABLE_INSTALLER_SOURCE="${KAORIOS_ENABLE_INSTALLER_SOURCE:-true}"

# Optional framework features already integrated on main.
KAORIOS_ENABLE_DEVSTATUS="${KAORIOS_ENABLE_DEVSTATUS:-true}"
KAORIOS_ENABLE_BUILD_SPOOF="${KAORIOS_ENABLE_BUILD_SPOOF:-true}"

# Install the runtime Toolbox app and its privapp permission XML.
KAORIOS_INSTALL_TOOLBOX="${KAORIOS_INSTALL_TOOLBOX:-true}"

# Validate a supplied keybox XML. Validation never embeds the private key.
KAORIOS_VALIDATE_KEYBOX="${KAORIOS_VALIDATE_KEYBOX:-true}"

# When dev-status is enabled but the ROM layout is unsupported:
# false = warn and continue, true = fail the build.
KAORIOS_DEVSTATUS_STRICT="${KAORIOS_DEVSTATUS_STRICT:-false}"

# Build log verbosity. false = concise success output; true = print full upstream patch diffs.
KAORIOS_VERBOSE_LOG="${KAORIOS_VERBOSE_LOG:-false}"
