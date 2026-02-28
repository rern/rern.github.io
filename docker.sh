#!/bin/bash

#........................
arch=$( dialogMenu Docker "\
aarch64
armv7h
armv6h
Stop all" )
[[ $arch == 4 ]] && docker stop $( docker ps -aq ) && exit
#----------------------------------------------------------------------------
systemctl start docker
ar=( '' arch64 armv7h armv6h )
arch=${ar[$arch]}
docker start $arch
clear -x
docker exec -it $arch bash
