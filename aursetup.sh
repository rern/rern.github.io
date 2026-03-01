#!/bin/bash

dir_home=/home/alarm
dir_git=$dir_home/.config/git
dir_ssh=$dir_home/.ssh
if [[ -e $dir_ssh/aur ]]; then
#........................
	dialog $opt_yesno '
AUR Git has already setup.

\Z1Continue?\Z0

' 0 0 || exit
#----------------------------------------------------------------------------
fi
echo "
Host aur.archlinux.org
  IdentityFile ~/.ssh/aur
  User aur
" >> /etc/ssh/ssh_config
systemctl restart sshd
[[ -e /usr/bin/git ]] || pacman -Sy --noconfirm git
#........................
key=$( dialogMenu 'Raspberry Pi' "\
Use existing keys
Generate new keys" )
if [[ $key == 1 ]]; then
#........................
	dialog $opt_msg '
 Copy saved \Z1.ssh/{aur,aur.pub}\Z0 > $dir_home
 Then \Zr OK \ZR to continue.
' 7 58
else
	mkdir -p $dir_ssh
	ssh-keygen -t rsa -f $dir_ssh/aur -q -N ""
	sed -i 's/= .*$/=/' $dir_ssh/aur.pub # remove trailing USER@HOSTNAME
#........................
	dialog $opt_msg "
AUR > My Account

\Z1SSH Public Key:\Z0
$( cat $dir_ssh/aur.pub )

\Z1PGP Key Fingerprint:\Z0 (empty)
\Z1Your current password:\Z0 (password)
" 24 58
fi
#........................
email=$( dialog $opt_input '
 \Z1Email:\Z0
' 0 0 rernrern@gmail.com )
#........................
username=$( dialog $opt_input '
 \Z1Username:\Z0
' 0 0 rern )
echo "\
[user]
	email = $email
	name = $username
" > $dir_home/.gitconfig
mkdir -p $dir_git
touch $dir_git/{attributes,ignore}
chown -R alarm:alarm $dir_home
chmod 700 $dir_ssh
chmod 600 $dir_ssh/*
sudo -u alarm git init $dir_home
echo -e "
$bar Done
"
