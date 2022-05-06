React - Build Project
---

Compile `camillagui` for deployment

- Install
```sh
pacman -Sy npm
node install reactjs
```

- Download source > compile
```sh
# curl -L https://github.com/HEnquist/camillagui/archive/refs/tags/v1.0.0.tar.gz | bsdtar xf -
cd camillagui-1.0.0
npm run build
```

- Remove hashes
```sh
rm build/precache-manifest*.js

readarray -t files <<< $( find build/static -name 2.*.* -o -name main.*.* )
for file in "${files[@]}"; do
	newfile=$( echo $file | sed 's/\..*\(.css.*\)/\1/; s/\..*\(.js.*\)/\1/' )
	mv $file $newfile
done
```
