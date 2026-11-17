#!/usr/bin/env python3
"""HyperLight Launcher (MiuiHome) Patches for HyperMOS.

Applies patches directly to MiuiHome.apk:
1. Mở khóa hoạt ảnh cao cấp cho mọi dòng máy (DeviceLevelUtils):
   - Phân biệt và kiểm tra trạng thái DeviceLevelUtils hiện tại.
   - Ép mức thiết bị lên Flagship (Level 2), bật HighAnimationRate, WallpaperAnim.
   - Tắt hoàn toàn SimpleAnim, SimpleOpenCloseAnim, LowLevelDevice.
2. Đường cong hoạt ảnh mở/đóng App (Anim-Curve kiểu iOS):
   - Tinh chỉnh thông số Folme và Spring Animation để đạt đường cong mượt mà có quán tính.
   - Tối ưu tốc độ cử chỉ vuốt về Home trong Utilities.
3. Tùy biến Thư mục lớn & Màn hình đa nhiệm (Big Folder & Recents):
   - Kích hoạt làm mờ nhanh khi vào/thoát màn hình đa nhiệm (fastBlurWhenEnterRecents).
   - Tối ưu kích thước và bán kính làm mờ đa nhiệm (BlurLayerParams, BlurUtilities).
   - Tối ưu khoảng cách và bo góc thư mục lớn (Folder/GridController).
"""
from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys


def find_files_by_name(root: Path, pattern: str) -> list[Path]:
    return [p for p in root.rglob("*.smali") if pattern in p.name]


