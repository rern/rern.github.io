#!/bin/bash

. <( curl -sL https://github.com/rern/rOS/raw/main/common.sh )

bar Mount REPO ...
mkdir -p REPO
mount -t cifs //192.168.1.9/rern.github.io REPO -o username=guest,password=
[[ $? != 0 ]] && rmdir REPO && dialog.error_exit "Mount '\Z1REPO\Zn' failed."
#----------------------------------------------------------------------------
[[ ! $( ls REPO ) ]] && rmdir REPO && dialog.error_exit Repo empty: REPO
#----------------------------------------------------------------------------
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

dir_base=$PWD
shopt -s nullglob # suppress error if no *.zst
for arch in $selected; do
	cd REPO/$arch
	bar $arch
	[[ ! $newer_only ]] && rm -f +R*
	repo-add $newer_only -R +R.db.tar.xz *.pkg.tar.xz
	rm -f *.xz.old
done

cd $dir_base
umount -ql REPO
rmdir REPO

bar Done
