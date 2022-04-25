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

keys=$( dialog "${optbox[@]}" --output-fd 1 --nocancel --menu "
\Z1Raspberry Pi:\Z0
" 8 0 0 \
1 'Use existing keys' \
2 'Generate new keys' )

dirssh=/home/alarm/.ssh
if [[ $keys == 1 ]]; then
	dialog "${optbox[@]}" --msgbox "
 Copy \Z1.ssh/{aur,aur.pub}\Z0 > /home/alarm
 Then press OK to continue.
" 7 58
else
	ssh-keygen -t rsa -f ~/.ssh/aur -q -N ""
	sed -i 's/= .*$/=/' ~/.ssh/aur.pub # remove trailing USER@HOSTNAME
	mkdir -p $dirssh
	cp -r ~/.ssh/aur* $dirssh
	dialog "${optbox[@]}" --msgbox "
AUR > My Account

\Z1SSH Public Key:\Z0
$( cat $dirssh/aur.pub )

\Z1PGP Key Fingerprint:\Z0 (empty)
\Z1Your current password:\Z0 (password)
" 24 58
fi
chown -R alarm:alarm $dirssh

email=$( dialog "${optbox[@]}" --output-fd 1 --inputbox "
 \Z1Email:\Z0
" 0 0 rernrern@gmail.com )
username=$( dialog "${optbox[@]}" --output-fd 1 --inputbox "
 \Z1Username:\Z0
" 0 0 rern )

echo "\
[user]
	email = rernrern@gmail.com
	name = rern
" > /home/alarm/.gitconfig

chown -R alarm:alarm /home/alarm/.gitconfig $dirssh

sudo -u alarm git init /home/alarm
