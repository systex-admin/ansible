#!/bin/bash

script_name=$0
key_name=$1

if [[ $# -lt 1 ]]; then
        echo "usage: ${script_name} [key_name]"
        echo "Example:"
        echo "${script_name} tyc-170-tmps-admin"
        echo "error: too few arguments"
        exit 1
fi

source /home/heat-admin/overcloudrc
openstack keypair create --private-key ${key_name}.pem ${key_name}
sleep 3

chmod 600 ${key_name}.pem
