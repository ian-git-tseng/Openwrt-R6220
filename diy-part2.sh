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

# 移动补丁到正确位置
if [ -f "../patches/target/linux/ramips/dts/999-r6220-reserved-partition.patch" ]; then
    mv "../patches/target/linux/ramips/dts/999-r6220-reserved-partition.patch" "$PATCH_DIR/"
    echo "✅ 补丁已移动到正确位置: $PATCH_DIR/"
else
    echo "::error::找不到补丁文件!"
    exit 1
fi

# 验证补丁应用
echo "=== 检查补丁是否应用 ==="
if grep -q "read-only" target/linux/ramips/dts/mt7621_netgear_r6220.dts; then
    echo "::error::DTS 修改未生效!"
    exit 1
else
    echo "✅ DTS 修改已成功应用"
fi
