### HFS File System support
Source: [hfsprogs](https://github.com/muflone/pkgbuilds/tree/master/hfsprogs)
```sh
pacman -Syu
pacman -S --needed base-devel libbsd

su alarm
cd
curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/hfsprogs.tar.gz | bsdtar xf -
cd hfsprogs
makepkg -A
```
