#!/bin/bash
# Configure process for IIB
echo " "
echo "==================================="
echo "Configuring IIB"
echo "==================================="
echo " "

#DEBUG flag
DEBUG=false

#Get Current Scripts Directory
CPWD=`pwd`

#IIB Installed Version
IIB_VERSION=10.0.0.15

#Create iib group mqbrkrs
#groupadd -f mqbrkrs already exists from installer

#Create iibuser and Groups
if [ ! `cat /etc/passwd | grep iibuser` ]; then
   echo "Creating iibuser User"
   #useradd --create-home --home-dir /home/iibuser -G mqbrkrs,sudo,mqm,mqclient iibuser
   useradd iibuser --create-home --home-dir /home/iibuser
   #Set iibuser
   echo -e "iibuser\niibuser" | passwd iibuser
   # Create Groups and Memberships
   echo "Creating mqclient Group"
   groupadd -f mqclient
   echo "Adding iibuser to Groups"
   usermod -aG mqbrkrs,mqm,mqclient,wheel iibuser
   echo "Adding root to Groups"
   usermod -aG mqbrkrs,mqclient root
fi

#Update Ownership on IIB Directories
echo "Updating Ownership and Permissions on /opt/ibm/"
chown -R iibuser:mqbrkrs /opt/ibm/
chmod -R 755 /opt/ibm/
echo "Updating Ownership and Permissions on /var/mqsi/"
chown -R iibuser:mqbrkrs /var/mqsi/
chmod -R 755 /var/mqsi/

#Update the sudoers for iibuser
# To uncomment the passwordless entry
sed -i 's/\# \%wheel/\%wheel/' /etc/sudoers
# To comment the password required entry
sed -i '0,/\%wheel/ s/\%wheel/\# \%wheel/' /etc/sudoers

# Update ulimit for nofile
echo *	hard	nofile	10250 >> /etc/security/limits.conf
echo *	soft	nofile	10250 >> /etc/security/limits.conf

