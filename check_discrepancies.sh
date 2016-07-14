#!/bin/bash

#set -x

if [[ $@ -ne 1 ]] 
then
    echo "usage: $0 <stronghold_input>"; exit 1
fi

INPUT_STRONGHOLD=$1

OPENSTACK=`which openstack`

OUTPUT_DISC="./output_discrepancies.csv"
test -f $OUTPUT_DISC && rm $OUTPUT_DISC

OLDIFS=$IFS
IFS=","
while read user_id project_id role_id
do
    echo -e "USER: $user_id\n \
    PROJECT : $project_id\n \
    ROLE : $role_id\n"

    eval `$OPENSTACK user show $user_id -f shell --prefix openstack_ | grep ^openstack_username`
    eval `$OPENSTACK project show $project_id -f shell --prefix openstack_project_ | grep ^openstack_project_name`
    eval `$OPENSTACK role show $role_id -f shell --prefix openstack_role_ | grep ^openstack_role_name`

    test -z `$OPENSTACK user role list $user_id --project $project_id | grep $role_id` && echo "$user_id,$project_id,$role_id,$openstack_username,$openstack_project_name,$openstack_role_name" >> $OUTPUT_DISC
done < $INPUT_STRONGHOLD
IFS=$OLDIFS

#set -
