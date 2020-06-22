#!/usr/bin/env sh

# full screen wm workflow, by https://github.com/salman-abedin


###################
# config settings #
###################

# status bar
[ "$STATUS_BAR" ] || export STATUS_BAR=polybar

# BSPWM specific settings
top_padding=5
bspc config borderless_monocle true
bspc config gapless_monocle true

##########
# Script #
##########

mode=/tmp/cystal_0$(wmctrl -d | grep "\*" | cut -d ' ' -f 1)

case $1 in
	--navigate)
		if [ "$2" = "next" ]; then
			window=$(xdo id -rd | head -1)
		else
			#todo: previous window
			window=$(xdo id -rd | head -1)
		fi

		if [ -s "$mode" ] && xdo id -rd; then
			xdo hide
			xdo show "$window"
		else
			xdo activate "$window"
		fi
		;;

	--toggle)
		if [ -s "$mode" ]; then
			: > "$mode"
			xdo id -rd && xdo id -rd | xargs xdo show
			bspc desktop -l tiled
			if [ "$2" = "fullscreen" ]; then
				xdo show -a $STATUS_BAR
				bspc config top_padding $top_padding
			fi
		else
			echo mono > "$mode"
			xdo id -rd && xdo id -rd | xargs xdo hide
			bspc desktop -l monocle
			if [ "$2" = "fullscreen" ]; then
				xdo hide -a $STATUS_BAR
				bspc config top_padding 0
			fi
		fi
		bspc node -f prev.local
		bspc node -n biggest.local
		;;

	--close)
		xdo close
		if [ -s "$mode" ]; then
			if xdo id -rd; then
				xdo id -rd | head -1 | xargs xdo show
			else
				xdo show -a $STATUS_BAR
				bspc config top_padding $top_padding
			fi
		fi
		;;
	*) : ;;
esac
