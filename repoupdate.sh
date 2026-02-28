#!/bin/bash

unMount() {
	if [[ -L repo ]]; then
		unlink repo
	else
		umount -l $dirrepo
		rmdir repo
	fi
}
dirrepo=$PWD/repo
mkdir -p repo
if [[ ! $( ls /boot/kernel* 2> /dev/null ) ]]; then # not RPi
	ln -s /home/x/BIG/RPi/Git/rern.github.io repo
else
#........................
	localip=$( dialogIP 'Local \Z1rern.github.io\Z0 IP' )
	mnt=$( mount -t cifs //$localip/rern.github.io $dirrepo -o username=guest,password= )
	[[ $? != 0 ]] && error="Mount failed: $mnt\n"
fi
[[ ! $( ls $dirrepo ) ]] && error+="Repo empty: //$localip/rern.github.io\n"
[[ $error ]] && unMount && errorExit $error
#----------------------------------------------------------------------------
#........................
repo=$( dialog $opt_check '
\Z1Repository:\Z0
' 8 30 0 \
	aarch64 on \
	armv7h on \
	armv6h off \
	Rebuild off )
clear -x
if selected Rebuild; then
	action=Rebuild
else
	action=Update
	new=-n # newer only (deleted packages still exist in db)
fi
#........................
banner $action repository ...
for arch in $repo; do
	[[ $arch == Rebuild ]] && break
	
	echo -e "\n$bar $arch\n"
	cd $dirrepo/$arch
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
