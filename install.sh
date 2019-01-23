#!/bin/bash

#Setup Logs directory
mkdir -p logs

#Install MQ
mq/install_mq.sh 2>&1 | tee logs/install_mq.log

#Install IIB
iib/install_iib.sh 2>&1 | tee logs/install_iib.log


