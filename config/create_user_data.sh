#!/bin/bash
################################################################################
# create_user_data
########################################
# This script creates `user-data.yaml` from `user-data.yaml.in` by
# encoding all files in the `data` directory with gzip+base64, then appending
# a `write_files` block to the `cloud-init` config.
#
# WARNING: This script ASSUMES that your `user-data.yaml.in` ENDS in a `write_files`
# block, and appends more files to that. You cannot have multiple `write_files` blocks
################################################################################
BASEDIR=$(cd "${BASH_SOURCE[0]%/*}" && pwd)

CONFIG_DIR="${BASEDIR}"
DATA_DIR="${CONFIG_DIR}/../data"
USER_DATA="${CONFIG_DIR}/user-data.yaml"

cp ${CONFIG_DIR}/user-data.yaml.in ${USER_DATA}

for file in $(ls ${DATA_DIR}); do

  echo "  -   encoding: gzip" >>${USER_DATA}
  echo "      path: /home/ubuntu/${file}" >>${USER_DATA}
  echo "      content: !!binary |" >>${USER_DATA}
  echo -n "        " >>${USER_DATA}
  cat ${DATA_DIR}/${file} | gzip | base64 -w0 >>${CONFIG_DIR}/user-data.yaml
  
done

cloud-localds ${CONFIG_DIR}/seed.img ${CONFIG_DIR}/user-data.yaml ${CONFIG_DIR}/metadata.yaml
