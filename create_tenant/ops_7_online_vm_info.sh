#!/bin/bash

local_path=$(pwd)
tenant_vm_info_file=${local_path}/total_vm_info.log
tenant_list_file=${local_path}/tenant_list.log
tenant_Begin=124
tenant_End=502

source /home/heat-admin/overcloudrc
openstack project list | awk -F "|" '{print $3}' | grep "_" | sed s/[[:space:]]//g > ${tenant_list_file}

if [[ -f ${tenant_vm_info_file} ]]; then
        sudo rm ${tenant_vm_info_file}
fi

echo "| ID | Name | Status | Networks | Image | Flavor |" | awk -F '|' '{printf "|%-38s|%-40s|%-8s|%-83s|%-10s\n",$2,$3,$4,$5,$6}' >> ${tenant_vm_info_file}
for ((i=$tenant_Begin; i<=$tenant_End; i++))
do
        project_name=`cat ${tenant_list_file} | grep ${i}`
        if [[ ! -z ${project_name} ]]; then
                echo "======= Show Instance into ${project_name} Tenant ======="
                openstack server list --project ${project_name}
                echo

                #openstack server list --project ${project_name} | grep " ACTIVE " >> ${tenant_vm_info_file}
                openstack server list --project ${project_name} | grep " ACTIVE " | awk -F '|' '{printf "|%-10s|%-40s|%-8s|%-55s|%-10s\n",$2,$3,$4,$5,$6}' >> ${tenant_vm_info_file}
        fi
        project_name=""
done

all_vm_count=`cat ${tenant_vm_info_file} | grep " ACTIVE " | wc -l`
echo " VM Total: ${all_vm_count}" >> ${tenant_vm_info_file}
echo "" >> ${tenant_vm_info_file}
