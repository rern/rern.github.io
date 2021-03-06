Cross-Compiling
---
- [Distcc](#distcc)
- [Docker](#docker)

### Distcc
- [Wiki](https://archlinuxarm.org/wiki/Distributed_Compiling)
- [Toolchains](https://aur.archlinux.org/packages/distccd-alarm-armv7h/)

**Client/Volunteer - x86-64 Arch Linux**
- Install distcc
```sh
pacman -Sy distcc
```
- Toolchains
	- Get package
	```sh
	for arch in armv6h armv7h armv8; do
		wget https://github.com/rern/distcc-alarm/releases/download/20200823/distccd-alarm-$arch-10.2.0.20200823-3-x86_64.pkg.tar.zst
	done
	```

	- **OR** Build package
	```sh
	su USER
	cd
	curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/distccd-alarm.tar.gz | bsdtar xf -
	cd distccd-alarm
	makepkg -s

	su
	```

- Install toolchains
```sh
for arch in armv6h armv7h armv8; do
	pacman -U distccd-alarm-$arch
done

systemctl start distccd-[armv6h|armv7h|armv8]
# or
bash <( curl -L https://github.com/rern/distcc-alarm/raw/main/distcc.sh )
```
**Master - RPi**
- Install distcc
```sh
pacman -Sy distcc
```
- Config
```sh
# MAKEFLAGS="-j8"                             --- 2x max threads per client
# BUILDENV=(distcc color !ccache check !sign) --- unnegate !distcc
# DISTCC_HOSTS="192.168.1.9:3636/8"           --- CLIENT_IP:PORT/JOBS (JOBS: 2x max threads per client)
# Add Master IP to DISTCC_HOSTS to have it help running build.

clientip=CLIENT_IP

cores=4    # on client: $( lscpu | awk '/^Core/ {print $NF}' )
threads=1  # on client: $( lscpu | awk '/^Thread/ {print $NF}' )
jobs=$(( 2 * $cores * $threads ))
if [[ -e /boot/kernel8.img ]]; then
	port=3636  # armv8
elif [[ -e /boot/kernel7.img ]]; then
	port=3635  #armv7h
else
	port=3634  # armv6h
fi

sed -i -e '/^#MAKEFLAGS=/ a\
MAKEFLAGS="-j'$jobs'"
' -e 's/BUILDENV=(!distcc/BUILDENV=(distcc/
' -e '/#DISTCC_HOSTS=/ a\
DISTCC_HOSTS="'$clientip:$port/$jobs'"
' /etc/makepkg.conf

systemctl start distccd
```
- Build package
	- Setup and build as usual.
	- Monitor on another terminal: `distccmon-text 1` (1 - @ 1 second)
- Copy to repository
	- From Client:
	```sh
	scp root@MASTER_IP:/home/alarm/PKG_DIR/PKG.tar.xz /home/USER/GitHub/rern.github.io/ARCH
	bash <( curl -L https://github.com/rern/rAudio-addons/raw/main/0Packages/repoupdate.sh )	
	```
	- GitHub Desktop > Push


### Docker - on x86 Linux
- Notes
	- Native compile on RPi 4 is faster.
	- **`rust`/`cargo`, used by spotifyd,  must be run on RPi, for armv6h on armv7h - not aarch64.**
- Setup
```sh
pacman -Sy docker

systemctl start docker

# get image: https://github.com/mydatakeeper/archlinuxarm
for arch in armv6h armv7h aarch64; do
	docker pull mydatakeeper/archlinuxarm:$arch
done

# run
docker run -it --name ARCH mydatakeeper/archlinuxarm:ARCH bash

########## docker container ##########

# root password: root

# system upgrade
sed -i 's|^Server = http://|&REPO.|' /etc/pacman.d/mirrorlist
pacman -Syu nano wget
```
- Rerun image - with changes maintained from last exit
```sh
docker ps -a  # get NAME
docker start NAME
docker exec -it NAME bash
```
- Rename run image `--name NAME`
```sh
docker ps -a  # get NAME
docker rename NAME NEW_NAME
```
- Stop all running
```sh
docker stop $( docker ps -aq )
```
- Remove CONTAINER
```sh
docker ps -a  # get CONTAINER
docker rm CONTAINER
```
- Remove image:
```sh
docker image ls  # get REPOSITORY
docker rm REPOSITORY  # or REPOSITORY:TAG if more than 1
```
- Save updated image for later uses with another ssh:
```sh
docker ps -a  # get CONTAINER_ID
docker commit CONTAINER_ID IMG_NAME
docker save IMG_NAME:latest | gzip > IMG_NAME.tar.gz
```
