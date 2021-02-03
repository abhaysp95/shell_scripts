#!/usr/bin/env sh

#form="\n<b>Artist:</b>\t<span color='##a1b56c'>%artist%</span>\n<b>Album:</b>\t<span color='##6a9fb5'>%album%</span>\n<b>Title:</b><span color='##ac4142'>%title%</span>"

# TODO:

# add progress time beside progress bar, with real time change in finished seconds
# a idea can be to check the change in title

musicMsgId="991051"

#function songLength() {
#total_length=$(mpc | awk 'NR==2 {print $3}' | cut -d'/' -f2)
#mins=$(echo "${total_length}" | cut -d':' -f1)
#secs=$(echo "${total_length}" | cut -d':' -f2)
#total_secs=$(("${mins}" * 60 + ${secs}))
#echo "${total_secs}"
#}

while true
do
	mpc idle player

	#tot_len="$(songLength)"
	cur_len="$(mpc | awk 'NR==2 {print $4}' | cut -d'(' -f2 | cut -d')' -f1 | cut -d'%' -f1)"

	if [ -z "$(mpc current -f %album%)" ] && [ -z "$(mpc current -f %artist%)" ] \
		&& [ -z "$(mpc current -f %title%)" ]
		then
			toprint="$(mpc | head -n 1)"
		elif [ -z "$(mpc current -f %album%)" ] && [ -z "$(mpc current -f %artist%)" ]
		then
			form="$(printf "Title: %s" "%title%")"
			toprint="$(mpc current -f "$form")"
		elif [ -z "$(mpc current -f %album%)" ]
		then
			form="$(printf "Artist: %s\nTitle: %s" "%artist%" "%title%")"
			toprint="$(mpc current -f "$form")"
		else
			form="$(printf "Album: %s\nArtist: %s\nTitle: %s" "%album%" "%artist%" "%title%")"
			toprint="$(mpc current -f "$form")"
	fi

	echo "$toprint"

	status=$(mpc | awk 'NR==2 {print $1}' | cut -d'[' -f2 | cut -d']' -f1)

	# printf "Current Song %s\n%s\n%s" "${toprint}" "Status: ${status}" "Time Elapsed: $(mpc | awk 'NR==2 {print $3"  "$4}')"

	dunstify -a "music_change" -t 3000 -r "${musicMsgId}" \
		-i ~/.cache/notify-icons/music-note.png \
		"Current Song" "$(printf "%s\n%s\n%s" "${toprint}" "<b>Status:</b> ${status}" "<b>Time Elapsed:</b> $(mpc | awk 'NR==2 {print $3"  "$4}')")"
done

#"Current Song" "$(printf "%s\n%s\n%s" "${toprint}" "<b>Status:</b> ${status}" "$(getProgressString.sh 50 "=" "—" ${cur_len})")"
