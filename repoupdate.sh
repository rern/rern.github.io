#!/bin/bash

rm $0

updateRepo() {
	# recreate database
	cd $dirgit/rern.github.io/$1
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

clear

dirgit=/home/x/BIG/RPi/Git  # on PC
if [[ ! -d $dirgit ]]; then # on RPi
	localip=$( dialog --colors --output-fd 1 --cancel-label Skip --inputbox "
 Local \Z1rern.github.io\Z0 IP:
" 0 0 '192.168.1.9' )
	dirgit=$PWD/Git
	if [[ ! -e $dirgit/aarch64 ]]; then
		mkdir -p $dirgit
		mount -t cifs //$localip/rern.github.io $dirgit
		if [[ ! -e $dirgit/aarch64 ]]; then
			umount -l $dirgit
			rmdir $dirgit
			echo "$dirgit/aarch64 not found."
			exit
		fi
	fi
fi
dircurrent=$PWD
arch=$( dialog --colors --output-fd 1 --checklist '\n\Z1Arch:\Z0' 9 30 0 \
	1 aarch64 on \
	2 armv7h on \
	3 armv6h on )
for i in $arch; do
	case $i in
		1 ) updateRepo aarch64;;
		2 ) updateRepo armv7h;;
		3 ) updateRepo armv6h;;
	esac
done
cd $dircurrent
if [[ $localip ]]; then
	umount -l $dirgit 
	rmdir $dirgit
fi

dialog --colors --infobox "\n \Z1+R\Z0 repo updated succesfully." 5 40