#Check the Path
if [ -d "${CPWD}/iib/iib-scripts/" ]; then
	#Copy IIB and MQ Scripts
	echo "Copy IIB and MQ Scripts"
	cp ${CPWD}/iib/iib-scripts/*.sh /usr/local/bin/
	chmod 755 /usr/local/bin/*.sh
	echo "Copy Test.bar"
	cp ${CPWD}/iib/iib-scripts/*.bar /usr/local/bin/
	echo "Copy mq-config"
	cp ${CPWD}/iib/iib-scripts/mq-config /etc/mqm/mq-config
	chmod 755 /etc/mqm/mq-config
else
	if [ -d "${CPWD}/iib-scripts/" ]; then
		#Copy IIB and MQ Scripts
		echo "Copy IIB and MQ Scripts"
		cp ${CPWD}/iib-scripts/*.sh /usr/local/bin/
		chmod 755 /usr/local/bin/*.sh
		echo "Copy Test.bar"
		cp ${CPWD}/iib-scripts/*.bar /usr/local/bin/
		echo "Copy mq-config"
		cp ${CPWD}/iib-scripts/mq-config /etc/mqm/mq-config
		chmod 755 /etc/mqm/mq-config
	else
		echo "Unable to locate iib-scripts from the path ${CPWD}"
		exit
	fi
fi

# Set BASH_ENV to source mqsiprofile when using docker exec bash -c
export BASH_ENV=/usr/local/bin/iib_env.sh
export MQSI_MQTT_LOCAL_HOSTNAME=127.0.0.1
export MQSI_DONT_RUN_LISTENER=true
export LANG=en_US.UTF-8

# Expose default admin port and http ports
iptables -I INPUT -p tcp --dport 4414 -j ACCEPT
iptables -I INPUT -p tcp --dport 7800 -j ACCEPT
iptables -I INPUT -p tcp --dport 1414 -j ACCEPT

#Update root .bash_profile
if [ ! -f "/opt/ibm/rootupdated" ] && [ -d "/root" ]; then
	touch /opt/ibm/rootupdated
	if ! `grep -q "LICENSE=accept" /root/.bash_profile`; then
		echo "Adding LICENSE variable for root user"; echo export LICENSE=accept>> /root/.bash_profile
	fi
	if ! `grep -q ":/usr/local/bin" /root/.bash_profile`; then
	#	echo "Updating PATH with /usr/local/bin"; echo PATH='$PATH':/usr/local/bin>> /root/.bash_profile
		echo "Updating PATH with /usr/local/bin"; sed -i '/^PATH/s/$/:\/usr\/local\/bin/' /root/.bash_profile
	fi
	if ! `grep -q "/opt/ibm/iib-${IIB_VERSION}/server/bin" /root/.bash_profile`; then
	#	echo "Updating PATH with iib directories"; echo PATH='$PATH':/usr/local/bin:/opt/ibm/iib-${IIB_VERSION}/server/bin>> /root/.bash_profile
		echo "Updating PATH with mqm directories for root user"; sed -i '/^PATH/s/$/:\/opt\/ibm\/iib-${IIB_VERSION}\/server\/bin/' /root/.bash_profile
	fi
	#if ! `grep -q "source /opt/mqm/bin/setmqenv -s" /root/.bash_profile`; then
	#	echo "Setting source setmqenv for root user"; echo "source /opt/mqm/bin/setmqenv -s">> /root/.bash_profile
	#fi
	if ! `grep -q "source /opt/ibm/iib-${IIB_VERSION}/server/bin/mqsiprofile" /root/.bash_profile`; then
		echo "Setting source mqsiprofile for root user"; echo source /opt/ibm/iib-${IIB_VERSION}/server/bin/mqsiprofile>> /root/.bash_profile
	fi
	echo "Moving export PATH for root user"
	sed -i '/export PATH/d' /root/.bash_profile
	echo export PATH>> /root/.bash_profile
	#echo "Source /root/.bash_profile"
	#source /root/.bash_profile
fi

#Update iibuser .bash_profile
if [ ! -f "/opt/ibm/iibuserupdated" ] && [ -d "/home/iibuser/" ]; then
	touch /opt/ibm/iibuserupdated
	if ! `grep -q "LICENSE=accept" /home/iibuser/.bash_profile`; then
		echo "Adding LICENSE variable for iibuser user"; echo export LICENSE=accept>> /home/iibuser/.bash_profile
	fi
	if ! `grep -q ":/usr/local/bin" /root/.bash_profile`; then
	#	echo "Updating PATH with /usr/local/bin"; echo PATH='$PATH':/usr/local/bin>> /root/.bash_profile
		echo "Updating PATH with /usr/local/bin"; sed -i '/^PATH/s/$/:\/usr\/local\/bin/' /root/.bash_profile
	fi
	if ! `grep -q ":/opt/mqm/bin:/opt/mqm/samp/bin" /home/iibuser/.bash_profile`; then
	#	echo "Updating PATH with mqm directories"; echo PATH='$PATH':/opt/mqm/bin:/opt/mqm/samp/bin>> /home/iibuser/.bash_profile
		echo "Updating PATH with mqm directories for iibuser user"; sed -i '/^PATH/s/$/:\/opt\/mqm\/bin:\/opt\/mqm\/samp\/bin/' /home/iibuser/.bash_profile
	fi
	if ! `grep -q "/opt/ibm/iib-${IIB_VERSION}/server/bin" /home/iibuser/.bash_profile`; then
	#	echo "Updating PATH with iib directories"; echo PATH='$PATH':/usr/local/bin:/opt/ibm/iib-${IIB_VERSION}/server/bin>> /home/iibuser/.bash_profile
		echo "Updating PATH with iib directories for iibuser user"; sed -i '/^PATH/s/$/:\/opt\/ibm\/iib-${IIB_VERSION}\/server\/bin/' /home/iibuser/.bash_profile
	fi
	if ! `grep -q "source /opt/mqm/bin/setmqenv -s" /home/iibuser/.bash_profile`; then
		echo "Setting source setmqenv for iibuser user"; echo "source /opt/mqm/bin/setmqenv -s">> /home/iibuser/.bash_profile
	fi
	if ! `grep -q "source /opt/ibm/iib-${IIB_VERSION}/server/bin/mqsiprofile" /home/iibuser/.bash_profile`; then
		echo "Setting source mqsiprofile for iibuser user"; echo source /opt/ibm/iib-${IIB_VERSION}/server/bin/mqsiprofile>> /home/iibuser/.bash_profile
	fi
	echo "Moving export PATH for iibuser user"
	sed -i '/export PATH/d' /home/iibuser/.bash_profile
	echo export PATH>> /home/iibuser/.bash_profile
	#echo "Source /home/iibuser/.bash_profile"
	#source /home/iibuser/.bash_profile
fi

#Update mqm .bash_profile
#if [ ! -f "/opt/ibm/mqmupdated" ] && [ -d "/home/mqm/" ]; then
#	touch /opt/ibm/mqmupdated
#	if ! `grep -q "LICENSE=accept" /home/mqm/.bash_profile`; then
#		echo "Exporting License"; echo export LICENSE=accept>> /home/mqm/.bash_profile
#	fi
#	if ! `grep -q "/opt/ibm/iib-${IIB_VERSION}/server/bin" /home/mqm/.bash_profile`; then
#		echo "Updating PATH"; echo PATH='$PATH':/usr/local/bin:/opt/ibm/iib-${IIB_VERSION}/server/bin>> /home/mqm/.bash_profile
#	fi
#	if ! `grep -q "source /opt/mqm/bin/setmqenv -s" /home/mqm/.bash_profile`; then
#		echo "Setting source setmqenv"; echo "source /opt/mqm/bin/setmqenv -s">> /home/mqm/.bash_profile
#	fi
#	if ! `grep -q "source /opt/ibm/iib-${IIB_VERSION}/server/bin/mqsiprofile" /home/mqm/.bash_profile`; then
#		echo "Setting source mqsiprofile"; echo source /opt/ibm/iib-${IIB_VERSION}/server/bin/mqsiprofile>> /home/mqm/.bash_profile
#	fi
#	echo "Exporting Path"
#	sed -i '/export PATH/d' /home/mqm/.bash_profile
#	echo export PATH>> /home/mqm/.bash_profile
#	echo "Source /home/mqm/.bash_profile"
#	source /home/mqm/.bash_profile
#fi

#Update iibuser .bash_profile
#if [ ! -f "/opt/ibm/iibuserupdated" ] && [ -d "/home/iibuser/" ]; then
#	touch /opt/ibm/iibuserupdated
#	if ! `grep -q "LICENSE=accept" /home/iibuser/.bash_profile`; then
#		echo "Exporting License"; echo export LICENSE=accept>> /home/iibuser/.bash_profile
#	fi
#	if ! `grep -q ":/opt/mqm/bin:/opt/mqm/samp/bin" /home/iibuser/.bash_profile`; then
#		echo "Updating PATH"; echo PATH='$PATH':/opt/mqm/bin:/opt/mqm/samp/bin>> /home/iibuser/.bash_profile
#	fi
#	if ! `grep -q "/opt/ibm/iib-${IIB_VERSION}/server/bin" /home/iibuser/.bash_profile`; then
#		echo "Updating PATH"; echo PATH='$PATH':/usr/local/bin:/opt/ibm/iib-${IIB_VERSION}/server/bin>> /home/iibuser/.bash_profile
#	fi
#	if ! `grep -q "source /opt/mqm/bin/setmqenv -s" /home/iibuser/.bash_profile`; then
#		echo "Setting source setmqenv"; echo "source /opt/mqm/bin/setmqenv -s">> /home/iibuser/.bash_profile
#	fi
#	if ! `grep -q "source /opt/ibm/iib-${IIB_VERSION}/server/bin/mqsiprofile" /home/iibuser/.bash_profile`; then
#		echo "Setting source mqsiprofile"; echo source /opt/ibm/iib-${IIB_VERSION}/server/bin/mqsiprofile>> /home/iibuser/.bash_profile
#	fi
#	echo "Exporting Path"
#	sed -i '/export PATH/d' /home/iibuser/.bash_profile
#	echo export PATH>> /home/iibuser/.bash_profile
#	echo "Source /home/iibuser/.bash_profile"
#	source /home/iibuser/.bash_profile
#fi

#Run as mqm
#runuser -l mqm -c "mqsiservice -v"

#Run as iibuser
#runuser -l iibuser -c "mqsiservice -v"

#Verify IIB
#/opt/ibm/iib-10.0.0.11/iib verify all
#/opt/ibm/iib-${IIB_VERSION}/iib verify all

# Set entrypoint to run management script to verify the installation
#iib_manage.sh
#sleep 10

#Cleanup IIBV10NODE1 and QM1
#mqsistop IIBV10NODE
#endmqm QM1

# Delete the IIB Node
#mqsideletebroker IIBV10NODE
# Delete the QueueManager
#dltmqm QM1

# Start IIB and MQ as iibuser
#runuser -l iibuser -c "iib_manage.sh"





