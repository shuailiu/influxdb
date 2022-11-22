#!/bin/bash

function stop_systemd {
    systemctl stop rtdb >/dev/null 2>&1
}

function stop_update_rcd {
    service rtdb stop >/dev/null 2>&1
}

function stop_chkconfig {
    service rtdb stop >/dev/null 2>&1
}

if [[ -f /etc/redhat-release ]]; then
    # RHEL-variant logic
    if [[ "$1" = "0" ]]; then
        if command -v systemctl &>/dev/null; then
            stop_systemd
        else
            # Assuming sysv
            stop_chkconfig
        fi
    fi
elif [[ -f /etc/lsb-release ]]; then
    # Debian/Ubuntu logic
    if [[ "$1" != "upgrade" ]]; then
        if command -v systemctl &>/dev/null; then
            stop_systemd
        else
            # Assuming sysv
            stop_update_rcd
        fi
    fi
elif [[ -f /etc/os-release ]]; then
    source /etc/os-release
    if [[ "$ID" = "amzn" ]] && [[ "$1" = "0" ]]; then
        if [[ "$NAME" = "Amazon Linux" ]]; then
            # Amazon Linux 2+ logic
            stop_systemd
        elif [[ "$NAME" = "Amazon Linux AMI" ]]; then
            # Amazon Linux logic
            stop_chkconfig
        fi
    fi
fi
