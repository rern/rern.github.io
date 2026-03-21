#!/bin/bash

. <( curl -sL https://raw.githubusercontent.com/rern/rOS/main/common.sh )

! grep -q ^Model.*Rasp /proc/cpuinfo && dialog.error_exit This is not a Raspberry Pi
#----------------------------------------------------------------------------
#........................
dialog.splash Package Utilities
list="\
Package Build        : package_build
Repo Update          : repo_update
AUR Setup            : aur_setup
guide.tar.xz         :
radioparadise.tar.xz :
regdomcodes.json     : wireless_regdom"
#........................
task=$( dialog.menu Package "$( sed 's/ *:.*//' <<< $list )" )
name=$( sed -n "$task {s/ *:.*//; p}" <<< $list )
script=$( sed -n "$task {s/.*: *//; p}" <<< $list )
#........................
dialog.splash $name
clear -x
if [[ $script ]]; then
	. <( curl -sL $https_io/$script.sh )
else
	grep -q guide <<< $name && dir=assets/img/guide || dir=data/webradio
	bsdtar cjvf $name -C /srv/http/$dir .
fi
