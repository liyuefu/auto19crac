#!/bin/bash
#change format from dos to unix
#2023.06.19 useradd 增加oracle, grid时,在-G后面也要加oinstall. 否则/etc/group没有. 执行orachk时报错没有权限访问密码文件. Databases alert log showing ORA-17503/ORA-01017 (Doc ID 2919585.1)
dos2unix *.sh *.ini
. /stage/setup.ini
# setup host01
#check hostname setup on setup.ini
if [ `hostname` == ${NODE1_HOSTNAME} ]; then
  export  ORA_SID=${DB_NAME}1
  export GI_SID=+ASM1
elif [ `hostname` == ${NODE2_HOSTNAME} ]; then
  export  ORA_SID=${DB_NAME}2
  export GI_SID=+ASM2
else
  echo "checkup setup.ini, makesure NODE1_HOSTNAME is same as `hosname` on node1 and also node2. exit now."
  exit 1
fi


####install RPM package. support RHEL7/8/9 ########################
OSVER=`cat /etc/redhat-release  | awk '{ print $(NF-1) }' | awk -F. '{ print $1 }'`
if [ $OSVER != 7  -a $OSVER != 8 -a $OSVER != 9 ] ; then
    echo "Only support RHEL/OL 7/8/9. Exit"
    exit 1;
fi


ISO_MOUNT_DIR="/mnt"
echo $ISO
if [ "`ls -A $ISO_MOUNT_DIR`" = "" ]; then
#如果发现/mnt没有内容，自动mount
  if [ ! ${ISO} ]  || [ ${ISO}"x" = "false""x" ];then
#如果没有定义ISO或者ISO定义为"false"
    mount /dev/sr0 $ISO_MOUNT_DIR
  elif  [ -f /stage/$ISO ]; then
    mount -o loop /stage/${ISO}  $ISO_MOUNT_DIR
  else
      exit 1;
  fi

  #if [ ${ISO} = "false" ]; then echo "ok" ; else echo "no" ;fi
  if [ $? != "0" ]; then
#mount失败，退出
    echo "please mount ISO on /mnt."
    exit 1
  fi
fi

if [ ! -d /etc/yum.repos.d/bak ]; then
  mkdir /etc/yum.repos.d/bak
fi
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak


#create iso.repo file
if [ $OSVER != "7" ]; then
#for RHEL8/RHEL9
cat > /etc/yum.repos.d/iso.repo <<EOF
[iso_appstream]
name=iso_appstream
baseurl=file:///mnt/AppStream
enabled=1
gpgcheck=0
[iso_baseos_base]
name=iso_baseos_base
baseurl=file:///mnt/BaseOS
enabled=1
gpgcheck=0
EOF
else
cat > /etc/yum.repos.d/iso.repo <<EOF
[iso]
name=iso
baseurl=file:///mnt
enabled=1
gpgcheck=0
EOF
fi    


#RPM package 
if [ $OSVER = "7" ]; then
cat  > /stage/pkg.lst <<EOF
compat-libstdc++-33
binutils
compat-libcap1
gcc
gcc-c++
glibc
glibc-devel
ksh
libaio
libaio-devel
libgcc
libstdc++
libstdc++-devel
libXi
libXtst
make
sysstat
xdpyinfo
psmisc
expect
xorg-x11-xauth
EOF
elif [ $OSVER = "8" ]; then
cat  > /stage/pkg.lst <<EOF
bc
binutils
elfutils-libelf
elfutils-libelf-devel
fontconfig-devel
gcc
glibc
glibc-devel
ksh
libaio
libaio-devel
libXrender
libX11
libXau
libXi
libXtst
libgcc
libnsl
librdmacm
libstdc++
libstdc++-devel
libxcb
libibverbs
make
smartmontools
expect
sysstat
EOF
elif [ $OSVER = "9" ]; then
cat  > /stage/pkg.lst <<EOF
bc
binutils
compat-openssl11
elfutils-libelf
fontconfig
gcc
glibc
glibc-devel
ksh
libaio
libaio-devel
libasan
liblsan
libX11
libXau
libXi
libXrender
libXtst
libxcrypt-compat
libgcc
libibverbs
libnsl
librdmacm
libstdc++
libstdc++-devel
libxcb
libvirt-libs
make
policycoreutils
policycoreutils-python-utils
smartmontools
sysstat
expect
EOF
fi

yum install -y `awk '{print $1}' /stage/pkg.lst`
if [ $? -ne 0 ]; then
    echo "check yum and iso."
    exit 1
