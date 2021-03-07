#!/bin/bash

optbox=( --colors --no-shadow --no-collapse )

dialog "${optbox[@]}" --infobox "


                        \Z1Docker\Z0
" 9 58
sleep 1

arch=$( dialog "${optbox[@]}" --output-fd 1 --menu "
 \Z1Arch\Z0:
" 8 0 0 \
1 armv6h \
2 armv7h \
3 armv8/aarch64 )

case $arch in
	1 ) arch=armv6h;;
	2 ) arch=armv7h;;
	3 ) arch=aarch64;;
esac

systemctl start docker
docker stop $( docker ps -aq ) &> /dev/null
docker start $arch
docker exec -it $arch bash
