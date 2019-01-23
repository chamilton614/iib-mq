#!/bin/bash

#Setup Logs directory
mkdir -p logs

#Get Current Scripts Directory
CPWD=`pwd`

#Uninstall IIB
${CPWD}/iib/uninstall_iib.sh 2>&1 | tee logs/uninstall_iib.log

#Uninstall MQ
${CPWD}/mq/uninstall_mq.sh 2>&1 | tee logs/uninstall_mq.log


