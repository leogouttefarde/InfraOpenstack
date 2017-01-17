#!/bin/bash

DIR=$(cd "$(dirname "$0")" && pwd)

OLDIFS=$IFS
IFS=";"
while read -r url imageName imageType
do
	name=$(basename "$url")

	echo "Downloading $imageName"
	curl -O $url &>/dev/null

	echo "Adding $imageName"
	glance --os-image-api-version 2 image-create \
					--name $imageName --disk-format $imageType \
					--container-format bare \
					--visibility public \
					--file "$name"

done < "$DIR"/images.csv
IFS=$OLDIFS

