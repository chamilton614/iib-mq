#!/bin/bash
# Install process for MQ
echo " "
echo "==================================="
echo "Installing MQ"
echo "==================================="
echo " "

#DEBUG flag
DEBUG=false

#Get Current Scripts Directory
CPWD=`pwd`
#read -p "CPWD is ${CPWD}"

mkdir -p ${CPWD}/logs/mq/

# Install additional packages required by MQ, this install process and the runtime scripts
yum -y install \
  bash \
  bc \
  ca-certificates \
  coreutils \
  curl \
  file \
  findutils \
  gawk \
  glibc-common \
  grep \
  passwd \
  procps-ng \
  sed \
  tar \
  vim \
  psmisc \
  util-linux

# Download and extract the MQ installation files
echo "exporting DIR_EXTRACT=/tmp/mq"
export DIR_EXTRACT=/tmp/mq
mkdir -p /tmp/mq/
#cd /tmp/mq

MQ_FILE=mqadv_dev911_linux_x86-64.tar.gz
MQ_URL="https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqadv/${MQ_FILE}"

#Check if /iibdata/mqadv_dev911_linux_x86-64.tar.gz exists, otherwise download it
if [ -e "${DIR_EXTRACT}/${MQ_FILE}" ]; then
	echo "${DIR_EXTRACT}/${MQ_FILE} exists, no download required"
else
	echo "Downloading MQ to $DIR_EXTRACT"
	#Download MQ to /tmp/mq
	(cd ${DIR_EXTRACT} && curl -LO ${MQ_URL})
fi

#Extract MQ
tar -zxvf ${DIR_EXTRACT}/${MQ_FILE} -C ${DIR_EXTRACT}/ 2>&1 > /dev/null

# Recommended: Create the mqm user ID with a fixed UID and group, so that the file permissions work between different images
groupadd --system --gid 980 mqm
useradd --system --uid 980 --gid mqm --create-home --home-dir /home/mqm mqm
usermod -aG mqm root

#MQ Packages to Install
MQ_PACKAGES="MQSeriesRuntime-*.rpm MQSeriesServer-*.rpm MQSeriesJava*.rpm MQSeriesJRE*.rpm MQSeriesGSKit*.rpm MQSeriesMsg*.rpm MQSeriesSamples*.rpm MQSeriesAMS-*.rpm"

# Find directory containing .rpm files
export DIR_RPM=$(find ${DIR_EXTRACT} -name "*.rpm" -printf "%h\n" | sort -u | head -1)

# Find location of mqlicense.sh
export MQLICENSE=$(find ${DIR_EXTRACT} -name "mqlicense.sh")

# Accept the MQ license
echo ${MQLICENSE}
${MQLICENSE} -text_only -accept

# Install MQ using the RPM packages
echo "Installing the RPM Packages"
mkdir -p /opt/mqm
for x in ${MQ_PACKAGES}; do rpm -ivh ${DIR_RPM}/$x; done

echo "Performing a Yum Update"
yum -y update

# Remove tar.gz files unpacked by RPM postinst scripts
find /opt/mqm/ -name '*.tar.gz' -delete

# Recommended: Set the default MQ installation (makes the MQ commands available on the PATH)
/opt/mqm/bin/setmqinst -i -p /opt/mqm/

# Create Home directory for .bash_profile
#mkdir -p /home/mqm
#chown -R mqm:mqm /home/mqm
#chmod -R 755 /home/mqm

#Update /opt/mqm
#chown -R mqm:mqm /opt/mqm
#chmod -R 755 /opt/mqm

# Remove the directory structure under /var/mqm which was created by the installer
#rm -rf /var/mqm

#Update /var/mqm
#mkdir -p /var/mqm/
#chown -R mqm:mqm /var/mqm/
#chmod -R 755 /var/mqm/

# Create the mount point for volumes
#mkdir -p /mnt/mqm

# Create the directory for MQ configuration files
mkdir -p /etc/mqm
chown -R mqm:mqm /etc/mqm/
chmod -R 755 /etc/mqm/

# Create a symlink for /var/mqm -> /mnt/mqm/data
#ln -s /mnt/mqm/data /var/mqm

#Setup the Environment for the User
source /opt/mqm/bin/setmqenv -s

#Verify the Installation Version
dspmqver

