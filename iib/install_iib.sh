#!/bin/bash
# Install process for IIB
echo " "
echo "==================================="
echo "Installing IIB"
echo "==================================="
echo " "

#DEBUG flag
DEBUG=false

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
if [ -e "${DIR_EXTRACT}/${IIB_FILE}" ]; then
	echo "${DIR_EXTRACT}/${IIB_FILE} exists, no download required"
else
	echo "Downloading IIB to ${DIR_EXTRACT}"
	#Download IIB to /tmp/iib
	(cd ${DIR_EXTRACT} && curl -LO ${IIB_URL})
fi

#Extract IIB
tar -Uzxvf ${DIR_EXTRACT}/${IIB_FILE} -C /opt/ibm/ 2>&1 > /dev/null
#tar -Uzxvf ${DIR_EXTRACT}/${IIB_FILE} --exclude iib-${IIB_VERSION}/tools -C /opt/ibm/ 2>&1 > /dev/null

#Launch Installer
/opt/ibm/iib-${IIB_VERSION}/iib make registry global accept license silently
export LICENSE=accept

#Verify the Installation
/opt/ibm/iib-${IIB_VERSION}/iib verify all

#Verify the Installation Version
/opt/ibm/iib-${IIB_VERSION}/iib version

# Clean up all the downloaded files
rm -rf ${DIR_EXTRACT}
rm -f /tmp/iib-*

#Check the DEBUG flag
if [ "$DEBUG" == "true" ]; then
	exit
fi

#Check Path
if [ -e "${CPWD}/iib/configure_iib.sh" ]; then
	#Configure IIB
	${CPWD}/iib/configure_iib.sh
else
	if [ -e "${CPWD}/configure_iib.sh" ]; then
		#Configure IIB
		${CPWD}/configure_iib.sh
	else
		echo "Unable to locate configure_iib.sh from the path ${CPWD}"
		exit
	fi
fi

