#!/bin/bash
#========================================================================================================================
# Description: Automatically Build ImmortalWrt for Amlogic ARMv8
# Function: Diy script (After Update feeds, Modify the default IP, hostname, theme, add/remove software packages, etc.)
# Source code repository: https://github.com/immortalwrt/immortalwrt.git / Branch: 21.02
#========================================================================================================================

# Set etc/openwrt_release
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCECODE='immortalwrt'" >>package/base-files/files/etc/openwrt_release

# Set ssid
sed -i "s/OpenWrt/LYNX/g" package/kernel/mac80211/files/lib/wifi/mac80211.sh

# Set default password
sed -i '18s/^/# /' package/emortal/default-settings/files/99-default-settings

# Set timezone
sed -i -e "s/CST-8/WIB-7/g" -e "s/Shanghai/Jakarta/g" package/emortal/default-settings/files/99-default-settings-chinese

# Set hostname
sed -i "s/ImmortalWrt/LYNX/g" package/base-files/files/bin/config_generate

# Set passwd
sed -i "s/root::0:0:99999:7:::/root:"'$'"1"'$'"pSFNodTy"'$'"ej92Jju6QPD9AIAuelgnr.:18993:0:99999:7:::/g" package/base-files/files/etc/shadow

# Set Interface
sed -i "9 i\uci set network.wan1=interface\nuci set network.wan1.proto='dhcp'\nuci set network.wan1.device='eth1'\nuci set network.wan2=interface\nuci set network.wan2.proto='dhcp'\nuci set network.wan2.device='wwan0'\nuci set network.wan3=interface\nuci set network.wan3.proto='dhcp'\nuci set network.wan3.device='usb0'\nuci commit network\n" package/emortal/default-settings/files/99-default-settings
sed -i "20 i\uci add_list firewall.@zone[1].network='wan1'\nuci add_list firewall.@zone[1].network='wan2'\nuci add_list firewall.@zone[1].network='wan3'\nuci commit firewall\n" package/emortal/default-settings/files/99-default-settings

# Add luci-theme-tano (Default)
svn co https://github.com/lynxnexy/luci-theme-tano/trunk package/luci-theme-tano
sed -i "s/+luci-theme-bootstrap //" feeds/luci/collections/luci/Makefile

# Set banner
rm -rf ./package/emortal/default-settings/files/openwrt_banner
svn export https://github.com/lynxnexy/immortalwrt/trunk/amlogic/common/rootfs/etc/banner package/emortal/default-settings/files/openwrt_banner

# Set shell zsh
sed -i "s/\/bin\/ash/\/usr\/bin\/zsh/g" package/base-files/files/etc/passwd

# Set php7 max_size
sed -i -e "s/upload_max_filesize = 2M/upload_max_filesize = 1024M/g" -e "s/post_max_size = 8M/post_max_size = 1024M/g" feeds/packages/lang/php7/files/php.ini

# Add luci-app-3ginfo
svn co https://github.com/lynxnexy/luci-app-3ginfo/trunk package/luci-app-3ginfo

# Add luci-app-atinout-mod
svn co https://github.com/lynxnexy/luci-app-atinout-mod/trunk package/luci-app-atinout-mod

# Add luci-app-amlogic
svn co https://github.com/lynxnexy/luci-app-amlogic/trunk package/luci-app-amlogic

# Add p7zip
svn co https://github.com/hubutui/p7zip-lede/trunk package/p7zip

# Add luci-app-tinyfilemanager
svn co https://github.com/lynxnexy/luci-app-tinyfilemanager/trunk package/luci-app-tinyfilemanager

# Add luci-app-adguardhome
# svn co https://github.com/rufengsuixing/luci-app-adguardhome/trunk package/luci-app-adguardhome

