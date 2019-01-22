#!/bin/bash

#Setup Logs directory
mkdir -p logs

#Uninstall IIB
/iib/iib_uninstall.sh | tee logs/uninstall_iib.log 2>&1

#Uninstall MQ
/mq/mq_uninstall.sh | tee logs/uninstall_mq.log 2>&1


