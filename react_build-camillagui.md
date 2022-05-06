React - Build `camillagui`
---

Compile for deployment

- Install
```sh
pacman -Sy npm
npm install reactjs
npm install react-app-rewired --save-dev
```

- Download source
```sh
curl -L https://github.com/HEnquist/camillagui/archive/refs/tags/v1.0.0.tar.gz | bsdtar xf -
cd camillagui-1.0.0
```

- Omit hash in filenames
```sh
cat << EOF > config-overrides.js
module.exports = function override(config, env) {
	config.output = {
		...config.output,
		filename: "static/js/[name].js",
		chunkFilename: "static/js/[name].chunk.js",
	};
	return config;
}
EOF
sed -i 's/"build":.*/"build": "react-app-rewired build",/' package.json
```

- Edit for custom css
	- `src/index.tsx`
		- Change VU meter size - `<canvas` -+ `width = '230px'`, -+`height = '40px'`
		- Omit dB marks - + `//drawDbMarkers`, + `//drawDbMarkerLabels`, + `//console.log`
		- Add Tooltip delay - `<ReactTooltip` + `delayShow={1500} delayHide={1000}`
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
ln -s /srv/http/assets build/static
rm build/precache-manifest*.js

sed -i -e 's|\(css/.*\)\..*\.chunk\.css|\1.css|g
' -e 's|\(js/.*\)\..*\.chunk\.js|\1.js|g
' build/index.html

readarray -t files <<< $( find build/static -name 2.*.* -o -name main.*.* )
for file in "${files[@]}"; do
	if [[ ${file: -3} == map ]]; then
		rm $file
		continue
	else
		sed -i -e '/sourceMappingURL/ d
' -e 's|css/\(.*\)\..*\.chunk\.css|\1.css|
' -e 's|js/\(.*\)\..*\.chunk\.js|\1.js|
' $file
	fi
	newfile=$( echo $file | sed 's/\..*\(.css\)/\1/; s/\..*\(.js\)/\1/' )
	mv $file $newfile
done
```
