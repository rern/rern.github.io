#!/bin/bash

unMount() {
	if [[ -L repo ]]; then
		unlink repo
	else
		umount -l repo
		rmdir repo
	fi
}
#........................
ip_repo=$( dialog.ip 'Local \Z1rern.github.io\Z0 IP' )
mkdir -p repo
mount -t cifs //$ip_repo/rern.github.io repo -o username=guest,password=
[[ $? != 0 ]] &&  && dialog.error_exit Mount //$ip_repo/rern.github.io failed.
#----------------------------------------------------------------------------
[[ ! $( ls repo ) ]] && dialog.error_exit Repo empty: repo
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
	
	bar $arch
	cd repo/$arch
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
bar Done
