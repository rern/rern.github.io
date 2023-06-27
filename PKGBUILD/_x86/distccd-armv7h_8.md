```sh
curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/distccd-alarm.tar.gz | bsdtar xf -
cd distccd-alarm
makepkg

pacman -U distccd*
```
