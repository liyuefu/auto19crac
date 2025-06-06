#!/bin/bash
make_gi_installation() {
cat > gi_installation.sh <<EOF
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

${GI_HOME}/gridSetup.sh  -applyRU /stage/patch/${GI_RU}/${GI_RU} -applyOneOffs /stage/patch/${GI_MRP}/${GI_MRP} -ignorePrereq -waitforcompletion -silent \\
    -responseFile ${GI_HOME}/install/response/gridsetup.rsp \\
    INVENTORY_LOCATION=${ORA_INVENTORY} \\
    SELECTED_LANGUAGES=${ORA_LANGUAGES} \\
    oracle.install.option=CRS_CONFIG \\
    ORACLE_BASE=${GRID_BASE} \\
    oracle.install.asm.OSDBA=asmdba \\
    oracle.install.asm.OSOPER=asmoper \\
    oracle.install.asm.OSASM=asmadmin \\
    oracle.install.crs.config.scanType=LOCAL_SCAN \\
    oracle.install.crs.config.gpnp.scanName=${SCAN_NAME} \\
    oracle.install.crs.config.gpnp.scanPort=${SCAN_PORT} \\
    oracle.install.crs.config.ClusterConfiguration=STANDALONE \\
    oracle.install.crs.config.configureAsExtendedCluster=false \\
    oracle.install.crs.config.clusterName=${CLUSTER_NAME} \\
    oracle_install_crs_ConfigureMgmtDB=false \\
    oracle.install.crs.config.clusterNodes=${NODE1_HOSTNAME}:${NODE1_VIPNAME}:HUB,${NODE2_HOSTNAME}:${NODE2_VIPNAME}:HUB \\
    oracle.install.crs.config.networkInterfaceList=${NET_DEVICE1}:${PUBLIC_SUBNET}:1,${NET_DEVICE2}:${PRIVATE_SUBNET}:5 \\
    oracle.install.crs.config.gpnp.configureGNS=false \\
    oracle.install.crs.config.autoConfigureClusterNodeVIP=false \\
    oracle.install.asm.configureGIMRDataDG=false \\
    oracle.install.crs.config.useIPMI=false \\
    oracle.install.asm.storageOption=ASM \\
    oracle.install.asmOnNAS.configureGIMRDataDG=false \\
    oracle.install.asm.SYSASMPassword=${SYS_PASSWORD} \\
    oracle.install.asm.diskGroup.name=${OCR_NAME} \\
    oracle.install.asm.diskGroup.redundancy=${OCR_REDUNDANCY} \\
    oracle.install.asm.diskGroup.AUSize=4 \\
EOF

DISKS=`ls -dm  $OCR_DISK`
DISKS=`echo $DISKS|tr -d ' '`
cat >> gi_installation.sh <<EOF
    oracle.install.asm.diskGroup.disks=${DISKS} \\
    oracle.install.asm.diskGroup.diskDiscoveryString=${DISKDISCOVERYSTRING} \\
    oracle.install.asm.configureAFD=false \\
    oracle.install.asm.gimrDG.AUSize=1 \\
    oracle.install.asm.monitorPassword=${SYS_PASSWORD} \\
    oracle.install.crs.configureRHPS=false \\
    oracle.install.crs.config.ignoreDownNodes=false \\
    oracle.install.config.managementOption=NONE \\
    oracle.install.config.omsPort=0 \\
    oracle.install.crs.rootconfig.executeRootScript=false
EOF
}

make_gi_config() {
cat > gi_config.sh <<EOF
source  /stage/setup.ini
${GI_HOME}/gridSetup.sh -silent -executeConfigTools \\
    -responseFile ${GI_HOME}/install/response/gridsetup.rsp \\
    INVENTORY_LOCATION=${ORA_INVENTORY} \\
    SELECTED_LANGUAGES=${ORA_LANGUAGES} \\
    oracle.install.option=CRS_CONFIG \\
    ORACLE_BASE=${GRID_BASE} \\
    oracle.install.asm.OSDBA=asmdba \\
    oracle.install.asm.OSOPER=asmoper \\
    oracle.install.asm.OSASM=asmadmin \\
    oracle.install.crs.config.scanType=LOCAL_SCAN \\
    oracle.install.crs.config.gpnp.scanName=${SCAN_NAME} \\
    oracle.install.crs.config.gpnp.scanPort=${SCAN_PORT} \\
    oracle.install.crs.config.clusterName=${CLUSTER_NAME} \\
    oracle.install.crs.config.ClusterConfiguration=STANDALONE \\
    oracle.install.crs.config.configureAsExtendedCluster=false \\
    oracle_install_crs_ConfigureMgmtDB=false \\
    oracle.install.crs.config.gpnp.configureGNS=false \\
    oracle.install.crs.config.autoConfigureClusterNodeVIP=false \\
    oracle.install.asm.configureGIMRDataDG=false \\
    oracle.install.crs.config.useIPMI=false \\
    oracle.install.asm.storageOption=ASM \\
    oracle.install.asmOnNAS.configureGIMRDataDG=false \\
    oracle.install.asm.SYSASMPassword=${SYS_PASSWORD} \\
    oracle.install.asm.diskGroup.name=${OCR_NAME} \\
    oracle.install.asm.diskGroup.redundancy=${OCR_REDUNDANCY} \\
    oracle.install.asm.diskGroup.AUSize=4 \\
    oracle.install.asm.gimrDG.AUSize=1 \\
    oracle.install.asm.monitorPassword=${SYS_PASSWORD} \\
    oracle.install.crs.configureRHPS=false \\
    oracle.install.crs.config.ignoreDownNodes=false \\
    oracle.install.config.managementOption=NONE \\
    oracle.install.config.omsPort=0 \\
    oracle.install.crs.rootconfig.executeRootScript=false
EOF
}

