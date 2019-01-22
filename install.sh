#!/bin/bash

#Setup Logs directory
mkdir -p logs

#Install MQ
/mq/mq_install.sh | tee logs/install_mq.log 2>&1

#Install IIB
/iib/iib_install.sh | tee logs/install_iib.log 2>&1


