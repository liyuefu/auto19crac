#!/bin/bash

config_file="config.ini"
source ./config.ini

#get verion 
if [[ "$ISO_FILE" =~ rhel-server-([0-9]+)  ]] ||  [[ "$ISO_FILE" =~ rhel-([0-9]+) ]] || [[ "$ISO_FILE" =~ OracleLinux-R([0-9]+) ]]; then
  RHEL_VER=${BASH_REMATCH[1]}
else
  echo "Invalid ISO filename"
  exit
fi
# Function to replace variables in the model file with values from config.ini
replace_vars() {
  local model_file=$1
  local config_file=$2
  local output_file=$3

  cp "$model_file" "$output_file"

  # Read the config.ini file and replace the variables in the output file
  while IFS='=' read -r key value; do
    if [[ $key && $value && ! $key =~ ^# ]]; then
      sed -i "s|$key|$value|g" "$output_file"
    fi
  done < "$config_file"
}


#change setup.ini
while IFS='=' read -r key value; do
  if [[ $key && $value && ! $key =~ ^# ]]; then
    export "$key=$value"
  fi
done < config.ini

# Perform the replacement in setup.model
sed -e "s/DB_NAME_STR/$DB_NAME/g" \
    -e "s/GI_RU_STR/$GI_RU/g" \
    -e "s/GI_MRP_STR/$GI_MRP/g" \
    -e "s/DB_DPBP_STR/$DB_DPBP/g" \
    -e "s/NODE1_NAME/$NODE1_NAME/g" \
    -e "s/NODE2_NAME/$NODE2_NAME/g" \
    -e "s/NODE1_IP/$NODE1_IP/g" \
    -e "s/NODE2_IP/$NODE2_IP/g" \
    -e "s/NODE_VIP1/$NODE_VIP1/g" \
    -e "s/NODE_VIP2/$NODE_VIP2/g" \
    -e "s/RAC_SCAN_IP/$RAC_SCAN_IP/g" \
    setup.model > setup.ini


# 01 shell
model_file="01_create_vm.model"
output_file="01_create_vm.sh"

# Replace variables in the model file
replace_vars "$model_file" "$config_file" "$output_file"

# Make the generated script executable
chmod +x "$output_file"

# 01a shell
model_file="01a_add_sharedisk.model"
output_file="01a_add_sharedisk.sh"

# Replace variables in the model file
replace_vars "$model_file" "$config_file" "$output_file"

# Make the generated script executable
chmod +x "$output_file"



#redhat1.ini, redhat2.ini
if [ "$RHEL_VER"x == "7"x ]; then
  model_file="redhat7_1.model"
  output_file="redhat1.ini"
  replace_vars "$model_file" "$config_file" "$output_file"
  model_file="redhat7_2.model"
  output_file="redhat2.ini"
  replace_vars "$model_file" "$config_file" "$output_file"
elif [ "$RHEL_VER"x == "8"x ]; then
  model_file="redhat8_1.model"
  output_file="redhat1.ini"
  replace_vars "$model_file" "$config_file" "$output_file"
  model_file="redhat8_2.model"
  output_file="redhat2.ini"
  replace_vars "$model_file" "$config_file" "$output_file"
elif [ "$RHEL_VER"x == "9"x ]; then
  model_file="redhat9_1.model"
  output_file="redhat1.ini"
  replace_vars "$model_file" "$config_file" "$output_file"
  model_file="redhat9_2.model"
  output_file="redhat2.ini"
  replace_vars "$model_file" "$config_file" "$output_file"
fi


echo "done"

