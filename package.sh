#!/bin/bash

. <( curl -sL https://github.com/rern/rOS/raw/main/common.sh )
#........................
dialogSplash 'Package Utilities'
list_menu="\
Build Package
Update Repo
AUR Setup
Create guide.tar.xz
Create radioparadise.tar.xz
Create regdomcodes.json"
i=0
#........................
menu=$( dialogMenu Package "$list_menu" )
#........................
dialogSplash "$( sed -n "$menu p" <<< $list_menu )"
case $menu in
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
. <( curl -sL https://github.com/rern/rern.github.io/raw/main/$file.sh )