# Clean up yum files
yum -y clean all
rm -rf /var/cache/yum/*

# Clean up all the downloaded files
rm -rf ${DIR_EXTRACT}

##Update mqm .bash_profile
#if [ ! -f "/opt/mqm/mqmupdated" ] && [ -d "/home/mqm/" ]; then
#	touch /opt/mqm/mqmupdated
#	if ! `grep -q "LICENSE=accept" /home/mqm/.bash_profile`; then
#		echo "Exporting License"; echo export LICENSE=accept>> /home/mqm/.bash_profile
#	fi
#	if ! `grep -q ":/opt/mqm/bin:/opt/mqm/samp/bin" /home/mqm/.bash_profile`; then
#		echo "Updating PATH"; echo PATH='$PATH':/opt/mqm/bin:/opt/mqm/samp/bin>> /home/mqm/.bash_profile
#	fi
#	#if ! `grep -q "source /opt/mqm/bin/setmqenv" /home/mqm/.bash_profile`; then
#	#	echo "Setting source setmqenv"; echo "source /opt/mqm/bin/setmqenv -s">> /home/mqm/.bash_profile
#	#fi
#	echo "Exporting Path"
#	sed -i '/export PATH/d' /home/mqm/.bash_profile
#	echo export PATH>> /home/mqm/.bash_profile
#	echo "Source /home/mqm/.bash_profile"
#	source /home/mqm/.bash_profile
#fi

#Update root .bash_profile
if [ ! -f "/opt/mqm/rootupdated" ] && [ -d "/root/" ]; then
	touch /opt/mqm/rootupdated
	if ! `grep -q "LICENSE=accept" /root/.bash_profile`; then
		echo "Adding LICENSE variable for root user"; echo export LICENSE=accept>> /root/.bash_profile
	fi
	#sed -i '/^PATH/s/$/<stuff to add>/' <FILE>
	if ! `grep -q ":/usr/local/bin" /root/.bash_profile`; then
		echo "Updating PATH variable for root user"; sed -i '/^PATH/s/$/:\/usr\/local\/bin/' /root/.bash_profile
	fi
	if ! `grep -q ":/opt/mqm/bin:/opt/mqm/samp/bin" /root/.bash_profile`; then
		echo "Updating PATH with mqm directories"; sed -i '/^PATH/s/$/:\/opt\/mqm\/bin:\/opt\/mqm\/samp\/bin/' /root/.bash_profile
	fi
	if ! `grep -q "source /opt/mqm/bin/setmqenv -s" /root/.bash_profile`; then
		echo "Setting source setmqenv"; echo "source /opt/mqm/bin/setmqenv -s">> /root/.bash_profile
	fi
	
	#Moving the export PATH line to be the last line in the .bash_profile
	echo "Moving export PATH"
	sed -i '/export PATH/d' /root/.bash_profile
	echo export PATH>> /root/.bash_profile
	#echo "Source /root/.bash_profile"
	#source /root/.bash_profile
fi

#Update mqm .bash_profile
if [ ! -f "/opt/mqm/mqmupdated" ] && [ -d "/home/mqm/" ]; then
	touch /opt/mqm/mqmupdated
	if ! `grep -q "LICENSE=accept" /home/mqm/.bash_profile`; then
		echo "Adding LICENSE variable for mqm user"; echo export LICENSE=accept>> /home/mqm/.bash_profile
	fi
	#sed -i '/^PATH/s/$/<stuff to add>/' <FILE>
	if ! `grep -q ":/usr/local/bin" /home/mqm/.bash_profile`; then
		echo "Updating PATH with /usr/local/bin"; sed -i '/^PATH/s/$/:\/usr\/local\/bin/' /home/mqm/.bash_profile
	fi
	if ! `grep -q ":/opt/mqm/bin:/opt/mqm/samp/bin" /home/mqm/.bash_profile`; then
		echo "Updating PATH with mqm directories"; sed -i '/^PATH/s/$/:\/opt\/mqm\/bin:\/opt\/mqm\/samp\/bin/' /home/mqm/.bash_profile
	fi
	if ! `grep -q "source /opt/mqm/bin/setmqenv -s" /home/mqm/.bash_profile`; then
		echo "Setting source setmqenv"; echo "source /opt/mqm/bin/setmqenv -s">> /home/mqm/.bash_profile
	fi
	
	#Moving the export PATH line to be the last line in the .bash_profile
	echo "Moving export PATH"
	sed -i '/export PATH/d' /root/.bash_profile
	echo export PATH>> /root/.bash_profile
	#echo "Source /root/.bash_profile"
	#source /root/.bash_profile
fi


