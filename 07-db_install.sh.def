#!/bin/bash

make_RDBMS_software_installation() {
cat > /stage/RDBMS_software_installation.sh <<EOF
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


${DB_HOME}/runInstaller -applyRU /stage/patch/${GI_RU}/${GI_RU}  -applyOneOffs /stage/patch/${GI_MRP}/${GI_MRP},/stage/patch/${DB_DPBP}/${DB_DPBP}  -ignorePrereq -waitforcompletion -silent \\
        -responseFile ${DB_HOME}/install/response/db_install.rsp \\
        oracle.install.option=INSTALL_DB_SWONLY \\
        ORACLE_HOSTNAME=${ORACLE_HOSTNAME} \\
        UNIX_GROUP_NAME=oinstall \\
        INVENTORY_LOCATION=${ORA_INVENTORY} \\
        SELECTED_LANGUAGES=${ORA_LANGUAGES} \\
        ORACLE_HOME=${DB_HOME} \\
        ORACLE_BASE=${DB_BASE} \\
        oracle.install.db.InstallEdition=EE \\
        oracle.install.db.OSDBA_GROUP=dba \\
        oracle.install.db.OSBACKUPDBA_GROUP=backupdba \\
        oracle.install.db.OSDGDBA_GROUP=dgdba \\
        oracle.install.db.OSKMDBA_GROUP=kmdba \\
        oracle.install.db.OSRACDBA_GROUP=racdba \\
        oracle.install.db.CLUSTER_NODES=${NODE1_HOSTNAME},${NODE2_HOSTNAME} \\
        oracle.install.db.isRACOneInstall=false \\
        oracle.install.db.rac.serverpoolCardinality=0 \\
        oracle.install.db.config.starterdb.type=GENERAL_PURPOSE \\
        oracle.install.db.ConfigureAsContainerDB=true \\
        SECURITY_UPDATES_VIA_MYORACLESUPPORT=false \\
        DECLINE_SECURITY_UPDATES=true
EOF
}

source /stage/setup.ini

if [ `hostname` == ${NODE1_HOSTNAME} ] 
then

  # install rdbms software 
  echo "-----------------------------------------------------------------"
  echo -e "${INFO}`date +%F' '%T`: Install Oracle db"
  echo "-----------------------------------------------------------------"
  make_RDBMS_software_installation;
  su - oracle -c "sh /stage/RDBMS_software_installation.sh" >/tmp/db_install.log
  sh ${DB_HOME}/root.sh
  ssh root@${NODE2_HOSTNAME} sh ${DB_HOME}/root.sh

  echo "-----------------------------------------------------------------"
  echo -e "${INFO}`date +%F' '%T`: Install Oracle db finished."
  echo "-----------------------------------------------------------------"

fi
