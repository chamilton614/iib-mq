#!/bin/bash

#Setup Logs directory
mkdir -p logs
read -p "CPWD is ${CPWD}"

#Get Current Scripts Directory
CPWD=`pwd`

#Install MQ
${CPWD}/mq/install_mq.sh 2>&1 | tee logs/install_mq.log

#Install IIB
${CPWD}/iib/install_iib.sh 2>&1 | tee logs/install_iib.log


