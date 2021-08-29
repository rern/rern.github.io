AUR Package Upload
---

- Generate SSH key:
```sh
echo "
Host aur.archlinux.org
  IdentityFile ~/.ssh/aur
  User aur
" >> /etc/ssh/ssh_config

systemctl restart sshd

su USER
ssh-keygen -f ~/.ssh/aur
```

- Login > My Account > SSH Public Key: Content of `~/.ssh/aur.pub` without last ` USER@HOSTNAME`

- New repo:
```sh
git clone ssh://aur@aur.archlinux.org/pkgbase.git
git init
git config --global user.email "EMAIL@DOMAIN"
git config --global user.name "NAME"
git remote add REPONAME ssh://aur@aur.archlinux.org/pkgbase.git
git fetch REPONAME
cd REPONAME

# Create PKGBUILD and other files if any.
```

- Existing repo
```sh
git clone ssh://aur@aur.archlinux.org/REPONAME.git
```

- Checksum
```sh
wget https://github.com/REPO/REPONAME/archive/refs/tags/RELEASE.tar.gz
shasum -a 256 RELEASE.tar.gz

# sha256sums=( ... )
```

- Upload:
```sh
makepkg --printsrcinfo > .SRCINFO
git add PKGBUILD .SRCINFO
git commit -m "COMMIT MESSAGE"
git push
```
