#!/bin/bash

list=(
1  Build
2 'Update repo'
3 'AUR setup'
4 'Create guide.tar.xz' )
5 'Create radioparadise.tar.xz' )
6 'Create regdomcodes.json'

file=$( dialog --colors --no-shadow --no-collapse --output-fd 1 --nocancel --menu "
Package:
" 8 0 0 "${list[@]}" )

case $file in
	1 ) file=pkgbuild;;
	2 ) file=repoupdate;;
	3 ) file=aursetup;;
	4 )	bsdtar cjvf guide.tar.xz -C /srv/http/assets/img/guide .; exit;;
	5 )	bsdtar cjvf radioparadise.tar.xz -C /srv/http/data/webradio .; exit;;
	6 ) file=wirelessregdom;;
esac
bash <( curl -L https://github.com/rern/rern.github.io/raw/main/$file.sh )
