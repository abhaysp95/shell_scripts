#!/usr/bin/env bash

# make the user enter the critical level
# and check whether the critical_status function is working or not

# check for the notification id, so new notification should replace the old one
# instead of opening a new one

# TODO:
# add the functionality to detect and tell if machine is running hot

batteryMsgId="991052"

bsfile="$HOME/.cache/temp/bsfile"
if [ ! -f "${bsfile}" ]; then
	if [ ! -d "$(dirname ${bsfile})" ]; then
		mkdir -p "$(dirname ${bsfile})"
	fi
	touch "$bsfile"
	echo "0 Charged" > "${bsfile}"
fi

function get_help() {
	printf "Usage:\talert_battery.sh [Option]\n\n"
	printf "\tSupported Options:\n"
	printf "\t\t--stat:\tGives notification of Charging, Discharging,\n"
	printf "\t\t\t\tCharged and Low battery\n"
	printf "\t\t--help:\tShow this help menu\n\n"
	printf "Note:\n1. Provide no option runs the script to show only Low Battery Status\n"
	printf "2. Running the script with cron and/or some type of auto-startup uitility is recommended\n"
	printf "3. Requires some notification-daemon already running in system\n"
}

function general_status() {
	local flag=$(cut -d' ' -f 2 "${bsfile}")
	local crit_stat=$(cut -d' ' -f 3 "${bsfile}")
	if [ "${status_bat}" != "${flag}" ]; then
		if [ -z "${crit_stat}" ]; then
			echo "0 ${status_bat}" > "${bsfile}"
		else
			echo "0 ${status_bat} ${crit_stat}" > "${bsfile}"
		fi
		if [ ${status_bat} = "Discharging" ]; then
			echo "Battery is now Discharging"
			dunstify -a "batteryStat" -r "${batteryMsgId}" \
				-t 7500 -i "$HOME/.cache/notify-icons/battery_disconnected.png" \
				"Battery is now ${status_bat}" "Current level: ${capacity}"
		elif [ "${status_bat}" = "Charging" ]; then
			echo "Battery is now Charging"
			dunstify -a "batteryStat" -r "${batteryMsgId}" \
				-t 7500 -i "$HOME/.cache/notify-icons/battery_charging.png" \
				"Battery is now ${status_bat}" "Current level: ${capacity}"
		elif [ "${status_bat}" = "Full" ]; then
			echo "Battery is ${status_bat}"
			dunstify -a "batteryStat" -r "${batteryMsgId}" \
				-t 7500 -i "$HOME/.cache/notify-icons/battery_charging.png" \
				"Battery is now ${status_bat}" "Current level: ${capacity}"
		fi
	fi
}

function critical_status() {
	local crit_stat=$(cut -d' ' -f 3 "${bsfile}")
	if [ -z "${crit_stat}" ]; then
		crit_stat=30
	fi
	if [ "${capacity}" -le "${crit_stat}" ] && [ "${status_bat}" = "Discharging" ]; then
		# replace notification with charging one, so that sleep doesn't effect it's showing
		dunstify --urgency=critical -a "batteryStat" -r "${batteryMsgId}" \
			-t 10000 -i "$HOME/.cache/notify-icons/battery_low.png" \
			"Battery level, Please plug the charger" "Current Battery-level: ${capacity}%"
		count=$(cut -d' ' -f 1 ${bsfile})
		while true; do
			if [ "${status_bat}" != "Charging" ]; then
				count=$(( count + 1 ))
				echo "${count} ${status_bat} ${crit_stat}" > "${bsfile}"
				if [ "${count}" -eq 59 ]; then
					echo "0 ${status_bat}" "${crit_stat}"> "${bsfile}"
					break
				fi
				sleep 1
			fi
		done
	fi
}

for battery in /sys/class/power_supply/BAT?; do
	capacity=$(cat "${battery}"/capacity)
	status_bat=$(cat "${battery}"/status)

	case "$1" in
		--help)
			get_help
			# break ;;
			exit 0 ;;
		--stat)
			general_status
			critical_status
			# break ;;
			exit 0 ;;
		--critical)
			echo "0 some_status $2" > "${bsfile}"
			exit 0 ;;
		*)
			critical_status
			# break ;;
			exit 0 ;;
	esac
done
