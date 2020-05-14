#!/bin/bash

#ANSIBLE_PASS="$1"
ANSIBLE_HOST="$1"
ANSIBLE_ROOT_PATH="$2"
STACK_LOG="$3"
F5_PATH="$4"

getStack(){
    scp -o StrictHostKeyChecking=no root@${ANSIBLE_HOST}:${ANSIBLE_ROOT_PATH}/${STACK_LOG} ${F5_PATH}/
}

getStack

