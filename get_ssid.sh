# script written to work with slstatus (show connection name, wired and wireless and network up/down speed)

conn_status=true

function conn_name() {
	eth_name="$(nmcli -t device | \
		awk -F: '/ethernet:/ && $3 == "connected" {print $NF}')"
	wifi_name="$(nmcli -t device | \
		awk -F: '/wifi:/ && $3 == "connected" {print $NF}')"
	if [ -n "${eth_name}" ] && [ -z "${wifi_name}" ]; then
		printf " %s" "${eth_name}"
	elif [ -n "${wifi_name}" ] && [ -z "${eth_name}" ]; then
		printf " %s" "${wifi_name}"
	elif [ -n "${wifi_name}" ] && [ -n "${eth_name}" ]; then
		printf " %s  %s" "${eth_name}" "${wifi_name}"
	else
		printf "  "
		conn_status=false
	fi
}

function speed_calc() {
	# $1 = num(rx/tx_bytes), $2 = base value
	prefix_100="B,K,M,G,T,P,E,Z,Y"
	prefix_1024="B,Ki,Mi,Gi,Ti,Pi,Ei,Zi,Yi"
	#prefix_1000=( "", "K", "M", "G", "T", "P", "E", "Z", "Y" )
	#prefix_1024=( "", "Ki", "Mi", "Gi", "Ti", "Pi", "Ei", "Zi", "Yi" )
	prefix_len=9  # change this, if you change above prefixes
	sp_value="${1}"
	scale="${sp_value}"
	base="${2}"

	case "${base}" in
		1000)
			#prefix="${prefix_1000[@]}" ;;
			prefix="${prefix_1000}" ;;
		1024)
			#prefix="${prefix_1024[@]}" ;;
			prefix="${prefix_1024}" ;;
	esac

	for (( i = 1; i <= prefix_len && scale >= base; i++ )); do
		sp_value=$(echo "scale=4; ${sp_value} / ${base}" | bc)
		scale=$(echo "${sp_value} * ${base} / ${base}" | bc)
	done

	unit="$(echo "${prefix}" | cut -d',' -f${i})"
	speed=$(printf "%.1f %s/S" "${sp_value}" "${unit}")
}

function get_speed() {
	logdir=${XDG_CACHE_HOME:-$HOME/.cache}/net
	logfile=${XDG_CACHE_HOME:-$HOME/.cache}/net/log

	[ ! -d "${logdir}" ] && \
		mkdir -p "${logdir}" && \
		touch "${logfile}"

	prevdata="$(cat "${logfile}")"

	curr_rx="$(( $(cat /sys/class/net/*/statistics/rx_bytes | paste -sd '+') ))"
	curr_tx="$(( $(cat /sys/class/net/*/statistics/tx_bytes | paste -sd '+') ))"

	#echo "curr_rx: ${curr_rx}, curr_tx: ${curr_tx}"

	use_rx="$(( curr_rx - ${prevdata%% *} ))"
	use_tx="$(( curr_tx - ${prevdata##* } ))"

	#echo "use_rx: ${use_rx}, use_tx: ${use_tx}"

	rx_update="0.0"
	if [ "${use_rx}" -gt 0 ]; then
		speed_calc "${use_rx}" "${1}"
		rx_update=" ${speed}"
	fi
	tx_update="0.0"
	if [ "${use_tx}" -gt 0 ]; then
		speed_calc "${use_tx}" "${1}"
		tx_update=" ${speed}"
	fi

	printf "%s %s" "${rx_update}" "${tx_update}"

	echo "${curr_rx} ${curr_tx}" > "${logfile}"
}

case "$1" in
	--name)
		conn_name
		printf "\n" ;;
	--speed)
		get_speed 1024
		printf "\n" ;;
	*)
		conn_name
		if "${conn_status}"; then
			printf " "
			get_speed 1024
		fi
		printf "\n" ;;
esac


#speed=""
#kib=1024
#mib=1048576
#if [ "${1}" -ge "${mib}" ]; then
	#speed=$(( ${1} / ${mib} ))
	#speed="${speed} M/s"
#elif [ "${1}" -ge "${kib}" ]; then
	#speed="$(( ${1} / ${kib} ))"
	#speed="${speed} K/s"
#else
	#speed="${speed} B/s"
#fi
#echo "${1}"
