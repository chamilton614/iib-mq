#!/bin/bash
# Install process for MQ and IIB
echo " "
echo "==================================="
echo "Installing MQ and IIB"
echo "==================================="
echo " "

#Get Current Scripts Directory
CPWD=`pwd`
#read -p "CPWD is ${CPWD}"

#Setup Logs directory
mkdir -p ${CPWD}/logs

#Install MQ
if [ -e "${CPWD}/mq/install_mq.sh" ]; then
	${CPWD}/mq/install_mq.sh 2>&1 | tee ${CPWD}/logs/install_mq.log
else
	if [ -e "${CPWD}/install_mq.sh" ]; then
		${CPWD}/install_mq.sh 2>&1 | tee ${CPWD}/logs/install_mq.log
	else
		echo "Unable to locate install_mq.sh in the path ${CPWD}"
		exit 1
	fi
fi

#Install IIB
if [ -e "${CPWD}/iib/install_iib.sh" ]; then
	${CPWD}/iib/install_iib.sh 2>&1 | tee ${CPWD}/logs/install_iib.log
else
	if [ -e "${CPWD}/install_iib.sh" ]; then
		${CPWD}/install_iib.sh 2>&1 | tee ${CPWD}/logs/install_iib.log
	else
		echo "Unable to locate install_iib.sh in the path ${CPWD}"
		exit 1
	fi
fi

echo " "
echo "============================================================"
echo "Install of IIB and MQ has been completed"
echo "Logout and Login for profile settings to take affect"
echo "============================================================"
echo " "
