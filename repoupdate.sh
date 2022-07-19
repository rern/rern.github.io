#!/bin/bash

rm $0

currentdir=$PWD

updateRepo() {
	# recreate database
	cd $currentdir/Git/$1
	rm -f +R*
	repo-add -R +R.db.tar.xz *.pkg.tar.xz
	
	# index.html
	html='<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title>+R Packages</title>
	<style>
		table { font-family: monospace; white-space: pre; border: none }
		td:last-child { padding-left: 10px; text-align: right }
	</style>
</head>
<body>
<table>
	<tr><td><a href="/">../</a></td><td></td></tr>'
	pkg=( $( ls *.pkg.tar.xz ) )
	readarray -t sizedate <<<$( ls -lh --time-style='+%Y%m%d %H:%M' *.pkg.tar.xz | tr -s ' ' | cut -d' ' -f5-7 )
	pkgL=${#pkg[@]}
	for (( i=1; i < $pkgL; i++ )); do
		pkg=${pkg[$i]}
		html+='
	<tr><td><a href="'$1'/'$pkg'">'$pkg'</a></td><td>'${sizedate[$i]}'</td></tr>'
	done
	html+='
<table>
</body>
</html>'

	echo -e "$html" > ../$1.html
}

arch=$( dialog --colors --output-fd 1 --checklist '\n\Z1Arch:\Z0' 9 30 0 \
	1 aarch64 on \
	2 armv7h on \
	3 armv6h on )
arch=" $arch "
[[ $arch == *' 1 '* ]] && aarch64=1
[[ $arch == *' 2 '* ]] && armv7h=1
[[ $arch == *' 3 '* ]] && armv6h=1
if [[ ! $aarch64 && ! $armv7h && ! $armv6h ]]; then
	dialog --colors --infobox '\n No \Z1Arch\Z0 selected.' 5 40
	exit
fi

localip=$( dialog --colors --output-fd 1 --cancel-label Skip --inputbox "
 Local \Z1rern.github.io\Z0 IP:
" 0 0 '192.168.1.9' )

clear

if [[ ! -e $currentdir/Git/aarch64 ]]; then
	mkdir -p $currentdir/Git
	mount -t cifs //$localip/rern.github.io $currentdir/Git
fi

[[ $aarch64 ]] && updateRepo aarch64
[[ $armv7h ]] && updateRepo armv7h
[[ $armv6h ]] && updateRepo armv6h

umount -l $currentdir/Git
rmdir $currentdir/Git

cd "$currentdir"

dialog --colors --infobox "\n \Z1+R\Z0 repo updated succesfully." 5 40
