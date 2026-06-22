## `machinectl` / `systemd-nspawn`

- Slightly faster than RPi 4, 5
- Much faster than RPi 3 and less

```sh
pacman -Sy --needed qemu-user-static qemu-user-static-binfmt
systemctl restart systemd-binfmt # run once

# clone rpi0 ROOT partition in usb reader
dir_rpi0=/home/x/rpi0_sysroot
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
# boot
systemd-nspawn -bD /var/lib/machines/rpi0 --tmpfs=/tmp --tmpfs=/root/.cache
# shutdown: hold Ctrl and ] 3 times
```
