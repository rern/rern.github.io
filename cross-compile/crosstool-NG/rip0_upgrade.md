```sh
sysroot=/home/x/x-sysroot
cd $sysroot

ln -s /home/x/GitHub/rern.github.io/armv6h/ $sysroot

cat << EOF > pacman.conf
[options]
Architecture = armv6h
CacheDir     = /var/cache/pacman/pkg/
DBPath       = /var/lib/pacman/
LogFile      = /var/log/pacman.log
GPGDir       = /etc/pacman.d/gnupg/
HookDir      = /etc/pacman.d/hooks/
SigLevel     = PackageOptional DatabaseOptional TrustAll

[core]
Server = file:///armv6h/core

[extra]
Server = file:///armv6h/extra
EOF

pacman --config pacman.conf --sysroot $sysroot -Syy

pacman --config pacman.conf --sysroot $sysroot -S \
    core/glibc \
    core/openssl \
    core/gcc-libs \
    core/gcc \
    core/pacman \
        --overwrite 'usr/*'

sudo pacman --config pacman.conf --sysroot $sysroot -Suu \
    --ignore linux-firmware-mellanox \
    --ignore linux-firmware-nvidia \
    --ignore linux-firmware-qcom \
    --overwrite 'usr/*'
    
dir_lib=$sysroot/usr/lib
rm -f $dir_lib/libstdc++.so.6
ln -s $sysroot/usr/armv6-rpi-linux-gnueabihf/lib/libstdc++.so.6.0.35 $dir_lib/libstdc++.so.6

rm $sysroot/pacman.conf $sysroot/armv6h

# insert card reader with rpi0 sd card
rsync -aAXv --delete
    --exclude='/boot/*'
    --exclude='/etc/fstab'
    --exclude='/etc/crypttab'
        $sysroot/ /run/media/x/ROOT/



sed -i '/REPOSITORIES/,$ d' /etc/pacman.conf
cat << EOF >> /etc/pacman.conf
DisableSandbox

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