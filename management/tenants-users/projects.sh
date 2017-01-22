#! /bin/bash

DIR=$(cd "$(dirname "$0")" && pwd)

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

#
#	Send data to the provided email adress
#	INFRA_MAILGUN_API_KEY, INFRA_MAILGUN_MAIL, INFRA_MAILGUN_API_END_POINT need to be set before calling this function
#	$1: email address		Only one email address possible
#	$2: email title
#	$3: email content 		path. File content will be 'cat' to a variable
#	$4: email attachment (optionnal)
#
function send_data_to_groups {
	address="$1"
	email_title="$2"
	email_content="$3"
	email_attachment="$4"

	if [ -z "$INFRA_MAILGUN_API_KEY" ] || [ -z "$INFRA_MAILGUN_MAIL" ]  || [ -z "$INFRA_MAILGUN_API_END_POINT" ]  ;then
        echo -n "You haven't set variables ! "
        echo "INFRA_MAILGUN_API_KEY, INFRA_MAILGUN_MAIL, INFRA_MAILGUN_API_END_POINT "
		exit
	fi;

	content=$(cat "$email_content")
	curl -s --user "api:$INFRA_MAILGUN_API_KEY" \
			"$INFRA_MAILGUN_API_END_POINT" \
		-F from="Openstack equipe infra <$INFRA_MAILGUN_MAIL>" \
		-F to="$address" \
		-F subject="$email_title" \
		-F text="$content" \
		-F attachment=@"$email_attachment"

}

#
#	WARNING: Needs keystonerc file sourced before (in order to have OS_AUTH_URL and so one)
#	WARNING: Override OS_USERNAME, OS_PASSWORD, OS_TENANT_NAME to create bastion
#	$1: Openstack login
#	$2: Openstack password
#	$3: Openstack tenant
#
function create_bastion {

	if [ -z "$INFRA_OPENSTACK_AUTH_URL" ] ;then
        echo -n "You haven't set variables ! "
        echo "INFRA_OPENSTACK_AUTH_URL"
		exit
	fi;

	user="$1"
	password="$2"
	tenant="$3"

	export OS_USERNAME="$user"                                                
	export OS_PASSWORD="$password"                                             
	export OS_TENANT_NAME="$tenant"

	rm -rf "$tenant" 2> /dev/null
	mkdir "$tenant"


	openstack stack create -t bastion.hot -e bastion_parameters.hot bastion 
	openstack stack output show bastion private_key -f value | tail -n +3 > "$tenant"/bastion.pem
	chmod 700 "$tenant"/bastion.pem
	openstack stack output show bastion bastion_ip -f value | tail -n +3 > "$tenant"/floating_ip

}

#
#	$1: Openstack login
#	$2: Openstack password
#	$3: Openstack tenant
#	$4: output dir
#
function create_keystrone_rc {
	if [ -z "$INFRA_OPENSTACK_AUTH_URL" ] ;then
        echo -n "You haven't set variables ! "
        echo "INFRA_OPENSTACK_AUTH_URL"
		exit
	fi;

	user="$1"
	password="$2"
	tenant="$3"
	output_dir="$4"

	# indent will be the same in file
	echo "
unset OS_SERVICE_TOKEN
export OS_USERNAME=$user
export OS_PASSWORD=$password
export OS_AUTH_URL=$INFRA_OPENSTACK_AUTH_URL
export PS1='[\u@\h \W(keystone_$user)]\$ '

export OS_TENANT_NAME=$tenant
export OS_REGION_NAME=region1
" > "$output_dir"/keystonerc_"$user"

}



OLDIFS=$IFS
IFS=";"
while read -r project user1 pwd1 user2 pwd2 email bastion
do
 	echo "Creating project $project"
 	openstack project create "$project"
	create_user "$project" "$user1" "$pwd1"
	create_user "$project" "$user2" "$pwd2"	
done < "$DIR"/users.csv


while read -r project user1 pwd1 user2 pwd2 email bastion
do
 	echo "Exporting info for $project"

 	output_dir=$project
	mkdir "$output_dir"
 	
 	if [ "yes" == "$bastion" ]; then
 		echo "Creating bastion"
 		create_bastion "$user1" "$pwd1" "$project"
 	fi;
 	
	create_keystrone_rc "$user1" "$pwd1" "$project" "$output_dir"
	create_keystrone_rc "$user2" "$pwd2" "$project" "$output_dir"

	tar -cf "$output_dir".tar.gz "$output_dir"

	send_data_to_groups "$email" "Nouveau compte openstack $project" "new_acount_content.txt" "$output_dir".tar.gz
done < "$DIR"/users.csv




IFS=$OLDIFS