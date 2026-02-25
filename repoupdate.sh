#!/bin/bash

#........................
banner Update Repositories
dirrepo=$PWD/repo
mkdir -p $dirrepo
if [[ ! $( ls /boot/kernel* 2> /dev/null ) ]]; then # not RPi
	ln -s /home/x/BIG/RPi/Git/rern.github.io repo
else
#........................
	localip=$( dialog $opt_input '
 Local \Z1rern.github.io\Z0 IP:
' 0 0 192.168.1.9 )
	mnt=$( mount -t cifs //$localip/rern.github.io $dirrepo -o username=guest,password= )
	if [[ $? != 0 ]]; then
		error="Mount failed: mount -t cifs //$localip/rern.github.io repo -o username=guest,password=\n"
	elif [[ ! -e $dirrepo/aarch64 ]]; then
		error="Not found: //$localip/rern.github.io/aarch64\n"
	fi
	if [[ $error ]]; then
		umount -l repo &> /dev/null
		rmdir $dirrepo &> /dev/null
		errorExit $error
#----------------------------------------------------------------------------
	fi
fi

#........................
select=$( dialog $opt_check '
\n\Z1Repository:\Z0' 9 30 0 \
	aarch64 on \
	armv7h on \
	armv6h off \
	Rebuild off )
if selected Rebuild; then
	action=Rebuild
else
	action=Update
	new=-n # newer only (deleted packages still exist in db)
fi
#........................
banner $action repository ...
for arch in $select; do
	[[ $arch == Rebuild ]] && break
	
	echo -e "\n$bar $arch\n"
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
if [[ -L repo ]]; then
	unlink repo
else
	umount -l repo
	rmdir repo
fi
echo -e "
$bar Done
"
