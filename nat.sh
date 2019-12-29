#!/bin/bash

local_path=`pwd`
nat_log=${local_path}/nat.log
stack_log=${local_path}/stack.log

if [[ ! -f ${nat_log} ]]; then
        echo "[ERROR][F5] ${nat_log} FILE NOT FOUND."
        exit 1
fi

if [[ ! -f ${stack_log} ]]; then
        echo "[ERROR][F5] ${stack_log} FILE NOT FOUND."
        exit 1
fi

private_limit=`cat ${stack_log} | wc -l`
nat_range=16
count=0
num=1
while [[ ${count} -lt ${private_limit} ]]; do
        ###
        #       PRIVATE IP
        ###
        nat_private_ip=`cat ${stack_log} | head -n ${num} | tail -n 1`
        echo ${num}". nat_private_ip="$nat_private_ip
        nat_private_24bit=`cat ${stack_log} | head -n ${num} | tail -n 1 | cut -d"." -f 1-3`
        echo ${num}". nat_private_24bit="$nat_private_24bit
        nat_private_ip_header=`cat ${nat_log} | egrep -v "^$|^#" | grep "${nat_private_24bit}" | tail -n 1 | awk -F "-" '{print $1}'`
        echo ${num}". nat_private_ip_header="$nat_private_ip_header
        exit 1
        ###
        #       PUBLIC IP
        ###
        nat_public_24bit=`cat nat_map_list.log | egrep -v "^$|^#" | grep "${nat_private_24bit}" | tail -n 1 | awk -F "-" '{print $2}' | cut -d'.' -f 1-3`
        #echo ${num}". nat_public_24bit="${nat_public_24bit}
        nat_public_ip_header=`cat nat_map_list.log | egrep -v "^$|^#" | grep "${nat_private_24bit}" | tail -n 1 | awk -F "-" '{print $2}'`
        #echo ${num}". nat_public_ip_header="$nat_public_ip_header
        if [[ -z ${nat_public_24bit} ]]; then
                echo "${nat_private_24bit} not found mapping list."
                exit 1
        fi

        ip_count=0
        while [[ ${ip_count} -lt ${nat_range} ]]; do
                private_count=`echo "$nat_private_ip_header" | cut -d"." -f 4`
                value=$((10#${private_count}+${ip_count}))
                scan_private_ip=$nat_private_24bit"."$value
                #echo "pricate IP: "$nat_private_24bit"."$value
                public_count=`echo "$nat_public_ip_header" | cut -d"." -f 4`
                value2=$((10#${public_count}+${ip_count}))
                scan_public_ip=$nat_public_24bit"."$value2
                #echo "public IP: "$nat_public_24bit"."$value2

                if [[ "${nat_private_ip}" == "${scan_private_ip}" ]]; then
                        nat_name="NAT_"${nat_private_ip}
                        nat_list=`tmsh list ltm nat "${nat_name}" 2>&1`
                        chk_nat_list=`echo ${nat_list} | egrep -v "not found"`
                        if [[ ! -z ${chk_nat_list} ]]; then
                                tmsh delete ltm nat "${nat_name}" > /dev/null 2>&1
                        fi
                        tmsh create ltm nat ${nat_name} originating-address ${nat_private_ip} translation-address ${scan_public_ip}
                fi
                (( ip_count++ ))
        done
        (( count++ ))
        (( num++ ))
done

###
#   Result
###
echo ""
echo "---------------------"
echo "[Result Mapping List]"
echo "---------------------"
tmsh list ltm nat
