#!/bin/bash
source /stage/setup.ini

DISKS=`ls -dm ${ARCH_DISK}`
DISKS=`echo $DISKS|tr -d ' '`

echo "DISK list: ${DISKS}"
echo "Diskgroup Name: ${ARCH_NAME}"
cat > /tmp/create_dg_arch.sh <<EOF
$GI_HOME/bin/asmca -silent  -createDiskGroup -diskGroupName ${ARCH_NAME} -diskList $DISKS -redundancy EXTERNAL 	-compatible.asm 19.0.0.0 -compatible.rdbms 19.0.0.0 -compatible.advm 19.0.0.0
EOF

su - grid -c "sh /tmp/create_dg_arch.sh" 
