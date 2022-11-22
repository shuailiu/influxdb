#!/bin/bash
#
# Generate rpm package

#curr_dir=$(pwd)
base_dir=$1
output_dir=$2
agilor_ver=$3

script_dir="$(dirname $(readlink -f $0))"
pkg_dir="${top_dir}/rpmworkroom"
spec_file="${script_dir}/agilor.spec"

#echo "curr_dir: ${curr_dir}"
#echo "top_dir: ${top_dir}"
#echo "script_dir: ${script_dir}"
echo "base_dir: ${base_dir}"
echo "pkg_dir: ${pkg_dir}"
echo "spec_file: ${spec_file}"

csudo=""
if command -v sudo > /dev/null; then
    csudo="sudo"
fi

if [ -d ${pkg_dir} ]; then
	 ${csudo} rm -rf ${pkg_dir}
fi
${csudo} mkdir -p ${pkg_dir}
cd ${pkg_dir}

${csudo} mkdir -p BUILD BUILDROOT RPMS SOURCES SPECS SRPMS

# TODO: 去掉QA_RPATHS=0x0002会出错，路径好像并没有问题
# ${csudo} rpmbuild --define="_version ${agilor_ver}" --define="_topdir ${pkg_dir}" --define="_basedir ${compile_dir}" -bb ${spec_file}
${csudo} QA_RPATHS=0x0002 rpmbuild --define="_version ${agilor_ver}" --define="_basedir ${base_dir}" --define="_topdir ${pkg_dir}"  -bb ${spec_file}

# copy rpm package to output_dir, then clean temp dir
#echo "rmpbuild end, cur_dir: $(pwd) "
${csudo} cp -rf RPMS/* ${output_dir}
cd ..
${csudo} rm -rf ${pkg_dir}