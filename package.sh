#!/bin/bash

. <( curl -sL https://github.com/rern/rOS/raw/main/common.sh )

if [[ $( uname -m ) == x86_64 ]]; then
    . <( curl -sL $https_io/repo_update.sh )
    exit
#----------------------------------------------------------------------------
fi

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
