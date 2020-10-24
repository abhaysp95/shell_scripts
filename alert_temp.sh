#!/usr/bin/bash

tpfile="$HOME/.cache/temp/tpfile"
high_temp=80

if [ ! -f "${tpfile}" ]; then
	touch "${tpfile}"
fi

# put down the temp in file
function setValue() {
	echo "${cur_temp}" > ${tpfile}
}

# print message if temp changes
function msg() {
	from_file=$(cat "${tpfile}")
	if [ "${cur_temp}" -ne ${from_file} ]; then
		if [ "${cur_temp}" -ge "${high_temp}" ]; then
			echo "Machine is getting hot"
		elif [ "${cur_temp}" -ne "${high_temp}" ] && [ "${from_file}" -ge "${high_temp}" ]; then
			echo "Machine's temp is now in control"
		else
			echo "done"
		fi
		setValue  # set latest value in file
	fi
}

function setTemp() {
	if [ -z "$1" ]; then
		echo "provide high temp value(eg., 80)"
		return
	fi
	high_temp="$1"
	echo "${high_temp}"
}

# driver function
function checkTemp() {
	cur_temp=$(sensors | grep -i 'temp1' | awk 'NR==1 {print $2}' | cut -b 2-3)
	while true; do
		msg
		sleep 1.5
	done
}

function daemonize() {
	while true; do
		nohup setsid "$0" -a 2>/dev/null &
	done
}

case "$1" in
	-a) checkTemp ;;
	-t) setTemp "$2" ;;
	-d) daemonize ;;
esac
