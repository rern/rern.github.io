#!/bin/bash

. <( curl -sL https://github.com/rern/rOS/raw/main/common.sh )
#........................
dialogSplash 'Package Utilities'
list_package="\
Build Package
Update Repo
AUR Setup
Create \Z1guide.tar.xz\Zn
Create \Z1radioparadise.tar.xz\Zn
Create \Z1regdomcodes.json\Zn"
i=0
while read l; do
	(( i++ ))
	list_menu+=( $i "$l" )
done <<< $list_package
#........................
menu=$( dialog $opt_menu "
Package:
" $(( i + 2 )) 0 0 "${list_menu[@]}" )
#........................
dialogSplash "$( sed -n "$menu p" <<< $list_package )"
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
clear -x
. <( curl -sL https://github.com/rern/rern.github.io/raw/main/$file.sh )
