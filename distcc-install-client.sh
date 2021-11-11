#!/bin/bash

optbox=( --colors --no-shadow --no-collapse )

dialog "${optbox[@]}" --infobox "
                 Install \Z1Distcc\Z0 Client
" 9 58
sleep 1

pacman -Sy --noconfirm distcc
clientip=$( dialog "${optbox[@]}" --output-fd 1 --inputbox "
Client IP:
" 0 0 192.168.1.9 )

# build toolchains:
# curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/distccd-alarm.tar.gz | bsdtar xf -
# cd distccd-alarm
# makepkg
for arch in armv6h armv7h armv8; do
	wget https://github.com/rern/distcc-alarm/releases/download/20200823/distccd-alarm-$arch-10.2.0.20200823-3-x86_64.pkg.tar.zst
	pacman -U distccd-alarm-$arch
done
rm distccd-alarm-*
systemctl enable sshd
