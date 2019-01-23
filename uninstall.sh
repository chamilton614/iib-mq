#!/bin/bash

#Get Current Scripts Directory
CPWD=`pwd`
#read -p "CPWD is ${CPWD}"

#Setup Logs directory
mkdir -p ${CPWD}/logs

#Uninstall IIB
${CPWD}/iib/uninstall_iib.sh 2>&1 | tee ${CPWD}/logs/uninstall_iib.log

#Uninstall MQ
${CPWD}/mq/uninstall_mq.sh 2>&1 | tee ${CPWD}/logs/uninstall_mq.log