fi
#for RHEL9 need libcap1 , but not on ISO, so install from local disk.
if [ $OSVER != "7" ]; then
  yum install -y compat-libcap1*
fi


rpm -ivh compat-libstdc++-33-3.2.3-72.el7.x86_64.rpm
#CVUQDISK_GRP=oinstall; export CVUQDISK_GRP
#rpm -iv cvuqdisk-1.0.10-1.rpm


###########################just for RHEL7###############
#mount /dev/sr0 /mnt
#cat > /etc/yum.repos.d/redhat.repo <<EOF
#[iso]
#name=iso
#baseurl=file:///mnt
#enabled=1
#gpgcheck=0
#EOF

##pkg. ref: Doc ID 1587357.1
#cat > /stage/pkg.lst <<EOF
#bc
#binutils
#compat-libcap1
#compat-libstdc++33
#elfutils-libelf
#elfutils-libelf-devel
#fontconfig-devel
#glibc
#glibc-devel
#ksh
#libaio
#libaio-devel
#libX11
#libXau
#libXi
#libXtst
#libXrender
#libXrender-devel
#libgcc
#libstdc++
#libstdc++-devel
#libxcb
#make
#net-tools
#smartmontools
#sysstat
#xorg-x11-xauth
#nfs-utils
#psmisc
#expect
#EOF
#
#yum install -y `awk '{print $1}' /stage/pkg.lst`
#rpm -ivh compat-libstdc++-33-3.2.3-72.el7.x86_64.rpm
#CVUQDISK_GRP=oinstall; export CVUQDISK_GRP
#rpm -iv cvuqdisk-1.0.10-1.rpm
#
############################just for RHEL7 end#####################
cat > /etc/profile.d/oracle-grid.sh <<EOF
#Setting the appropriate ulimits for oracle and grid user
if [ \$USER = "oracle" ]; then
  if [ \$SHELL = "/bin/ksh" ]; then
    ulimit -u 16384
    ulimit -n 65536
  else
    ulimit -u 16384 -n 65536
  fi
fi
if [ \$USER = "grid" ]; then
  if [ \$SHELL = "/bin/ksh" ]; then
    ulimit -u 16384
    ulimit -n 65536
  else
    ulimit -u 16384 -n 65536
  fi
fi
EOF

cat > /etc/security/limits.d/99-grid-oracle-limits.conf <<EOF
oracle soft nproc 16384
oracle hard nproc 16384
oracle soft nofile 65536
oracle hard nofile 65536
oracle soft stack 10240
oracle hard stack 32768
oracle soft memlock -1
oracle hard memlock -1
grid soft nproc 16384
grid hard nproc 16384
grid soft nofile 65536
grid hard nofile 65536
grid soft stack 10240
grid hard stack 32768
grid soft memlock -1
grid hard memlock -1
EOF

# Recommended value for NOZEROCONF
cat  >> /etc/sysconfig/network <<EOF
NOZEROCONF=yes
EOF



#disable transparent_hugepage
mv /etc/default/grub /etc/default/grub.def
sed 's/\(.*\)quiet/\1quiet transparent_hugepage=never numa=off/' /etc/default/grub.def > /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
###

cat > /etc/hosts <<EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
EOF

cat >> /etc/hosts <<EOF
# Public host info
${NODE1_PUBLIC_IP}    ${NODE1_HOSTNAME}
${NODE2_PUBLIC_IP}    ${NODE2_HOSTNAME}
# Private host info
${NODE1_PRIV_IP}     ${NODE1_PRIVNAME}
${NODE2_PRIV_IP}     ${NODE2_PRIVNAME}
# Virtual host info
${NODE1_VIP_IP}      ${NODE1_VIPNAME}
${NODE2_VIP_IP}      ${NODE2_VIPNAME}
EOF

echo "-----------------------------------------------------------------"
echo -e "${INFO}`date +%F' '%T`: Setup SCAN on /etc/hosts"
echo "-----------------------------------------------------------------"
cat >> /etc/hosts <<EOF
# SCAN
${SCAN_IP1}      ${SCAN_NAME}
EOF



#####

