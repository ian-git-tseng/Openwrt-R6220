#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate
# 获取实际内核版本
KERNEL_VER=$(grep 'KERNEL_PATCHVER' target/linux/ramips/Makefile | cut -d= -f2 | tr -d ' ')
echo "检测到内核版本: $KERNEL_VER"

# 创建正确的补丁目录
PATCH_DIR="target/linux/ramips/patches-$KERNEL_VER"
mkdir -p $PATCH_DIR

# 正确获取补丁文件路径
SOURCE_PATCH_FILE="${GITHUB_WORKSPACE}/patches/target/linux/ramips/dts/999-r6220-reserved-partition.patch"

# 调试输出
echo "当前工作目录: $(pwd)"
echo "GITHUB_WORKSPACE: $GITHUB_WORKSPACE"
echo "查找补丁文件: $SOURCE_PATCH_FILE"

# 检查补丁文件是否存在
if [ -f "$SOURCE_PATCH_FILE" ]; then
    # 复制补丁到正确位置
    cp "$SOURCE_PATCH_FILE" "$PATCH_DIR/"
    echo "✅ 补丁已复制到正确位置: $PATCH_DIR/999-r6220-reserved-partition.patch"
    
    # 手动应用补丁（确保立即生效）
    echo "手动应用补丁确保生效..."
    patch -p1 -d target/linux/ramips/dts/ < "$SOURCE_PATCH_FILE"
    if [ $? -ne 0 ]; then
        echo "::error::手动应用补丁失败!"
        exit 1
    fi
    echo "✅ 补丁已成功应用"
else
    # 列出可能的路径帮助调试
    echo "::error::找不到补丁文件!"
    echo "检查以下位置:"
    find "${GITHUB_WORKSPACE}/patches" -name "*.patch" 2>/dev/null || echo "未找到任何补丁文件"
    exit 1
fi

# 验证修改是否生效
echo "=== 检查DTS文件修改 ==="
DTS_FILE="target/linux/ramips/dts/mt7621_netgear_r6220.dts"
if grep -q "read-only" "$DTS_FILE"; then
    echo "::error::DTS修改未生效!"
    echo "文件内容:"
    cat "$DTS_FILE" | grep -A 5 -B 5 "reserved"
    exit 1
else
    echo "✅ DTS修改已成功应用"
fi
