#!/bin/bash
source /stage/setup.ini

DISKS=`ls -dm ${DATA_DISK}`
DISKS=`echo $DISKS|tr -d ' '`

cat > /tmp/create_dg.sh <<EOF
$GI_HOME/bin/asmca -silent  -createDiskGroup -diskGroupName ${DATA_NAME} -diskList $DISKS -redundancy EXTERNAL 	-compatible.asm 19.0.0.0 -compatible.rdbms 19.0.0.0 -compatible.advm 19.0.0.0
EOF

su - grid -c "sh /tmp/create_dg.sh" 
