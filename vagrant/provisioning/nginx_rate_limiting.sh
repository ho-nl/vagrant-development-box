# Disable all rate limiting for connections from the host.

AS_USER="sudo -u ${VAGRANT_USER}"
HOME_DIR=$(getent passwd ${VAGRANT_USER} | cut -d ':' -f6)

CONFIG="map \$remote_addr \$conn_limit_map {
    default '';
}
";

rm -f "${HOME_DIR}/nginx/http.conn_ratelimit";
touch "${HOME_DIR}/nginx/http.conn_ratelimit";
echo -n "${CONFIG}" > "${HOME_DIR}/nginx/http.conn_ratelimit"

service nginx restart
