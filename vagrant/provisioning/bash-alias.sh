HOME_DIR=$(getent passwd ${VAGRANT_USER} | cut -d ':' -f6)

echo "🔥  Setting up bash aliases"

CONFIG="
alias phpd='php -dxdebug.remote_autostart=On'
";

rm -f "${HOME_DIR}/.bash_aliases";
touch "${HOME_DIR}/.bash_aliases";
$AS_USER echo -n "${CONFIG}" > "${HOME_DIR}/.bash_aliases"

echo $(cat ${HOME_DIR}/.bash_aliases)
