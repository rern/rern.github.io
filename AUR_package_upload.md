AUR Package Upload
---

### Prepare SSH
- If already done, skip to **New / Clone repo**
```sh
# ssh
echo "
Host aur.archlinux.org
  IdentityFile ~/.ssh/aur
  User aur
" >> /etc/ssh/ssh_config

systemctl restart sshd

pacman -Sy --needed git

# ssh key
su USER
git init
git config --global user.email "EMAIL@DOMAIN"
git config --global user.name "NAME"

ssh-keygen -f ~/.ssh/aur
cat ~/.ssh/aur.pub
```
- AUR Login > My Account > SSH Public Key - Paste content of `~/.ssh/aur.pub` without last ` USER@HOSTNAME`
- Fill `Your current password:`
- If autofill password, make sure `PGP Key Fingerprint:` box is empty.

### New / Clone repo
```sh
git clone ssh://aur@aur.archlinux.org/REPONAME.git
```

### Checksum source
```sh
# skip
sha256sums=(SKIP)

# replace existing in PKGBUILD
#     md5sums=(...)
#     sha512sums=(...)
makepkg -g

# remove ./src and source files
```

### Push repo
```sh
cd REPONAME
makepkg --printsrcinfo > .SRCINFO
git add PKGBUILD .SRCINFO OTHER.FILES
git commit -m "COMMIT MESSAGE"
git push
```
