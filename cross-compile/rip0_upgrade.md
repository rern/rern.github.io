```sh
# on rpi0
sed -i '/REPOSITORIES/,$ d' /etc/pacman.conf
cat << EOF >> /etc/pacman.conf
[+R]
SigLevel = Optional TrustAll
Server = file:///home/x/GitHub/rern.github.io/armv6h/+R

[alarm]
SigLevel = Optional TrustAll
Server = file:///home/x/GitHub/rern.github.io/armv6h/alarm

[core]
SigLevel = Optional TrustAll
Server = file:///home/x/GitHub/rern.github.io/armv6h/core

[extra]
SigLevel = Optional TrustAll
Server = file:///home/x/GitHub/rern.github.io/armv6h/extra
EOF

# for just compile
pacman -Syy coreutils curl cryptsetup gcc glibc gpgme kmod krb5 \
    libarchive libssh2 libubsan mkinitcpio pacman openssl openssl-1.1 \
    --overwrite '*'


pacman -S archlinuxarm-keyring filesystem firmware-raspberrypi \
    linux-firmware linux-rpi raspberrypi-bootloader raspberrypi-utils \
    --overwrite '*'
reboot

pacman -Su --overwrite '*' --ignore 'python*,systemd*,util-linux*'
echo ". $dirbash/bashrc" >> /etc/bash.bashrc # restore prompt
chown -R alarm:alarm /home/alarm
chmod 700 /home/alarm

# util-linux - boot stuck at [  OK  ] Reached target Graphical Interface.
# systemd    - boot failed
pacman -S python systemd systemd-debug systemd-resolvconf systemd-sysvcompat util-linux \
    --overwrite '*'
```
