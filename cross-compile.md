Cross-Compiling
---
## x86_64 Manjaro
```sh
# clone rpi0 ROOT partition in usb reader
dir_root=/var/lib/machines/rpi0
mkdir -p $dir_root
rsync -aAXv --info=progress2 /run/media/x/ROOT/ $dir_root/
cp -f /etc/resolv.conf $dir_root/etc/resolv.conf
sed -i -E 's/#*(MAKEFLAGS="-j).*/\112"/' /etc/makepkg.conf

# allow root login
systemd-nspawn -D /var/lib/machines/rpi0
cat << EOF >> /etc/securetty
console
pts/0
pts/1
pts/2
pts/3
container
EOF
exit

# login
systemd-nspawn -bD /var/lib/machines/rpi0
```

```sh
# setup ------------------------------------------------------------------------
pacman -Sy --needed base-devel git qemu-user-static-binfmt arch-install-scripts
# clone ROOT partition
dir_root=/mnt/rpi0
mkdir -p $dir_root
rsync -aAXv --info=progress2 /run/media/x/ROOT/ $dir_root/
cp -f /etc/resolv.conf $dir_root/etc/
cp /usr/bin/qemu-arm-static /mnt/rpi0/usr/bin/
sed -i -E 's/#*(MAKEFLAGS="-j).*/\112"/' /etc/makepkg.conf

# chroot
# mount script
cat << EOF > chroot-rpi0.sh
#!/bin/bash

dir_root=/mnt/rpi0

if [[ $1 ]]; then
        for mp in '' run dev/pts dev sys proc; do
                umount -l $dir_root/$mp
        done
        exit
fi

mount -t proc /proc    $dir_root/proc
mount -t sysfs /sys    $dir_root/sys
mount --make-rslave    $dir_root/sys
mount --bind /dev      $dir_root/dev
mount --bind /dev/pts  $dir_root/dev/pts
mount --bind /run      $dir_root/run
mount --bind $dir_root $dir_root
mount -o remount,suid,dev,exec $dir_root

arch-chroot $dir_root /bin/bash
EOF
chmod +x chroot-rpi0.sh

# fix openssl ----------------------------------------------------------------------
### host
dir_alarm=$dir_root/home/alarm
dir_build=$dir_alarm/openssl-1.1
mkdir -p $dir_build/src
curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/openssl-1.1.tar.gz | bsdtar xf - -C $dir_alarm
curl -L https://www.openssl.org/source/openssl-1.1.1w.tar.gz | bsdtar xf - -C $dir_build/src

./chroot-rpi0.sh
### chroot
cd /home/alarm
chown -R alarm:alarm openssl-1.1.1
cd alarm/openssl-1.1.1/openssl-1.1.1w/src
# compile
su alarm
./config # makepkg failed here
make -j$(nproc)
# ctrl+d back to root
make install
#cp libcrypto.* libssl.* /lib

# gcc -----------------------------------------------------------------------
pkgver=11.2.0
dir_build=$dir_alarm/gcc-$pkgver
mkdir -p $dir_build/src
cd $dir_build

# PKGBUILD
commit=00071916624e7b3234609c4cab4ce22934649eee
url=https://github.com/archlinuxarm/PKGBUILDs/raw/$commit/core/gcc
for f in PKGBUILD c89 c99 gcc-ada-repro.patch gdc_phobos_path.patch; do
	curl -LO $url/$f
done
# source
curl -L https://sourceware.org/pub/gcc/releases/gcc-$pkgver$/gcc-$pkgver.tar.xz | bsdtar xf - -C src
mv $dir_build/src/{gcc-$pkgver$,gcc-build}

./chroot-rpi0.sh
cd /home/alarm
chown -R alarm:alarm gcc-11.2.0
# compile
su alarm

MAKEFLAGS="-j4" makepkg -Ae --nodeps --skipinteg # -e no extraxt
# error: ... > s-options - recompile with: MAKEFLAGS="-j1" makepkg -Ae--nodeps --skipinteg (limit to single core)
# error: reversed patch - comment out the patch line in prepare()
```

