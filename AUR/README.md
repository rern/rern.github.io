AUR Package Repo
---

### Git setup
```sh
bash <( curl -L https://github.com/rern/rern.github.io/raw/master/AUR/git_setup.sh )
```

### New / Clone
```sh
su alarm
cd
git clone ssh://aur@aur.archlinux.org/REPONAME.git
cd REPONAME
```

### Set checksum
```sh
# skip: chksum='sha256sums=(SKIP)'
chksum=$( makepkg -g )
sed -i "s/^sha.*/$chksum/" PKGBUILD
```

### Push
```sh
makepkg --printsrcinfo > .SRCINFO
git add PKGBUILD .SRCINFO OTHER_BUILD_FILES
git commit -m "COMMIT MESSAGE"
git push
```