#!/bin/bash

#........................
arch=$( dialogMenu Distcc "$\
aarch64
armv7h
armv6h" )
ar=( '' arcarmv8h64 armv7h armv6h )
arch=${ar[$arch]}
systemctl stop distccd-arm*
systemctl start distccd-$arch
status=$( systemctl status distccd-$arch | sed 's/active (running)/\\e[32m&\\e[0m/' )
clear -x
echo -e "$bar distccd-client $arch
$status"
