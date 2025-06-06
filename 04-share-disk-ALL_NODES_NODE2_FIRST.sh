#!/bin/bash
. /stage/setup.ini
if [ `hostname` == ${NODE1_HOSTNAME} ] 
then
cat /dev/null > /etc/udev/rules.d/99-oracleasm.rules 
echo "KERNEL==\"sdb1\",SUBSYSTEM==\"block\",PROGRAM==\"/lib/udev/scsi_id -g -u -d /dev/\$parent\",RESULT==\"`/lib/udev/scsi_id -g -u -d /dev/sdb`\",SYMLINK+=\"asm-2g-ocr \",OWNER=\"grid\",GROUP=\"asmadmin\",MODE=\"0660\"" >> /etc/udev/rules.d/99-oracleasm.rules
echo "KERNEL==\"sdc1\",SUBSYSTEM==\"block\",PROGRAM==\"/lib/udev/scsi_id -g -u -d /dev/\$parent\",RESULT==\"`/lib/udev/scsi_id -g -u -d /dev/sdc`\",SYMLINK+=\"asm-10g-data1 \",OWNER=\"grid\",GROUP=\"asmadmin\",MODE=\"0660\"" >> /etc/udev/rules.d/99-oracleasm.rules
echo "KERNEL==\"sdd1\",SUBSYSTEM==\"block\",PROGRAM==\"/lib/udev/scsi_id -g -u -d /dev/\$parent\",RESULT==\"`/lib/udev/scsi_id -g -u -d /dev/sdd`\",SYMLINK+=\"asm-10g-data2 \",OWNER=\"grid\",GROUP=\"asmadmin\",MODE=\"0660\"" >> /etc/udev/rules.d/99-oracleasm.rules

partprobe /dev/sdb
partprobe /dev/sdc
partprobe /dev/sdd
ls -l /dev/asm*

sleep 5

udevadm control --reload
udevadm trigger
exit
fi

##host2#############################
#disk="/dev/sdb /dev/sdc /dev/sdd /dev/sde"
disk="/dev/sdb /dev/sdc /dev/sdd "

for i in $disk;do
echo "n
p
1


w
"|fdisk $i;done

cat /dev/null > /etc/udev/rules.d/99-oracleasm.rules 
echo "KERNEL==\"sdb1\",SUBSYSTEM==\"block\",PROGRAM==\"/lib/udev/scsi_id -g -u -d /dev/\$parent\",RESULT==\"`/lib/udev/scsi_id -g -u -d /dev/sdb`\",SYMLINK+=\"asm-2g-ocr \",OWNER=\"grid\",GROUP=\"asmadmin\",MODE=\"0660\"" >> /etc/udev/rules.d/99-oracleasm.rules
echo "KERNEL==\"sdc1\",SUBSYSTEM==\"block\",PROGRAM==\"/lib/udev/scsi_id -g -u -d /dev/\$parent\",RESULT==\"`/lib/udev/scsi_id -g -u -d /dev/sdc`\",SYMLINK+=\"asm-10g-data1 \",OWNER=\"grid\",GROUP=\"asmadmin\",MODE=\"0660\"" >> /etc/udev/rules.d/99-oracleasm.rules
echo "KERNEL==\"sdd1\",SUBSYSTEM==\"block\",PROGRAM==\"/lib/udev/scsi_id -g -u -d /dev/\$parent\",RESULT==\"`/lib/udev/scsi_id -g -u -d /dev/sdd`\",SYMLINK+=\"asm-10g-data2 \",OWNER=\"grid\",GROUP=\"asmadmin\",MODE=\"0660\"" >> /etc/udev/rules.d/99-oracleasm.rules

udevadm control --reload
udevadm trigger
sleep 5
ls -l /dev/asm*
