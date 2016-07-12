#!/bin/bash

# A script to reassign a role to all the user-tenant relationships.

set -x

# a role that will be reassigned
ROLE_NAME="_member_"
openstack_chosen_role=`openstack role list -f value | grep $ROLE_NAME | awk {' print $1 '}`
test -z $openstack_chosen_role && echo "ERROR: There is no role to assign. Exiting..." && exit
test `echo $openstack_chosen_role | wc -l` -ne 1 && echo "ERROR: Expecting a single vaule, instead got: $openstack_chosen_role. Exiting..." && exit

# get all the users (together with the system ones like `nova`, `glance`, etc.)
openstack_users=`openstack user list --column ID -f value`

for user in $openstack_users
do
	# make sure variables for user id and project id are not set
	unset openstack_id
	unset openstack_project_id
	# gets both user id and project id
	# and sets them into variables with "openstack_" prefix
	eval `openstack user show $user -f shell --prefix openstack_ | grep id`
	openstack_user_name=`openstack user list -f value | grep $openstack_id | awk {' print $2 '}`
	echo "DEBUG: Current user id is $openstack_id ($openstack_user_name)."
	# check if variables are not empty
	test $user != $openstack_id && echo "ERROR: User id $user differs from this from the openstack command $openstack_id" && exit
	if [[ -z $openstack_project_id ]]
	then
		echo "WARNING: User $openstack_id ($openstack_user_name) is not assigned to a project (this can be OK for users like nova). Skipping..."
	else
		# check if the user has a role assigned already
		if [[ -n  `openstack user role list $openstack_id --project $openstack_project_id | grep $openstack_chosen_role` ]]
		then
			echo "WARNING: User $openstack_id ($openstack_user_name) has the role $openstack_chosen_role assigned already within project $openstack_project_id. Skipping..."
		else
			openstack role add --user $openstack_id --project $openstack_project_id $openstack_chosen_role
		fi
	fi
done

set +