change_ssh()
{
  OSVER=`cat /etc/redhat-release  | awk '{ print $(NF-1) }' | awk -F. '{ print $1 }'`
  if [ $OSVER = 9 ] ; then
    #ref: 2555697.1, https://blog.csdn.net/yhw1809/article/details/132968293
    if [ ! -f /usr/bin/scp.orig ];then
      cat >/tmp/scp <<AAA
      /usr/bin/scp.orig -T -O \$*
AAA
      cat >/stage/fix_openssh8.sh <<EOF
      cd /usr/bin
      cp /usr/bin/scp /usr/bin/scp.`date +%y%m%d_%H%M%S`
      mv /usr/bin/scp /usr/bin/scp.orig
      mv /tmp/scp /usr/bin/scp
      chmod 555 /usr/bin/scp
EOF
      sh /stage/fix_openssh8.sh
    fi
    cat >/stage/fix_sshUserSetup.sh <<EOF
      source /stage/setup.ini
      cd $GI_HOME/deinstall;
      sed -i.bak 's/BITS=1024/BITS=3072/g' sshUserSetup.sh
EOF
    sh /stage/fix_sshUserSetup.sh
  fi

}

setup_equiv()
{
  source /stage/setup.ini
  change_ssh

  expect /stage/setup_user_equ.ini grid   ${GRID_PASSWORD}   ${NODE1_HOSTNAME} ${NODE2_HOSTNAME} ${GI_HOME}/deinstall/sshUserSetup.sh >/tmp/setup_equiv_grid.log
  expect /stage/setup_user_equ.ini oracle ${ORACLE_PASSWORD} ${NODE1_HOSTNAME} ${NODE2_HOSTNAME} ${GI_HOME}/deinstall/sshUserSetup.sh >/tmp/setup_equiv_oracle.log
  expect /stage/setup_user_equ.ini root ${ROOT_PASSWORD} ${NODE1_HOSTNAME} ${NODE2_HOSTNAME} ${GI_HOME}/deinstall/sshUserSetup.sh >/tmp/setup_equiv_root.log 

}    

install_cvuqdisk()
{
  source /stage/setup.ini
  rpm -ivh  ${GI_HOME}/cv/rpm/cvuqdisk*.rpm
  scp ${GI_HOME}/cv/rpm/cvuqdisk*.rpm ${NODE2_HOSTNAME}:/stage
  ssh root@${NODE2_HOSTNAME} rpm -ivh /stage/cvuqdisk*.rpm
}
source /stage/setup.ini

if [ `hostname` == ${NODE1_HOSTNAME} ] 
then
  # setup ssh equivalence (node1 only)
  echo "-----------------------------------------------------------------"
  echo -e "${INFO}`date +%F' '%T`: Setup  equivalence"
  echo "-----------------------------------------------------------------"
  setup_equiv;

  # Install cvuqdisk package
  echo "-----------------------------------------------------------------"
  echo -e "${INFO}`date +%F' '%T`: Install cvuqdisk package"
  echo "-----------------------------------------------------------------"

  install_cvuqdisk;

  echo "-----------------------------------------------------------------"
  echo -e "${INFO}`date +%F' '%T`: Make GI install command"
  echo "-----------------------------------------------------------------"
  make_gi_installation ;
  echo "-----------------------------------------------------------------"
  echo -e "${INFO}`date +%F' '%T`: grid_setup.sh "
  echo "-----------------------------------------------------------------"

  su - grid -c "sh /stage/gi_installation.sh" > /tmp/gi_install.log 2>&1

  #-------------------------------------------------------
  echo "-----------------------------------------------------------------"
  echo -e "${INFO}`date +%F' '%T`: root.sh node1"
  echo "-----------------------------------------------------------------"
  sh ${ORA_INVENTORY}/orainstRoot.sh
  sh ${GI_HOME}/root.sh > /tmp/gi_root.log 2>&1

  if [ $? != 0 ]; then
    echo "run gi_root.sh on  node1 failed."
    exit 2
  fi
  #-------------------------------------------------------
  echo "-----------------------------------------------------------------"
  echo -e "${INFO}`date +%F' '%T`: root.sh node2"
  echo "-----------------------------------------------------------------"

  ssh root@${NODE2_HOSTNAME} sh ${ORA_INVENTORY}/orainstRoot.sh
  ssh root@${NODE2_HOSTNAME} sh ${GI_HOME}/root.sh > /tmp/node2_gi_root.log 2>&1
  #-------------------------------------------------------

  if [ $? != 0 ]; then
    echo "run gi_root.sh on  node2 failed."
    exit 2
  fi
  echo "-----------------------------------------------------------------"
  echo -e "${INFO}`date +%F' '%T`: after root.sh ,finish grid setup"
  echo "-----------------------------------------------------------------"
  make_gi_config ;

  su - grid -c "sh /stage/gi_config.sh" > /tmp/after_root_config.log 2>&1
  echo "-----------------------------------------------------------------"
  echo -e "${INFO}`date +%F' '%T`: gi install finished."
  echo "-----------------------------------------------------------------"
fi
