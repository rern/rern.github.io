#!/bin/bash

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

arch=$( dialog --colors --output-fd 1 --checklist '
\n\Z1Repository:\Z0' 9 30 0 \
	1 aarch64 on \
	2 armv7h on \
	3 armv6h off \
	4 \\Z1Rebuild\\Z0 off )
if [[ $arch == *4 ]]; then
	action=Rebuild
else
	action=Update
	new=-n # newer only (deleted packages still exist in db)
fi

for i in $arch; do
	case $i in
		1 ) arch=aarch64;;
		2 ) arch=armv7h;;
		3 ) arch=armv6h;;
		4 ) break;;
	esac
	
	echo -e "\n\n\e[44m  \e[0m $action repository $arch ...\n"
	cd $dirrepo/$arch
	[[ ! $new ]] && rm -f +R*
	repo-add $new -R +R.db.tar.xz *.pkg.tar.xz
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
	<tr><td><a href="'$arch'/'$pkg'">'$pkg'</a></td><td>'${sizedate[$i]}'</td></tr>'
	done
	html+='
<table>
</body>
</html>'

	echo -e "$html" > ../$arch.html
done
cd $PDW
if [[ -L repo ]]; then
	unlink repo
else
	umount -l repo
	rmdir $dirrepo
fi

echo -e "\n\e[44m  \e[0m Done."
