```sh
sed -i '/^\[+R/,/^server/ d' /etc/pacman.conf
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