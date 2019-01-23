#!/bin/bash

#Setup Logs directory
mkdir -p logs

#Get Current Scripts Directory
CPWD=`pwd`

#Install MQ
${CPWD}/mq/install_mq.sh 2>&1 | tee logs/install_mq.log

#Install IIB
${CPWD}/iib/install_iib.sh 2>&1 | tee logs/install_iib.log


