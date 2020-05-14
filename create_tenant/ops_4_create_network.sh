#!/bin/bash

script_name=$0
project_name=$1
provider_segment=$2
tenant_external_ip_24bit=$3
tenant_manage_ip_24bit=$4

if [[ $# -lt 4 ]]; then
        echo "----------------------"
        echo "(1) Create Network CLI"
        echo "(2) Create Subnets CLI"
        echo "(3) Create Router  CLI"
        echo "----------------------"
        echo "usage: ${script_name} [project_name] [provider_external_segment_number] [tenant_external_ip_24bit] [tenant_manage_ip_24bit]"
        echo "Example:"
        echo "${script_name} 124_dpps 124 10.241.62 10.251.62"
        echo
        echo "error: too few arguments"
        exit 1
fi

source /home/heat-admin/overcloudrc
export OS_PROJECT_NAME=${project_name}
sleep 3
openstack network create ${project_name}_external --external --provider-network-type vlan --provider-physical-network datacentre --provider-segment ${provider_segment}
sleep 1
openstack network create ${project_name}_manage --external --provider-network-type vlan --provider-physical-network datacentre --provider-segment 2${provider_segment}
sleep 1
openstack network create ${project_name}_tenant-external --provider-network-type vxlan
sleep 1
openstack network create ${project_name}_tenant-manage --provider-network-type vxlan
sleep 1

openstack subnet create ${project_name}_external-sub --network ${project_name}_external --subnet-range ${tenant_external_ip_24bit}.0/24 --gateway ${tenant_external_ip_24bit}.254 --allocation-pool start=${tenant_external_ip_24bit}.1,end=${tenant_external_ip_24bit}.6 --dhcp --ip-version 4 --dns-nameserver 10.255.4.1 --dns-nameserver 10.255.4.2
sleep 1
openstack subnet create ${project_name}_manage-sub --network ${project_name}_manage --subnet-range ${tenant_manage_ip_24bit}.0/24 --gateway ${tenant_manage_ip_24bit}.254 --allocation-pool start=${tenant_manage_ip_24bit}.101,end=${tenant_manage_ip_24bit}.116 --dhcp --ip-version 4 --dns-nameserver 10.255.4.1 --dns-nameserver 10.255.4.2
sleep 1
openstack subnet create ${project_name}_tenant-external-sub --network ${project_name}_tenant-external --subnet-range 10.0.0.0/24 --gateway 10.0.0.1 --allocation-pool start=10.0.0.2,end=10.0.0.254 --dhcp --ip-version 4 --dns-nameserver 10.255.4.1 --dns-nameserver 10.255.4.2
sleep 1
openstack subnet create ${project_name}_tenant-manage-sub --network ${project_name}_tenant-manage --subnet-range 10.0.1.0/24 --gateway 10.0.1.1 --allocation-pool start=10.0.1.2,end=10.0.1.254 --dhcp --ip-version 4
sleep 1

openstack router create ${project_name}_external-router
sleep 1
openstack router set ${project_name}_external-router --external-gateway ${project_name}_external
sleep 1
openstack router add subnet ${project_name}_external-router ${project_name}_tenant-external-sub
sleep 1

openstack router create ${project_name}_manage-router
sleep 1
openstack router set ${project_name}_manage-router --external-gateway ${project_name}_manage
sleep 1
openstack router add subnet ${project_name}_manage-router ${project_name}_tenant-manage-sub
sleep 1
