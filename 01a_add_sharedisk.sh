#!/bin/bash

# Set up environment variables
export PATH="/usr/bin/virtualbox:$PATH"
var_nodename1="1927c1"
var_nodename2="1927c2"
var_groupname="19c27-ol94"
var_vmdata="/home/nome/work/vm"

# Attach storage for NODE1
VBoxManage storageattach "$var_nodename1" --storagectl SATA --port 1 --device 0 --type hdd --medium "$var_vmdata/$var_groupname/${var_groupname}_19c-rac-ocr.vdi" --mtype shareable
VBoxManage storageattach "$var_nodename1" --storagectl SATA --port 3 --device 0 --type hdd --medium "$var_vmdata/$var_groupname/${var_groupname}_19c-rac-data01.vdi" --mtype shareable
VBoxManage storageattach "$var_nodename1" --storagectl SATA --port 4 --device 0 --type hdd --medium "$var_vmdata/$var_groupname/${var_groupname}_19c-rac-data02.vdi" --mtype shareable

# Attach storage for NODE2
VBoxManage storageattach "$var_nodename2" --storagectl SATA --port 1 --device 0 --type hdd --medium "$var_vmdata/$var_groupname/${var_groupname}_19c-rac-ocr.vdi" --mtype shareable
VBoxManage storageattach "$var_nodename2" --storagectl SATA --port 3 --device 0 --type hdd --medium "$var_vmdata/$var_groupname/${var_groupname}_19c-rac-data01.vdi" --mtype shareable
VBoxManage storageattach "$var_nodename2" --storagectl SATA --port 4 --device 0 --type hdd --medium "$var_vmdata/$var_groupname/${var_groupname}_19c-rac-data02.vdi" --mtype shareable

# Start the virtual machines
VBoxManage startvm "$var_nodename1"
VBoxManage startvm "$var_nodename2"

