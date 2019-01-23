#!/bin/bash

#Get Current Scripts Directory
CPWD=`pwd`
#read -p "CPWD is ${CPWD}"

#Cleanup IBNODE01 and QM01
#mqsistop IBNODE01
#endmqm QM01
#mqsideletebroker IBNODE01
#dltmqm QM01
#
#Cleanup IBNODE1 and QM1
#mqsistop IBNODE1
#endmqm QM1
#mqsideletebroker IBNODE1
#dltmqm QM1

#Kill User Processes
killall -9 -u mqm

#Remove Users
userdel --remove mqm

#Remove Groups
#groupdel mqbrkrs
#groupdel mqclient
groupdel mqm

#Remove MQ Packages
rpm -qa | grep MQSeries | xargs rpm -ev 2>&1 > /dev/null

rm -rf /home/mqm
rm -rf /opt/mqm
rm -rf /var/mqm
rm -rf /tmp/mq
rm -rf /etc/mqm/mq-config
#rm -rf /etc/init.d/iibservice
