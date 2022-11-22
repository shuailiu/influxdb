#!/bin/bash

BIN_DIR=/usr/bin
DATA_DIR=/var/lib/rtdb
LOG_DIR=/var/log/rtdb
SCRIPT_DIR=/usr/lib/rtdb/scripts
LOGROTATE_DIR=/etc/logrotate.d
RTDB_CONFIG_PATH=/etc/rtdb/rtdb.toml

function install_init {
    cp -f $SCRIPT_DIR/init.sh /etc/init.d/rtdb
    chmod +x /etc/init.d/rtdb
}

function install_systemd {
    cp -f $SCRIPT_DIR/rtdb.service /lib/systemd/system/rtdb.service
    systemctl enable rtdb
    systemctl daemon-reload
}

function install_update_rcd {
    update-rc.d rtdb defaults
}

function install_chkconfig {
    chkconfig --add rtdb
}

function init_config {
    mkdir -p $(dirname ${RTDB_CONFIG_PATH})

    local config_path=${RTDB_CONFIG_PATH}
    # if [[ -s ${config_path} ]]; then
    #     config_path=${RTDB_CONFIG_PATH}.defaults
    #     echo "Config file ${RTDB_CONFIG_PATH} already exists, writing defaults to ${config_path}"
    # fi

#     cat << EOF > ${config_path}
# bolt-path = "/var/lib/rtdb"
# engine-path = "/var/lib/rtdb/storage"
# EOF
}

# Add defaults file, if it doesn't exist
if [[ ! -s /etc/default/rtdbv2 ]]; then
cat << EOF > /etc/default/rtdbv2
RTDB_CONFIG_PATH=${RTDB_CONFIG_PATH}
EOF
fi

# Remove legacy symlink, if it exists
if [[ -L /etc/init.d/rtdb ]]; then
    rm -f /etc/init.d/rtdb
fi

# Distribution-specific logic
if [[ -f /etc/redhat-release ]]; then
    # RHEL-variant logic
    if command -v systemctl &>/dev/null; then
        install_systemd
    else
        # Assuming sysv
        install_init
        install_chkconfig
    fi
elif [[ -f /etc/debian_version ]]; then
    # Ownership for RH-based platforms is set in build.py via the `rmp-attr` option.
    # We perform ownership change only for Debian-based systems.
    # Moving these lines out of this if statement would make `rmp -V` fail after installation.
    chown -R -L rtdb:rtdb $LOG_DIR
    chown -R -L rtdb:rtdb $DATA_DIR
    chmod 755 $LOG_DIR
    chmod 755 $DATA_DIR

    # Debian/Ubuntu logic
    if command -v systemctl &>/dev/null; then
        install_systemd
    else
        # Assuming sysv
        install_init
        install_update_rcd
    fi
elif [[ -f /etc/os-release ]]; then
    source /etc/os-release
    if [[ "$NAME" = "Amazon Linux" ]]; then
        # Amazon Linux 2+ logic
        install_systemd
    elif [[ "$NAME" = "Amazon Linux AMI" ]]; then
        # Amazon Linux logic
        install_init
        install_chkconfig
    fi
fi

# Init config
init_config
