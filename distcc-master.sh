#!/bin/bash

optbox=( --colors --no-shadow --no-collapse )

dialog "${optbox[@]}" --infobox "


                 Install \Z1Distcc\Z0 Master
" 9 58
sleep 1

pacman -Sy distcc
clientip=$( dialog "${optbox[@]}" --output-fd 1 --inputbox "
Client IP:

" 0 0 192.168.1.9 )

jobs=12
if [[ -e /boot/kernel8.img ]]; then
  port=3636
elif [[ -e /boot/kernel7.img ]]; then
  port=3635
else
  port=3634
  jobs=8
fi

sed -i -e 's/^#*\(MAKEFLAGS="-j\).*/\1'$jobs'"/
' -e 's/!distcc/distcc/
' -e "s|^#*\(DISTCC_HOSTS=\"\).*|\1$clientip:$port/$jobs\"|
" /etc/makepkg.conf

systemctl start distccd
status=$( systemctl status distccd | sed 's/active (running)/\\e[32m&\\e[0m/' )
clear -x
echo -e "\
\e[32mdistccd-master\e[0m
$status"
