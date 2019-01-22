
# Install MQ v9.1.1.x Developer edition

mkdir -p logs/mq/

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
  util-linux

# Download and extract the MQ installation files
echo "exporting DIR_EXTRACT=/tmp/mq"
export DIR_EXTRACT=/tmp/mq/
mkdir -p /tmp/mq/
#cd /tmp/mq

MQ_FILE=mqadv_dev911_linux_x86-64.tar.gz
MQ_URL="https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqadv/$MQ_FILE"

#Check if /iibdata/mqadv_dev911_linux_x86-64.tar.gz exists, otherwise download it
if [ -e "$DIR_EXTRACT/$MQ_FILE" ] then
	echo $DIR_EXTRACT/$MQ_FILE exists, no download required
else
	#Download MQ to /tmp/mq
	(cd /tmp/mq/ && curl -LO $MQ_URL)
	#curl -LO https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqadv/mqadv_dev911_linux_x86-64.tar.gz
fi

#Extract MQ
tar -zxvf /tmp/mq/$MQ_FILE -C /tmp/mq/ 2>&1 > /dev/null

#Extract MQ from /iibdata
#tar -zxvf /iibdata/mqadv_dev911_linux_x86-64.tar.gz -C /tmp/mq 2>&1 > /dev/null

# Recommended: Create the mqm user ID with a fixed UID and group, so that the file permissions work between different images
groupadd --system --gid 980 mqm
useradd --system --uid 980 --gid mqm mqm
usermod -G mqm root
#usermod -aG mqm root

#MQ Packages to Install
MQ_PACKAGES="MQSeriesRuntime-*.rpm MQSeriesServer-*.rpm MQSeriesJava*.rpm MQSeriesJRE*.rpm MQSeriesGSKit*.rpm MQSeriesMsg*.rpm MQSeriesSamples*.rpm MQSeriesAMS-*.rpm"

# Find directory containing .rpm files
export DIR_RPM=$(find ${DIR_EXTRACT} -name "*.rpm" -printf "%h\n" | sort -u | head -1)

# Find location of mqlicense.sh
export MQLICENSE=$(find ${DIR_EXTRACT} -name "mqlicense.sh")

# Accept the MQ license
echo $MQLICENSE
${MQLICENSE} -text_only -accept

# Install MQ using the RPM packages
echo "Installing the RPM Packages"
mkdir -p /opt/mqm
#rpm -Uivh /tmp/mq/MQServer/MQSeriesRuntime-9.1.1-0.x86_64.rpm 2>&1 >> logs/mq/rpm.log
#rpm -Uivh /tmp/mq/MQServer/MQSeriesJRE-9.1.1-0.x86_64.rpm 2>&1 >> logs/mq/rpm.log 
#rpm -Uivh /tmp/mq/MQServer/MQSeriesJava-9.1.1-0.x86_64.rpm 2>&1 >> logs/mq/rpm.log
#rpm -Uivh /tmp/mq/MQServer/MQSeriesServer-9.1.1-0.x86_64.rpm 2>&1 >> logs/mq/rpm.log
#rpm -Uivh /tmp/mq/MQServer/MQSeriesWeb-9.1.1-0.x86_64.rpm 2>&1 >> logs/mq/rpm.log
#rpm -Uivh /tmp/mq/MQServer/MQSeriesExplorer-9.1.1-0.x86_64.rpm 2>&1 >> logs/mq/rpm.log
#rpm -Uivh /tmp/mq/MQServer/MQSeriesGSKit-9.1.1-0.x86_64.rpm 2>&1 >> logs/mq/rpm.log
#rpm -Uivh /tmp/mq/MQServer/MQSeriesClient-9.1.1-0.x86_64.rpm 2>&1 >> logs/mq/rpm.log
#rpm -Uivh /tmp/mq/MQServer/MQSeriesMan-9.1.1-0.x86_64.rpm 2>&1 >> logs/mq/rpm.log
#rpm -Uivh /tmp/mq/MQServer/MQSeriesMsg_es-9.1.1-0.x86_64.rpm 2>&1 >> logs/mq/rpm.log
#rpm -Uivh /tmp/mq/MQServer/MQSeriesSamples-9.1.1-0.x86_64.rpm 2>&1 >> logs/mq/rpm.log
#rpm -Uivh /tmp/mq/MQServer/MQSeriesSDK-9.1.1-0.x86_64.rpm 2>&1 >> logs/mq/rpm.log

echo rpm -ivh $DIR_RPM/$MQ_PACKAGES
rpm -ivh $DIR_RPM/$MQ_PACKAGES

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
#rm -rf ${DIR_EXTRACT}

##Copy MQ Scripts
#echo "Copy MQ Scripts"
##cp /iibdata/mq-scripts/*.sh /usr/local/bin/
#cp mq-scripts/*.sh /usr/local/bin/
#chmod 755 /usr/local/bin/*.sh
##cp /iibdata/mq-scripts/mq-config /etc/mqm/mq-config
#cp mq-scripts/mq-config /etc/mqm/mq-config
#chmod 755 /etc/mqm/mq-config
#
##cp /iibdata/mq-scripts/iibservice /etc/init.d/iibservice
##cp mq-scripts/iibservice /etc/init.d/iibservice
##chmod 755 /etc/init.d/iibservice
#
##Update the Path
#export PATH=$PATH:/usr/local/bin/
#echo $PATH
