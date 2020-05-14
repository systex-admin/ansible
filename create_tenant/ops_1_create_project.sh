#!/bin/bash

script_name=$0
description_name=$1
project_name=$2

if [[ $# -lt 2 ]]; then
        echo "usage: ${script_name} [school_name] [project_name] "
        echo "Example:"
        echo "${script_name} 大埔國小 124_dpps"
        echo
        echo "error: too few arguments"
        exit 1
fi

source /home/heat-admin/overcloudrc
openstack project create --description "${description_name}" ${project_name} --domain default
