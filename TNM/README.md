# TNM

Android control app prototype for HyperOS.

- Package: `com.android.trinhngocminh`
- Label: `TNM`
- UI: `compose-miuix-ui/miuix` 0.9.4
- Theme: system Light/Dark
- One-page interface
- Font: choose a local TTF/OTF, with backup/restore of the previous theme-font directory
- Thermal: runtime switch between Stock Xiaomi and TNM Eco (root required)
- System information: device, SoC/CPU, RAM/storage, Android/HyperOS, battery/SoC/GPU temperature, root and thermal sconfig

The Eco profile is derived from the Xiaomi 15 Pro stock thermal profile supplied during development. Camera, charging and critical thermal profiles are not replaced by TNM.

## Build

The `Build TNM APK` GitHub Actions workflow builds a debug APK with JDK 21, Gradle 9.7.1 and Android SDK 36.
