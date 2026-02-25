#!/bin/bash

#........................
banner Wireless Regulatory Domain Codes
echo -e "$bar Get wireless-regdb ..."
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
iso3166=$( sed -E -n '/alpha_2_code=|\s+name=/ {
				s/^.*name=/:/
				s/^.*code=/, /
				s/ .>$//
				p
			}' /usr/share/xml/iso-codes/iso_3166.xml )
list=$( echo '{ "00 (worldwide)": "00"'$iso3166' }' \
			| jq \
			| grep -E "$codes" \
			| sed -E 's/\s*"(.*)": "(.*)",*/"\2": "\1",/' \
			| sed '/, / {s/, / (/; s/":/)":/}' )
regdom=regdomcodes.json
file_regdom=/srv/http/assets/data/$regdom
jq -S <<< "{ ${list:0:-1} }" > $regdom
changes=$( diff $regdom $file_regdom )
if [[ $changes ]]; then
	mv -f $regdom $file_regdom
	changes+="
$regdom replaced"
else
	changes='(No changes)'
fi
echo -e "
$bar Done
Changes:
$changes
"
