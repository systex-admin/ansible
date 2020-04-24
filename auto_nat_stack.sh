#!/bin/bash

source /home/heat-admin/overcloudrc

# Current folder
local_path=`pwd`


function getStack(){
    STACK=`openstack stack list | egrep -v "^#|^$|^\+" | grep "CREATE_COMPLETE" | sed s/[[:space:]]//g`
    if [[ "$STACK" != "" ]]; then
        STACK
    fi
}

function getPID(){
    OSP_PID=`echo $$`
    echo $STACK > ${local_path}/tmp_${OSP_PID}.log
}

function getLimit(){
    STACK_LIMIT=`cat ${local_path}/tmp_${pid}.log | wc -l`
}

function getParameter(){
    # Floating_IP
    array_stack_id[$count]=`sed -n "${num}p" ${local_path}/tmp_${pid}.log | awk -F "|" '{print $2}'`
    ext_ip[$count]=`openstack stack show ${array_stack_id[$count]} | grep  -A1 "output_key: server1_public_ip" | sed s/[[:space:]]//g | awk -F "|" '{print $3}' | grep "output_value" | awk -F ":" '{print $2}'`



}

count=0
num=1
while [ $count -lt $STACK_LIMIT ]; do



    (( count++ ))
    (( num++ ))
done

