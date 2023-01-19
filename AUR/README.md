AUR Package Repo
---

### Git setup
```sh
# as root
bash <( curl -L https://github.com/rern/rern.github.io/raw/main/AUR/git_setup.sh )
```

### Git repo
- New / Existing
```sh
su alarm
cd
git clone ssh://aur@aur.archlinux.org/REPONAME
cd REPONAME
```

### Set checksum
- Skip: `sha256sums=(SKIP [SKIP ...])`
- Create
```sh
makepkg -g
# paste stdout in PKGBUILD
```

### Push
```sh
makepkg --printsrcinfo > .SRCINFO
git add PKGBUILD .SRCINFO [OTHER_BUILD_FILES ...]
git commit -m "MESSAGE"
git push
```
