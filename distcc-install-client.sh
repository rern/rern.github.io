#!/bin/bash

optbox=( --colors --no-shadow --no-collapse )

dialog "${optbox[@]}" --infobox "


                 Install \Z1Distcc\Z0 Client
" 9 58
sleep 1

pacman -Sy --noconfirm distcc

# for ssh start distccd from master
sed -i -e 's/#\(PermitRootLogin \).*/\1yes/' /etc/ssh/sshd_config
systemctl enable sshd
[[ ! -e /usr/bin/distccd-armv8 ]] && pkg=distccd-armv8
[[ ! -e /usr/bin/distccd-armv6h ]] && pkg+=' distccd-armv6h'
[[ ! $pkg ]] && exit

dialog "${optbox[@]}" --infobox "


          Please build and install toolchains
		  $pkg
		  
" 9 58
