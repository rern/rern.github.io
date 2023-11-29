#!/bin/bash

dircurrent=$PWD

updateRepo() {
	echo -e "\n\n\e[44m  \e[0m Update repository $1 ...\n"
	cd $dirrepo/$1
	repo-add -n -R +R.db.tar.xz *.pkg.tar.xz
	rm -f *.xz.old
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

dirrepo=$PWD/repo
mkdir -p $dirrepo
if [[ ! $( ls /boot/kernel* 2> /dev/null ) ]]; then # not RPi
	ln -s /home/x/BIG/RPi/Git/rern.github.io repo
else
	localip=$( dialog --colors --output-fd 1 --cancel-label Skip --inputbox "
 Local \Z1rern.github.io\Z0 IP:
" 0 0 '192.168.1.9' )
	mount -t cifs //$localip/rern.github.io $dirrepo -o username=guest,password=
	if [[ $? != 0 ]]; then
		error="
\e[41m  \e[0m Mount failed: mount -t cifs //$localip/rern.github.io repo -o username=guest,password=
"
	elif [[ ! -e $dirrepo/aarch64 ]]; then
		error="
\e[41m  \e[0m Not found: //$localip/rern.github.io/aarch64
"
	fi
	if [[ $error ]]; then
		umount -l repo &> /dev/null
		rmdir $dirrepo &> /dev/null
		echo -e "$error"
		exit
	fi
fi

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
cd "$dircurrent"
if [[ -L repo ]]; then
	rm -r repo
else
	umount -l repo &> /dev/null
	rmdir $dirrepo &> /dev/null
fi

echo -e "\n\e[44m  \e[0m Done."
