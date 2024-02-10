#!/bin/bash

list=(
1  Build
2 'Update repo'
3 'AUR setup'
4 'Create regdomcodes.json'
5 'Create guide.tar.xz' )
[[ -e /boot/kernel.img ]] && list+=( 6 'Update firmware' )

file=$( dialog --colors --no-shadow --no-collapse --output-fd 1 --nocancel --menu "
Package:
" 8 0 0 "${list[@]}" )

case $file in
	1 ) file=pkgbuild;;
	2 ) file=repoupdate;;
	3 ) file=aursetup;;
	4 ) file=wirelessregdom;;
	5 )	bsdtar cjvf guide.tar.xz -C /srv/http/assets/img/guide .; exit;;
 	6 ) sed -i '1 i\Server = http://mirror.archlinuxarm.org/armv7h/$repo' /etc/pacman.d/mirrorlist
		pacman -Syy --noconfirm --needed firmware-raspberrypi linux-firmware linux-firmware-whence raspberrypi-bootloader
		sed -i '/armv7h/ d' /etc/pacman.d/mirrorlist
		pacman -Syy
  		exit
		;;
esac
bash <( curl -L https://github.com/rern/rern.github.io/raw/main/$file.sh )
