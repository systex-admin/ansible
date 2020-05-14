#!/bin/bash

# Example:
# openstack user create --project 170_tmps --password rbqaGsNZhdR73Qp2bvKFQvUXw 170_tmps_admin
#
script_name=$0
project_name=$1
user_name=$2

if [[ $# -lt 2 ]]; then
        echo "usage: ${script_name} [project_name] [user_name]"
        echo "Example:"
        echo "${script_name} 170_tmps 170_tmps_admin"
        echo "error: too few arguments"
        exit 1
fi

source /home/heat-admin/overcloudrc
openstack user create --project ${project_name} --password rbqaGsNZhdR73Qp2bvKFQvUXw ${user_name}
