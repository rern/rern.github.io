AUR Package Upload
---

### Git setup
```sh
bash <( curl -L https://github.com/rern/rern.github.io/raw/master/AUR/git_setup.sh )
```

### New / Clone repo
```sh
git clone ssh://aur@aur.archlinux.org/REPONAME.git
```

### Checksum for files
```sh
# skip
sha256sums=(SKIP)

# replace existing in PKGBUILD
#     md5sums=(...)
#     sha512sums=(...)
makepkg -g
```

### Push to repo
```sh
cd REPONAME
makepkg --printsrcinfo > .SRCINFO
git add PKGBUILD .SRCINFO OTHER_BUILD_FILES
git commit -m "COMMIT MESSAGE"
git push
```
