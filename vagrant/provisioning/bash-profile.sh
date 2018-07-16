HOME_DIR=$(getent passwd ${VAGRANT_USER} | cut -d ':' -f6)

echo "🔥  Setting up bash profile"

CONFIG="
export HISTCONTROL=$HISTCONTROL:ignoredups
";

rm -f "${HOME_DIR}/.bash_profile";
touch "${HOME_DIR}/.bash_profile";
$AS_USER echo -n "${CONFIG}" > "${HOME_DIR}/.bash_profile"

echo $(cat ${HOME_DIR}/.bash_profile)

