**AgilorRTDB 服务化打包**

# 发行版打包

当前支持RedHat系列Linux的RPM打包和Debian系列Linux的DEB包

### 编译源码构建可执行文件
首先进入 /path/to/agilordb/package ，使用 "非root权限" 执行如下命令

```bash
./make.sh
```
编译后的可执行文件位于：/path/to/agilordb/bin/

### RPM打包
首先进入 /path/to/agilordb/package ，使用 "root权限" 执行如下命令

```bash
# 构建Release版本
./release.sh rpm release
# 构建Debug版本
./release.sh rpm debug
```
RPM包位于：/path/to/agilordb/package/rpm_output/
### DEB打包
首先进入/path/to/agilordb/package，使用root权限执行如下命令
```bash
# 构建Release版本
./release.sh deb release
# 构建Debug版本
./release.sh deb debug
```
DEB包位于：/path/to/agilordb/package/deb_output/

# 安装说明

RPM包的安装与卸载

```bash
# 安装
sudo rpm -ivh agilor-xxx.rpm
# 查询
sudo rpm -qa | grep agilor
# 卸载
sudo rpm -e --nodeps agilor-xxx
```
DEB包的安装与卸载

```bash
# 安装
sudo dpkg -i agilor-xxx.deb
# 查询
sudo dpkg -l | grep agilor
# 卸载
sudo dpkg -P agilor

```

# 系统服务管理

在使用systemd做系统服务管理（较新的操作系统）的操作系统上：

```bash
# 启动服务
sudo systemctl start agilord
# 查询服务
sudo systemctl status agilord
# 停止服务
sudo systemctl stop agilord
```

在使用service做系统服务管理（较老的操作系统）的操作系统上：

```bash
# 启动服务
sudo service agilor start
# 查询服务
sudo service agilor status
# 停止服务
sudo service agilor stop
```

# AgilorRTDB默认配置
安装后，通过系统服务去启动agilord进程，默认使用"agilor"用户去启动agilord进程，如果操作系统不存在"agilor"用户，则安装文件会自动创建"agilor"用户，且该自动创建的"agilor"用户的默认HOME路径为：/var/lib/agilor，如果操作系统已存在"agilor"用户，则安装文件直接使用该"agilor"用户去启动agilord进程。

agilord系统服务启动后，通过 /etc/default/agilorv6 文件中的环境变量"AGILORD_CONFIG_PATH"去读取配置文件的参数，默认配置文件的路径为：/etc/agilor/agilor.toml

因此，安装并启动agilord后，默认参数为：
```bash
http-address = ":8713"
log-level = "info"
sysdata-path = "/var/lib/agilor/sysdata.dat"  # 安装文件自动创建的"agilor"用户
             = "/path/to/agilor/home/.agilor/sysdata.dat"  # 安装文件自动创建的"agilor"用户
data-path = "/var/lib/agilor/storage"
wal-fsync-time = "0s"
cache-max-size = 1073741824
```

可以在/etc/agilor/agilor.toml配置文件中修改参数，并重启agilord系统服务使参数生效。也可以在 /etc/default/agilorv6 文件中指定配置文件的路径，并重启agilord系统服务使参数生效。

注意：如果使用命令行启动agilord（./agilord），默认读取 /etc/agilor/agilor.toml 中的配置信息
