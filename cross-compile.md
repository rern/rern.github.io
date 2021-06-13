Cross-Compiling
---
- [Distcc](#distcc)
- [Docker](#docker)

### Selection
- aarch64 / armv7h
	- Native + Distcc
	- Native alone is faster than Docker
- armv6h
	- Native + Distcc
	- `spotifyd` - RPi armv7h + Docker armv6h - `rust`/`cargo` - not support Distcc

### Distcc
- Master - RPi
- Client/Volunteer - x86-64 Arch Linux
- Build package

**Master - RPi**
- Install distcc + setup: `bash <( curl -L https://github.com/rern/rern.github.io/raw/master/distcc-install-master.sh )`

**Client/Volunteer - x86-64 Arch Linux**
- Install distcc + toolchains: `bash <( curl -L https://github.com/rern/rern.github.io/raw/master/distcc-install-client.sh )`

**Build package**
- Start Distcc
	- Client `systemctl start distccd-ARCH` (`ARCH` - armv6h, armv7h, armv8)
	- Master `systemctl start distccd`
- Setup and build as usual.
- Monitor with another SSH: 
	```sh
	su USER
	distccmon-text 1  # 1: @ 1 second
	```
- Copy to repository from Client:
	```sh
	scp root@MASTER_IP:/home/alarm/PKG_DIR/PKG.tar.xz /home/USER/GitHub/rern.github.io/ARCH
	bash <( curl -L https://github.com/rern/rAudio-addons/raw/main/0Packages/repoupdate.sh )	
	```
	- GitHub Desktop > Push


### Docker
- Setup
	- x86 PC
	```sh
	# pakages for running ARM images on x86
	path=https://github.com/rern/rern.github.io/releases/download/20210307
	wget $path/binfmt-qemu-static-20210119-1-any.pkg.tar.zst
	wget $path/glib2-static-2.66.6-1-x86_64.pkg.tar.zst
	wget $path/pcre-static-8.44-5-x86_64.pkg.tar.zst
	wget $path/qemu-user-static-5.2.0-1-x86_64.pkg.tar.zst
	pacman -U *.zst

	pacman -Sy docker

	systemctl start docker

	# get image: https://github.com/mydatakeeper/archlinuxarm
	for arch in armv6h armv7h aarch64; do
		docker pull mydatakeeper/archlinuxarm:$arch
	done
	```
	- RPi 4
	```sh
	pacman -Sy docker

	systemctl start docker
	
	docker pull mydatakeeper/archlinuxarm:armv6h
	```
- Run
```sh
# run
docker run -it --name ARCH mydatakeeper/archlinuxarm:ARCH bash

########## docker container ##########

# root password: root

# system upgrade
sed -i 's|^Server = http://|&REPO.|' /etc/pacman.d/mirrorlist
pacman -Syu nano wget openssh
```
- Re-run image (changes maintained from last exit)
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
- Stop all running images
```sh
docker stop $( docker ps -aq )
```
- Remove CONTAINER (run image)
```sh
docker ps -a  # get CONTAINER
docker rm CONTAINER
```
- Remove REPOSITORY (image)
```sh
docker image ls  # get REPOSITORY
docker image rm REPOSITORY  # or REPOSITORY:TAG if more than 1
```
- Save updated image for later uses with another ssh:
```sh
docker ps -a  # get CONTAINER_ID
docker commit CONTAINER_ID IMG_NAME
docker save IMG_NAME:latest | gzip > IMG_NAME.tar.gz
```
- Copy file to host:
```sh
# scp
scp sourcefile USER@IP_ADDRESS:/path/to/file

# docker
docker ps -a  # get NAME
docker cp NAME:/path/to/file .
```
