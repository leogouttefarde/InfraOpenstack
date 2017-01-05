#! /bin/bash

OLDIFS=$IFS
IFS=";"
while read -r project user1 pwd1 user2 pwd2
do
 	echo "Creating project $project for $user1 and $user2"
	openstack project create "$project"
	openstack user create --password "$pwd1" --project "$project" "$user1"
	openstack user create --password "$pwd2" --project "$project" "$user2"
done < "users.csv"
IFS=$OLDIFS