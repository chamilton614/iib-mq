#!/bin/bash

#Setup Logs directory
mkdir -p logs

#Install MQ
/mq/install_mq.sh | tee logs/install_mq.log 2>&1

#Install IIB
/iib/install_iib.sh | tee logs/install_iib.log 2>&1


