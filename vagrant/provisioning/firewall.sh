# ufw is disabled by default in the boxfile image because sometimes the firewall gets
# in the way when mounting the directories with specific synced folder fs types
if $firewall_enabled; then
    echo "Enabling production-like firewall"
    if grep -q xenial /etc/lsb-release; then
        systemctl enable ufw 2> /dev/null || /bin/true
        systemctl start ufw 2> /dev/null || /bin/true
    else
        rm -f /etc/init/ufw.override
        service ufw status | grep -q 'start/running' || service ufw start
    fi
fi
