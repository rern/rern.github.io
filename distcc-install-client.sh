#!/bin/bash

. <( curl -sL https://github.com/rern/rOS/raw/refs/heads/main/common.sh )

#........................
dialog $opt_info '


                 Install \Z1Distcc\Z0 Client
' 9 58
sleep 1
pacman -Sy --noconfirm distcc
# for ssh start distccd from master
sed -i -e 's/#\(PermitRootLogin \).*/\1yes/' /etc/ssh/sshd_config
systemctl enable sshd
[[ -e /usr/bin/distccd-armv8 && -e /usr/bin/distccd-armv7h ]] && exit
#----------------------------------------------------------------------------
#........................
dialog $opt_info '


          Please build and install toolchains:
 https://aur.archlinux.org/packages/distccd-alarm-armv8
' 9 58
