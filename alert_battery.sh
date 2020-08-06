#!/usr/bin/env bash

for battery in /sys/class/power_supply/BAT?; do
	capacity=$(cat "${battery}"/capacity)
	status_bat=$(cat "${battery}"/status)

	if [ "${capacity}" -le 30 ] && [ "${status_bat}" = "Discharging" ]; then
		notify-send --urgency=critical -t 10000 -i "$HOME/.cache/notify-icons/battery.png" "Battery level, Please plug the charger" "Current Battery-level: ${capacity}%"
	fi
done
