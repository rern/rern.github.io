#!/bin/bash

echo "Get wireless-regdb ..."
url=https://kernel.org/pub/software/network/wireless-regdb
file=$( curl -skL $url \
			| tail -3 \
			| head -1 \
			| cut -d'"' -f2 )
curl -skL $url/$file | bsdtar xf - wireless-regdb*/db.txt
codes=$( grep ^country wireless-regdb*/db.txt \
			| cut -d' ' -f2 \
			| tr -d : \
			| xargs \
			| tr ' ' '|' )
iso3166=$( sed -E -n '/alpha_2_code=|\s+name=/ {s/^.*name=/:/; s/^.*code=/, /; s/ .>$//; p}' /usr/share/xml/iso-codes/iso_3166.xml )
list=$( echo '{ "00": "00"'$iso3166' }' \
			| jq \
			| grep -E "$codes" \
			| sed -E 's/\s*"(.*)": "(.*)",*/"\2": "\1",/' \
			| sed '/, / {s/, / (/; s/":/)":/}' )
jq -S <<< "{ ${list:0:-1} }" > regdomcodes.json
file=/srv/http/assets/data/regdomcodes.json
changes="
$file:
"
d=$( diff regdomcodes.json $file )
[[ $d ]] && changes+=$d || changes+='(No changes)'
echo "$changes"
