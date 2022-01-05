#!/bin/bash

optbox=( --colors --no-shadow --no-collapse )

dialog "${optbox[@]}" --infobox "


                 Install \Z1Distcc\Z0 Master
" 9 58
sleep 1

[[ ! $clientip ]] && clientip=$( dialog "${optbox[@]}" --output-fd 1 --inputbox "
Client IP:

" 0 0 192.168.1.9 )

pacman -Sy --noconfirm distcc

# MAKEFLAGS="-j12"                                --- 2x max threads per client
# BUILDENV=(distcc color !ccache check !sign)     --- unnegate !distcc
# DISTCC_HOSTS="192.168.1.9:3636/8 192.168.1.4/4" --- CLIENT_IP:PORT/JOBS (JOBS: 2x max threads per client)
# Single core CPU - Omit Master IP from DISTCC_HOSTS

jobs=12
if [[ -e /boot/kernel8.img ]]; then
  port=3636
  arch=armv8/aarch64
elif [[ -e /boot/kernel7.img ]]; then
  port=3635
  arch=armv7h
else
  port=3634
  arch=armv6h
  jobs=8
fi

sed -i -e 's/^#*\(MAKEFLAGS="-j\).*/\1'$jobs'"/
' -e 's/!distcc/distcc/
' -e "s|^#*\(DISTCC_HOSTS=\"\).*|\1$clientip:$port/$jobs\"|
" /etc/makepkg.conf

systemctl start distccd
status=$( systemctl status distccd | sed 's/active (running)/\\e[32m&\\e[0m/' )
clear -x
echo -e "\
\e[32mdistccd-master $arch\e[0m
$status"
