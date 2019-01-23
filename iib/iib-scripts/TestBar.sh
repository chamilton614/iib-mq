### Comments and description
# Creating QM1 Queue Manager
crtmqm QM01
# Starting the QM1 Queue Manager
strmqm QM01
# Creating Integration Node with associate Queue Manager
mqsicreatebroker IBNODE -q QM01
# stopping the Queue Manager
endmqm QM01
# Starting the Integration Node
# creating Queues
runmqsc QM01
DEFINE QL(IN)
DEFINE QL(OUT)
mqsistart IBNODE
# Stopping the Integration Node
mqsistop IBNODE
# Creating the Integration Servver/ Execution Group
mqsicreateexecutiongroup IBNODE -e EG1
# Starting the message flow
mqsistartmsgflow IBNODE -e EG1
# Deploying the barfile in to integration server on the Integration Node
mqsideploy IBNODE -e EG1 -a TestBar.bar -m -w 600
# Creating the Sample Configurable Service
mqsicreateconfigurableservice IBNODE -c ActivityLog -o SampleConfigService -n filter,fileName,minSeverityLevel,formatEntries,executionGroupFilter,numberOfLogs,enabled,maxFileSizeMb,maxAgeMins -v "","","INFO","false","","4","true","25","0"
# Testing the bar files after succesffuly deployed you can RFHUtil tool or command line as below.
#Testing by putting message
#Putting the message on IN queue
amqsput IN QM01
Test1
Test2
#Getting the message from the OUT queue
amqsget OUT QM01
