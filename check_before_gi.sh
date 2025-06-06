#!/bin/bash

source /stage/setup.ini

#pause function
pause(){
    echo "-----------------------------------------------------------------"
    echo -e "${INFO}Press any key to continue to check $1.."
    echo "-----------------------------------------------------------------"
    read -n 1
}

#check localhost define
pause "check localhost"
cat /etc/hosts
grep ^localhost /etc/hosts
LOCALHOST=`grep ^127.0.0.1 /etc/hosts |grep localhost | wc -l `
if [ $LOCALHOST -eq 0 ]; then
   echo -e "${ERROR} /etc/hosts no define localhost. please check it!!"
   exit;
else
   echo -e "${INFO} /etc/hosts is ok"
fi

CLUVFY=""
rm -f /tmp/cluvfy.txt
pause "check with cluvfy..., more details in /tmp/cluvfy.txt"
echo -e "${INFO} now checking cluvfy, please wait ..."
if [ -f $STAGE/grid/runcluvfy.sh ]; then
  CLUVFY=$STAGE/grid/runcluvfy.sh
elif [ $GI_HOME/bin/cluvfy  ];then
  CLUVFY=$GI_HOME/bin/cluvfy
else
  echo -e "${ERROR} no cluvfy can be found. please check it."
  exit
fi

su - grid -c "$CLUVFY stage -pre crsinst -n ${NODE1_HOSTNAME},${NODE2_HOSTNAME} -r 11gR2 -verbose " > /tmp/cluvfy.txt
grep -B 3 "failed" /tmp/cluvfy.txt


#check rpm 
pause "check rpm count"
cat /stage/pkg.lst | wc  -l 
rpm -qa `awk '{print $1}' /stage/pkg.lst` | sort | wc -l
rpm -qa|grep cvuqdisk
pause "check sharedisk"
#    共享盘在两边可见,权限正确  
echo "<DISKDISCOVERYSTRING>"
ls -l $DISKDISCOVERYSTRING
echo "<OCR_DISK>"
ls -l $OCR_DISK
echo "<DATA_DISK>"
ls -l $DATA_DISK
echo "<owner:group for udev>"
ls -l /dev/sd*
echo "<owner:group for multipath>"
ls -l /dev/dm*

pause "check user id";
#  用户grid，oracle的uid，gid在两个节点完全一样 

id grid
id oracle

pause "check selinux, getenforce"
#check selinux, enforce
getenforce
cat /etc/selinux/config

#禁用透明大页
pause "transparent_hugepage"
cat /etc/default/grub
cat /sys/kernel/mm/transparent_hugepage/enabled

#内核参数
pause "sysctl, shmmax,shmall,shmmni,shmsem,aio-max-nr,file-max,ip_local_port_range"
cat /proc/sys/kernel/shmmax
cat /proc/sys/kernel/shmall
cat /proc/sys/kernel/shmmni
cat /proc/sys/kernel/sem
cat /proc/sys/fs/aio-max-nr 
cat /proc/sys/fs/file-max
cat /proc/sys/net/ipv4/ip_local_port_range

#    防火墙
pause "firewalld"
systemctl status firewalld


pause "ulimit oracle"
su - oracle -c "ulimit -a"

pause "ulimit grid"
su - grid  -c "ulimit -a"

#ssh 
pause "check ssh grid"
su - grid -c "ssh  ${NODE2_HOSTNAME} date"
su - grid -c "ssh  ${NODE1_HOSTNAME} date"
su - oracle -c "ssh  ${NODE2_HOSTNAME} date"
su - oracle -c "ssh  ${NODE1_HOSTNAME} date"

