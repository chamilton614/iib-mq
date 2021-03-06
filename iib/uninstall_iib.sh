#!/bin/bash
# Uninstall process for IIB
echo " "
echo "==================================="
echo "Uninstalling IIB"
echo "==================================="
echo " "

#Get Current Scripts Directory
CPWD=`pwd`
#read -p "CPWD is ${CPWD}"

export IIB_VERSION=10.0.0.15

#Cleanup IBNODE01 and QM01
mqsistop IBNODE01
endmqm QM01
mqsideletebroker IBNODE01
dltmqm QM01

#Cleanup IIBV10NODE1 and QM1
mqsistop IIBV10NODE
endmqm QM1
mqsideletebroker IIBV10NODE
dltmqm QM1

#Kill User Processes
killall -u iibuser
killall -u iibmquser
#killall -9 -u mqm

#Remove Users
userdel --remove iibuser
#userdel --remove mqm

#Remove root from groups
gpasswd -d root mqbrkrs
gpasswd -d root mqclient

#Remove Groups
groupdel mqbrkrs
groupdel iibuser

echo "Cleaning .bash_profile"
sed -i '/export LICENSE=accept/d' /root/.bash_profile
sed -i "s/:\/opt\/ibm\/iib-.*\/server\/bin//g" /root/.bash_profile
sed -i '/source \/opt\/mqm\/bin\/setmqenv -s/d' /root/.bash_profile
sed -i '/source \/opt\/ibm\/iib-/d' /root/.bash_profile

#Source the root profile to load the necessary variables
echo "Source /root/.bash_profile"
source /root/.bash_profile

# Clean up all the downloaded files
rm -rf /tmp/iib/
rm -f /tmp/iib-*

rm -rf /home/iibmquser
rm -rf /opt/ibm
rm -f /var/log/syslog
rm -rf /var/mqsi

#rm -rf /var/run/syslogd.pid

# Kill the rsyslogd process
if [ -e /var/run/syslogd.pid ]; then
	sudo kill $(cat /var/run/syslogd.pid | awk '{ print $1 }')
fi

iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X
iptables-save

#Check Path
if [ -d "${CPWD}/iib/iib-scripts/" ]; then
	cd ${CPWD}/iib/iib-scripts/
else
	if [ -d "${CPWD}/iib-scripts/" ]; then
		cd ${CPWD}/iib-scripts/
	else
		echo "Unable to locate iib-scripts from the path ${CPWD}"
		exit
	fi
fi

#Remove the iib-scripts copied to /usr/local/bin
for f in `ls *.sh`
do
 echo "Removing /usr/local/bin/$f"
 rm -rf /usr/local/bin/$f
done

echo " "
echo "============================================================"
echo "Uninstall of IIB has been completed"
echo "Logout and Login for profile settings to take affect"
echo "============================================================"
echo " "

