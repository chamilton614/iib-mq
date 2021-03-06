#!/bin/bash
# Uninstall process for MQ
echo " "
echo "==================================="
echo "Uninstalling MQ"
echo "==================================="
echo " "

#Get Current Scripts Directory
CPWD=`pwd`
#read -p "CPWD is ${CPWD}"

#Cleanup IBNODE01 and QM01
#mqsistop IBNODE01
#endmqm QM01
#mqsideletebroker IBNODE01
#dltmqm QM01
#
#Cleanup IIBV10NODE1 and QM1
#mqsistop IIBV10NODE1
#endmqm QM1
#mqsideletebroker IIBV10NODE1
#dltmqm QM1

#Kill User Processes
killall -u mqm

#Remove Users
userdel --remove mqm

#Remove root from mqm
gpasswd -d root mqm

#Remove Groups
#groupdel mqbrkrs
groupdel mqclient
groupdel mqm

echo "Cleaning .bash_profile"
sed -i '/export LICENSE=accept/d' /root/.bash_profile
sed -i '/source \/opt\/mqm\/bin\/setmqenv -s/d' /root/.bash_profile
sed -i 's/:\/opt\/mqm\/bin:\/opt\/mqm\/samp\/bin//g' /root/.bash_profile

#Source the root profile to load the necessary variables
echo "Source /root/.bash_profile"
source /root/.bash_profile

#Remove MQ Packages
rpm -qa | grep MQSeries | xargs rpm -ev 2>&1 > /dev/null

# Clean up all the downloaded files
rm -rf /tmp/mqm/
rm -f /tmp/mqconfig*

rm -rf /home/mqm
rm -rf /opt/mqm
rm -rf /var/mqm
rm -rf /tmp/mq
rm -rf /etc/mqm
#rm -rf /etc/init.d/iibservice

echo " "
echo "============================================================"
echo "Uninstall of MQ has been completed"
echo "Logout and Login for profile settings to take affect"
echo "============================================================"
echo " "
