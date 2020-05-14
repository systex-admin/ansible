#!/bin/bash

script_name=$0
user_name=$1
project_name=$2
project_member_name=$3

if [[ $# -lt 3 ]]; then
        echo "usage: ${script_name} [user_name] [project_name] [project_member_name <\"_member_\", \"admin\">]"
        echo "Example:"
        echo "You need to add two members \"member\" and \"admin\""
        echo "${script_name} 124_dpps_admin 124_dpps \"_member_\""
        echo "${script_name} admin 124_dpps \"_member_\""
        echo "and"
        echo "${script_name} 124_dpps_admin 124_dpps \"admin\""
        echo "${script_name} admin 124_dpps \"admin\""
        echo
        echo "error: too few arguments"
        exit 1
fi

source /home/heat-admin/overcloudrc
openstack role add --user ${user_name} --project ${project_name} ${project_member_name}
