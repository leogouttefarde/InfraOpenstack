#!/bin/bash

OLDIFS=$IFS
IFS=";"
while read -r url imageName
do
	name=$(basename "$url")

	echo "Downloading $imageName"
	curl -O $url &>/dev/null

	echo "Adding $imageName"
	glance --os-image-api-version 2 image-create \
					--name $imageName --disk-format qcow2 \
					--container-format bare \
					--visibility public \
					--file "$name"
done < "images.csv"
IFS=$OLDIFS

