#!/bin/bash

#set -x

if [[ $# -ne 1 ]] 
then
    echo "usage: $0 <output_discrepancies>"
    exit 1
fi

INPUT_DISC=$1

OPENSTACK=`which openstack`

# a list of roles that the user should have in order to reassign the role 
#S_ROLES="3d45ccc2358e4d96a8dc491b0f48d2b5 ea62349431f846f1a2a0e0b8705c6ab0"

# a role that will be reassigned
ROLE_NAME="_member_"
openstack_chosen_role=`openstack role list -f value | grep $ROLE_NAME | awk {' print $1 '}`

# a list of user that have both the Stronghold roles
OUTPUT_CONF="./output_confirmed.csv"
test -f $OUTPUT_CONF && rm $OUTPUT_CONF

# go thorought the whole reference file (csv) and parse columns
OLDIFS=$IFS
IFS=","
while read user_id project_id role_id
do
    echo -e "USER: $user_id\n \
    PROJECT : $project_id\n"

    CMD_ROLES=`$OPENSTACK user role list $user_id --project $project_id -f value -c ID`
    if [[ $? -eq 0 ]] && [[ $CMD_ROLES =~ "3d45ccc2358e4d96a8dc491b0f48d2b5" ]] && [[ $CMD_ROLES =~ "ea62349431f846f1a2a0e0b8705c6ab0" ]]
    then
        echo "$user_id,$project_id,$role_id" >> $OUTPUT_CONF
        echo "I want to execute: openstack role add --user $user_id --project $project_id $openstack_chosen_role"
        read -r -p "Are you sure? [Y/n] " response
        response=${response,,} # tolower
        if [[ $response =~ ^(yes|y| ) ]]; then
            # execute the command
            echo "Executing the comand (yeah, not really)"
        fi
    fi
done < $INPUT_DISC
IFS=$OLDIFS

#set +x
