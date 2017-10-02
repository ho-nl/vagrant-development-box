#!/bin/bash

set -e

AS_USER="sudo -u ${VAGRANT_USER}"
HOME_DIR=$(getent passwd ${VAGRANT_USER} | cut -d ':' -f6)

service varnish restart

sleep 1

if ! [ ${VARNISH_VCL} == 'false' ]; then
    varnishadm vcl.load mag2 ${HOME_DIR}/${VARNISH_VCL}
    varnishadm vcl.use mag2
    varnishadm vcl.discard boot
    varnishadm "ban req.url ~ ."
fi
