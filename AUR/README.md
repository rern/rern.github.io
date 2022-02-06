AUR Package Upload
---

### Git setup
```sh
su alarm
bash <( curl -L https://github.com/rern/rern.github.io/raw/master/AUR/git_setup.sh )
```

### New / Clone repo
```sh
git clone ssh://aur@aur.archlinux.org/REPONAME.git
```

### Checksum for files
```sh
makepkg -g # Replace existing in PKGBUILD
```
(Skip: `sha256sums=(SKIP)`)

### Push to repo
```sh
cd /home/alarm/REPONAME
makepkg --printsrcinfo > .SRCINFO
git add PKGBUILD .SRCINFO OTHER_BUILD_FILES
git commit -m "COMMIT MESSAGE"
git push
```
