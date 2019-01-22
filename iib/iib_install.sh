
# Install IIB v10.0.0.x Developer edition

mkdir -p /opt/ibm
#cd /opt/ibm

#Check if /iibdata/10.0.0.15-IIB-LINUX64-DEVELOPER.tar.gz exists, otherwise download it

#Download IIB
curl -LO http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/integration/10.0.0.15-IIB-LINUX64-DEVELOPER.tar.gz

#Extract IIB
tar -Uzxvf 10.0.0.15-IIB-LINUX64-DEVELOPER.tar.gz -C /opt/ibm/ 2>&1 > /dev/null

#Extract IIB from /iibdata
#tar -Uzxvf /iibdata/10.0.0.11-IIB-LINUX64-DEVELOPER.tar.gz -C /opt/ibm/ 2>&1 > /dev/null

#Launch Installer
#/opt/ibm/iib-10.0.0.11/iib make registry global accept license silently
/opt/ibm/iib-10.0.0.15/iib make registry global accept license silently
export LICENSE=accept

# Configure system
#echo "IIB_10:" > /etc/rpm_chroot 
#touch /var/log/syslog
#chown root:root /var/log/syslog

# Create user to run as
groupadd -f mqbrkrs
groupadd -f mqclient
useradd iibuser
usermod -aG mqbrkrs,mqm,mqclient,wheel iibuser

# Set BASH_ENV to source mqsiprofile when using docker exec bash -c
export BASH_ENV=/usr/local/bin/iib_env.sh MQSI_MQTT_LOCAL_HOSTNAME=127.0.0.1 MQSI_DONT_RUN_LISTENER=true LANG=en_US.UTF-8

# Expose default admin port and http ports
iptables -I INPUT -p tcp --dport 4414 -j ACCEPT
iptables -I INPUT -p tcp --dport 7800 -j ACCEPT
iptables -I INPUT -p tcp --dport 1414 -j ACCEPT

#Verify IIB
#/opt/ibm/iib-10.0.0.11/iib verify all
/opt/ibm/iib-10.0.0.15/iib verify all

# Set entrypoint to run management script
read -p "Proceed to run iib_manage.sh? Ctrl+C to quit"
iib_manage.sh

#source /opt/ibm/iib-10.0.0.11/server/bin/mqsiprofile
source /opt/ibm/iib-10.0.0.15/server/bin/mqsiprofile
mqsiservice -v