#add kernel params. ref: (Doc ID 1587357.1)
#cat > /etc/sysctl.d/97-oracledatabase-sysctl.conf <<EOF
#fs.aio-max-nr = 1048576
#fs.file-max = 6815744
#kernel.shmall = 18446744073692774399
#kernel.shmmax = 18446744073692774399
#kernel.shmmni = 4096
#kernel.sem = 250 32000 100 128
#kernel.panic_on_oops = 1
#net.ipv4.ip_local_port_range = 9000 65500
#net.core.rmem_default = 262144
#net.core.rmem_max = 4194304
#net.core.wmem_default = 262144
#net.core.wmem_max = 1048576
#EOF
#add kernel params. ref: (Doc ID 1587357.1)
cat > /etc/sysctl.d/97-oracledatabase-sysctl.conf <<EOF
kernel.sem = 250 32000 100 128
# ref: Orabug: 26798697
kernel.panic_on_oops = 1
#turn off ASLR
kernel.exec-shield=0
kernel.randomize_va_space=0
fs.file-max = 6815744
kernel.shmall = 18446744073692774399
kernel.shmmax = 18446744073692774399
kernel.shmmni = 4096
fs.aio-max-nr = 1048576

net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
net.ipv4.ip_local_port_range = 9000 65500
#vm.min_free_kbytes = 1048576 #when RAM >=256G, set it.
#vm.swappiness = 10
kernel.numa_balancing = 0
net.ipv4.conf.bond1.rp_filter = 2
net.ipv4.conf.bond0.rp_filter = 1
net.ipv4.ipfrag_low_thresh= 15728640
net.ipv4.ipfrag_high_thresh= 16777216
EOF

/sbin/sysctl --system

userdel -fr oracle
userdel -fr grid
groupdel oinstall
groupdel dba
groupdel backupdba
groupdel dgdba
groupdel kmdba
groupdel racdba
groupadd -g 1001 oinstall
groupadd -g 1002 oper
groupadd -g 1003 dba
groupadd -g 1004 asmadmin
groupadd -g 1005 asmoper
groupadd -g 1006 asmdba
groupadd -g 1007 backupdba
groupadd -g 1008 dgdba
groupadd -g 1009 kmdba
groupadd -g 1010 racdba
useradd oracle  -p $(echo "oracle" | openssl passwd -1 -stdin) -g 1001 -G 1001,1002,1003,1004,1006,1007,1008,1009,1010
useradd grid    -p $(echo "oracle" | openssl passwd -1 -stdin) -g 1001 -G 1001,1002,1003,1004,1005,1006

cat >> /home/grid/.bash_profile <<EOF

export ORACLE_BASE=/u01/app/grid
export ORACLE_HOME=/u01/app/19.0.0/grid
export ORACLE_SID=${GI_SID}
export PATH=\$PATH:\$ORACLE_HOME/bin

umask 022
EOF

cat >> /home/oracle/.bash_profile <<EOF
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=\$ORACLE_BASE/product/19.0.0/dbhome_1
export ORACLE_SID=${ORA_SID}
export PATH=\$PATH:\$ORACLE_HOME/bin:
umask 022
EOF


cat >> /etc/pam.d/login <<EOF
session    required     pam_limits.so
EOF
#disable selinux
sed -i "s#SELINUX=enforcing#SELINUX=disabled#g" /etc/selinux/config
setenforce 0

#set tmpfs 2G
#cat >>/etc/fstab <<EOF
#tmpfs           /dev/shm        tmpfs   defaults,size=2g        0 0
#EOF

#move to 05 script.
#mkdir -p /u01/app/19.0.0/grid
#mkdir -p /u01/app/grid
#mkdir -p /u01/app/oracle/product/19.0.0/dbhome_1

#chown -R grid:oinstall /u01
#chown -R oracle:oinstall /u01/app/oracle

#mkdir -p /stage/patch/${GI_RU}
#mkdir -p /stage/patch/${GI_MRP}
#mkdir -p /stage/patch/${DB_DPBP}
#chown -R grid:oinstall /stage

#time
systemctl stop chronyd
systemctl disable chronyd
mv /etc/chrony.conf /etc/chrony.conf.bak
#firewall
systemctl stop firewalld
systemctl disable firewalld
#tuned
systemctl stop tuned.service
systemctl disable tuned.service

#
systemctl stop avahi-dnsconfd
systemctl stop avahi-daemon
systemctl disable avahi-dnsconfd
systemctl disable avahi-daemon

#ref: 2380526.1
#for RHEL8, if stop NetworkManager, netcar can not be turned on.
if [ $OSVER == 7 ]; then
  systemctl stop NetworkManager.service
  systemctl disable NetworkManager.service
fi


#for dbca . ref: Doc ID 2331884.1 
cat  >> /etc/systemd/system.conf <<EOF
DefaultTasksMax=infinity 
EOF

