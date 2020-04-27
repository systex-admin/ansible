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

getPrivateIP(){
    NUM=$(( $COUNT + 1 ))
    RRIVATE_IP=`cat auto_stack.log | grep "IP" | awk -F ": " '{print $2}' | head -n $NUM | tail -n 1`
}


COUNT=0
#while [ $COUNT -lt $LIMIT ]; do
while true ; do
    if [ $COUNT -ge $LIMIT ]; then
        break
    fi

    if [ $COUNT -lt $LIMIT ]; then
        getVLAN
        getPrivateIP
        N=$(( $COUNT + 1 ))
        echo "[${N}]"
        #echo "P VLAN: "$VLAN
        #echo "P RRIVATE IP: "$RRIVATE_IP
        tmsh list ltm nat NAT_${RRIVATE_IP}
        echo
    fi

    (( COUNT++ ))
done


