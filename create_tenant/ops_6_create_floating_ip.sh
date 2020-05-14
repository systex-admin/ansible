#!/bin/bash

script_name=$0
project_name=$1
floating_ip_address=$2

if [[ $# -lt 2 ]]; then
        echo "usage: ${script_name} [project_name] [floating_ip_address]"
        echo "Example:"
        echo "${script_name} 124_dpps 10.241.62.101"
        echo "error: too few arguments"
        exit 1
fi

source /home/heat-admin/overcloudrc
openstack floating ip create --subnet ${project_name}_external-sub --floating-ip-address ${floating_ip_address} --project ${project_name} ${project_name}_external
