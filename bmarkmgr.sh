#!/usr/bin/env bash

mainpy=""

if [ "$1" == '-p' ] || [ "$1" == '--path' ]; then
	mainpy="$2"
	shift
	shift
else
	mainpy="/home/raytracer/Downloads/git-materials/my_repos/centralized-bookmarks/main.py"
fi

python3 "${mainpy}" $@
