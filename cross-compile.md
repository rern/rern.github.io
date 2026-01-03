Cross-Compiling
---
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
- Install distcc + setup: `bash <( curl -L https://github.com/rern/rern.github.io/raw/main/distcc-install-master.sh )`

**Client/Volunteer - x86-64 Arch Linux**
- Build toolchains + install:
	```sh
 	su USER
 	curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/distccd-alarm.tar.gz | bsdtar xf -
 	cd distccd-alarm
 	makepkg
 	su
 	pacman -U distccd-alarm-arm*
	```
- Install distcc: `bash <( curl -L https://github.com/rern/rern.github.io/raw/main/distcc-install-client.sh )`

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
