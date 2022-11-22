#!/bin/bash

function disable_systemd {
    systemctl disable rtdb >/dev/null 2>&1
    systemctl daemon-reload >/dev/null 2>&1
    rm -f /lib/systemd/system/rtdb.service >/dev/null 2>&1
}

function disable_update_rcd {
    update-rc.d -f rtdb remove >/dev/null 2>&1
    rm -f /etc/init.d/rtdb >/dev/null 2>&1
}

function disable_chkconfig {
    chkconfig --del rtdb >/dev/null 2>&1
    rm -f /etc/init.d/rtdb >/dev/null 2>&1
}

if [[ -f /etc/redhat-release ]]; then
    # RHEL-variant logic
    if [[ "$1" = "0" ]]; then
        # RTDB is no longer installed, remove from init system
        rm -f /etc/default/rtdbv2

        if command -v systemctl &>/dev/null; then
            disable_systemd
        else
            # Assuming sysv
            disable_chkconfig
        fi
    fi
elif [[ -f /etc/lsb-release ]]; then
    # Debian/Ubuntu logic
    if [[ "$1" != "upgrade" ]]; then
        # Remove/purge
        rm -f /etc/default/rtdbv2

        if command -v systemctl &>/dev/null; then
            disable_systemd
        else
            # Assuming sysv
            disable_update_rcd
        fi
    fi
elif [[ -f /etc/os-release ]]; then
    source /etc/os-release
    if [[ "$ID" = "amzn" ]] && [[ "$1" = "0" ]]; then
        # RTDB is no longer installed, remove from init system
        rm -f /etc/default/rtdbv2

        if [[ "$NAME" = "Amazon Linux" ]]; then
            # Amazon Linux 2+ logic
            disable_systemd
        elif [[ "$NAME" = "Amazon Linux AMI" ]]; then
            # Amazon Linux logic
            disable_chkconfig
        fi
    fi
fi
