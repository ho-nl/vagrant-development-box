HOME_DIR=$(getent passwd ${VAGRANT_USER} | cut -d ':' -f6)

echo "🔥  Setting up bash aliases"

CONFIG="
alias phpd='php -dxdebug.remote_autostart=On'

";

rm -f "${HOME_DIR}/.bash_aliases";
touch "${HOME_DIR}/.bash_aliases";
$AS_USER echo -n "${CONFIG}" > "${HOME_DIR}/.bash_aliases"

echo "$(cat ${HOME_DIR}/.bash_aliases)"

if [ ! -z "${VAGRANT_HOST_CUSTOM_PROFILE}" ]
then
    echo "🔥  Setting up custom shell profile"
    $AS_USER echo "${VAGRANT_HOST_CUSTOM_PROFILE}" > ${HOME_DIR}/.profile_custom

    grep profile_custom ${HOME_DIR}/.bash_profile > /dev/null || printf "\nsource ${HOME_DIR}/.profile_custom\n\n" >> ${HOME_DIR}/.bash_profile
fi
