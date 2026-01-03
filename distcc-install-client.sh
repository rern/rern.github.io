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
[[ ! -e /usr/bin/distccd-armv8 ]] && pkg8='https://aur.archlinux.org/packages/distccd-alarm-armv8'
[[ ! -e /usr/bin/distccd-armv7h ]] && pkg7='https://aur.archlinux.org/packages/distccd-alarm-armv7h'
[[ ! $pkg && ! $pkg7 ]] && exit

dialog "${optbox[@]}" --infobox "


          Please build and install toolchains:
     $pkg8
	 $pkg7
		  
" 9 58
