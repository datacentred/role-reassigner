#!/bin/bash

#set -x

if [[ $# -ne 1 ]]
then
    echo "usage: $0 <file_with_uuids>"
    exit 1
fi

INPUT_UUIDS=$1
OUTPUT_NAMES="./output_names_from_uuids.csv"
cp $INPUT_UUIDS $OUTPUT_NAMES

OPENSTACK=`which openstack`

# get data from the openstack command in the form of "uuid:name"
# and use it as a array simulating a Pythonish dictionary
usersmap=( `$OPENSTACK user list -f value | tr ' '  :` )
projectsmap=( `$OPENSTACK project list -f value | tr ' '  :` )
rolesmap=( `$OPENSTACK role list -f value | tr ' '  :` )

# replace UUIDs from 1st column
for item in "${usersmap[@]}"
do
    awk -v pattern=${item%%:*} -v replace=${item##*:} -v file=$OUTPUT_NAMES 'BEGIN{ FS=","; OFS="," } { gsub(pattern,replace,$1); print > file }' $OUTPUT_NAMES
done
# replace UUIDs from 2nd column
for item in "${projectsmap[@]}"
do
    awk -v pattern=${item%%:*} -v replace=${item##*:} -v file=$OUTPUT_NAMES 'BEGIN{ FS=","; OFS="," } { gsub(pattern,replace,$2); print > file }' $OUTPUT_NAMES
done
# replace UUIDs from 3rd column
for item in "${rolesmap[@]}"
do
    awk -v pattern=${item%%:*} -v replace=${item##*:} -v file=$OUTPUT_NAMES 'BEGIN{ FS=","; OFS="," } { gsub(pattern,replace,$3); print > file }' $OUTPUT_NAMES
done
