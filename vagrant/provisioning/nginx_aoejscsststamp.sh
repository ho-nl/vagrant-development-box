# Add rewrite so that Aoe_JsCssTstamp works out of the box

AS_USER="sudo -u ${VAGRANT_USER}"
HOME_DIR=$(getent passwd ${VAGRANT_USER} | cut -d ':' -f6)

$AS_USER rm -f "${HOME_DIR}/nginx/server.aoejscsststamp";
$AS_USER touch "${HOME_DIR}/nginx/server.aoejscsststamp";
$AS_USER echo -n "rewrite \"^/(.*)\.(\d{10})\.(gif|png|jpg|css|js|html)\$\" /\$1.\$3 last;" > "${HOME_DIR}/nginx/server.aoejscsststamp"

service nginx restart
