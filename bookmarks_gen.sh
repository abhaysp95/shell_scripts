#!/usr/bin/env sh

# wrapper script for bookmarks_gen.py

# both of the script files are already in path


bfile="$HOME/.config/bookmarks"

urls=$(cut -d' ' -f 2- "${bfile}" | tail -n +2 | head --bytes -2)

open_url() {
	got_url=$(bookmarks_gen.py --get "$1")
	if [ "$BROWSER" = "qutebroswer" ]; then
		nohup "$BROWSER" --target=tab "${got_url}" &
	else
		nohup "$BROWSER" "${got_url}" &
	fi
	notify-send -t 2000 "Opening Url:" "${selected_url}"
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	bookmarks_gen.py --help shell
	exit 0
elif [ "$1" = "--update" ]; then
	bookmarks_gen.py --update
	exit 0
elif [ "$1" = "--rofi" ]; then
	selected_url=$(echo "${urls[@]}" | rofi -dmenu -p "Select URL: ")
	open_url "${selected_url}"
elif [ "$1" = "--fzf" ] || [ "$1" = "" ]; then
	selected_url=$(echo "${urls[@]}" | fzf \
		--prompt "Select URL: " \
		--border sharp \
		--height 55%)
	open_url "${selected_url}"
else
	echo "ERROR!"
	echo "Try: bookmarks_gen.sh --help"
	exit 2
fi
