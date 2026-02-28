#!/bin/bash

#........................
arch=$( dialog $opt_menu "
 \Z1Distcc\Z0:
" 8 0 0 \
	1 armv8 \
	2 armv7h \
	3 armv6h )
arch=${arch/aarch64/armv8}
systemctl stop distccd-arm*
systemctl start distccd-$arch
status=$( systemctl status distccd-$arch | sed 's/active (running)/\\e[32m&\\e[0m/' )
clear -x
echo -e "$bar distccd-client $arch
$status"
