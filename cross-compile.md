Cross-Compiling
---
## x86_64 Manjaro

- `systemd-nspawn`
- Slightly faster than RPi 4, 5
- Much faster than RPi 3 and less

```sh
pacman -Sy --needed qemu-user-static qemu-user-static-binfmt
systemctl restart systemd-binfmt # run once

# clone rpi0 ROOT partition in usb reader
dir_rpi0=/root/rpi0
mkdir -p $dir_root $dir_rpi0
rsync -aAXv --info=progress2 /run/media/x/ROOT/ $dir_rpi0/
cp -f /etc/resolv.conf $dir_rpi0/etc/resolv.conf
sed -i -E 's/#*(MAKEFLAGS="-j).*/\112"/' $dir_rpi0/etc/makepkg.conf
ln -s $dir_rpi0 /var/lib/machines

# allow rpi0 to user host tmpfs(ram)
mkdir -p /etc/systemd/system/systemd-nspawn@rpi0.d/
cat << 'EOF' > /etc/systemd/system/systemd-nspawn@rpi0.d/override.conf
[Service]
DevicePolicy=closed
ExecStart=
ExecStart=systemd-nspawn --quiet --keep-unit --boot --link-journal=try-guest --settings=override --machine=%I --tmpfs=/tmp --tmpfs=/root/.cache
EOF
systemctl daemon-reload

# allow network / internet
cat << EOF > /etc/systemd/nspawn/rpi0.nspawn
[Network]
VirtualEthernet=no
EOF

# start rpi0
machinectl start rpi0
# rpi0 prompt
machinectl shell root@rpi0

machinectl kill rpi0 --signal=SIGKILL # machinectl stop rpi0 # not working

# list
machinectl list
machinectl show rpi0

# if needed to boot rpi0 normally
# allow root login
cat << EOF >> /etc/securetty
console
pts/0
pts/1
pts/2
pts/3
container
EOF
exit
# boot         -b
systemd-nspawn -bD /var/lib/machines/rpi0 --tmpfs=/tmp --tmpfs=/root/.cache
```

- [Distcc](#distcc)
    - [crosstool-NG](https://github.com/rern/rern.github.io/tree/main/crosstool-NG) for armv6h Distcc

- [Docker](#docker)

### Method Selection
- aarch64
	- Crosstools-NG
	- Native + Distcc
	- `systemd-nspawn'
- aarch64 / armv7h
	- Crosstools-NG
	- `systemd-nspawn'
	- Native + Distcc
- armv6h
	- Crosstools-NG
	- `systemd-nspawn'
	
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
