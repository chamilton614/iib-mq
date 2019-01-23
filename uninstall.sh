#!/bin/bash

#Get Current Scripts Directory
CPWD=`pwd`
#read -p "CPWD is ${CPWD}"

#Setup Logs directory
mkdir -p ${CPWD}/logs

#Uninstall IIB
if [ -e "${CPWD}/iib/uninstall_iib.sh" ]; then
	${CPWD}/iib/uninstall_iib.sh 2>&1 | tee ${CPWD}/logs/uninstall_iib.log
else
	if [ -e "${CPWD}/uninstall_iib.sh" ]; then
		${CPWD}/uninstall_iib.sh 2>&1 | tee ${CPWD}/logs/uninstall_iib.log
	else
		echo "Unable to locate uninstall_iib.sh in the path ${CPWD}"
		exit 1
	fi
fi

#Uninstall MQ
if [ -e "${CPWD}/mq/uninstall_mq.sh" ]; then
	${CPWD}/mq/uninstall_mq.sh 2>&1 | tee ${CPWD}/logs/uninstall_iib.log
else
	if [ -e "${CPWD}/uninstall_mq.sh" ]; then
		${CPWD}/uninstall_mq.sh 2>&1 | tee ${CPWD}/logs/uninstall_iib.log
	else
		echo "Unable to locate uninstall_mq.sh in the path ${CPWD}"
		exit 1
	fi
fi

echo ""
echo "Uninstall of IIB and MQ has been completed"


