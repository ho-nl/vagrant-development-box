#!/bin/bash

set -e

echo "Starting varnish..."

AS_USER="sudo -u ${VAGRANT_USER}"
HOME_DIR=$(getent passwd ${VAGRANT_USER} | cut -d ':' -f6)

[ ${VARNISH_VCL} ] && varnishadm vcl.load mag2 ${HOME_DIR}/${VARNISH_VCL}
[ ${VARNISH_VCL} ] && varnishadm vcl.use mag2
[ ${VARNISH_VCL} ] && varnishadm "ban req.url ~ ."

service varnish restart
