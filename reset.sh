#!/bin/bash

echo "Reset IIB-MQ"

#Change to the root directory
cd /root

#Delete the existing scripts directory if it exists
if [ -d /root/iib-mq ]; then
   rm -rf iib-mq
fi

#Get the latest scripts
git clone https://github.com/chamilton614/iib-mq.git

#Update Permissions on the scripts
chmod -R 755 iib-mq

#Change to the scripts directory
cd iib-mq

#Uninstall
if [ -d /opt/ibm/ ] && [ -d /opt/mqm/ ]; then
   ./uninstall.sh
fi

#Install
if [ ! -d /opt/ibm/ ] && [ ! -d /opt/mqm/ ]; then
   ./install.sh
fi
