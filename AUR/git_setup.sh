#!/bin/bash

optbox=( --colors --no-shadow --no-collapse )
dialog "${optbox[@]}" --infobox "

                          \Z1AUR\Z0

                       Git Setup
" 9 58
sleep 2

if [[ -e /home/alarm/.ssh/aur ]]; then
	dialog "${optbox[@]}" --yesno "
AUR Git has already setup.

\Z1Continue?\Z0

" 0 0
	[[ $? == 1 ]] && exit
fi

echo "
Host aur.archlinux.org
  IdentityFile ~/.ssh/aur
  User aur
" >> /etc/ssh/ssh_config

systemctl restart sshd

[[ -e /usr/bin/git ]] || pacman -Sy --noconfirm git

email=$( dialog "${optbox[@]}" --output-fd 1 --inputbox "
 \Z1Email:\Z0
" 0 0 rernrern@gmail.com )
username=$( dialog "${optbox[@]}" --output-fd 1 --inputbox "
 \Z1Username:\Z0
" 0 0 rern )

git init
git config --global user.email $email
git config --global user.name $username

keys=$( dialog "${opt[@]}" --output-fd 1 --nocancel --menu "
\Z1Raspberry Pi:\Z0
" 8 0 0 \
1 ) Generate new keys
2 ) Use existing keys )

if [[ $keys == 1 ]]; then
	ssh-keygen -f ~/.ssh/aur # remove trailing USER@HOSTNAME when paste in AUR
	dialog "${optbox[@]}" --msgbox "
AUR > My Account

\Z1SSH Public Key:\Z0
$( cat ~/.ssh/aur.pub | cut -d' ' -f1-2 )

\Z1PGP Key Fingerprint:\Z0 (empty)
\Z1Your current password:\Z0 (password)
" 24 58
else
	publickey=$( dialog "${optbox[@]}" --output-fd 1 --nocancel --inputbox "
 AUR > My Account
 \Z1Publickey key:\Z0
" 0 0 )
	mkdir -p /home/alarm/.ssh
	echo $publickey > /home/alarm/.ssh/aur.pub
	dialog "${optbox[@]}" --msgbox "
 Copy \Z1aur\Z0 - private key to /home/alarm/.ssh
" 7 58
fi
