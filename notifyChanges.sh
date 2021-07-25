#!/usr/bin/bash

# change volume

# a unique msg id(arbitrary)
volMsgId="991049"
brightMsgId="991050"

# set volume first

function upVolume() {
	curVol="$(pulsemixer --get-volume | cut -d' ' -f1)"
	if [ "${curVol}" -lt 100 ]; then
		if [ $((${curVol} + "$1")) -gt 100 ]; then
			pulsemixer --set-volume 100
		else
			pulsemixer --change-volume +"$1"
		fi
	fi
}

function downVolume() {
	curVol="$(pulsemixer --get-volume | cut -d' ' -f1)"
	if [ "${curVol}" -gt 0 ]; then
		if [ $((${curVol} - "$1")) -lt 0 ]; then
			pulsemixer --set-volume 0
		else
			pulsemixer --change-volume -"$1"
		fi
	fi
}

function toggleMute() {
	isMute=$(pulsemixer --get-mute)
	if [ "${isMute}" -eq 0 ]; then
		pulsemixer --mute
	else
		pulsemixer --unmute
	fi
}

function notificationForVolume() {
	volume=$(pulsemixer --get-volume | cut -d' ' -f 1)
	isMute=$(pulsemixer --get-mute)

	if [ "${volume}" -eq 0 ] || [ "${isMute}" -eq 1 ]; then
		# show notification for mute
		dunstify -a "changeVol" -i audio-volume-muted -r "$volMsgId" -t 5000 "Volume muted"
	else
		# show the volume notification
		dunstify -a "changeVol" -i audio-volume-high -r "$volMsgId" \
			--icon="~/.cache/notify-icons/speaker.png" -t 5000 \
			"Volume: ${volume}%" "$(getProgressString.sh 10 " " " " "${volume}")"
	fi
}

function notificationForLight() {
	bright=$(light -G)
	dunstify -a "changeLight" -r "$brightMsgId" \
		--icon="~/.cache/notify-icons/yellow-bulb.png" -t 5000 \
		"Brightness: ${bright}%" "$(getProgressString.sh 10 "" "——" "${bright}")"
}

function runAlertBattery() {
	while true; do
		alert_battery.sh --critical
		sleep 1
	done
}

case "$1" in
	--volume)
		case "$2" in
			--set) pulsemixer --set-volume "$3" ;;
			--up) upVolume "$3" ;;
			--down) downVolume "$3" ;;
			--toggle-mute) toggleMute ;;
		esac
		notificationForVolume ;;
	--brightness)
		case "$2" in
			# using "light" is safe that's why no conditional checking for max and min
			--set) light -S "$3";;
			--up) light -A "$3";;
			--down) light -U "$3";;
		esac
		notificationForLight ;;
	--battery)
		runAlertBattery ;;
esac
