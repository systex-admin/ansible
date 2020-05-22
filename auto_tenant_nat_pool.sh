#!/bin/bash

DIR=`pwd`
NAT_PYTHON=$1
NAT_LIST_JSON_FILE=$2
NAT_PYTHON_DIR="${DIR}/${NAT_PYTHON}"
OSP_LOG=$3
DNAT_STR_POOL=$4
DNAT_END_POOL=$5
SNAT_STR_POOL=$6
SNAT_END_POOL=$7
INDEX=0
IS_DNAT="10.24"
IS_SNAT="10.25"

if [[ $# -lt 7 ]]; then
    echo "usage: ./${0##*/} ${DIR}/nat.py nat_list.json auto_stack.log 101 112 201 212 "
    exit 1
fi

LIMIT=`cat ${DIR}/${OSP_LOG} | grep "VLAN" | wc -l`

function getEXTPOOL(){
    NUM=$(( $COUNT + 1 ))
    EXT_POOL=`cat ${OSP_LOG} | grep "EXT_POOL" | awk -F ": " '{print $2}' | head -n $NUM | tail -n 1`
    pool=`echo ${EXT_POOL} | egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"`
    EXT_POOL_ARRAY[${INDEX}]="${pool}"

}

function checkNAT(){
    check_nat=`echo ${EXT_POOL_ARRAY[${INDEX}]} | egrep -o "[0-9]{2}\.2[4-5]{1}"`
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
    PRIVATE_COUNT=""
        count=$DNAT_STR_POOL
        while true
        do
            if [ $count -gt ${DNAT_END_POOL} ]; then
                break
            fi

            if [ ${count} -le ${DNAT_END_POOL} ]; then
                PRIVATE_COUNT="${EXT_POOL_ARRAY[${INDEX}]}.${count}"
                NAT_LIST_MSG=`tmsh list ltm nat nat_${PRIVATE_COUNT} 2>&1`
                NAT_HAVE_MSG="inherited-traffic-group true"
                NAT_RESULT=$(echo $NAT_LIST_MSG | grep "${NAT_HAVE_MSG}")
                echo "NAT_RESULT=${NAT_RESULT}"
                if [[ "${NAT_RESULT}" == "" ]] ; then
                    if [[ -f ${NAT_PYTHON_DIR} ]]; then
                        python ${NAT_PYTHON_DIR} ${VLAN} ${PRIVATE_COUNT} add ${NAT_LIST_JSON_FILE}
                    fi
                else
                    echo "[INFO] VLAN: \"${VLAN}\" ,PRIVATE IP: \"${PRIVATE_COUNT}\" ALREADY EXIST IN THE F5 NAT LIST."
                fi
            fi
            (( count++ ))
        done
}

function getSNATPool(){
    echo "SNAT is disable."
}

function getVLAN(){
    NUM=$(( $COUNT + 1 ))
    VLAN=`cat ${OSP_LOG} | grep "VLAN" | awk -F ": " '{print $2}' | head -n $NUM | tail -n 1 | sed s/[[:space:]]//g`

    i=0
    while true
    do
        if [ ${i} -ge ${#VLAN_ARRAY[@]} ]; then
            INDEX=${#VLAN_ARRAY[@]}
            VLAN_ARRAY[${INDEX}]="${VLAN}"
            getEXTPOOL
            is_nat=$(checkNAT)
            if [ "${is_nat}" == "DNAT" ]; then
                getDNATPool
            elif [ "${is_nat}" == "SNAT" ]; then
                getSNATPool
            else
                echo "[ERROR] CHECK ${EXT_POOL} SNAT OR DNAT FAIL."
                exit 1
            fi
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

COUNT=0
while true
do
    if [ $COUNT -ge $LIMIT ]; then
        break
    fi

    if [ $COUNT -lt $LIMIT ]; then
        getVLAN
    fi

    (( COUNT++ ))
done
