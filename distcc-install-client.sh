#!/bin/bash

pacman -Sy --noconfirm distcc
# for ssh start distccd from master
sed -i -e 's/#\(PermitRootLogin \).*/\1yes/' /etc/ssh/sshd_config
systemctl enable sshd
if [[ -e /usr/bin/distccd-armv8 && -e /usr/bin/distccd-armv7h ]]; then
    clear -x
    echo -e "\n$bar Done\n"
else
    errorExit Please build + install toolchains: https://aur.archlinux.org/packages/distccd-alarm-armv8
fi
