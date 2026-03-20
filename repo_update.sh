#!/bin/bash

bar Mount REPO ...
mkdir -p BIG REPO
if [[ $( uname -m ) == x86_64 ]]; then
	dev_big=$( lsblk -pro name,label | awk '/BIG/ {print $1}' )
	mount $dev_big BIG
	mount --bind BIG/RPi/Git/rern.github.io REPO
else
	mount -t cifs //192.168.1.9/rern.github.io REPO -o username=guest,password=
fi
[[ $? != 0 ]] && dialog.error_exit Mount '\Z1REPO\Zn' failed.
#----------------------------------------------------------------------------
[[ ! $( ls REPO ) ]] && dialog.error_exit Repo empty: REPO
#----------------------------------------------------------------------------
#........................
selected=$( dialog $opt_check '
\Z1Repository:\Z0
' 8 30 0 \
	aarch64 on \
	armv7h on \
	armv6h off \
	Rebuild off )
#........................
if [[ $selected == Rebuild ]]; then
	action=Rebuild
else
	action=Update
	new=-n # newer only (deleted packages still exist in db)
fi
banner $action Repository
dir_base=$PWD
for arch in $selected; do
	[[ $arch == Rebuild ]] && continue
	
	bar $arch
	cd REPO/$arch
	[[ ! $new ]] && rm -f +R*
	repo-add $new -R +R.db.tar.xz *.pkg.tar.xz
	rm -f *.xz.old
	# index.html
	html='
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title>+R rAudio Packages</title>
	<style>
		table { font-family: monospace; white-space: pre; border: none }
		td:last-child { padding-left: 10px; text-align: right }
	</style>
</head>
<body>
<table>
	<tr><td><a href="/">../</a></td><td></td></tr>
'
	html+=$( ls -lh --time-style='+%y/%m/%d %H:%M:%S' *.pkg.tar.xz \
				| awk '{print "<tr><td><a href=\"'$arch'/"$8"\">"$8"</a></td><td>"$5" "$6" "$7"</td></tr>"}' )
	html+='
<table>
</body>
</html>'
	echo -e "$html" > ../$arch.html
done
cd $dir_base
umount -ql BIG REPO
rmdir BIG REPO
bar Done
