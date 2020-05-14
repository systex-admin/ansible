#!/bin/bash

DIR=`pwd`
TENANT_LOG=$1
PROJECT_VLAN=$2
PROJECT_DESCRIPTION=$3
PROJECT_EXT_SEGMENT_NUM=$4
PROJECT_EXT_IP_24BIT=$5
PROJECT_MANAGE_IP_24BIT=$6

default_name="_admin"

############################################
###
###     TEST
###
############################################

#if [ -f ${TENANT_LOG} ]; then
#    sudo rm -rf ${TENANT_LOG}
#fi

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
    
}

function keystone(){
    source /home/heat-admin/overcloudrc
}

function project(){
    openstack project create --description "${PROJECT_DESCRIPTION}" ${PROJECT_VLAN} --domain default
}

function user(){
    openstack user create --project ${project_name} --password rbqaGsNZhdR73Qp2bvKFQvUXw ${user_name}
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








create_openstack_tenant




