### A spotify daemon
Source: [Spotifyd](https://github.com/Spotifyd/spotifyd)
```sh
pacman -Syu
pacman -S --needed base-devel cargo rust alsa-lib libogg libpulse dbus

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

### RPi Zero
- Run build on [RPi 4 armv7h Docker](https://github.com/rern/distcc-alarm/blob/main/README.md#docker)
