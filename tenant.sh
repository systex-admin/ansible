#!/bin/bash

DIR=`pwd`
TENANT_LOG=$1
PROJECT_VLAN=$2
PROJECT_DESCRIPTION=$3
PROJECT_EXT_SEGMENT_NUM=$4
PROJECT_EXT_IP_24BIT=$5
PROJECT_MANAGE_IP_24BIT=$6
PROJECT_USER_PASS=$7
default_name="_admin"
DNS1="10.255.4.1"
DNS2="10.255.4.2"

############################################
###
###     TEST
###
############################################

#echo "${PROJECT_VLAN}" >> ${TENANT_LOG}
#echo "${PROJECT_DESCRIPTION}"  >> ${TENANT_LOG}
#echo "${PROJECT_EXT_SEGMENT_NUM}"  >> ${TENANT_LOG}
#echo "${PROJECT_EXT_IP_24BIT}"  >> ${TENANT_LOG}
#echo "${PROJECT_MANAGE_IP_24BIT}"  >> ${TENANT_LOG}

function create_openstack_tenant(){
    keystone
    project
    user
    role
    export OS_PROJECT_NAME=${PROJECT_VLAN}
    network
    subnets
    router
    export OS_PROJECT_NAME=admin
    keypair
    set_tenant_log
}

function keystone(){
    source /home/heat-admin/overcloudrc
}

function project(){
    openstack project create --description "${PROJECT_DESCRIPTION}" ${PROJECT_VLAN} --domain default
}

function user(){
    openstack user create --project ${PROJECT_VLAN} --password ${PROJECT_USER_PASS} "${PROJECT_VLAN}${default_name}"
}

function role(){
    openstack role add --user "${PROJECT_VLAN}${default_name}" --project "${PROJECT_VLAN}" "_member_"
    sleep 1
    openstack role add --user "admin" --project "${PROJECT_VLAN}" "_member_"
    sleep 1
    openstack role add --user "${PROJECT_VLAN}${default_name}" --project "${PROJECT_VLAN}" "admin"
    sleep 1
    openstack role add --user "admin" --project "${PROJECT_VLAN}" "admin"
    sleep 1
}

function network(){
    openstack network create ${PROJECT_VLAN}_external --external --provider-network-type vlan --provider-physical-network datacentre --provider-segment ${PROJECT_EXT_SEGMENT_NUM}
    sleep 1
    openstack network create ${PROJECT_VLAN}_manage --external --provider-network-type vlan --provider-physical-network datacentre --provider-segment 2${PROJECT_EXT_SEGMENT_NUM}
    sleep 1
    openstack network create ${PROJECT_VLAN}_tenant-external --provider-network-type vxlan
    sleep 1
    openstack network create ${PROJECT_VLAN}_tenant-manage --provider-network-type vxlan
    sleep 1
}

function subnets(){
    openstack subnet create ${PROJECT_VLAN}_external-sub --network ${PROJECT_VLAN}_external --subnet-range ${PROJECT_EXT_IP_24BIT}.0/24 --gateway ${PROJECT_EXT_IP_24BIT}.254 --allocation-pool start=${PROJECT_EXT_IP_24BIT}.1,end=${PROJECT_EXT_IP_24BIT}.6 --dhcp --ip-version 4 --dns-nameserver ${DNS1} --dns-nameserver ${DNS2}
    sleep 1
    openstack subnet create ${PROJECT_VLAN}_manage-sub --network ${PROJECT_VLAN}_manage --subnet-range ${PROJECT_MANAGE_IP_24BIT}.0/24 --gateway ${PROJECT_MANAGE_IP_24BIT}.254 --allocation-pool start=${PROJECT_MANAGE_IP_24BIT}.1,end=${PROJECT_MANAGE_IP_24BIT}.6 --dhcp --ip-version 4 --dns-nameserver ${DNS1} --dns-nameserver ${DNS2}
    sleep 1
    openstack subnet create ${PROJECT_VLAN}_tenant-external-sub --network ${PROJECT_VLAN}_tenant-external --subnet-range 10.0.0.0/24 --gateway 10.0.0.1 --allocation-pool start=10.0.0.2,end=10.0.0.254 --dhcp --ip-version 4 --dns-nameserver ${DNS1} --dns-nameserver ${DNS2}
    sleep 1
    openstack subnet create ${PROJECT_VLAN}_tenant-manage-sub --network ${PROJECT_VLAN}_tenant-manage --subnet-range 10.0.1.0/24 --gateway 10.0.1.1 --allocation-pool start=10.0.1.2,end=10.0.1.254 --dhcp --ip-version 4
    sleep 1
}

function router(){
    openstack router create ${PROJECT_VLAN}_external-router
    sleep 1
    openstack router set ${PROJECT_VLAN}_external-router --external-gateway ${PROJECT_VLAN}_external
    sleep 1
    openstack router add subnet ${PROJECT_VLAN}_external-router ${PROJECT_VLAN}_tenant-external-sub
    sleep 1

    openstack router create ${PROJECT_VLAN}_manage-router
    sleep 1
    openstack router set ${PROJECT_VLAN}_manage-router --external-gateway ${PROJECT_VLAN}_manage
    sleep 1
    openstack router add subnet ${PROJECT_VLAN}_manage-router ${PROJECT_VLAN}_tenant-manage-sub
    sleep 1
}

function keypair(){
    KEY_NAME="tyc-${PROJECT_VLAN}-admin"
    openstack keypair create --private-key ${KEY_NAME}.pem ${KEY_NAME}
    sleep 1
    chmod 600 ${KEY_NAME}.pem
    echo "Please check key: ${DIR}/${KEY_NAME}.pem "
}

function set_tenant_log(){
    if [ -f ${TENANT_LOG} ]; then
        sudo rm -rf ${TENANT_LOG}
    fi
    echo "VLAN: ${PROJECT_EXT_SEGMENT_NUM}" >> ${TENANT_LOG}
    echo "EXT_IP_STR: ${PROJECT_EXT_IP_24BIT}.101"
    echo "MANAGE_IP_STR: ${PROJECT_MANAGE_IP_24BIT}.201"
}

create_openstack_tenant

