#!/bin/bash

# echo -n "["$(date +"%H:%M")"] "
# echo -n "$(hostname)"

# if [ $PWD != ${HOME} ]; then
# 	echo -n ':'
# 	echo -n $(basename $PWD)
# fi

RB='\e[1;31m'
BB='\e[1;34m'
CB='\e[1;36m'
GB='\e[1;32m'
MB='\e[1;35m'
WB='\e[1;37m'
YB='\e[1;33m'

R='\033[0;31m'
B='\033[0;34m'
C='\033[0;36m'
G='\033[0;32m'
M='\033[0;35m'
Y='\033[0;33m'

# reset color
W='\033[0m'


# echo -e "\\e[1mOS: \\e[0;32m$(uname -ro) \\e[0m"
echo -e $WB"OS: "$G"$(uname -ro)" $W
echo -e $WB"Uptime:"$G "$(uptime -p | sed 's/^up //')" $W
echo -e $WB"Hostname: "$G"$(uname -n)" $W

echo -e $WB"Disk usage: " $W
echo -ne $(df -l -h | grep -E 'dev/(xvda|sd|mapper|nvme)' \
	| awk '{printf "\\t%s\t%4s : %4s %s\\n", $6, $3, $2, $5}' \
	| sed -e 's/^\(.*\([8][5-9]\|[9][0-9]\)%.*\)$/\\e[0;31m\1\\e[0m/' \
	-e 's/^\(.*\([7][5-9]\|[8][0-4]\)%.*\)$/\\e[0;33m\1\\e[0m/' \
	| paste -sd '')
echo

# http://tdt.rocks/linux_network_interface_naming.html
echo -e $WB"Network:" $W
echo -ne $(ip addr show up scope global \
	| grep -E ': <|inet' \
	| sed -e 's/^[[:digit:]]\+: //' \
		-e 's/: <.*//' \
		-e 's/.*inet[[:digit:]]* //' \
		-e 's/\/.*//' \
	| awk 'BEGIN {i=""} /\.|:/ {print i" "$0"\n"; next} // {i = $0}'\
	| sort \
	| column -t -R1 | \

	 # public addresses are underlined for visibility
	sed 's/ \([^ ]\+\)$/ \\e[4m\1/' | \

	# private addresses are not
	sed 's/m\(\(10\.\|172\.\(1[6-9]\|2[0-9]\|3[01]\)\|192\.168\.\).*\)/m\\e[24m\1/' | \

	# unknown interfaces are purple
	sed 's/^\( *[^ ]\+\)/\\e[35m\1/' | \

	# ethernet interfaces are normal
	sed 's/\(\(en\|em\|eth\)[^ ]* .*\)/\\e[39m\1/' | \

	# wireless interfaces are cyan
	sed 's/\(wl[^ ]* .*\)/\\e[36m\1/' | \

	# wwan interfaces are yellow
	sed 's/\(ww[^ ]* .*\)/\\e[33m\1/' | \
	sed 's/$/\\e[0m/' | sed 's/^/\t/')
echo

# set r $(random 0 100)
rand=${RANDOM}
r=$(echo "${rand} % 100" | bc)

if [ $r -lt 5 ]; then  # only rarely show backlog (5%)
	echo -e $WB" Backlog" $W
	echo -e $B " [project] <description> " $W
fi

echo
echo -e $WB"TODOs:" $W
if [ $r -lt 10 ]; then
	# unimportant, so show rarely
	echo -ne $C
	# echo "[something]"
	echo -ne $W
fi
if [ $r -lt 25 ]; then
	# back of my mind, show occasionally
	echo -ne $G
	# echo "[something]"
	echo -ne $W
fi
if [ $r -lt 50 ]; then
	# upcoming, so prompt atleast regularly
	echo -ne $Y
	# echo "[something]"
	echo -ne $W
fi
# urgent, so prompt always
echo -e $R"[something urgent]" $W

echo

if [ -s ~/todo ]; then
	echo -ne $M
	# cat ~/todo | sed 's/^/ /'
	cat ~/todo
	echo
fi
echo -ne $W
