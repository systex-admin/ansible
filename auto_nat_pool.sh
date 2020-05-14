#!/bin/bash

DIR=`pwd`
NAT_PYTHON=$1
NAT_LIST_JSON_FILE=$2
NAT_PYTHON_DIR="${DIR}/${NAT_PYTHON}"
DNAT_STR_POOL=$3
DNAT_END_POOL=$4
SNAT_STR_POOL=$5
SNAT_END_POOL=$6
#VLAN_ARRAY=""
RRIVATE_IP=""
IS_DNAT="10.24"
IS_SNAT="10.25"

if [[ $# -lt 6 ]]; then
    echo "usage: ./${0##*/} ${DIR}/nat.py nat_list.json 101 112 201 212 "
    exit 1
fi

LIMIT=`cat ${DIR}/auto_stack.log | grep "VLAN" | wc -l`

function getVLAN(){
    NUM=$(( $COUNT + 1 ))
    VLAN=`cat auto_stack.log | grep "VLAN" | awk -F ": " '{print $2}' | head -n $NUM | tail -n 1 | sed s/[[:space:]]//g`

        i=0
        while true
        do
                if [ ${i} -ge ${#VLAN_ARRAY[@]} ]; then
                        INDEX=${#VLAN_ARRAY[@]}
                        VLAN_ARRAY[${INDEX}]="${VLAN}"
                        ### TEST - SHOW VLAN ARRAY ###
                        #echo "VLAN ARRAY[${INDEX}] = ${VLAN}"
                        break
                fi

                if [ ${i} -lt ${#VLAN_ARRAY[@]} ]; then
                        if [ "${VLAN_ARRAY[${i}]}" == "${VLAN}" ]; then
                                break
                        fi
                fi

                (( i++ ))
        done
}

function getPrivateIP(){
    NUM=$(( $COUNT + 1 ))
    RRIVATE_IP=`cat auto_stack.log | grep "IP" | awk -F ": " '{print $2}' | head -n $NUM | tail -n 1`
}

function checkNAT(){
        check_nat=`echo ${RRIVATE_IP} | egrep -o "[0-9]{2}\.2[4-5]{1}"`
        retval=""
        if [ "${check_nat}" == "${IS_DNAT}" ]; then
                retval="DNAT"
        elif [ "${check_nat}" == "${IS_SNAT}" ]; then
                retval="SNAT"
        else
                                retval="FAIL"
        fi
        echo ${retval}
}

function getDNATPool(){
        pool=`echo ${RRIVATE_IP} | egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"`
                PRIVATE_COUNT=""
        if [ "${STACK_RRIVATE_IP_POOL}" != "${pool}" ]; then
                STACK_RRIVATE_IP_POOL="${pool}"
                                echo "POOL: ${pool}"
                                echo "STACK_RRIVATE_IP_POOL: ${STACK_RRIVATE_IP_POOL}"

                count=$DNAT_STR_POOL
                while true
                do
                                        if [ $count -gt ${DNAT_END_POOL} ]; then
                                                break
                                        fi

                                        if [ ${count} -le ${DNAT_END_POOL} ]; then
                                                PRIVATE_COUNT="${pool}.${count}"
                                                echo "${PRIVATE_COUNT}"
                                                echo ${count}
                                                NAT_LIST_MSG=`tmsh list ltm nat nat_${PRIVATE_COUNT} 2>&1`
                                                NAT_HAVE_MSG="inherited-traffic-group true"
                                                NAT_RESULT=$(echo $NAT_LIST_MSG | grep "${NAT_HAVE_MSG}")
                                                if [[ "${NAT_RESULT}" == "" ]] ; then
                                                        if [[ -f ${NAT_PYTHON_DIR} ]]; then
                                                                echo "VLAN: "$VLAN
                                                                python ${NAT_PYTHON_DIR} ${VLAN} ${PRIVATE_COUNT} add ${NAT_LIST_JSON_FILE}

                                                        fi
                                                else
                                                        echo "[INFO] ${PRIVATE_COUNT} IS EXIST OF NAT LIST."
                                                fi
                                        fi
                                        sleep 1
                                        (( count++ ))
                done
                else
                        echo "POOL: ${pool}"
                        echo "[INFO] STACK PRIVATE POOL HAS BEEN DUPLICATED."
        fi
        pool=""
}

function getSNATPool(){
        echo "SNAT is disable."
}

COUNT=0
while true
do
    if [ $COUNT -ge $LIMIT ]; then
        break
    fi

    if [ $COUNT -lt $LIMIT ]; then
        getVLAN
        #getPrivateIP
        is_nat=$(checkNAT)
        if [ "${is_nat}" == "DNAT" ]; then
            getDNATPool
        elif [ "${is_nat}" == "SNAT" ]; then
            getSNATPool
        else
            echo "[ERROR] CHECK ${RRIVATE_IP} SNAT OR DNAT FAIL."
        fi
        #RRIVATE_IP=""
    fi

    (( COUNT++ ))
done
