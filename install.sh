#!/bin/bash

#Get Current Scripts Directory
CPWD=`pwd`
#read -p "CPWD is ${CPWD}"

#Setup Logs directory
mkdir -p ${CPWD}/logs

#Install MQ
${CPWD}/mq/install_mq.sh 2>&1 | tee logs/install_mq.log

#Install IIB
${CPWD}/iib/install_iib.sh 2>&1 | tee logs/install_iib.log


