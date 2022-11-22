%global _enable_debug_package 0
%global debug_package %{nil}
%global __os_install_post /usr/lib/rpm/brp-compress %{nil}

%define homepath             %{_usr}/lib/agilor
%define bin_install_dir      %{_usr}/bin
%define etc_install_dir      %{_sysconfdir}/agilor
%define script_install_dir   %{homepath}/scripts

%define agilor_service_name  "agilord"

Name:		agilor
Version:	%{_version}
Release:	1%{?dist}
Summary:	agilor-rtdb from agilor.co
License:	Commercial
URL:		http://agilor.co/

#BuildRoot:  %_topdir/BUILDROOT
BuildRoot:   %{_tmppath}/%{name}-%{version}-%{release}-root

Prefix: %{_usr}/lib/agilor

#BuildRequires:
#Requires:

%description
Agilor Real-time Database

%install
#make install DESTDIR=%{buildroot}
echo basedir: %{_basedir}
echo topdir: %{_topdir}  # 宏%_topdir: ~/rpmbuild
echo version: %{_version}
echo buildroot: %{buildroot}

rm -rf %{buildroot}
# create install path, and copy file
mkdir -p %{buildroot}%{bin_install_dir}
mkdir -p %{buildroot}%{etc_install_dir}
mkdir -p %{buildroot}%{script_install_dir}

# copy file
cp %{_basedir}/bin/agilord        %{buildroot}%{bin_install_dir}
cp %{_basedir}/bin/agilor-cli     %{buildroot}%{bin_install_dir}

cp %{_basedir}/package/etc/agilor.toml   %{buildroot}%{etc_install_dir}

cp %{_basedir}/package/scripts/agilord.service   %{buildroot}%{script_install_dir}
cp %{_basedir}/package/scripts/init.sh   %{buildroot}%{script_install_dir}
cp %{_basedir}/package/scripts/agilord-systemd-start.sh   %{buildroot}%{script_install_dir}

chmod 755 %{buildroot}%{script_install_dir}/*.sh
chmod 644 %{buildroot}%{script_install_dir}/agilord.service

#Scripts executed before installation
%pre
#!/bin/bash

DATA_DIR=/var/lib/agilor
USER=agilor
GROUP=agilor
LOG_DIR=/var/log/agilor

if ! id agilor &>/dev/null; then
    useradd --system -U -M agilor -s /bin/false -d $DATA_DIR
fi

# check if DATA_DIR exists
if [ ! -d "$DATA_DIR" ]; then
    mkdir -p $DATA_DIR
    chown $USER:$GROUP $DATA_DIR
fi

# check if LOG_DIR exists
if [ ! -d "$LOG_DIR" ]; then
    mkdir -p $LOG_DIR
    chown $USER:$GROUP $LOG_DIR
fi

#Scripts executed after installation
%post
#!/bin/bash

BIN_DIR=/usr/bin
DATA_DIR=/var/lib/agilor
LOG_DIR=/var/log/agilor
SCRIPT_DIR=/usr/lib/agilor/scripts
LOGROTATE_DIR=/etc/logrotate.d
AGILORD_CONFIG_PATH=/etc/agilor/agilor.toml

function install_init {
    cp -f $SCRIPT_DIR/init.sh /etc/init.d/agilord
    chmod +x /etc/init.d/agilord
}

function install_systemd {
    cp -f $SCRIPT_DIR/agilord.service /lib/systemd/system/agilord.service
    systemctl enable agilord
    systemctl daemon-reload
}

function install_update_rcd {
    update-rc.d agilord defaults
}

function install_chkconfig {
    chkconfig --add agilord
}

function init_config {
    mkdir -p $(dirname ${AGILORD_CONFIG_PATH})

    local config_path=${AGILORD_CONFIG_PATH}
    # if [[ -s ${config_path} ]]; then
    #     config_path=${AGILORD_CONFIG_PATH}.defaults
    #     echo "Config file ${AGILORD_CONFIG_PATH} already exists, writing defaults to ${config_path}"
    # fi

#     cat << EOF > ${config_path}
# bolt-path = "/var/lib/agilor"
# engine-path = "/var/lib/agilor/storage"
# EOF
}

# Add defaults file, if it doesn't exist
if [[ ! -s /etc/default/agilorv6 ]]; then
cat << EOF > /etc/default/agilorv6
AGILORD_CONFIG_PATH=${AGILORD_CONFIG_PATH}
EOF
fi

# Remove legacy symlink, if it exists
if [[ -L /etc/init.d/agilord ]]; then
    rm -f /etc/init.d/agilord
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
    chown -R -L agilor:agilor $LOG_DIR
    chown -R -L agilor:agilor $DATA_DIR
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

# Scripts executed before uninstall
%preun
#!/bin/bash

function stop_systemd {
    systemctl stop agilord
}

function stop_update_rcd {
    service agilord stop
}

function stop_chkconfig {
    service agilord stop
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


# Scripts executed after uninstall
%postun
#!/bin/bash

function disable_systemd {
    systemctl disable agilord
    systemctl daemon-reload
    rm -f /lib/systemd/system/agilord.service
}

function disable_update_rcd {
    update-rc.d -f agilord remove
    rm -f /etc/init.d/agilord
}

function disable_chkconfig {
    chkconfig --del agilord
    rm -f /etc/init.d/agilord
}

if [[ -f /etc/redhat-release ]]; then
    # RHEL-variant logic
    if [[ "$1" = "0" ]]; then
        # AgilorRTDB is no longer installed, remove from init system
        rm -f /etc/default/agilorv6

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
        rm -f /etc/default/agilorv6

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
        # AgilorRTDB is no longer installed, remove from init system
        rm -f /etc/default/agilorv6

        if [[ "$NAME" = "Amazon Linux" ]]; then
            # Amazon Linux 2+ logic
            disable_systemd
        elif [[ "$NAME" = "Amazon Linux AMI" ]]; then
            # Amazon Linux logic
            disable_chkconfig
        fi
    fi
fi

# clean build dir
%clean
csudo=""
if command -v sudo > /dev/null; then
    csudo="sudo"
fi
${csudo} rm -rf %{buildroot}

#Specify the files to be packaged
%files
%{homepath}/*
%{bin_install_dir}/*
%{etc_install_dir}/*
%{script_install_dir}/*
#%doc

#Setting default permissions
%defattr  (-,root,root,0755)
#%{prefix}

#%changelog