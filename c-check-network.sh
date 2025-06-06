#!/bin/bash
#ref: 1054902.1 How to Validate Network and Name Resolution Setup for the Clusterware and RAC

source /stage/setup.ini

echo -e "netstat -in to check MTU"
/bin/netstat -in

#MTULIST=`netstat -ni |awk '{ print $2 }' |grep -v 65536 |grep -v MTU  |grep -v Interface | uniq`
#echo -e "${INFO} MTU are : $MTULIST"

echo -e "ifconfig to check ip, mask , subset..."
#check ip ,subnet, broadcast,mask
/sbin/ifconfig

#Linux default MTU is 1500.
MTU=1500
#Ping all public nodenames from the local public IP with packet size of MTU
if [ `hostname` == ${NODE1_HOSTNAME} ]; then
    FROMPUBLIC=${NODE1_PUBLIC_IP}
    FROMPRIV=${NODE1_PRIV_IP}
else
    FROMPUBLIC=${NODE2_PUBLIC_IP}
    FROMPRIV=${NODE2_PRIV_IP}
fi


echo -e "${INFO} ping public hostname"
echo "ping ${NODE1_HOSTNAME}"
/bin/ping -s $MTU  -c 2 -I ${FROMPUBLIC} ${NODE1_HOSTNAME}
/bin/ping -s $MTU  -c 2 -I ${FROMPUBLIC} ${NODE1_HOSTNAME}

echo "ping ${NODE2_HOSTNAME}"
/bin/ping -s $MTU  -c 2 -I ${FROMPUBLIC} ${NODE2_HOSTNAME}
/bin/ping -s $MTU  -c 2 -I ${FROMPUBLIC} ${NODE2_HOSTNAME}


echo -e "${INFO} ping priv ip"
#ping all private IPs from all local private ip with packet sizei of MTU.
echo "ping ${NODE1_PRIV_IP}"
/bin/ping -s $MTU -c 2 -I ${FROMPRIV} ${NODE1_PRIV_IP}
/bin/ping -s $MTU -c 2 -I ${FROMPRIV} ${NODE1_PRIV_IP}
echo "ping ${NODE2_PRIV_IP}"
/bin/ping -s $MTU -c 2 -I ${FROMPRIV} ${NODE2_PRIV_IP}
/bin/ping -s $MTU -c 2 -I ${FROMPRIV} ${NODE2_PRIV_IP}

echo -e "${INFO} traceroute "
#Traceroute all private IP(s) from all local private IP(s) with 
/bin/traceroute -s ${FROMPRIV}  -r -F ${NODE1_PRIV_IP}  --mtu 28
/bin/traceroute -s ${FROMPRIV}  -r -F ${NODE2_PRIV_IP}  --mtu 28

echo -e "${INFO} ping vip-name"
# Ping of all VIP nodename should resolve to correct IP
# Before the clusterware is installed, ping should be able to resolve VIP nodename but
# should fail as VIP is managed by the clusterware
# After the clusterware is up and running, ping should succeed

/bin/ping -c 2 ${NODE1_VIPNAME}
/bin/ping -c 2 ${NODE1_VIPNAME}

/bin/ping -c 2 ${NODE2_VIPNAME}
/bin/ping -c 2 ${NODE2_VIPNAME}


echo -e "${INFO} ping ${SCAN_NAME}"
# Ping of SCAN name should resolve to correct IP
# Before the clusterware is installed, ping should be able to resolve SCAN name but
# should fail as SCAN VIP is managed by the clusterware
# After the clusterware is up and running, ping should succeed

/bin/ping -s $MTU -c 2 -I ${FROMPUBLIC} ${SCAN_NAME}
/bin/ping -s $MTU -c 2 -I ${FROMPUBLIC} ${SCAN_NAME}

#Nslookup VIP hostname and SCAN name
# applies to 11gR2
# To check whether VIP nodename and SCAN name are setup properly in DNS
# we don't use nameserver. so skip this.
#/usr/bin/nslookup ${NODE1_VIPNAME}
#/usr/bin/nslookup ${NODE2_VIPNAME}
#/usr/bin/nslookup ${SCAN_NAME}

#To check name resolution order
# /etc/nsswitch.conf on Linux, Solaris and hp-ux, /etc/netsvc.conf on AIX
echo -e "${INFO} nsswitch.conf "
/bin/grep ^hosts /etc/nsswitch.conf

echo -e "${INFO} /etc/hosts"
#To check local hosts file
# If local files is in naming switch setting (nsswitch.conf), to make sure
# hosts file doesn't have typo or misconfiguration, grep all nodename and IP
# 127.0.0.1 should not map to SCAN name, public, private and VIP hostname
cat /etc/hosts

