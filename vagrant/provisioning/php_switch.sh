#!/usr/bin/env bash

# Installing PHP-related packages seems to reset the curently active PHP version, and switching
# version within the same provisioning script does not seem to work for some reason, so force it
# back to the configured version in a separate script.
echo "🔥  Switching to PHP $VAGRANT_PHP_VERSION"
hypernode-switch-php $VAGRANT_PHP_VERSION &>/dev/null