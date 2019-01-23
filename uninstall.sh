#!/bin/bash

#Setup Logs directory
mkdir -p logs

#Uninstall IIB
iib/uninstall_iib.sh 2>&1 | tee logs/uninstall_iib.log

#Uninstall MQ
mq/uninstall_mq.sh 2>&1 | tee logs/uninstall_mq.log


