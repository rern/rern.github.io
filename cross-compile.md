Cross-Compiling
---
- [Distcc](#distcc)
- [Docker](#docker)
- [crosstool-NG](#crosstool-ng)

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
- Install distcc + setup: `bash <( curl -L https://github.com/rern/rern.github.io/raw/main/distcc-install-master.sh )`

**Client/Volunteer - x86-64 Arch Linux**
- Install distcc + toolchains: `bash <( curl -L https://github.com/rern/rern.github.io/raw/main/distcc-install-client.sh )`

**Build package**
- Start Distcc - needed on client only
	- Client `systemctl start distccd-ARCH` (`ARCH` - armv6h, armv7h, armv8)
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
	- x86 PC - build and install:
		- [`binfmt-qemu-static`](https://aur.archlinux.org/packages/binfmt-qemu-static)
		- [`glib2-static`](https://aur.archlinux.org/packages/glib2-static)
		- [`pcre-static`](https://aur.archlinux.org/packages/pcre-static)
		- [`qemu-user-static`](https://aur.archlinux.org/packages/qemu-user-static)
	```sh
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
- On docker - Copy files:
```sh
# on host (sed -i 's/#\(PermitRootLogin \).*/\1yes/' /etc/ssh/sshd_config)
# systemctl start sshd

# to docker
scp sourcefile*.ext USER@IP_ADDRESS:/path/to

# from docker
scp USER@IP_ADDRESS:/path/to/file.ext .
```
- On host - Copy files:
```sh
docker ps -a  # get NAME
docker cp NAME:/path/to/file . # no wildcards
```

### crosstool-NG
On Linux host:
- Install
```sh
cd
version=1.25.0
wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-$version.tar.xz
bsdtar xf crosstool-ng-$version.tar.xz
cd crosstool-ng-$version
./configure --prefix=/home/x/ct-ng
make
make install
export PATH=$PATH:/home/x/ct-ng/bin
mkdir build
cd build
wget https://archlinuxarm.org/builder/xtools/10.2.0/xtools-dotconfig-v6
cp xtools-dotconfig-v6 .config
ct-ng oldconfig
# review all settings / set packages to latest versions
ct-ng build
```
