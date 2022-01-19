#!/bin/bash

optbox=( --colors --no-shadow --no-collapse )

dialog "${optbox[@]}" --infobox "


                     \Z1Distcc Client\Z0
" 9 58
sleep 1

arch=$( dialog "${optbox[@]}" --output-fd 1 --menu "
 \Z1Distcc\Z0:
" 8 0 0 \
1 aarch64 \
2 armv7h \
3 armv6h )

case $arch in
	1 ) arch=armv8;;
	2 ) arch=armv7h;;
	3 ) arch=armv6h;;
esac

systemctl stop distccd-arm*
systemctl start distccd-$arch
status=$( systemctl status distccd-$arch | sed 's/active (running)/\\e[32m&\\e[0m/' )
clear -x
echo -e "\
\e[32mdistccd-client $arch\e[0m
$status"
