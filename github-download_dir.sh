#!/bin/bash

# Download single directory from GitHub
# Usage: github_download.sh URL_TO_DIRECTORY

url=$1
user=$( cut -d/ -f4 <<< $url )
repo=$( cut -d/ -f5 <<< $url )
branch=$( cut -d/ -f7 <<< $url )
path=$( cut -d/ -f8- <<< $url )
urlcontent=https://api.github.com/repos/$user/$repo/contents/$path?ref=$branch
subdir=$( basename $path )
dirtarget=$PWD

fileGet() {
	dirtarget+=/$1
	mkdir -p $dirtarget
	
	lines=$( curl -s $urlcontent )
	types=$( grep '"type":' <<< $lines | cut -d'"' -f4 )
	names=( $( grep '"name":' <<< $lines | cut -d'"' -f4 ) )
	readarray -t download_url <<< $( grep '"download_url":' <<< $lines | cut -d'"' -f4 )
	dirs=
	i=0
	for t in $types; do
		name=${names[i]}
		if [[ $t == file ]]; then
			echo File: $name
			curl -LO ${download_url[i]} --output-dir $dirtarget
		else
			dirs+="$name "
		fi
		(( i++ ))
	done
	if [[ $dirs ]]; then
		for d in $dirs; do
			echo Subdirectory: $d
			urlcontent=${urlcontent/\?*}/$d?ref=$branch
			fileGet $d
		done
	fi
}

fileGet $subdir

echo "
Download successfully to: $subdir
"
