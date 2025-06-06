#!/bin/bash
source /stage/setup.ini

#create directory before unzip
rm -rf /u01/app/
mkdir -p /u01/app/19.0.0/grid
mkdir -p /u01/app/grid
mkdir -p /u01/app/oracle/product/19.0.0/dbhome_1

chown -R grid:oinstall /u01
chown -R oracle:oinstall /u01/app/oracle

rm -rf /stage/patch/*
mkdir -p /stage/patch/${GI_RU}
mkdir -p /stage/patch/${GI_MRP}
mkdir -p /stage/patch/${DB_DPBP}
chown -R grid:oinstall /stage

if [ `hostname` == ${NODE1_HOSTNAME} ] 
then

echo "-----------------------------------------------------------------"
echo -e "${INFO}`date +%F' '%T`: unzip software now..."
echo "-----------------------------------------------------------------"

su - grid -c "cd ${GI_HOME};unzip /stage/*grid*.zip >/tmp/unzip_grid.log"
su - oracle -c "cd ${DB_HOME};unzip /stage/*db*.zip > /tmp/unzip_db.log"

su - grid -c "cd ${GI_HOME};mv OPatch OPatch.`date +%F-%T`;unzip /stage/p6880*.zip" >/tmp/unzip_p688.log
su - oracle -c "cd ${DB_HOME};mv OPatch OPatch.`date +%F-%T`;unzip /stage/p688*.zip" > /tmp/unzip_db_p688.log

cd /stage/patch/${GI_RU}; 
su grid -c "unzip /stage/*${GI_RU}*.zip" >/tmp/unzip_p${GI_RU}.log
cd /stage/patch/${GI_MRP}; 
su grid -c "unzip /stage/*${GI_MRP}*.zip" >/tmp/unzip_p${GI_MRP}.log
cd /stage/patch/${DB_DPBP}; 
su grid -c "unzip /stage/*${DB_DPBP}*.zip" >/tmp/unzip_p${DB_DPBP}.log

#unzip stubs.tar, this is only for RHEL9
OSVER=`cat /etc/redhat-release  | awk '{ print $(NF-1) }' | awk -F. '{ print $1 }'`

if [ $OSVER = "9" ]; then
  su - grid -c "mkdir /stage/patch/35775632;cd /stage/patch/35775632;unzip /stage/p35775632_190000_Linux*.zip" > /tmp/unzip_stubs.log

  su - grid -c "cd  ${GI_HOME}/lib/stubs; tar -xvf /stage/patch/35775632/stubs.tar" > /tmp/tar_stubs.log

  su - oracle -c "cd  ${DB_HOME}/lib/stubs; tar -xvf /stage/patch/35775632/stubs.tar" > /tmp/tar_stubs.log
fi


echo "-----------------------------------------------------------------"
echo -e "${INFO}`date +%F' '%T`: unzip software done..."
echo "-----------------------------------------------------------------"
fi
