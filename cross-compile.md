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
- Run - create a new CONTAINER
```sh
# run
docker run -it --name armv6h mydatakeeper/archlinuxarm:armv6h bash

########## docker container ##########

# root password: default = root > ros
passwd

# system upgrade
echo 'Server = http://alaa.ad24.cz/repos/2022/02/06/$arch/$repo' /etc/pacman.d/mirrorlist
sed -i 's/^#IgnorePkg.*/IgnorePkg = linux-api-headers/' /etc/pacman.conf
pacman -Syu base-devel nano openssh wget
```
- Start - start a CONTAINER
```sh
docker ps -a  # get NAME
docker start NAME
docker exec -it NAME bash
```
- Rename a CONTAINER
```sh
docker ps -a  # get NAME
docker rename NAME NEW_NAME
```
- Stop all running CONTAINERs
```sh
docker stop $( docker ps -aq )
```
- Remove CONTAINER
```sh
docker ps -a  # get CONTAINER
docker rm CONTAINER
```
- Remove IMAGE
```sh
docker image ls  # get IMAGE_ID
docker image rm IMAGE_ID  # or REPOSITORY:TAG if more than 1
```
- Backup a CONTAINER
```sh
docker ps -a  # get CONTAINER_ID
docker commit CONTAINER_ID IMG_NAME
docker save -o IMG_NAME.tar IMG_NAME
```
- Restore from a backup CONTAINER
```sh
docker image load -i IMG_NAME.tar 
```
- On docker - Copy files:
```sh
# on host (sed -i 's/#\(PermitRootLogin \).*/\1yes/' /etc/ssh/sshd_config)
# systemctl start sshd

# to docker
scp SOURCE_FILE USER@IP_ADDRESS:/path/to
scp -r SOURCE_DIR USER@IP_ADDRESS:/path/to

# from docker
scp USER@IP_ADDRESS:/path/to/SOURCE_FILE .
scp -r USER@IP_ADDRESS:/path/to/SOURCE_DIR .
```
- On host - Copy file from docker
```sh
docker ps -a  # get NAME
docker cp NAME:/path/to/SOURCE_FILE . # no wildcards
```
