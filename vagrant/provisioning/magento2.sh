#!/bin/bash

set -e

AS_USER="sudo -u ${VAGRANT_USER}"
HOME_DIR=$(getent passwd ${VAGRANT_USER} | cut -d ':' -f6)
MAGENTO_DIR=${VAGRANT_PROJECT_DIR:-magento2}

echo "🔥 Ensuring the box is ready for Magento 2"

$AS_USER touch ${HOME_DIR}/nginx/magento2.flag

[ -d ${HOME_DIR}/${MAGENTO_DIR} ] || $AS_USER mkdir ${HOME_DIR}/${MAGENTO_DIR}
[ -d ${HOME_DIR}/${MAGENTO_DIR}/pub ] || $AS_USER mkdir ${HOME_DIR}/${MAGENTO_DIR}/pub

rm -rf ${HOME_DIR}/public
$AS_USER ln -fs ${HOME_DIR}/${MAGENTO_DIR}/pub ${HOME_DIR}/public
