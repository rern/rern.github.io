#!/bin/bash

#........................
banner Wireless Regulatory Domain Codes
bar Get wireless-regdb ...
url=$( curl -sI https://kernel.org/pub/software/network/wireless-regdb | awk '/^location/ {sub(/\r/, ""); print $NF}' ) # \r must be removed
file_db=$( curl -sL $url | awk '/href="wireless-regdb/ {line=$0} END {split(line, a, "\""); print a[2]}' )
curl -sL $url/$file_db | bsdtar xf - --strip-components=1 wireless*/db.txt
codes=$( awk '/^country/ {printf "|" substr($2, 1, 2)}' db.txt )
country_code=$( jq '.["3166-1"] | sort_by(.name) | map({(.name): .alpha_2}) | add' /usr/share/iso-codes/json/iso_3166-1.json \
					| grep -E "${codes:4}" )

regdom=regdomcodes.json
file_regdom=/srv/http/assets/data/$regdom
jq <<< '{ "00 (worldwide)": "00", '${country_code:0:-1}'}' > $regdom
diff=$( diff $regdom $file_regdom )
if [[ $diff ]]; then
	mv -f $regdom $file_regdom
	changes="Changes:
$diff

\e[33m$regdom\e[0m replaced"
else
	changes='(No changes)'
fi
bar "Done
$changes
"