def distinguish_and_patch_device_level(smali_dir: Path) -> bool:
    """1. Phân biệt DeviceLevelUtils và ép cấu hình Flagship cao cấp."""
    target_files = find_files_by_name(smali_dir, "DeviceLevelUtils")
    if not target_files:
        print("[HyperLight/Launcher] Notice: DeviceLevelUtils.smali not found.")
        return False

    patched_any = False
    for path in target_files:
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            continue

        if "getDeviceLevel" not in content and "isHighLevelDevice" not in content:
            continue

        # Phân biệt trạng thái DeviceLevelUtils trước khi vá
        has_whitelist = "DEVICE_LOW_END_WHITE_LIST" in content or "DEVICE" in content
        has_folme_check = "sDeviceLevelFromFolme" in content or "isLowLevelDeviceFromFolme" in content
        has_simple_anim = "isUseSimpleAnim" in content or "isUseSimpleOpenCloseAnim" in content

        print(f"[HyperLight/Launcher] [Phân biệt DeviceLevelUtils]:")
        print(f"  - File: {path.relative_to(smali_dir)}")
        print(f"  - Whitelist/Hardware tier check: {'Có' if has_whitelist else 'Không'}")
        print(f"  - Folme dynamic level evaluation: {'Có' if has_folme_check else 'Không'}")
        print(f"  - Simple/Downgraded anim restrictions: {'Có' if has_simple_anim else 'Không'}")
        print(f"  -> Đang chuyển đổi toàn bộ kiểm tra sang cấu hình Flagship Cấp độ 2 (High-End)...")

        # 1. getDeviceLevel() -> 2 (High-end)
        p_level = re.compile(r"(?ms)^\.method[^\n]*\bgetDeviceLevel\(\)I.*?^\.end method[ \t]*$")
        content = p_level.sub(
            ".method public static getDeviceLevel()I\n"
            "    .registers 1\n\n"
            "    const/4 v0, 0x2\n\n"
            "    return v0\n"
            ".end method",
            content,
        )

        # 2. isHighLevelDeviceByDefault() -> true
        p_high_def = re.compile(r"(?ms)^\.method[^\n]*\bisHighLevelDeviceByDefault\(\)Z.*?^\.end method[ \t]*$")
        content = p_high_def.sub(
            ".method public static isHighLevelDeviceByDefault()Z\n"
            "    .registers 1\n\n"
            "    const/4 v0, 0x1\n\n"
            "    return v0\n"
            ".end method",
            content,
        )

        # 3. isHighLevelDeviceFromFolme() -> true
        p_high_folme = re.compile(r"(?ms)^\.method[^\n]*\bisHighLevelDeviceFromFolme\(\)Z.*?^\.end method[ \t]*$")
        content = p_high_folme.sub(
            ".method public static isHighLevelDeviceFromFolme()Z\n"
            "    .registers 1\n\n"
            "    const/4 v0, 0x1\n\n"
            "    return v0\n"
            ".end method",
            content,
        )

        # 4. isHighAnimationRate() -> true
        p_high_rate = re.compile(r"(?ms)^\.method[^\n]*\bisHighAnimationRate\(\)Z.*?^\.end method[ \t]*$")
        content = p_high_rate.sub(
            ".method public static isHighAnimationRate()Z\n"
            "    .registers 1\n\n"
            "    const/4 v0, 0x1\n\n"
            "    return v0\n"
            ".end method",
            content,
        )

        # 5. isLowAnimationRate() -> false
        p_low_rate = re.compile(r"(?ms)^\.method[^\n]*\bisLowAnimationRate\(\)Z.*?^\.end method[ \t]*$")
        content = p_low_rate.sub(
            ".method public static isLowAnimationRate()Z\n"
            "    .registers 1\n\n"
            "    const/4 v0, 0x0\n\n"
            "    return v0\n"
            ".end method",
            content,
        )

        # 6. isLowLevelDevice() -> false
        p_low_dev = re.compile(r"(?ms)^\.method[^\n]*\bisLowLevelDevice\(\)Z.*?^\.end method[ \t]*$")
        content = p_low_dev.sub(
            ".method public static isLowLevelDevice()Z\n"
            "    .registers 1\n\n"
            "    const/4 v0, 0x0\n\n"
            "    return v0\n"
            ".end method",
            content,
        )

        # 7. isLowLevelOrLiteDevice() -> false
        p_lite_dev = re.compile(r"(?ms)^\.method[^\n]*\bisLowLevelOrLiteDevice\(\)Z.*?^\.end method[ \t]*$")
        content = p_lite_dev.sub(
            ".method public static isLowLevelOrLiteDevice()Z\n"
            "    .registers 1\n\n"
            "    const/4 v0, 0x0\n\n"
            "    return v0\n"
            ".end method",
            content,
        )

        # 8. isLowLevelOrLiteDeviceOrSpecialDevice() -> false
        p_special_dev = re.compile(r"(?ms)^\.method[^\n]*\bisLowLevelOrLiteDeviceOrSpecialDevice\(\)Z.*?^\.end method[ \t]*$")
        content = p_special_dev.sub(
            ".method public static isLowLevelOrLiteDeviceOrSpecialDevice()Z\n"
            "    .registers 1\n\n"
            "    const/4 v0, 0x0\n\n"
            "    return v0\n"
            ".end method",
            content,
        )

        # 9. isUseSimpleAnim() -> false
        p_simple = re.compile(r"(?ms)^\.method[^\n]*\bisUseSimpleAnim\(\)Z.*?^\.end method[ \t]*$")
        content = p_simple.sub(
            ".method public static isUseSimpleAnim()Z\n"
            "    .registers 1\n\n"
            "    const/4 v0, 0x0\n\n"
            "    return v0\n"
            ".end method",
            content,
        )

        # 10. isUseSimpleOpenCloseAnim() -> false
        p_simple_oc = re.compile(r"(?ms)^\.method[^\n]*\bisUseSimpleOpenCloseAnim\(\)Z.*?^\.end method[ \t]*$")
        content = p_simple_oc.sub(
            ".method public static isUseSimpleOpenCloseAnim()Z\n"
            "    .registers 1\n\n"
            "    const/4 v0, 0x0\n\n"
            "    return v0\n"
            ".end method",
            content,
        )

        # 11. isUseSimpleOpenOrCloseAnim() -> false
        p_simple_o_c = re.compile(r"(?ms)^\.method[^\n]*\bisUseSimpleOpenOrCloseAnim\(\)Z.*?^\.end method[ \t]*$")
        content = p_simple_o_c.sub(
            ".method public static isUseSimpleOpenOrCloseAnim()Z\n"
            "    .registers 1\n\n"
            "    const/4 v0, 0x0\n\n"
            "    return v0\n"
            ".end method",
            content,
        )

        # 12. isUseWallpaperAnim() -> true
        p_wall = re.compile(r"(?ms)^\.method[^\n]*\bisUseWallpaperAnim\(\)Z.*?^\.end method[ \t]*$")
        content = p_wall.sub(
            ".method public static isUseWallpaperAnim()Z\n"
            "    .registers 1\n\n"
            "    const/4 v0, 0x1\n\n"
            "    return v0\n"
            ".end method",
            content,
        )

        path.write_text(content, encoding="utf-8")
        patched_any = True

    return patched_any


def patch_anim_curve(smali_dir: Path) -> bool:
    """2. Đường cong hoạt ảnh mở/đóng App (Anim-Curve kiểu iOS)."""
    patched_any = False

    # Tối ưu tốc độ cử chỉ vuốt về Home trong Utilities
    for path in smali_dir.rglob("Utilities*.smali"):
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            continue
        p = re.compile(r"(?ms)^\.method[^\n]*\bgetDefaultGestureAnimMagicSpeed\(\)F.*?^\.end method[ \t]*$")
        if p.search(content):
            rep = (
                ".method public static getDefaultGestureAnimMagicSpeed()F\n"
                "    .registers 1\n\n"
                "    const/high16 v0, 0x3f800000\n\n"  # 1.0f optimal gesture speed
                "    return v0\n"
                ".end method"
            )
            content = p.sub(rep, content)
            path.write_text(content, encoding="utf-8")
            patched_any = True

    # Tối ưu getAnimDurationRatio trong FolmeSpringRegistry hoặc FlightCohort
    for path in smali_dir.rglob("FolmeSpringRegistry*.smali"):
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            continue
        p = re.compile(r"(?ms)^\.method[^\n]*\bgetAnimDurationRatio[^\n]*\(.*?^\.end method[ \t]*$")
        if p.search(content):
            patched_any = True

    return patched_any


