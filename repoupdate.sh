#!/bin/bash

unMount() {
	if [[ -L repo ]]; then
		unlink repo
	else
		umount -l $dir_repo
		rmdir repo
	fi
}
BIG=$( awk '/BIG/ {print $2}' /etc/fstab )
if [[ $BIG ]]; then # on manjaro
	dir_repo=$BIG/RPi/Git/rern.github.io
else
#........................
	localip=$( dialogIP 'Local \Z1rern.github.io\Z0 IP' )
	dir_repo=$PWD/repo
	mkdir -p repo
	mount -t cifs //$localip/rern.github.io $dir_repo -o username=guest,password=
	[[ $? != 0 ]] && exit
#----------------------------------------------------------------------------
fi
[[ ! $( ls $dir_repo ) ]] && errorExit Repo empty: $dir_repo
#----------------------------------------------------------------------------
#........................
repo=$( dialog $opt_check '
\Z1Repository:\Z0
' 8 30 0 \
	aarch64 on \
	armv7h on \
	armv6h off \
	Rebuild off )
#........................
banner $action repository ...
if selected Rebuild; then
	action=Rebuild
else
	action=Update
	new=-n # newer only (deleted packages still exist in db)
fi
for arch in $repo; do
	[[ $arch == Rebuild ]] && break
	
	echo -e "\n$bar $arch\n"
	cd $dir_repo/$arch
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
unMount
echo -e "
$bar Done
"
