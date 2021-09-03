NGINX Upgrade with pushstream
---
- rAudio needs NGINx with **pushstream**
- **pushstream** is not available as a separated package

###
```sh
pacman -Syu
pacman -S --needed base-devel geoip mailcap

su alarm
cd
curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/nginx-mainline-pushstream.tar.gz | bsdtar xf -
cd nginx-mainline-pushstream
makepkg
```
