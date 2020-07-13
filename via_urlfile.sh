#!/usr/bin/env sh

# download multiple files via curl

oldifs=$IFS

if [ "$1" = "-h" ]; then
	printf "Usage:\t./via_urlfile.sh {url_file}\n"
	printf "\t-h:\t\tshow help\n"
	printf "\turl_file:\t\ta file with only url stored in it\n"
	exit 0
fi

if [ -z "$1" ]; then
	printf "provide a url file as argument\n"
	exit 1
fi

echo "Reading File..."
url_file="$1"
lines="$(wc -l "${url_file}" | cut -d' ' -f1)"

# either using curl -O <url> to automatically get the filename with extension
# or use wget, I'm using wget

# to read file line by line, -r to prevent backslash escape
while IFS= read -r line; do
	if wget -q --show-progress "${line}"; then
		echo "Download Complete"
	fi
	echo
	if [ "${lines}" -ge 1 ]; then
		echo "Downloading Next File"
		lines=$(( lines - 1 ))
	fi
done < "${url_file}"

echo "Downlaoding Done"
IFS=$oldifs
