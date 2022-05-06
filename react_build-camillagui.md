React - Build `camillagui`
---

Compile for deployment

- Install
```sh
pacman -Sy npm
node install reactjs
```

- Download source
```sh
# curl -L https://github.com/HEnquist/camillagui/archive/refs/tags/v1.0.0.tar.gz | bsdtar xf -
cd camillagui-1.0.0
```

- Edit for custom css
	- `src/index.tsx`
		- Change VU meter size - `<canvas` -+ `width = '230px'`, -+`height = '40px'`
		- Omit dB marks - + `//drawDbMarkers`, + `//drawDbMarkerLabels`, + `//console.log`
		- Add Tooltip delay - `<ReactTooltip` + `delayShow={1500}`
	- `src/compactview.tsx`
		- Add class - `className="tabpanel"` + `compactview`
	- `src/sidepanel/vumeter.tsx`
		- Add class - `TabPanel` + `class=TABNAME`

- Compile
```sh
npm run build
# result files in build directory
```

- Remove hashes from `*.css`, `*.js`
	- Consistent names in custom `index.html` across upgrades
	- On load - appended `?v=xxxxxxxxx` by js instead
```sh
rm build/precache-manifest*.js

readarray -t files <<< $( find build/static -name 2.*.* -o -name main.*.* )
for file in "${files[@]}"; do
	newfile=$( echo $file | sed 's/\..*\(.css.*\)/\1/; s/\..*\(.js.*\)/\1/' )
	mv $file $newfile
done
```
