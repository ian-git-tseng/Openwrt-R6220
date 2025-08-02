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
echo "===== 直接修改DTS文件 ====="
DTS_FILE="target/linux/ramips/dts/mt7621_netgear_r6220.dts"

# 备份原始文件
cp "$DTS_FILE" "$DTS_FILE.bak"

# 移除 read-only 属性
sed -i '/partition@4200000 {/,/};/s/read-only;//' "$DTS_FILE"

# 验证修改
if grep -q "read-only" "$DTS_FILE"; then
    echo "::error::DTS修改未生效!"
    diff -u "$DTS_FILE.bak" "$DTS_FILE" || true
    exit 1
else
    echo "✅ DTS修改已成功应用"
fi
