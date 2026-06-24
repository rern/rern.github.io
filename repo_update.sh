#!/bin/bash

if [[ $( uname -m ) == x86_64 ]]; then
	manjaro=1
else
	bar Mount REPO ...
	mkdir -p BIG REPO
	mount -t cifs //192.168.1.9/rern.github.io REPO -o username=guest,password=
	[[ $? != 0 ]] && dialog.error_exit Mount '\Z1REPO\Zn' failed.
#----------------------------------------------------------------------------
	[[ ! $( ls REPO ) ]] && dialog.error_exit Repo empty: REPO
#----------------------------------------------------------------------------
fi
#........................
selected=$( dialog $opt_check '
\Z1Repository:\Z0
' 8 30 0 \
	aarch64 on \
	armv7h  on \
	armv6h  off \
	''      off \
	Rebuild off )
#........................
if grep -q Rebuild <<< $selected; then
	action=Rebuild
	selected=$( grep -v Rebuild <<< $selected )
else
	action=Update
	new=-n # newer only (deleted packages still exist in db)
fi
#........................
banner $action Repository
for arch in $selected; do
	if [[ $manjaro ]]; then
		cd /home/x/GitHub/rern.github.io/$arch
	else
		dir_base=$PWD
		cd $dir_base/REPO/$arch
	fi
	bar $arch
	[[ ! $new ]] && rm -f +R*
	repo-add $new -R +R.db.tar.xz *.pkg.tar.xz *.pkg.tar.zst
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
	html+=$( ls -lh --time-style='+%y/%m/%d %H:%M:%S' *.pkg.tar.{xz,zst} \
				| awk '{print "<tr><td><a href=\"'$arch'/"$8"\">"$8"</a></td><td>"$5" "$6" "$7"</td></tr>"}' )
	html+='
<table>
</body>
</html>'
	echo -e "$html" > ../$arch.html
done

if [[ ! $manjaro ]]; then
	cd $dir_base
	umount -ql BIG REPO
	rmdir BIG REPO
fi

bar Done
