#!/bin/bash

# Install IIB v10.0.0.x Developer edition

#Get Current Scripts Directory
CPWD=`pwd`
#read -p "CPWD is ${CPWD}"

mkdir -p /tmp/iib
mkdir -p /opt/ibm
#cd /opt/ibm

echo "exporting DIR_EXTRACT=/tmp/iib"
export DIR_EXTRACT=/tmp/iib
mkdir -p ${DIR_EXTRACT}

IIB_VERSION=10.0.0.15
IIB_FILE=${IIB_VERSION}-IIB.LINUX64-DEVELOPER.tar.gz
IIB_URL="http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/integration/${IIB_FILE}"

#Check if /iibdata/10.0.0.15-IIB-LINUX64-DEVELOPER.tar.gz exists, otherwise download it
if [ -e "${DIR_EXTRACT}/${IIB_FILE}" ]
then
	echo "${DIR_EXTRACT}/${IIB_FILE} exists, no download required"
else
	echo "Downloading IIB to ${DIR_EXTRACT}"
	#Download IIB to /tmp/iib
	(cd ${DIR_EXTRACT} && curl -LO ${IIB_URL})
fi

#Extract IIB
tar -Uzxvf ${DIR_EXTRACT}/${IIB_FILE} -C /opt/ibm/ 2>&1 > /dev/null

#Launch Installer
/opt/ibm/iib-${IIB_VERSION}/iib make registry global accept license silently
export LICENSE=accept

# Configure system
#echo "IIB_10:" > /etc/rpm_chroot 
#touch /var/log/syslog
#chown root:root /var/log/syslog

# Create user to run as
groupadd -f mqbrkrs
groupadd -f mqclient
useradd --create-home --home-dir /home/iibuser -G mqbrkrs,sudo,mqm,mqclient iibuser
#usermod -aG mqbrkrs,mqm,mqclient,wheel iibuser

#Update the sudoers for iibuser
sed -e 's/^%sudo	.*/%sudo	ALL=NOPASSWD:ALL/g' -i /etc/sudoers

# Update ulimit for nofile
echo *	hard	nofile	10250 >> /etc/security/limits.conf
echo *	soft	nofile	10250 >> /etc/security/limits.conf

#Copy IIB and MQ Scripts
echo "Copy IIB and MQ Scripts"
cp ${CPWD}/iib/iib-scripts/*.sh /usr/local/bin/
chmod 755 /usr/local/bin/*.sh
echo "Copy Test.bar"
cp ${CPWD}/iib/iib-scripts/*.bar /usr/local/bin/
echo "Copy mq-config"
cp ${CPWD}/iib/iib-scripts/mq-config /etc/mqm/mq-config
chmod 755 /etc/mqm/mq-config

# Set BASH_ENV to source mqsiprofile when using docker exec bash -c
export BASH_ENV=/usr/local/bin/iib_env.sh MQSI_MQTT_LOCAL_HOSTNAME=127.0.0.1 MQSI_DONT_RUN_LISTENER=true LANG=en_US.UTF-8

# Expose default admin port and http ports
iptables -I INPUT -p tcp --dport 4414 -j ACCEPT
iptables -I INPUT -p tcp --dport 7800 -j ACCEPT
iptables -I INPUT -p tcp --dport 1414 -j ACCEPT

#For IIB Service
#cp /iibdata/mq-scripts/iibservice /etc/init.d/iibservice
#cp mq-scripts/iibservice /etc/init.d/iibservice
#chmod 755 /etc/init.d/iibservice

#Update root .bash_profile
if [ ! -f "/opt/ibm/rootupdated" ]; then
	touch /opt/ibm/rootupdated
	echo export LICENSE=accept>> /root/.bash_profile
	echo PATH=$PATH:/usr/local/bin:/opt/mqm/bin:/opt/mqm/samp/bin:/opt/ibm/iib-${IIB_VERSION}/server/bin>> /root/.bash_profile
	echo source /opt/ibm/iib-${IIB_VERSION}/server/bin/mqsiprofile>> /root/.bash_profile
	source /root/.bash_profile
fi

#Update mqm .bash_profile
if [ ! -f "/opt/ibm/mqmupdated" ]; then
	touch /opt/ibm/mqmupdated
	echo export LICENSE=accept>> /home/mqm/.bash_profile
	echo PATH=$PATH:/usr/local/bin:/opt/mqm/bin:/opt/mqm/samp/bin:/opt/ibm/iib-${IIB_VERSION}/server/bin>> /home/mqm/.bash_profile
	echo source /opt/ibm/iib-${IIB_VERSION}/server/bin/mqsiprofile>> /home/mqm/.bash_profile
	source /home/mqm/.bash_profile
fi

#Update iibuser .bash_profile
if [ ! -f "/opt/ibm/iibuserupdated" ]; then
	touch /opt/ibm/iibuserupdated
	echo export LICENSE=accept>> /home/iibuser/.bash_profile
	echo PATH=$PATH:/usr/local/bin:/opt/mqm/bin:/opt/mqm/samp/bin:/opt/ibm/iib-${IIB_VERSION}/server/bin>> /home/iibuser/.bash_profile
	echo source /opt/ibm/iib-${IIB_VERSION}/server/bin/mqsiprofile>> /home/iibuser/.bash_profile
	source /home/iibuser/.bash_profile
fi

#Run as mqm
runuser -l mqm -c "mqsiservice -v"

#Run as iibuser
runuser -l iibuser -c "mqsiservice -v"

#Verify IIB
#/opt/ibm/iib-10.0.0.11/iib verify all
/opt/ibm/iib-${IIB_VERSION}/iib verify all

# Set entrypoint to run management script
#read -p "Proceed to run iib_manage.sh? Ctrl+C to quit"
runuser -l iibuser -c "iib_manage.sh"




