#!/bin/bash

# Current folder
local_path=`pwd`

# STACK LOG
#STACK_LOG="$1"

LIMIT=`cat ${local_path}/auto_stack.log | grep "VLAN" | wc -l`

getVLAN(){
    cat auto_stack.log | grep "VLAN" | awk -F ": " '{print $2}'

}


COUNT=0
while [ $COUNT -lt $LIMIT ]; do



    (( COUNT++ ))
done

