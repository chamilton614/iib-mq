#!/bin/bash
###################################
#Script Name: start_node.sh
#Created By: Prolifics
###################################

set -e

MQ_QMGR_NAME=${MQ_QMGR_NAME-QM1}
NODENAME=${NODENAME-IIBV10NODE}
SERVERNAME=${SERVERNAME-default}

echo "----------------------------------------"
echo "Starting queue manager $MQ_QMGR_NAME"
strmqm ${MQ_QMGR_NAME}
echo "----------------------------------------"

echo "----------------------------------------"
echo "Starting syslog"
sudo /usr/sbin/rsyslogd
echo "Starting node $NODENAME"
mqsistart $NODENAME
echo "----------------------------------------" 
exit
