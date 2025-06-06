#!/bin/bash
make_create_database() {
cat > create_database.sh <<EOF

source /stage/setup.ini
OSVER=`cat /etc/redhat-release  | awk '{ print $(NF-1) }' | awk -F. '{ print $1 }'`
if [  \$OSVER == 9 ] ; then
   cat /etc/os-release  |grep ^NAME |grep "Oracle Linux"
   if [ \$? -eq 0 ];then
      export CV_ASSUME_DISTID=OL8 
   else
      export CV_ASSUME_DISTID=RHEL8 
   fi
elif [  \$OSVER == 8 ] ; then
   cat /etc/os-release  |grep ^NAME |grep "Oracle Linux"
   if [ \$? -eq 0 ];then
      export CV_ASSUME_DISTID=OL7 
   else
      export CV_ASSUME_DISTID=RHEL7 
   fi
fi

${DB_HOME}/bin/dbca -silent -createDatabase \\
  -templateName New_Database.dbt \\
  -initParams db_recovery_file_dest_size=2G \\
  -responseFile NO_VALUE \\
  -gdbname ${DB_NAME} \\
  -characterSet AL32UTF8 \\
  -nationalCharacterSet  AL16UTF16 \\
  -dbOptions JSERVER:false,DV:false,APEX:false,OMS:false,SPATIAL:false,IMEDIA:false,ORACLE_TEXT:false,CWMLITE:false  \\
  -sysPassword ${SYS_PASSWORD} \\
  -systemPassword ${SYS_PASSWORD} \\
  -databaseType MULTIPURPOSE \\
  -automaticMemoryManagement false \\
  -totalMemory 2048 \\
  -redoLogFileSize 300 \\
  -emConfiguration NONE \\
  -ignorePreReqs \\
  -databaseConfigType RAC \\
  -nodelist ${NODE1_HOSTNAME},${NODE2_HOSTNAME} \\
  -storageType ASM \\
  -diskGroupName +DATA \\
  -asmsnmpPassword ${SYS_PASSWORD}
EOF
}

#  -templateName General_Purpose.dbc \\
# ---------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------
# Actions on node1 only
source /stage/setup.ini

if [ `hostname` == ${NODE1_HOSTNAME} ] 
then
  # Make create_database.sh
  echo "-----------------------------------------------------------------"
  echo -e "${INFO}`date +%F' '%T`: Make create database command"
  echo "-----------------------------------------------------------------"
  make_create_database;

  # create database 
  echo "-----------------------------------------------------------------"
  echo -e "${INFO}`date +%F' '%T`: Create database"
  echo "-----------------------------------------------------------------"
  su - oracle -c "sh /stage/create_database.sh" > /tmp/db_create.log

## run datapatch and utlrp
## update: 2024.02.29 need to run datapatch -verbose. Cause this script  using dbca and 
##  -templateName General_Purpose.dbc to database.
## ref: https://mikedietrichde.com/2017/05/25/dbca-execute-datapatch-oracle-database-12-2/
#####################################################
su - oracle -c "cd ${DB_HOME}/OPatch; ./datapatch -verbose"
cat > /tmp/runutlrp.sql <<EOF
  start ?/rdbms/admin/utlrp.sql
  exit
EOF
chmod 666 /tmp/runutlrp.sql
su - oracle -c "sqlplus / as sysdba @/tmp/runutlrp.sql"

#######################################################
echo "-----------------------------------------------------------------"
echo -e "${INFO}`date +%F' '%T`: check sqlpatch from dba_registry_sqlpatch."
echo "-----------------------------------------------------------------"
cat > /tmp/check_patch.sql <<EOF
col action for a10
col status for a10
col action_time for a30
col description for a50
set linesize 200
select PATCH_ID,ACTION,STATUS,ACTION_TIME,DESCRIPTION from dba_registry_sqlpatch order by action_time;
exit;
EOF
chmod 666 /tmp/check_patch.sql
su - oracle -c "sqlplus / as sysdba @/tmp/check_patch.sql"

##display lspatches
  echo "-----------------------------------------------------------------"
  echo -e "${INFO}`date +%F' '%T`: opatch lspatches on ${NODE1_HOSTNAME}"
  echo "-----------------------------------------------------------------"
  su - grid -c "${GI_HOME}/OPatch/opatch lspatches"
  su - oracle -c "${DB_HOME}/OPatch/opatch lspatches"

  echo "-----------------------------------------------------------------"
  echo -e "${INFO}`date +%F' '%T`: opatch lspatches on ${NODE2_HOSTNAME}"
  echo "-----------------------------------------------------------------"
  su - grid -c "ssh ${NODE2_HOSTNAME} ${GI_HOME}/OPatch/opatch lspatches"
  su - oracle -c "ssh ${NODE2_HOSTNAME} ${DB_HOME}/OPatch/opatch lspatches"
  echo "-----------------------------------------------------------------"
  echo -e "${INFO}`date +%F' '%T`: finished create database."
  echo "-----------------------------------------------------------------"
fi
