#!/bin/bash

killall -9 -u iibmquser
userdel --remove iibmquser
killall -9 -u iibuser
userdel --remove iibuser

groupdel mqbrkrs
groupdel mqclient

rm -rf /opt/ibm
rm -rf /tmp/mq
rm -f /var/log/syslog
rm -rf /var/mqsi
rm -rf /var/run/syslogd.pid

iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X
iptables-save

