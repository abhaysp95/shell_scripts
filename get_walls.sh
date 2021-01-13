#!/usr/bin/env bash

temp_wall_dir="$HOME/.cache/temp/temp_wallpapers"

[ ! -d "$temp_wall_dir" ] && echo "$temp_wall_dir" && mkdir -p "$temp_wall_dir"

maxpages=3
tag_options="#minimalism\n#cars\n#engines\n#fantasy girl\n#nature\n#linux"
if [ -z $1 ]; then
	query=$(echo -e "$tag_options" | dmenu -p "Choose tag: " -i)
	if [ -z "$query" ]; then
		notify-send -t 2500 "Exiting!!!" "No tag option selected"
		exit
	fi
else
	query=$1
fi

sort_options="date_added\nrelevance\nrandom\nviews\nfavorites\ntoplist\nhot"
sorting=$(echo -e "$sort_options" | dmenu -p "Select sort order: " -i)


query="$(sed 's/#//g' <<<$query)"
query="$(sed 's/ /+/g' <<<$query)"
echo $query

notify-send "Downloading of wallpapers started"
for page_num in $(seq 1 "$maxpages"); do
	curl -s https://wallhaven.cc/api/v1/search\?atleast\=1920x1080\&sorting\="$sorting"\&order=desc\&q\="$query"\&page\="$page_num" > ~/wall_tmp.txt
	page=$(cat ~/wall_tmp.txt | jq '.' | grep -Eoh "https:\/\/w\.wallhaven.cc\/full\/.*(jpg|jpeg|png)\b")
	echo "$page"
	wget -nc -P "$temp_wall_dir" "$page"
done

rm ~/wall_tmp.txt
notify-send "Downloading finished"
sxiv -t $walldir/*
mv "$temp_wall_dir"/* ~/Pictures/
