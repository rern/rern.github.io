#!/bin/bash

optbox=( --colors --no-shadow --no-collapse )

dialog "${optbox[@]}" --infobox "
                 Install \Z1Distcc\Z0 Client
" 9 58
sleep 1

pacman -Sy --noconfirm distcc

# build toolchains:
# curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/distccd-alarm.tar.gz | bsdtar xf -
# cd distccd-alarm
# makepkg
for arch in armv6h armv7h armv8; do
	wget https://github.com/rern/distcc-alarm/releases/download/20200823/distccd-alarm-$arch-11.2.0.20200823-3-x86_64.pkg.tar.zst
	pacman -U distccd-alarm-$arch
done
rm distccd-alarm-*
# for ssh start distccd from master
sed -i -e 's/#\(PermitRootLogin \).*/\1yes/' /etc/ssh/sshd_config
systemctl enable sshd
