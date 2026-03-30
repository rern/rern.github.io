#!/bin/bash

. <( curl -sL https://raw.githubusercontent.com/rern/rOS/main/common.sh )

! grep -q ^Model.*Rasp /proc/cpuinfo && dialog.error_exit This is not a Raspberry Pi
#----------------------------------------------------------------------------
#........................
dialog.splash Package Utilities
list="\
Package Build        : package_build
Repo Update          : repo_update
AUR Setup            : aur_setup"
#........................
task=$( dialog.menu Package "$( sed 's/ *:.*//' <<< $list )" )
name=$( sed -n "$task {s/ *:.*//; p}" <<< $list )
#........................
dialog.splash $name
clear -x
script=$( sed -n "$task {s/.*: *//; p}" <<< $list )
. <( curl -sL $https_io/$script.sh )
