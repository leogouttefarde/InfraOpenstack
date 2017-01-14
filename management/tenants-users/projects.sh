#! /bin/bash

#
#	Creates a user ($2) associated to the project ($1) with
#	roles : SwiftOperator, heat_stack_owner
#	$1 : project
#	$2 : user
#	$3 : passwd
#
function create_user {
	project="$1"
	user="$2"
	passwd="$3"
	echo "->Creating user $user"
	openstack user create --password "$passwd" --project "$project" "$user"
	openstack role add --project "$project" --user "$user" "SwiftOperator"
	openstack role add --project "$project" --user "$user" "heat_stack_owner"
}


OLDIFS=$IFS
IFS=";"
while read -r project user1 pwd1 user2 pwd2
do
 	echo "Creating project $project"
 	openstack project create "$project"
	create_user "$project" "$user1" "$pwd1"
	create_user "$project" "$user2" "$pwd2"	
done < "users.csv"
IFS=$OLDIFS