#!/bin/bash

fileconf=/etc/pacman-tmp.conf
if [[ ! -e $fileconf ]]; then
	repo='
[alarm]
SigLevel = PackageRequired
Server = https://sg.mirror.archlinuxarm.org/armv7h/$repo
'
	repo+=${repo/alarm/core}
	echo "$repo" > $fileconf
fi
pacman -Syy --needed --noconfirm --config $fileconf firmware-raspberrypi linux-firmware linux-firmware-whence raspberrypi-bootloader
rm $fileconf
