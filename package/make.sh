#!/bin/bash
#
# build rtdb and rtdb-cli

set -e

# $0：当前脚本的文件名
# readlink： 获取$0参数的全路径文件名
# dirname： 获取当前脚本所在的绝对路径
script_dir="$(dirname $(readlink -f $0))"
top_dir="$(readlink -m ${script_dir}/..)"

# compile source code
cd ${top_dir}
make clean
make