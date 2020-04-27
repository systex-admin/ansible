#!/bin/bash

ANSIBLE_PASS="$1"
ANSIBLE_HOST="$2"
ANSIBLE_ROOT_PATH="$3"
STACK_LOG="$4"
F5_PATH="$5"

getStack(){
    sshpass -p ${ANSIBLE_PASS} scp root@${ANSIBLE_HOST}:${ANSIBLE_ROOT_PATH}/${STACK_LOG} $F5_PATH/
}

getStack

