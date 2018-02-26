if $VAGRANT_CGROUP_ENABLED; then
    if grep -q xenial /etc/lsb-release; then
        echo "🔥  Ensuring memory management is enabled using systemd"
        # Do memory limit the systemd slice
        if [ -e /etc/systemd/system/limited.slice ]; then
            sed -i '/MemoryLimit=*/ s/^#*//' /etc/systemd/system/limited.slice
            systemctl daemon-reload
        fi
        # Ensure the hypernode oomkiller is enabled and started
        systemctl enable hypernode-oom-monitor 2> /dev/null || /bin/true
        systemctl start hypernode-oom-monitor 2> /dev/null || /bin/true
    else
        echo "🔥  Ensuring memory management is enabled using cgconfig"
        rm -f /etc/init/cgconfig.override
        rm -f /etc/init/hypernode-kamikaze.override
        if [ -f /etc/cgconfig.conf ]; then
            service cgconfig status | grep -q 'start/running' || service cgconfig start
            service hypernode-kamikaze status | grep -q 'start/running' || service hypernode-kamikaze start
        fi
    fi
else
    if grep -q xenial /etc/lsb-release; then
        echo "🔥  Ensuring memory management is disabled"
        # Don't memory limit the systemd slice
        if [ -e /etc/systemd/system/limited.slice ]; then
            sed -i '/MemoryLimit=*/ s/^#*/#/' /etc/systemd/system/limited.slice
            systemctl daemon-reload
        fi
        # Ensure the hypernode oomkiller is disabled and stopped
        systemctl disable hypernode-oom-monitor 2> /dev/null || /bin/true
        systemctl stop hypernode-oom-monitor 2> /dev/null || /bin/true
    fi
fi
