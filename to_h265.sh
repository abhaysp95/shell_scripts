#!/bin/bash

in_dir="${HOME}/Downloads/movies/hxh"
out_dir="${HOME}/Downloads/movies/hxh_265"

[ ! -d "${in_dir}" ] && echo "input directory \"${in_dir}\" doesn't exist" && exit 1
[ ! -d "${out_dir}" ] && mkdir -p "${out_dir}"

back_ifs="${IFS}"
IFS=$'\n'

echo "enter start (like 01):"
read -r start
echo "enter end (like 11):"
read -r end

file_prefix="HXH1999 - Ep -"
file_suffix="[Dual Audio 480p 8bit x264]_soulreaperzone.mkv"

for i in $(seq "${start}" "${end}"); do
	num=$(printf "%02d" "${i}")
	echo "num: ${num}"
	file="${file_prefix} ${num} ${file_suffix}"
	echo "converting ${in_dir}/${file}"
	ffmpeg -i \
		${in_dir}/${file} \
		-c:v libx265 \
		-vtag hvc1 \
		-c:a copy \
		-c:s copy \
		"${out_dir}/$(basename ${file} | sed 's/\(.\)x264\(.\)/\1x265\2/')"
done

# for file in $(find ${in_dir} -type f | sort -n); do
# 	echo "converting ${file}"
# 	ffmpeg -i \
# 		${file} \
# 		-c:v libx265 \
# 		-vtag hvc1 \
# 		-c:a copy \
# 		-c:s copy \
# 		"${out_dir}/$(basename ${file} | sed 's/\(.\)x264\(.\)/\1x265\2/')"
# done

IFS="${back_ifs}"

echo "-----------------------"
