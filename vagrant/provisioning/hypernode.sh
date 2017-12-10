#!/bin/bash
set -e

echo "🔥  Setting base config"

truncate -s 0 /var/mail/app

user='app'
homedir=$(getent passwd ${user} | cut -d ':' -f6)
mkdir -p /root/.ssh
sudo -u $user mkdir -p "$homedir/.ssh"
touch /root/.ssh/authorized_keys
sudo -u $user touch "$homedir/.ssh/authorized_keys"
chmod 700 /root/.ssh "$homedir/.ssh"
chmod 600 /root/.ssh/authorized_keys "$homedir/.ssh/authorized_keys"

if ssh-add -L >/dev/null 2>/dev/null; then
    user_combined=$(ssh-add -L | awk '!NF || !seen[$0]++' "$homedir/.ssh/authorized_keys" -)
    echo "$user_combined" > "$homedir/.ssh/authorized_keys"
    root_combined=$(ssh-add -L | awk '!NF || !seen[$0]++' /root/.ssh/authorized_keys -)
    echo "$root_combined" > "/root/.ssh/authorized_keys"
fi

cat << EOF >> $homedir/.ssh/authorized_keys
EOF

rm -f "/var/lib/varnish/`hostname`"
ln -s /var/lib/varnish/xxxxx-dummytag-vagrant.nodes.hypernode.io/ "/var/lib/varnish/`hostname`"

rm -rf /etc/cron.d/hypernode-fpm-monitor

# Copy default nginx configs to synced nginx directory if the files don't exist
if [ -d /etc/hypernode/defaults/nginx/ ]; then
    find /etc/hypernode/defaults/nginx -type f | sudo -u $user xargs -I {} cp -n {} /data/web/nginx/
fi

# Update magerun to the latest version
/usr/local/bin/n98-magerun -q self-update || true
/usr/local/bin/n98-magerun2 -q self-update || true

# if the webroot is empty, place our default index.php which shows the settings
if ! find /data/web/public/ -mindepth 1 -name '*.php' -name '*.html' | read; then
    cp /home/vagrant/vagrant-resources/*.{php,js,css} /data/web/public/
    chown -R $user:$user /data/web/public
fi

# @todo investigate what the memory management part settings do and what the best solution might be.
truncate -s 0 /etc/cgrules.conf
