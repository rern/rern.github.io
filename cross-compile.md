Cross-Compiling
---
- [Docker](#docker)
- [Distcc](#distcc)

### Docker
- `rust`/`cargo`, used by **spotifyd**,  must be run on RPi, for armv6h on armv7h - not aarch64.
```sh
pacman -Sy docker

systemctl start docker

# ready made image
# armv7h - docker-armv7h.tar.gz
# aarch64 - docker-aarch64.tar.gz
wget https://github.com/rern/distcc-alarm/releases/download/10.2.0.20200823-3/docker-armv6h.tar.gz
docker load -i docker-armv6h.tar.gz
docker run -it --platform arm armv6h bash


# OR start with new image from docker hub
# armv7h - eothel/armv7h-archlinux
# aarch64 - mydatakeeper/archlinuxarm:aarch64
docker run -it --platform arm eothel/armv6h-archlinux bash

########## docker container
pacman -Syu
pacman -S nano
nano /etc/pacman.d/mirrorlist  # set preferred repo
pacman -S base-devel cargo rust wget alsa-lib libogg libpulse dbus

passwd  # set root password
mkdir /home/alarm
useradd alarm
chown alarm /home/alarm

##### save docker image for later uses > another ssh:
docker ps -a  # get container id
docker commit CONTAINER_ID armv6h
docker save armv6h:latest | gzip > docker-armv6h
```

### Distcc
- [Wiki](https://archlinuxarm.org/wiki/Distributed_Compiling)
- [Toolchains](https://aur.archlinux.org/packages/distccd-alarm-armv7h/)

### Client/Volunteer - x86-64 Arch Linux
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

### Master - RPi
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
