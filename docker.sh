#!/bin/bash

#........................
arch=$( dialog $opt_menu "
 \Z1Docker\Z0:
" 8 0 0 \
	1 aarch64 \
	2 armv7h \
	3 armv6h \
	4 'Stop all' )
[[ $arch == 4 ]] && docker stop $( docker ps -aq ) && exit
#----------------------------------------------------------------------------
systemctl start docker
ar=( '' arch64 armv7h armv6h )
arch=${ar[$arch]}
docker start $arch
clear -x
docker exec -it $arch bash
