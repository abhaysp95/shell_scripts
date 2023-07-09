#!/bin/bash

[ -z "$1" ] && echo "usage: ltopinsta.sh <image.jpg>" && exit 1

tempimg="$(mktemp newimage.XXX.jpg)"

# blur the image
convert -resize 10% "$1" "${tempimg}"
convert -resize 1000% "${tempimg}" "${tempimg}"

# change aspect ratio
convert -gravity center -crop 9:16 "${tempimg}" "${tempimg}"

# make width change to original image (right now, it's 1920)
convert -resize 1920x "${tempimg}" "${tempimg}"

# overlay image
convert "${tempimg}" "$1" -gravity center -composite "${1%.*}_result.jpg"
