#!/bin/bash

def_url="http://images.mangafreak.net:8080/downloads/"
lfile="logfile.txt"

echo "Enter manga title:"
read -r mtitle

echo "Enter start and end index for chapters"
echo "Enter start:"
read -r start_from
echo "Enter end:"
read -r end_to

function mdownload() {
	url="${def_url}${mtitle}"
	for idx in $(seq ${start_from} ${end_to}); do
		echo "==> downloading ${mtitle}_${idx}"
		#wget -q --show-progress -O "${mtitle}_${idx}.zip" "${url}_${idx}"
		wget --show-progress -O "${mtitle}_${idx}.zip" "${url}_${idx}"
		echo "file downloaded"
		echo
	done

	printf "\n===============================================================\n\n"
}

if [ -n "$1" ] && [ "$1" = "--download" ]; then
	echo "Downloading ${mtitle}"
	mdownload
fi

delim="_"
delim_count=${mtitle//[^${delim}]}
delim_count=${#delim_count}
sort_col=$(( (delim_count + 1) * 2 + 2))

pdf_folder="${mtitle}_pdf"
[ ! -d "${pdf_folder}" ] && mkdir -p ${pdf_folder}

#unzip now
for idx in $(seq ${start_from} ${end_to}); do
	[ ! -f "${mtitle}_${idx}.zip" ] && echo "Zip file ${mtitle}_${idx}.zip not found. Skipping!!!" && continue
	folder_name="${mtitle}_${idx}"
	echo "==> creating folder ${folder_name}"
	mkdir -p "${folder_name}"
	echo "===> processing ${folder_name}"
	count=$(find ${folder_name} -type f | wc -l)
	if [ 0 -ne "${count}" ]; then
		echo "Folder not empty. Skipping unzipping. Check logfile to see names of zip not unzipped"
		echo "${mtitle}_${idx}.zip" >> "${lfile}"
		echo
		continue
	fi
	unzip "${folder_name}.zip" -d "${folder_name}" 1>/dev/null && echo "====> unzipped folder ${folder_name}"
	convert $(find "${folder_name}" -type f -iname "${mtitle}*.jpg" | sort -k "${sort_col}" -n -t "${delim}") "${pdf_folder}/${folder_name}.pdf"
	echo "==> pdf at ${pdf_folder}/${folder_name}.pdf created"
	[ -d "${folder_name}" ] && rm -r "${folder_name}" && echo "Folder ${folder_name} removed"
	echo
done
echo
echo "opertion done"
echo
