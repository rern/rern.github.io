#!/bin/bash

. <( curl -sL https://github.com/rern/rOS/raw/refs/heads/main/common.sh )

#........................
splash 'Package Utilities'
#........................
file=$( dialog $opt_menu "
Package:
" 8 0 0 \
	1  Build \
	2 'Update repo' \
	3 'AUR setup' \
	4 'Create guide.tar.xz' \
	5 'Create radioparadise.tar.xz' \
	6 'Create regdomcodes.json' )

case $file in
	1 ) 
		arch=$( pacman -Qi bash | awk '/^Arch/ {print $NF}' )
		[[ ! $arch =~ .*(aarch|armv).* ]] && errorExit This is not a Raspberry Pi
		#----------------------------------------------------------------------------
		file=pkgbuild
		;;
	2 ) file=repoupdate;;
	3 ) file=aursetup;;
	4 )	bsdtar cjvf guide.tar.xz -C /srv/http/assets/img/guide .; exit;;
	5 )	bsdtar cjvf radioparadise.tar.xz -C /srv/http/data/webradio .; exit;;
	6 ) file=wirelessregdom;;
esac
clear -x
bash <( curl -L https://github.com/rern/rern.github.io/raw/main/$file.sh )
