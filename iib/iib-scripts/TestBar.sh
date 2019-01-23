#!/bin/bash

# Creating QM1 Queue Manager
crtmqm QM01

# Starting the QM1 Queue Manager
strmqm QM01

# Creating Integration Node with associate Queue Manager
mqsicreatebroker IBNODE01 -q QM01

# Starting the Integration Node
# creating Queues
runmqsc QM01
DEFINE QL(IN)
DEFINE QL(OUT)
mqsistart IBNODE01

# Creating the Integration Servver/ Execution Group
mqsicreateexecutiongroup IBNODE01 -e EG01

# Starting the message flow
mqsistartmsgflow IBNODE01 -e EG01

# Deploying the barfile in to integration server on the Integration Node
mqsideploy IBNODE01 -e EG01 -a /usr/local/bin/TestBar.bar -m -w 600

# Creating the Sample Configurable Service
mqsicreateconfigurableservice IBNODE01 -c ActivityLog -o SampleConfigService -n filter,fileName,minSeverityLevel,formatEntries,executionGroupFilter,numberOfLogs,enabled,maxFileSizeMb,maxAgeMins -v "","","INFO","false","","4","true","25","0"
# Testing the bar files after succesffuly deployed you can RFHUtil tool or command line as below.
#Testing by putting message

#Putting the message on IN queue
amqsput IN QM01
Test1
Test2

#Getting the message from the OUT queue
amqsget OUT QM01
