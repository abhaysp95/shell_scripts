#!/bin/bash

echo "Getting total size of all docker containers..."

file_saved="/tmp/current_docker_images"
docker images > "${file_saved}"

# get images count
img_count="$(wc -l "${file_saved}" | cut -d' ' -f 1)"

total_size=0
while [ "${img_count}" -gt 1 ]; do

	# get the size of image with unit
	size_unit=$(awk -v img_count="$img_count" 'NR==img_count {print $7}' "${file_saved}")

	# get size without unit
	size_num=$(echo "${size_unit}" | grep -o "[0-9]\+\.\?[0-9]*")

	# get only unit
	unit=$(echo "${size_unit}" | grep -o "[a-zA-Z]\+$")

	# get size in KB(probably lowest size for a docker image)
	if [ "${unit}" = "MB" ]; then
		#printf "%.10f" "$(( 10.5 / 3 ))" can be used if you want to print
		size_in_KB="$(bc <<< "scale=3; ${size_num} * 1024")"
	fi

	# get total size in kb
	total_size="$(bc <<< "scale=3; ${total_size} + ${size_in_KB}")"
	img_count=$(( img_count - 1 ))
done

# leave unsignificant numbers
# if doesn't compares floating numbers
total_size="${total_size%%.*}"

# print in human readable format
printf "Total size is:\t"
if [ "${total_size}" -ge 1024 ]; then
	if [ "${total_size}" -ge "$(( 1024**2 ))" ]; then
		#printf "%.2fGB\n" "$(( total_size / 1024**2 ))"  isn't showing float
		#bc doesn't support exponential in **
		printf "%.2f GB\n" "$(bc <<< "scale=3; ${total_size} / (1024 ^ 2)")"
	else
		printf "%.2f MB\n" "$(bc <<< "scale=3; ${total_size} / 1024")"
	fi
else
	printf "%.2f KB\n" "${total_size}"
fi

rm /tmp/current_docker_images  # delete the file as it's not needed
