### A spotify daemon
Source: [Spotifyd](https://github.com/Spotifyd/spotifyd)
```sh
pacman -Syu
pacman -S --needed base-devel cargo rust

# no distcc for cargo/rust

su alarm

cd
mkdir spotifyd
cd spotifyd
wget https://github.com/archlinux/svntogit-community/raw/packages/spotifyd/trunk/PKGBUILD
sed -i -e 's/ --features .*$//
' -e 's|systemd/user|systemd/system|
' PKGBUILD
makepkg -A
```

### Cross compile armv6h on armv7h (on armv7h Pi 4 - not aarch64)
```sh
pacman -Sy docker

systemctl start docker

# pre-build image
wget https://github.com/rern/distcc-alarm/releases/download/10.2.0.20200823-3/docker-armv6h.tar.gz
docker load -i docker-armv6h.tar.gz
docker run -it armv6h bash

# OR new from docker hub
docker run -it eothel/armv6h-archlinux bash

########## docker container
pacman -Syu
pacman -S nano
nano /etc/pacman.d/mirrorlist  # set preferred repo
pacman -S base-devel cargo rust wget alsa-lib libogg libpulse dbus

passwd  # set root password
mkdir /home/alarm
useradd alarm
chown alarm /home/alarm

##### save docker image by another ssh
docker ps -a  # get container id
docker commit CONTAINER_ID IMG_NAME
docker save -o IMG_NAME.tar IMG_NAME:latest
#####

# proceed as above
```
