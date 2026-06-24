#!/bin/bash

. <( curl -sL https://github.com/rern/rOS/raw/main/common.sh )

updateRepo() {
	[[ ! $newer_only ]] && rm -f +R*
	repo-add $newer_only -R +R.db.tar.xz *.pkg.tar.xz *.pkg.tar.zst
	rm -f *.xz.old
}

if [[ $( uname -m ) == x86_64 ]]; then
	manjaro=1
else
	bar Mount REPO ...
	mkdir -p BIG REPO
	mount -t cifs //192.168.1.9/rern.github.io REPO -o username=guest,password=
	[[ $? != 0 ]] && dialog.error_exit "Mount '\Z1REPO\Zn' failed."
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
	newer_only=-n # newer only (deleted packages still exist in db)
fi
#........................
banner $action Repository

shopt -s nullglob # suppress error if no *.zst
for arch in $selected; do
	if [[ $manjaro ]]; then
		cd /home/x/GitHub/rern.github.io/$arch
	else
		dir_base=$PWD
		cd $dir_base/REPO/$arch
	fi
	bar $arch
	if [[ $arch == armv6h ]]; then
		for dir in alarm core extra; do
			bar $dir
			cd $dir
			updateRepo
			cd ..
		done
	else
		updateRepo
	fi
done

if [[ ! $manjaro ]]; then
	cd $dir_base
	umount -ql BIG REPO
	rmdir BIG REPO
fi

bar Done
