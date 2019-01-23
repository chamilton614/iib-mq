clear
mqsistop IBNODE01
endmqm QM01
mqsideletebroker IBNODE01
dltmqm QM01
sleep 10
echo "********* Creating QM01 Queue Manager*********"
/opt/ibm/iib-10.0.0.11/server/bin/crtmqm QM01
echo "********* Starting the QM01 Queue Manager*********"
/opt/ibm/iib-10.0.0.11/server/bin/strmqm QM01
echo "********* Creating Integration Node with associate Queue Manager*********"
/opt/ibm/iib-10.0.0.11/server/bin/mqsicreatebroker IBNODE01 -q QM01
echo "********* stopping the Queue Manager*********"
/opt/ibm/iib-10.0.0.11/server/bin/endmqm QM01
echo "********* Starting the Integration Node*********"
/opt/ibm/iib-10.0.0.11/server/bin/mqsistart IBNODE01
echo "********* Stopping the Integration Node*********"
/opt/ibm/iib-10.0.0.11/server/bin/mqsistop IBNODE01
echo "********* Creating the Integration Server/ Execution Group*********"
/opt/ibm/iib-10.0.0.11/server/bin/mqsicreateexecutiongroup IBNODE01 -e EG01
echo "********* Starting the message flow*********"
/opt/ibm/iib-10.0.0.11/server/bin/mqsistartmsgflow IBNODE01 -e EG01
echo "********* Deploying the barfile in to integration server on the Integration Node*********"
/opt/ibm/iib-10.0.0.11/server/bin/mqsideploy IBNODE01 -e EG01 -a /iibdata/bars/TestBar.bar -m -w 600
echo "********* Creating the Sample Configurable Service*********"
/opt/ibm/iib-10.0.0.11/server/bin/mqsicreateconfigurableservice IBNODE01 -c ActivityLog -o SampleConfigService -n filter,fileName,minSeverityLevel,formatEntries,executionGroupFilter,numberOfLogs,enabled,maxFileSizeMb,maxAgeMins -v "","","INFO","false","","4","true","25","0"

echo "********* Testing the bar files after succesffuly deployed you can RFHUtil tool or command line as below.*********"
echo "********* Testing by putting message*********"
echo "********* Putting the message on IN queue*********"
/opt/ibm/iib-10.0.0.11/server/bin/amqsput IN QM01
Test1
Test2
echo "********* Getting the message from the OUT queue*********"
/opt/ibm/iib-10.0.0.11/server/bin/amqsget OUT QM01