#!/bin/bash

# Current folder
DIR=`pwd`

# STACK LOG
#STACK_LOG="$1"

LIMIT=`cat ${DIR}/auto_stack.log | grep "VLAN" | wc -l`

getVLAN(){
    NUM=$(( $COUNT + 1 ))
    VLAN=`cat auto_stack.log | grep "VLAN" | awk -F ": " '{print $2}' | head -n $NUM | tail -n 1`
}

getPublicIP(){
    NUM=$(( $COUNT + 1 ))
    PUBLIC_IP=`cat auto_stack.log | grep "IP" | awk -F ": " '{print $2}' | head -n $NUM | tail -n 1`
}


COUNT=0
while [ $COUNT -lt $LIMIT ]; do
    
    getVLAN
    getPublicIP
    echo "[${COUNT}]"
    echo "P VLAN: "$VLAN
    echo "P PUBLIC IP: "$PUBLIC_IP
    echo
    
    (( COUNT++ ))
done