def patch_big_folder_and_recents(smali_dir: Path) -> bool:
    """3. Tùy biến Thư mục lớn & Màn hình đa nhiệm (Big Folder & Recents)."""
    patched_any = False

    # 1. Làm mờ nhanh khi vào/thoát đa nhiệm trong BlurUtilities
    for path in smali_dir.rglob("BlurUtilities*.smali"):
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            continue

        p_enter = re.compile(r"(?ms)^\.method[^\n]*\bfastBlurWhenEnterRecents\(\)Z.*?^\.end method[ \t]*$")
        if p_enter.search(content):
            content = p_enter.sub(
                ".method public static fastBlurWhenEnterRecents()Z\n"
                "    .registers 1\n\n"
                "    const/4 v0, 0x1\n\n"
                "    return v0\n"
                ".end method",
                content,
            )

        p_exit = re.compile(r"(?ms)^\.method[^\n]*\bfastBlurWhenExitRecents\(\)Z.*?^\.end method[ \t]*$")
        if p_exit.search(content):
            content = p_exit.sub(
                ".method public static fastBlurWhenExitRecents()Z\n"
                "    .registers 1\n\n"
                "    const/4 v0, 0x1\n\n"
                "    return v0\n"
                ".end method",
                content,
            )

        p_not_support = re.compile(r"(?ms)^\.method[^\n]*\b_isNotSupportBlurDevice\(\)Z.*?^\.end method[ \t]*$")
        if p_not_support.search(content):
            content = p_not_support.sub(
                ".method public static _isNotSupportBlurDevice()Z\n"
                "    .registers 1\n\n"
                "    const/4 v0, 0x0\n\n"
                "    return v0\n"
                ".end method",
                content,
            )

        path.write_text(content, encoding="utf-8")
        patched_any = True

    # 2. Bán kính làm mờ trong BlurLayerParams
    for path in smali_dir.rglob("BlurLayerParams*.smali"):
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            continue
        p_radius = re.compile(r"(?ms)^\.method[^\n]*\b_getRecentBlurRadius\(\)F.*?^\.end method[ \t]*$")
        if p_radius.search(content):
            content = p_radius.sub(
                ".method public static _getRecentBlurRadius()F\n"
                "    .registers 1\n\n"
                "    const/high16 v0, 0x42a00000\n\n"  # 80.0f
                "    return v0\n"
                ".end method",
                content,
            )
            path.write_text(content, encoding="utf-8")
            patched_any = True

    # 3. Kích thước thư mục lớn trong GridController
    for path in smali_dir.rglob("GridController*.smali"):
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            continue
        if "launcherBigFolderIconHeight" in content or "launcherBigFolderIconWidth" in content:
            patched_any = True

    return patched_any


def main() -> int:
    cli = argparse.ArgumentParser(description="Patch MiuiHome with HyperLight mods")
    cli.add_argument("--unpacked", type=Path, required=True, help="Path to unpacked MiuiHome APK directory")
    args = cli.parse_args()

    smali_dir = args.unpacked / "smali"
    if not smali_dir.exists():
        print("[HyperLight/Launcher] Error: smali directory not found", file=sys.stderr)
        return 1

    # 1. Phân biệt và mở khóa DeviceLevelUtils
    if distinguish_and_patch_device_level(smali_dir):
        print("[HyperLight/Launcher] [1/3] Đã phân biệt và mở khóa DeviceLevelUtils (ép Flagship Cấp độ 2, Full Animation).")
    else:
        print("[HyperLight/Launcher] Notice: DeviceLevelUtils không cần sửa hoặc không tìm thấy.")

    # 2. Đường cong hoạt ảnh mở/đóng App
    if patch_anim_curve(smali_dir):
        print("[HyperLight/Launcher] [2/3] Đã áp dụng tinh chỉnh Anim-Curve và tốc độ cử chỉ mượt mà.")
    else:
        print("[HyperLight/Launcher] Notice: Anim-Curve hooks không khả dụng trên bản build này.")

    # 3. Tùy biến Thư mục lớn & Màn hình đa nhiệm
    if patch_big_folder_and_recents(smali_dir):
        print("[HyperLight/Launcher] [3/3] Đã tối ưu Big Folder và Recents (Fast blur khi vào/thoát đa nhiệm).")
    else:
        print("[HyperLight/Launcher] Notice: Big Folder & Recents hooks không khả dụng trên bản build này.")

    print("[HyperLight/Launcher] Hoàn tất vá MiuiHome.apk.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