- [Distcc](#distcc)
    - [crosstool-NG](https://github.com/rern/rern.github.io/tree/main/crosstool-NG) for armv6h Distcc
- [Docker](#docker)

### Method Selection
- aarch64 / armv7h
	- Native + Distcc
	- Native without Distcc is still **faster** than Docker
- armv6h
	- Native + Distcc
	- Native without Distcc is **slower** than Docker
- `rust`/`cargo` - not support Distcc

### Distcc
- Master - RPi
- Client / Volunteer - x86-64 Arch Linux
- Build package

**Master - RPi**
- Install distcc + setup: `bash <( curl -sL https_://github.com/rern/rern.github._io/raw/main/distcc-install-master.sh )`

**Client/Volunteer - x86-64 Arch Linux**
- Build toolchains + install:
	```sh
 	su USER
 	curl -sL https://aur.archlinux.org/cgit/aur.git/snapshot/distccd-alarm.tar.gz | bsdtar xf -
 	cd distccd-alarm
 	makepkg
 	su
 	pacman -U distccd-alarm-arm*
	```
- Install distcc: `bash <( curl -sL https_://raw.githubusercontent.com/rern/rern.github._io/main/distcc-install-client.sh )`

**Build package**
- Start Distcc
	- Master - No need
	- Client `systemctl start distccd-ARCH` (`ARCH` - armv6h, armv7h, armv8)
- Setup and build as usual.
- Monitor with another RPi terminal:
	```sh
 	su USER
	distccmon-text 1  # 1: @ 1 second
	```

### Docker
```sh
pacman -Sy docker
systemctl start docker
```
- New CONTAINER
	- Source
   		- Custom - `docker import IMAGE_FILE.tar`
       		- rAudio Source
			```sh
			xz -kd rAudio-ARCH-VERSION.img.xz
			# dolphin: mount the rAudio-ARCH-VERSION.img
			cd /run/media/USER/ROOT/
			bsdtar cvf /home/USER/IMAGE_FILE.tar .
			docker import IMAGE_FILE.tar
			```
   			- `armv6h`:
        	```sh
         	docker run --privileged linuxkit/binfmt:v0.8

         	#   optional:
			#	fakeroot        : --ulimit nofile=1024:524288 (soft:hard)
			#	armv7l > armv6l : -e QEMU_CPU=arm1176
			docker run -it --ulimit nofile=1024:524288 --name CONTAINER_NAME -e QEMU_CPU=arm1176 IMAGE_NAME bash
         	```
	 	- Docker's
     		- List - `docker search SEARCH_STRING`
     		- Get  - `docker pull IMAGE`
  		- Existing IMAGE - `docker image ls`
      	- Docker's copy - `docker image load -i IMAGE_FILE.tar`
 	- Initialize - `docker run -it --name CONTAINER_NAME IMAGE_NAME bash`
- Existing CONTAINER
  	- List  - `docker ps -a`
	- Start - `docker start CONTAINER_NAME`
 	- Run   - `docker exec -it CONTAINER_NAME bash`
    - Stop  - `docker stop CONTAINER_NAME` (Stop all - `docker stop $( docker ps -aq )`)
    - Rename - `docker rename CONTAINER_NAME NEW_NAME`
  	- Remove - `docker rm CONTAINER_NAME`
- Existing IMAGE
  	- List - `docker image ls`
  	- Copy
  		- New IMAGE - `docker commit CONTAINER_ID IMAGE_NAME`
  	  	- New file  - `docker save -o IMAGE_FILE.tar IMAGE_NAME`
  	  	-
  	- Remove - `docker image rm IMAGE_NAME` (`REPOSITORY:TAG` if more than 1)
- Shared directory
	- Mount - `-v /home/USER/SHARE:/DOCKER_SHARE`
	- Copy file - `docker cp NAME:/path/to/SOURCE_FILE .`
