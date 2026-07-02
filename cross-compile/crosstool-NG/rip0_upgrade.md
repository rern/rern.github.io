```sh
# on rpi0
sed -i '/REPOSITORIES/,$ d' /etc/pacman.conf
cat << EOF >> /etc/pacman.conf
[+R]
SigLevel = Optional TrustAll
Server = https://rern.github.io/armv6h/+R

[alarm]
SigLevel = Optional TrustAll
Server = https://rern.github.io/armv6h/alarm

[core]
SigLevel = Optional TrustAll
Server = https://rern.github.io/armv6h/core

[extra]
SigLevel = Optional TrustAll
Server = https://rern.github.io/armv6h/extra
EOF

pacman -Syy
pacman -S archlinuxarm-keyring
pacman -S gcc glibc
pacman -S filesystem firmware-raspberrypi linux-firmware linux-rpi libatomic mkinitcpio netctl raspberrypi-bootloader util-linux --overwrite '*'

pacman -S coreutils cryptsetup curl hfsprogs hostapd kmod krb5 ldns \
    libarchive libevent libsasl libshout libssh libssh2 libubsan libwebsockets libzip \
    mosquitto nginx-mainline openssh openssl pacman python shairport-sync srt sudo websocat wpa_supplicant \
    systemd systemd-debug systemd-resolvconf systemd-sysvcompat \
    --overwrite '*'

pacman -Su --overwrite '*'

ldd /usr/bin/openssl


# insert card reader with rpi0 sd card
rsync -aAXv --delete
    --exclude='/boot/*'
    --exclude='/etc/fstab'
    --exclude='/etc/crypttab'
        $sysroot/ /run/media/x/ROOT/



sed -i '/REPOSITORIES/,$ d' /etc/pacman.conf
cat << EOF >> /etc/pacman.conf
[+R]
SigLevel = Optional TrustAll
Server = https://rern.github.io/armv6h/+R

[alarm]
SigLevel = Optional TrustAll
Server = https://rern.github.io/armv6h/alarm

[core]
SigLevel = Optional TrustAll
Server = https://rern.github.io/armv6h/core

[extra]
SigLevel = Optional TrustAll
Server = https://rern.github.io/armv6h/extra
EOF

pacman -Syy
pacman -Su \
    --ignore linux-firmware-mellanox \
    --ignore linux-firmware-nvidia \
    --ignore linux-firmware-qcom \
    --overwrite '/usr*' --overwrite '/etc/ssl*'



```