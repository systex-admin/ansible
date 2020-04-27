#!/bin/bash

STACK_LOG_PATH="$1"

ANSIBLE_ROOT_PATH="$2"
chown -R root:root ${STACK_LOG_PATH}
sudo cp ${STACK_LOG_PATH} ${ANSIBLE_ROOT_PATH}

