#!/bin/bash

. <( curl -sL https://github.com/rern/rOS/raw/main/common.sh )

! grep -q ^Model.*Rasp /proc/cpuinfo && errorExit This is not a Raspberry Pi
#----------------------------------------------------------------------------
#........................
dialog.splash Package Utilities
list="\
Build Package^pkgbuild
Update Repo^repoupdate
AUR Setup^aursetup
Create guide.tar.xz
Create radioparadise.tar.xz
Create regdomcodes.json^wirelessregdom"
#........................
task=$( dialog.menu Package "$( sed 's/\^.*//' <<< $list )" )
name=$( sed -n "$task {s/.*^//; p}" <<< $list )
#........................
dialog.splash $name
if [[ $name ]]; then
	. <( curl -sL https://github.com/rern/rern.github.io/raw/main/$name.sh )
elif grep -q guide <<< $name
	bsdtar cjvf guide.tar.xz -C /srv/http/assets/img/guide .
elif grep -q radio <<< $name
	bsdtar cjvf radioparadise.tar.xz -C /srv/http/data/webradio .
fi
