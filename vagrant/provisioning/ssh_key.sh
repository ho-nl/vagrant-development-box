#!/bin/bash

set -e
AS_USER="sudo -u ${VAGRANT_USER}"
HOME_DIR=$(getent passwd ${VAGRANT_USER} | cut -d ':' -f6)


# Add host user's ssh public key to authorized_hosts
$AS_USER echo "${VAGRANT_HOST_PUBLIC_KEY}" >> ${HOME_DIR}/.ssh/authorized_keys
$AS_USER chmod 600 ${HOME_DIR}/.ssh/authorized_keys
