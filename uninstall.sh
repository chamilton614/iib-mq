#!/bin/bash

#Setup Logs directory
mkdir -p logs

#Uninstall IIB
/iib/uninstall_iib.sh | tee logs/uninstall_iib.log 2>&1

#Uninstall MQ
/mq/uninstall_mq.sh | tee logs/uninstall_mq.log 2>&1


