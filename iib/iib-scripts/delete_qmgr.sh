#!/bin/bash
###################################
#Script Name: delete_qmgr.sh
#Created By: Prolifics
###################################

set -e

MQ_QMGR_NAME=${MQ_QMGR_NAME-QM1}
NODENAME=${NODENAME-IIBV10NODE}
SERVERNAME=${SERVERNAME-default}

echo "----------------------------------------"
echo "Stopping node $NODENAME..."
mqsistop $NODENAME
echo "----------------------------------------"
echo "Stopping node $NODENAME..."
endmqm $MQ_QMGR_NAME
# Kill the rsyslogd process
sudo kill $(cat /var/run/syslogd.pid | awk '{ print $1 }')
echo "----------------------------------------"
echo "Deleting node $MQ_QMGR_NAME..."
dltmqm $MQ_QMGR_NAME
exit
