#!/bin/bash
################################################################################
# create_user_data
########################################
# This script creates `user-data.yaml` from `user-data.yaml.in` by
# encoding all files in the `data` directory with gzip+base64, then appending
# a `write_files` block to the `cloud-init` config.
################################################################################
BASEDIR=$(cd "${BASH_SOURCE[0]%/*}" && pwd)

CONFIG_DIR="${BASEDIR}"
DATA_DIR="${CONFIG_DIR}/../data"
USER_DATA="${CONFIG_DIR}/user-data.yaml"
ADDL_USER_DATA="${CONFIG_DIR}/addl-user-data.yaml"

cp ${CONFIG_DIR}/user-data.yaml.in ${USER_DATA}

# If there's additional user data, go ahead and append it now.
# We shouldn't append it later, because if it contains
# any write_files directives, we want to append lines to that,
# since there can't be multiple.
if [ -f ${ADDL_USER_DATA} ]; then
  cat ${ADDL_USER_DATA} >> ${USER_DATA}
fi

# Get an array of filenames in $DATA_DIR
shopt -s nullglob
data_files=(${DATA_DIR}/*)
if [ ${#data_files[@]} -eq 0 ]; then
  exit 0
fi

# Determine if there are any write_files directives
if ! grep -xq "write_files:" ${USER_DATA}; then
  echo "write_files:" >>${USER_DATA}
fi

for file in $(ls ${DATA_DIR}); do
  data=$(cat ${DATA_DIR}/${file} | gzip | base64 -w0)
  text+="  -  encoding: gzip\n"
  text+="     path: /home/ubuntu/${file}\n"
  text+="     content: !!binary \|\n"
  text+="       ${data}"
  sed -i 's|write_files:|write_files:\n'"${text}"'|' ${USER_DATA}
done

cloud-localds ${CONFIG_DIR}/seed.img ${CONFIG_DIR}/user-data.yaml ${CONFIG_DIR}/metadata.yaml
