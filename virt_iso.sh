#!/usr/bin/env bash
#
# Abhay Shanker Pathak
# abhaysp9955@gmail.com
# https://github.com/coolabhays
#
#
# guest os installation with virt-install(requires sudo privileges)

echo 'Enter guest os name'
read -r gname
echo 'Enter guest os type'
read -r gvname
echo 'Enter Os variant'
read -r ovname
echo 'Enter memory to give'
read -r ram
echo 'Enter cpu to give'
read -r cpu
echo 'Enter disk space'
read -r space
echo 'Enter Network type(NAT or bridge), for NAT enter network:default, for bridge enter bridge:<name>'
echo 'Enter network'
read -r network
echo 'Enter path of iso(after Downlods/Programs/iso_files)'
read -r iso_path


virt-install \
	--name "$gname" \
	--os-type "$gvname" \
	--memory "$ram" \
	--vcpus "$cpu" \
	--os-variant "$ovname" \
	--disk size="$space" \
	--cdrom "$HOME/Downloads/Programs/iso_files/${iso_path}" \
	--network "$network"
