#!/bin/bash
#
# Generate deb package
base_dir=$1
output_dir=$2
rtdb_ver=$3

script_dir="$(dirname $(readlink -f $0))"
pkg_dir="${top_dir}/debworkroom"
go_os="$(go env GOOS)"

echo "script_dir: ${script_dir}"
echo "pkg_dir: ${pkg_dir}"

if [ -d ${pkg_dir} ]; then
	 rm -rf ${pkg_dir}
fi
mkdir -p ${pkg_dir}
cd ${pkg_dir}

# create install dir
install_bin_path="/usr/bin"
install_etc_path="/etc/rtdb"
install_script_path="/usr/lib/rtdb/scripts"

mkdir -p ${pkg_dir}${install_bin_path}
mkdir -p ${pkg_dir}${install_etc_path}
mkdir -p ${pkg_dir}${install_script_path}

# copy file
cp -r ${base_dir}/bin/${go_os}/rtdb                          ${pkg_dir}${install_bin_path}
cp -r ${base_dir}/bin/${go_os}/rtdb-cli                       ${pkg_dir}${install_bin_path}

cp -r ${base_dir}/package/etc/rtdb.toml              ${pkg_dir}${install_etc_path}

cp -r ${base_dir}/package/scripts/rtdb.service      ${pkg_dir}${install_script_path}
cp -r ${base_dir}/package/scripts/rtdb-systemd-start.sh      ${pkg_dir}${install_script_path}
cp -r ${base_dir}/package/scripts/init.sh              ${pkg_dir}${install_script_path}

cp -r ${base_dir}/package/deb/DEBIAN        ${pkg_dir}/

chmod 755 ${pkg_dir}/DEBIAN/*
chmod -R 755 ${pkg_dir}${install_script_path}
chmod 644 ${pkg_dir}${install_script_path}/rtdb.service
chmod 775 ${pkg_dir}${install_script_path}/rtdb-systemd-start.sh

# modify version of control
debver="Version: "$rtdb_ver
sed -i "2c$debver" ${pkg_dir}/DEBIAN/control

architecture=$(arch)

mkdir -p ${output_dir}/${architecture}

debName="rtdb-${rtdb_ver}.${architecture}"

# make deb package
dpkg -b ${pkg_dir} ${debName}.deb
echo "make deb package success!"

cp ${pkg_dir}/*.deb ${output_dir}/${architecture}
# clean tmep dir
rm -rf ${pkg_dir}