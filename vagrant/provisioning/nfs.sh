#!/bin/bash

set -e

echo "Changing user id"

service nginx stop
service ${VAGRANT_FPM_SERVICE} stop
usermod -u ${VAGRANT_UID} ${VAGRANT_USER}
service nginx start
service ${VAGRANT_FPM_SERVICE} start
true # Return true at the end of the stack
