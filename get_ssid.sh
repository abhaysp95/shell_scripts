# script written to work with slstatus (show connection name, wired and wireless)

eth="$(nmcli -t device | grep -i ethernet: | awk -F: '{print $NF}')"

if [ ! -z "${eth}" ]; then
	echo "${eth}"
	exit 0
else
	wifi="$(nmcli -t device | grep -i wifi: | awk -F: '{print $NF}')"
	if [ ! -z "${wifi}" ]; then
		echo "${wifi}"
		exit 0
	else
		echo "n/a"
	fi
fi
