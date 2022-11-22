#!/bin/bash
#
# Generate the deb package for ubunt, or rpm package for centos, or tar.gz package for other linux os

set -e
#set -x
if [ $# -ne 2 ]; then
    echo "Please input correct parameters, for example: ./release.sh {rpm} {debug}"
    exit 1
fi
pack_version=$1
compile_version=$2
echo "pack_version: ${pack_version}, compile_version: ${compile_version}"
if [[( "${pack_version}" != "deb" ) && ( "${pack_version}" != "rpm" )]]; then
    echo "Please input correct pack version: {deb} or {rpm}"
    exit 1
fi

if [[ ( "${compile_version}" != "Release" ) && ( "${compile_version}" != "release" ) && ( "${compile_version}" != "Debug" ) && ( "${compile_version}" != "debug" ) ]]; then
    echo "Please input correct compile version: {Debug} / {debug} / {Release} / {release}"
    exit 1
fi


curr_dir=$(pwd)
# $0：当前脚本的文件名
# readlink： 获取$0参数的全路径文件名
# dirname： 获取当前脚本所在的绝对路径
script_dir="$(dirname $(readlink -f $0))"
top_dir="$(readlink -m ${script_dir}/..)"
versioninfo="${top_dir}/package/build_version"

csudo=""
if command -v sudo > /dev/null; then
    csudo="sudo"
fi

function is_valid_version() {
    # [ -z $1 ] && return 1 || :

    # rx='^([0-9]+\.){3}(\*|[0-9]+)$'
    # if [[ $1 =~ $rx ]]; then
    #     return 0
    # fi

    # return 1

    return 0
}

function vercomp () {
    if [[ $1 == $2 ]]; then
        echo 0
        exit 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
        ver1[i]=0
    done

    for ((i=0; i<${#ver1[@]}; i++)); do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            echo 1
            exit 0
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            echo 2
            exit 0
        fi
    done
    echo 0
}

# 1. Read version information
version=$(cat ${versioninfo} | grep " version" | cut -d '"' -f2)
# compatible_version=$(cat ${versioninfo} | grep " compatible_version" | cut -d '"' -f2)

while true; do
  read -p "Do you want to release a new version? [y/N]: " is_version_change

  if [[ ( "${is_version_change}" == "y") || ( "${is_version_change}" == "Y") ]]; then
      read -p "Please enter the new version: " tversion
      # while true; do
      #     if (! is_valid_version $tversion) || [ "$(vercomp $tversion $version)" = '2' ]; then
      #         read -p "Please enter a correct version: " tversion
      #         continue
      #     fi
      #     version=${tversion}
      #     break
      # done
      version=${tversion}
      break
  elif [[ ( "${is_version_change}" == "n") || ( "${is_version_change}" == "N") ]]; then
      echo "Use old version: ${version}."
      break
  else
      continue
  fi
done

# output the version info to the buildinfo file.
build_time=$(date +"%F %R")
echo "char version[64] = \"${version}\";" > ${versioninfo}
echo "char gitinfo[128] = \"$(git rev-parse --verify HEAD)\";"  >> ${versioninfo}
echo "char buildinfo[512] = \"Built by ${USER} at ${build_time}\";"  >> ${versioninfo}

# 2. make executable file
#default use debug mode
compile_mode="debug"
if [[ $compile_version == "Release" ]] || [[ $compile_version == "release" ]]; then
  compile_mode="release"
fi

########################################
########  compile source code ##########
########################################
# cd ${top_dir}
# make clean
# make
########################################
########################################
########################################

cd ${curr_dir}

# # 3. judge the operating system type, then Call the corresponding script for packaging
# osinfo=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
# #osinfo=$(cat /etc/os-release | grep "NAME" | cut -d '"' -f2)
# #echo "osinfo: ${osinfo}"
if [[ "${pack_version}" == "deb" ]]; then
  echo "start building deb package..."
  output_dir="${top_dir}/package/deb_output"
  if [ -d ${output_dir} ]; then
	 ${csudo} rm -rf ${output_dir}
  fi
  ${csudo} mkdir -p ${output_dir}
  cd ${script_dir}/deb
  chmod 755 make_deb.sh
  ${csudo} ./make_deb.sh ${top_dir} ${output_dir} ${version}
elif [[ "${pack_version}" == "rpm" ]]; then
  echo "start building rpm package..."
  output_dir="${top_dir}/package/rpm_output"
  if [ -d ${output_dir} ]; then
	 ${csudo} rm -rf ${output_dir}
  fi
  ${csudo} mkdir -p ${output_dir}
  cd ${script_dir}/rpm
  chmod 755 make_rpm.sh
  ${csudo} ./make_rpm.sh ${top_dir} ${output_dir} ${version}
fi

# TODO: 如果既不是rpm package，也不是deb package，则打包成tar包，手动安装
# cd ${script_dir}/tools
# ${csudo} ./makepkg.sh ${compile_dir} ${version} "${build_time}"

# 4. Clean up temporary compile directories
#${csudo} rm -rf ${compile_dir}
