#!/bin/bash

#Get Current Scripts Directory
CPWD=`pwd`
#read -p "CPWD is ${CPWD}"

#Cleanup IBNODE01 and QM01
mqsistop IBNODE01
endmqm QM01
mqsideletebroker IBNODE01
dltmqm QM01

#Cleanup IBNODE1 and QM1
mqsistop IBNODE1
endmqm QM1
mqsideletebroker IBNODE1
dltmqm QM1

#Kill User Processes
killall -9 -u iibuser
#killall -9 -u mqm

#Remove Users
userdel --remove iibuser
#userdel --remove mqm

#Remove Groups
groupdel mqbrkrs
groupdel mqclient
#groupdel mqm

rm -rf /opt/ibm
rm -rf /tmp/iib
rm -f /var/log/syslog
rm -rf /var/mqsi
rm -rf /var/run/syslogd.pid

iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X
iptables-save

cd ${CPWD}/iib/iib-scripts/
for f in `ls *.sh`
do
 echo "Removing /usr/local/bin/$f"
 rm -rf /usr/local/bin/$f
done
cd -

