```sh
pacman -Sy github-cli git-lfs

gh auth login
# ? Where do you use GitHub?
#    GitHub.com
# ? What is your preferred protocol for Git operations on this host?
#    HTTPS
# ? How would you like to authenticate GitHub CLI?
#    Login with a web browser
#    (copy one-time code > [Enter])

git config --global user.email EMAIL
git config --global user.name USER

# Git LFS - largs file system (> 100MB)
cd PATH/REPO
git lfs install
# .gitattributes
for f in qcom mellanox nvidia; do
    git lfs track linux-firmware-$f-*
done

git add .gitattributes
git commit -m LFS
git pull
git push
```