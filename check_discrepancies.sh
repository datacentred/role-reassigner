#!/bin/bash

#set -x

if [[ $# -ne 1 ]] 
then
    echo "usage: $0 <stronghold_input>"
    exit 1
fi

INPUT_STRONGHOLD=$1

OPENSTACK=`which openstack`

OUTPUT_DISC="./output_discrepancies.csv"
test -f $OUTPUT_DISC && rm $OUTPUT_DISC

# go thorought the whole reference file (csv) and parse columns
OLDIFS=$IFS
IFS=","
while read user_id project_id role_id
do
    echo -e "USER: $user_id\n \
    PROJECT : $project_id\n \
    ROLE : $role_id\n"

    # check which roles are not present
    test -z `$OPENSTACK user role list $user_id --project $project_id | grep $role_id` && echo "$user_id,$project_id,$role_id" >> $OUTPUT_DISC
done < $INPUT_STRONGHOLD
IFS=$OLDIFS

#set -
