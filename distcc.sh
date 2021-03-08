#!/bin/bash

optbox=( --colors --no-shadow --no-collapse )

dialog "${optbox[@]}" --infobox "


                     \Z1Distcc Client\Z0
" 9 58
sleep 1

arch=$( dialog "${optbox[@]}" --output-fd 1 --menu "
 \Z1Distcc\Z0:
" 8 0 0 \
1 armv6h \
2 armv7h \
3 armv8/aarch64 )

case $arch in
	1 ) arch=armv6h;;
	2 ) arch=armv7h;;
	3 ) arch=armv8;;
esac

if [[ ! -e /usr/bin/distccd ]]; then
	pacman -Sy distcc
	clientip=$( dialog "${optbox[@]}" --output-fd 1 --inputbox "
 Client IP:

" 0 0 192.168.1.9 )
	if [[ -e /boot/kernel8.img ]]; then
		port=3636
	elif [[ -e /boot/kernel7.img ]]; then
		port=3635
	else
		port=3634
	fi
	cores=$( lscpu | awk '/^Core/ {print $NF}' )
	if (( $cores == 4 )); then
		jobs=12
		masterip=$( ifconfig | awk '/inet.*broadcast 192/ {print $2}' )
		hosts="$clientip:$port/$jobs $masterip:$port/$cores"
		dir=/etc/systemd/system/distccd.service.d
		mkdir -p $dir
		cat << 'EOF' > $dir/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/taskset -c 3 /usr/bin/distccd --no-detach --daemon $DISTCC_ARGS
EOF
		systemctl daemon-reload
	else
		jobs=8
		hosts="$clientip:$port/$jobs"
	fi
	sed -i -e 's/^#*\(MAKEFLAGS="-j\).*/\1'$jobs'"/
	' -e 's/!distcc/distcc/
	' -e "s|^#*\(DISTCC_HOSTS=\"\).*|\1$hosts\"|
	" /etc/makepkg.conf
else
	systemctl stop distccd-arm*
fi

systemctl start distccd-$arch
status=$( systemctl status distccd-$arch | sed 's/active (running)/\\e[32m&\\e[0m/' )
clear -x
echo -e "\
\e[32mdistccd-$arch\e[0m
$status"
