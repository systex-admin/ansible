#!/bin/bash

# Current folder
DIR=`pwd`
NAT_PYTHON=$1
NAT_PYTHON_DIR="${pwd}/${NAT_PYTHON}"

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
while true
do
    if [ $COUNT -ge $LIMIT ]; then
        break
    fi

    if [ $COUNT -lt $LIMIT ]; then
        getVLAN
        getPrivateIP

        N=$(( $COUNT + 1 ))

        NAT_LIST_MSG=`tmsh list ltm nat nat_${RRIVATE_IP}`
        NAT_HAVE_MSG="inherited-traffic-group true"
        NAT_RESULT=$(echo $NAT_LIST_MSG | grep "${NAT_HAVE_MSG}")
        if [[ "${NAT_RESULT}" == "" ]] ; then
                if [[ -f ${NAT_PYTHON_DIR} ]]; then
                    #python ${NAT_PYTHON_DIR} ${VLAN} ${RRIVATE_IP} add nat_list.json
                    echo "VLAN: "$VLAN
                    echo "RRIVATE IP: "$RRIVATE_IP
                    python ${NAT_PYTHON_DIR} ${VLAN} ${RRIVATE_IP} show nat_list.json
                fi
        else
                echo "${RRIVATE_IP} EXIST NAT."
        fi

        echo
    fi

    (( COUNT++ ))
done
