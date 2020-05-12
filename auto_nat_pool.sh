#!/bin/bash

# Current folder
DIR=`pwd`
NAT_PYTHON=$1
NAT_LIST_JSON_FILE=$2
NAT_PYTHON_DIR="${DIR}/${NAT_PYTHON}"
DNAT_STR_POOL=$3
DNAT_END_POOL=$4
SNAT_STR_POOL=$5
SNAT_END_POOL=$6
RRIVATE_IP=""
RRIVATE_IP_POOL=""
IS_DNAT="10.24"
IS_SNAT="10.25"


# STACK LOG
#STACK_LOG="$1"
if [[ $# -lt 6 ]]; then
    echo "usage: ./${0##*/} ${DIR}/nat.py nat_list.json 101 112 201 212 "
    exit 1
fi

LIMIT=`cat ${DIR}/auto_stack.log | grep "VLAN" | wc -l`

function getVLAN(){
    NUM=$(( $COUNT + 1 ))
    VLAN=`cat auto_stack.log | grep "VLAN" | awk -F ": " '{print $2}' | head -n $NUM | tail -n 1`
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
        private_ip_count=""

        if [ "${RRIVATE_IP_POOL}" != "${pool}" ]; then
                RRIVATE_IP_POOL="${pool}"
                count=$DNAT_STR_POOL
                while true
                do
                        if [ $count -gt ${DNAT_END_POOL} ]; then
                                break
                        fi

                        if [ ${count} -le ${DNAT_END_POOL} ]; then
                                private_ip_count="${pool}.${count}"
                                echo "${private_ip_count}"
                                echo ${count}
                                NAT_LIST_MSG=`tmsh list ltm nat nat_${RRIVATE_IP} 2>&1`
                                NAT_HAVE_MSG="inherited-traffic-group true"
                                NAT_RESULT=$(echo $NAT_LIST_MSG | grep "${NAT_HAVE_MSG}")
                                if [[ "${NAT_RESULT}" == "" ]] ; then
                                        if [[ -f ${NAT_PYTHON_DIR} ]]; then
                                                echo "VLAN: "$VLAN
                                                python ${NAT_PYTHON_DIR} ${VLAN} ${RRIVATE_IP} add ${NAT_LIST_JSON_FILE}

                                        fi
                                else
                                        echo "[INFO] ${RRIVATE_IP} IS EXIST OF NAT LIST."
                                fi
                        fi
                        sleep 1
                        (( count++ ))
                done
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
        getPrivateIP
                is_nat=$(checkNAT)
                if [ "${is_nat}" == "DNAT" ]; then
                        getDNATPool
                elif [ "${is_nat}" == "SNAT" ]; then
                        getSNATPool
                else
                        echo "[ERROR] CHECK ${RRIVATE_IP} SNAT OR DNAT FAIL."
                fi

                RRIVATE_IP=""
    fi

    (( COUNT++ ))
done