# Set adguardhome-core
# mkdir -p files/usr/bin/AdGuardHome
# AGH_CORE=$(curl -sL https://api.github.com/repos/AdguardTeam/AdGuardHome/releases | grep /AdGuardHome_linux_arm64 | awk -F '"' '{print $4}' | sed -n '1p')
# wget -qO- $AGH_CORE | tar xOvz > files/usr/bin/AdGuardHome/AdGuardHome
# chmod +x files/usr/bin/AdGuardHome/AdGuardHome

# Add luci-app-openclash
rm -rf feeds/luci/applications/luci-app-openclash
svn co https://github.com/vernesong/OpenClash/branches/dev/luci-app-openclash package/luci-app-openclash
pushd package/luci-app-openclash/tools/po2lmo
make && sudo make install
popd

# Set clash-core
mkdir -p files/etc/openclash/core
# VERNESONG_CORE=$(curl -sL https://api.github.com/repos/vernesong/OpenClash/releases/tags/Clash | grep /clash-linux-armv8 | awk -F '"' '{print $4}')
# VERNESONG_TUN=$(curl -sL https://api.github.com/repos/vernesong/OpenClash/releases/tags/TUN-Premium | grep /clash-linux-armv8 | awk -F '"' '{print $4}')
# VERNESONG_GAME=$(curl -sL https://api.github.com/repos/vernesong/OpenClash/releases/tags/TUN | grep /clash-linux-armv8 | awk -F '"' '{print $4}')
DREAMACRO_CORE=$(curl -sL https://api.github.com/repos/Dreamacro/clash/releases | grep /clash-linux-armv8 | awk -F '"' '{print $4}' | sed -n '1p')
DREAMACRO_TUN=$(curl -sL https://api.github.com/repos/Dreamacro/clash/releases/tags/premium | grep /clash-linux-armv8 | awk -F '"' '{print $4}')
META_CORE=$(curl -sL https://api.github.com/repos/MetaCubeX/Clash.Meta/releases | grep /Clash.Meta-linux-arm64-v | awk -F '"' '{print $4}' | sed -n '1p')
# wget -qO- $VERNESONG_CORE | tar xOvz > files/etc/openclash/core/clash_vernesong
# wget -qO- $VERNESONG_TUN | gunzip -c > files/etc/openclash/core/clash_tun_vernesong
# wget -qO- $VERNESONG_GAME | tar xOvz > files/etc/openclash/core/clash_game_vernesong
wget -qO- $DREAMACRO_CORE | gunzip -c > files/etc/openclash/core/clash
wget -qO- $DREAMACRO_TUN | gunzip -c > files/etc/openclash/core/clash_tun
wget -qO- $META_CORE | gunzip -c > files/etc/openclash/core/clash_meta
chmod +x files/etc/openclash/core/clash*

# Set v2ray-rules-dat
mkdir -p files/etc/openclash
curl -sL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -o files/etc/openclash/GeoSite.dat
curl -sL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -o files/etc/openclash/GeoIP.dat

# Set yt-dlp
mkdir -p files/bin
curl -sL https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o files/bin/yt-dlp
chmod +x files/bin/yt-dlp

# Set speedtest
mkdir -p files/bin
wget -qO- https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-aarch64.tgz | tar xOvz > files/bin/speedtest
chmod +x files/bin/speedtest

# Set oh-my-zsh
mkdir -p files/root
pushd files/root
git clone https://github.com/robbyrussell/oh-my-zsh ./.oh-my-zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ./.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ./.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ./.oh-my-zsh/custom/plugins/zsh-completions
cp $GITHUB_WORKSPACE/amlogic/common/patches/zsh/.zshrc .
cp $GITHUB_WORKSPACE/amlogic/common/patches/zsh/example.zsh ./.oh-my-zsh/custom/example.zsh
popd

# Set modemmanager to disable
mkdir -p feeds/luci/protocols/luci-proto-modemmanager/root/etc/uci-defaults
cat << EOF > feeds/luci/protocols/luci-proto-modemmanager/root/etc/uci-defaults/70-modemmanager
[ -f /etc/init.d/modemmanager ] && /etc/init.d/modemmanager disable
exit 0
EOF
