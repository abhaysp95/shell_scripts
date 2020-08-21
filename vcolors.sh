#!/usr/bin/env bash

# get the theme in file
theme_file="/tmp/vim-colorschemes"
vim_colors_file="${HOME}/.config/nvim/modules/color_settings.vim"

# update the file with latest colorschemes
function change_colorschme() {
	[ -f "${theme_file}" ] && rm "${theme_file}"

	# get the current colorscheme
	theme_in_file=$(grep -o "^colorscheme\s[-_a-zA-Z0-9]\+$" "${vim_colors_file}" | cut -d' ' -f 2)
	echo "Your current colorscheme is ${theme_in_file}"

	sleep 0.1 && echo "Choose new colorscheme: "

	# put the theme names in the file
	nvim -esc \
		"put=getcompletion('', 'color') \
		|put=globpath('~/.config/nvim/plugged/*/colors', '*.vim', 0, 1) \
		|execute('%s/.*\/\([^/]*\).vim*$/\1/')" "${theme_file}" -c wq
	scheme_name=$(cat "${theme_file}" \
		| fzf \
			--prompt "Select theme name: " \
			--border sharp \
			--height 45%)
	if [ "${scheme_name}" != "${theme_in_file}" ]; then
		sed -i -e "s/^\(colorscheme\s\)[-_[:alpha:]]\+$/\1${scheme_name}/g" "${vim_colors_file}"
		theme_in_file=$(grep -o "^colorscheme\s[-_a-zA-Z0-9]\+$" "${vim_colors_file}" | cut -d' ' -f 2)
		echo "New colorscheme set to ${theme_in_file}"
	else
		echo "${scheme_name} is already set as your default colorscheme for n/vim"
	fi
}

function set_background() {
	current_background=$(sed -n -e "s/^set\sbackground\s\?=\s\?\([dark|light]\+\)/\1/p" "${vim_colors_file}")
	if [ "${current_background}" != $1 ]; then
		sed -i -e "s/^\(set\sbackground\s\?=\s\?\)[dark|light]\+$/\1$1/g" "${vim_colors_file}"
		current_background=$(sed -n -e "s/^set\sbackground\s\?=\s\?\([dark|light]\)/\1/p" "${vim_colors_file}")
		echo "Now, background set to \"${current_background}\""
	else
		echo "You already have $1 background set"
	fi
}

function get_help() {
	cat << EOH

Usage: vcolor.sh [arguments]
	-h, --help		shows this help
	-bg, --background	changes the background between light and dark
	-c, --colorscheme	shows fzf menu containing installed colorschemes to Choose
				colorscheme from it
Note: if no argument is provided then it'll be default to changing colorscheme

EOH
}

case "$1" in
	--help|-h) get_help ;;
	-bg|--background) set_background $2 ;;
	-c|--colorscheme|'') change_colorschme ;;
	*) printf "Invalid option\tTry: --help\n" ;;
esac
