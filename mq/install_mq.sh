#!/bin/bash

# Install MQ v9.1.1.x Developer edition

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
  util-linux

# Download and extract the MQ installation files
echo "exporting DIR_EXTRACT=/tmp/mq"
export DIR_EXTRACT=/tmp/mq
mkdir -p /tmp/mq/
#cd /tmp/mq

MQ_FILE=mqadv_dev911_linux_x86-64.tar.gz
MQ_URL="https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqadv/${MQ_FILE}"

#Check if /iibdata/mqadv_dev911_linux_x86-64.tar.gz exists, otherwise download it
if [ -e "${DIR_EXTRACT}/${MQ_FILE}" ]
then
	echo "${DIR_EXTRACT}/${MQ_FILE} exists, no download required"
else
	echo "Downloading MQ to $DIR_EXTRACT"
	#Download MQ to /tmp/mq
	(cd ${DIR_EXTRACT} && curl -LO ${MQ_URL})
	#curl -LO https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqadv/mqadv_dev911_linux_x86-64.tar.gz
fi

#Extract MQ
tar -zxvf ${DIR_EXTRACT}/${MQ_FILE} -C ${DIR_EXTRACT}/ 2>&1 > /dev/null

#Extract MQ from /iibdata
#tar -zxvf /iibdata/mqadv_dev911_linux_x86-64.tar.gz -C /tmp/mq 2>&1 > /dev/null

# Recommended: Create the mqm user ID with a fixed UID and group, so that the file permissions work between different images
groupadd --system --gid 980 mqm
useradd --system --uid 980 --gid mqm mqm
usermod -G mqm root
#usermod -aG mqm root

# Create Home directory for .bash_profile
mkdir -p /home/mqm

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

#Create /var/mqm
mkdir -p /var/mqm/

#Create /etc/mqm/
mkdir -p /etc/mqm/

# Recommended: Set the default MQ installation (makes the MQ commands available on the PATH)
/opt/mqm/bin/setmqinst -p /opt/mqm/ -i

# Clean up yum files
yum -y clean all
rm -rf /var/cache/yum/*

# Clean up all the downloaded files
rm -rf ${DIR_EXTRACT}



