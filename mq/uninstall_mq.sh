#End MQ Activity
/opt/mqm/bin/setmqenv -s
dspmq -o installation
endmqm QM1
endmqlsr -m QM1

#Remove MQ Packages
rpm -qa | grep MQSeries | xargs rpm -ev
killall -9 -u mqm
userdel --remove mqm
groupdel mqm

rm -rf /opt/mqm
rm -rf /var/mqm
rm -rf /tmp/mq
rm -rf /etc/mqm/mq-config
rm -rf /etc/init.d/iibservice
for f in `ls /iibdata/mq-scripts/*`
do
 echo "Removing $f"
 rm -rf /usr/local/bin/$f
done
