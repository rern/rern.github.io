#!/bin/bash

optbox=( --colors --no-shadow --no-collapse )
dialog "${optbox[@]}" --infobox "

                          \Z1AUR\Z0

                       Git Setup
" 9 58
sleep 2

echo "
Host aur.archlinux.org
  IdentityFile ~/.ssh/aur
  User aur
" >> /etc/ssh/ssh_config

systemctl restart sshd

[[ -e /usr/bin/git ]] || pacman -Sy --noconfirm git

email=$( dialog "${optbox[@]}" --output-fd 1 --inputbox "
 Email:
" 0 0 rernrern@gmail.com )
username=$( dialog "${optbox[@]}" --output-fd 1 --inputbox "
 Username:
" 0 0 rern )

su alarm
git init
git config --global user.email $email
git config --global user.name $username

ssh-keygen -f ~/.ssh/aur # remove trailing USER@HOSTNAME when paste in AUR

dialog "${optbox[@]}" --infobox "
AUR > My Account

\Z1SSH Public Key:\Z0
$( cat ~/.ssh/aur.pub | cut -d' ' -f1-2 )

\Z1PGP Key Fingerprint:\Z0 (empty)
\Z1Your current password:\Z0 (password)
" 20 58
