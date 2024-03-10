#!/bin/bash

url=http://sg.mirror.archlinuxarm.org/armv7h
listalarm=$( curl -L $url/alarm )
listcore=$( curl -L $url/core )
packages='firmware-raspberrypi linux-firmware linux-firmware-whence raspberrypi-bootloader'
for pkg in $packages; do
	rm -f *.xz
	if [[ ${pkg:0:1} == l ]]; then
		href=$url/core/$( grep -m1 $pkg <<< $listcore | cut -d'"' -f2 )
	else
		href=$url/alarm/$( grep -m1 $pkg <<< $listalarm | cut -d'"' -f2 )
	fi
	wget $href
done
pacman -U --needed *.xz
