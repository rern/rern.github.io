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

	- Install
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

# MAKEFLAGS="-j12"                                --- 2x max threads per client
# BUILDENV=(distcc color !ccache check !sign)     --- unnegate !distcc
# DISTCC_HOSTS="192.168.1.9:3636/8 192.168.1.4/4" --- CLIENT_IP:PORT/JOBS (JOBS: 2x max threads per client)
# Single core CPU - Omit Master IP from DISTCC_HOSTS

clientip=CLIENT_IP

if [[ -e /boot/kernel8.img ]]; then
	port=3636  # armv8
elif [[ -e /boot/kernel7.img ]]; then
	port=3635  #armv7h
else
	port=3634  # armv6h
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

systemctl start distccd
```
- Build package
	- Setup and build as usual.
	- Monitor with another SSH: `distccmon-text 1` (1: @ 1 second)
- Copy to repository from Client:
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

# run
docker run -it --name ARCH mydatakeeper/archlinuxarm:ARCH bash

########## docker container ##########

# root password: root

# system upgrade
sed -i 's|^Server = http://|&REPO.|' /etc/pacman.d/mirrorlist
pacman -Syu nano wget
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
docker rm REPOSITORY  # or REPOSITORY:TAG if more than 1
```
- Save updated image for later uses with another ssh:
```sh
docker ps -a  # get CONTAINER_ID
docker commit CONTAINER_ID IMG_NAME
docker save IMG_NAME:latest | gzip > IMG_NAME.tar.gz
```
