Cross-Compiling
---
- [Distcc](#distcc)
    - [crosstool-NG](https://github.com/rern/rern.github.io/tree/main/crosstool-NG) for armv6h Distcc
- [Docker](#docker)

### Method Selection
- aarch64 / armv7h
	- Native + Distcc
	- Lone native is faster than Docker
- armv6h
	- Native + Distcc
	- Docker is faster than lone native
- `rust`/`cargo` - not support Distcc

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
- Setup (x86 host requires: `glib2-static` `pcre-static` `qemu-user-static` `binfmt-qemu-static`)
```sh
# x86 host only ##############################################################################
su
currentdir=$PWD
USER=x
cd /home/$USER

for name in glib2-static pcre-static qemu-user-static binfmt-qemu-static; do # keep order
	curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/$name.tar.gz | sudo -u $USER bsdtar xf -
	cd $name
	sudo -u $USER makepkg -A --skipinteg
	pacman -U *.zst
	cd ..
done

cd $currentdir
# x86 host only ##############################################################################

# install docker
pacman -Sy docker
systemctl start docker
docker pull mydatakeeper/archlinuxarm:armv6h
```
- Run
```sh
# run
docker run -it --name armv6h mydatakeeper/archlinuxarm:armv6h bash

########## docker container ##########

# root password: default = root > ros
passwd

# system upgrade
echo 'Server = http://alaa.ad24.cz/repos/2022/02/06/$arch/$repo' /etc/pacman.d/mirrorlist
sed -i '/^#IgnorePkg.*/IgnorePkg = linux-api-headers/' /etc/pacman.conf
pacman -Syu base-devel nano openssh wget
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
