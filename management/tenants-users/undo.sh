#! /bin/bash

DIR=$(cd "$(dirname "$0")" && pwd)

OLDIFS=$IFS
IFS=";"
while read -r project user1 pwd1 user2 pwd2
do
 	echo "Deleting project $project"
	openstack project delete "$project"
	openstack user delete "$user1" "$user2"
done < "$DIR"/users.csv
IFS=$OLDIFS