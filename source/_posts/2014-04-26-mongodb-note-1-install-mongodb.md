title: mongodb笔记(一) 安装启动mongodb
date: 2014-04-26 22:26:20
tags:
- MongoDB
categories:
- Database
- MongoDB
description: 数据库， mongodb 安装，mongodb 启动，mongodb install
---
## Windows下安装

> 从 2.2 开始已经不再支持 Windows XP。
Windows Server 2008 R2 或 Windows 7下需要安装一个补丁： [DOS 错误代码时使用 FlushViewOfFile() 函数，在 Windows 7 中，或在 Windows Server 2008 R2 中清除内存内存映射文件](http://support.microsoft.com/kb/2731284)

<!-- more -->

### 安装

- 下载
    
    从 <http://www.mongodb.org/downloads> 下载你所需要的版本，可以通过下面的命令判断你需要安装的版本
```shell
wmic os get osarchitecture
```

- 解压缩文件
    
    将下载的压缩包解压到一个目录中，例如 D:\PortableApps\mongodb\

- 设置系统变量

    为了在控制台执行命令方便可以设置系统环境变量  

    计算机--属性--高级系统配置--环境变量--系统变量中的path,加上`;D:\PortableApps\mongodb\bin` ，注意前面的分号。

### 运行mongodb

> 不要让mongod.exe运行在没有身份验证设置的“安全模式”的公网上。MongoDB被设计运行在可信任的环境中，数据库默认情况下没有启用“安全模式”。

- 配置 mongodb 运行环境
    
    配置mongodb的数据库目录，mongodb默认的存放数据的目录是`\data\db`。如果你的mongodb在D盘，那么`\data\db`就在你的D盘根目录下，即`D:\data\db`，此目录需要自己创建，mongodb不会帮你创建，可以使用下面命令创建。
```shell
md \data\db
```
    也可以用 `--dbpath` 参数来指定mongodb的运行数据目录。如果你的目录路径中包含空格，记得在路径两边加引号。

- 启动mongodb服务
    
    运行下面命令
```shell
cd D:\PortableApps\mongodb
bin\mongod --dbpath data\db
```
    如果有"waiting for connections"的提示，说明你已经运行成功了，请选择私有网络运行mongodb，比如家庭或工作网络。  
    
    mongod还会启动一个非常基本的HTTP服务器，使用端口28017,可以访问http://localhost:28017 来获取数据库的管理信息。要更好利用好管理接口，需要用--rest选项开启REST支持。可以通过--nohttpinterface关闭管理接口。

- 连接mongodb
    
    运行下面命令连接到mongodb
```shell
cd D:\PortableApps\mongodb\bin
mongo
```

### 添加mongodb为windows服务

- 需要以管理员权限启动命令行窗口

    **Windows 7 / Vista / Server 2008 (and R2)** 按`Win + R`，输入`cmd`，再按`Ctrl + Shift + Enter`  

    **Windows 8** 按`Win + X`，再按`A`

- 创建目录
    
    为数据库文件和日志文件创建目录
```shell
md D:\portableapps\mongodb\data\db
md D:\portableapps\mongodb\data\log
```

- 创建配置文件
    
    配置文件中必须包含有效的logpath
```shell
echo logpath=D:\PortableApps\mongodb\data\log\mongod.log> "D:\portableapps\mongodb\mongod.cfg"
echo dbpath=D:\PortableApps\mongodb\data\db>> "D:\portableapps\mongodb\mongod.cfg"
echo fork=true>> "D:\portableapps\mongodb\mongod.cfg"
```
    配置文件中#开头为注释，配置项形式`选项=值`，对于命令中如`--fork`这样的选项，其值为true


- 添加系统服务
    
    执行下面命令，binPath需要对`"`进行转义
```shell
sc create MongoDB binPath= "\"D:\PortableApps\mongodb\bin\mongod.exe\" --service --config=\"D:\PortableApps\mongodb\mongod.cfg\"" DisplayName= "MongoDB" start= "demand"
```
    start设置为`demand`，需要每次手动启动，可以设置为`auto`  

    成功后将会输出`[SC] CreateService 成功`  

{% blockquote 百度百科, http://baike.baidu.com/view/1367668.htm?fr=ala0_1_1#3 %}
sc [ServerName] create [ServiceName] [type= {own | share | kernel | filesys | rec | adapt | interacttype= {own | share}}] [start= {boot | system | auto | demand | disabled}] [error= {normal | severe | critical | ignore}] [binpath= BinaryPathName] [group= LoadOrderGroup] [tag= {yes | no}] [depend= dependencies] [obj= {AccountName | ObjectName}] [displayname= DisplayName] [password= Password]
{% endblockquote %}

- 启动服务

```shell
net start MongoDB
```

- 停止或删除服务

    停止服务
```shell
net stop MongoDB
```
    先停止服务，然后删除 MongoDB 服务
```shell
sc delete MongoDB
```

## Linux下安装

### 安装

- 下载
    
    执行下面命令，下载压缩包
```shell
curl -0 https://fastdl.mongodb.org/linux/mongodb-linux-i686-2.6.0.tgz
```

- 解压

    执行下面命令解压下载好的文件
```shell
tar -zxvf mongodb-linux-i686-2.6.0.tgz
```

- 将解压后的目录复制到要运行mongodb的目录
    
    执行下面命令拷贝mongodb
```shell
mkdir -p /opt/mongodb
cp -R -n mongodb-linux-i686-2.6.0/ /opt/mongodb
```

- 确保可执行文件的在PATH变量中
    
    可以在`/etc/profile`中添加`PATH=/opt/mongodb/bin:$PATH`，也可以在`/usr/local/bin`中创建符号链接。

- 其它
    
    几个主流的Linux操作系统，可以分别通过它们的包管理工具安装mongodb:[Red Hat]、[Ubuntu]、[Debian]

### 运行mongodb

- 创建数据目录

    默认数据库文件存放在`/data/db`下。需要自己创建目录，可以执行下面的命令
```shell
mkdir -p /data/db
```

- 设置用户对数据目录的权限
    
    在运行mongod之前需要确保用户对，用户对mongodb的数据库目录有读写权限。

- 运行mongodb

    执行下面命令
```shell
mongod
```
    或者
```shell
mongod --dbpath <path to data directory>
```
    前者将使用默认的数据库目录`/data/db`

- 启动脚本

    <http://wbzyl.inf.ug.edu.pl/nosql/fedora/f16/mongod.sh>  

    <https://github.com/mongodb/mongo/blob/master/debian/init.d>  

    对于Debian， 在 `/etc/init.d/mongod` 中创建脚本  

    对于Red Hat，在 `/etc/rc.d/init.d/mongod` 中创建脚本  

- 停止

    1. Ctrl + C
    2. kill -2 pid (SIGINT)
    3. kill pid (SIGTERM)
    4. `use admin; db.shutdownServer()`
    5. db.runCommand({"shutdown":1})

## 参数

下表为mongodb启动的参数说明

- 基本参数

| 参数                   | 描述                                                              |
|----------------------|-----------------------------------------------------------------|
| --port arg             | 指定服务端口号，默认端口27017                                     |
| --bind_ip arg          | 绑定服务IP，若绑定127.0.0.1，则只能本机访问，不指定默认本地所有IP |
| --logpath arg          | 指定MongoDB日志文件，注意是指定文件不是目录                       |
| --logappend            | 使用追加的方式写日志                                              |
| --dbpath arg           | 指定数据库路径                                                    |
| --config arg (-f arg)  | 指定配置文件                                                      |
| --quiet                | 安静输出                                                          |
| --pidfilepath arg      | PID File 的完整路径，如果没有设置，则没有PID文件                  |
| --keyFile arg          | 集群的私钥的完整路径，只对于Replica Set 架构有效                  |
| --unixSocketPrefix arg | UNIX域套接字替代目录,(默认为 /tmp)                                |
| --fork                 | 以守护进程的方式运行MongoDB，创建服务器进程                       |
| --auth                 | 启用验证                                                          |
| --cpu                  | 定期显示CPU的CPU利用率和iowait                                    |
| --diaglog arg          | diaglog选项 0=off 1=W 2=R 3=both 7=W+some reads                   |
| --directoryperdb       | 设置每个数据库将被保存在一个单独的目录                            |
| --journal              | 启用日志选项，MongoDB的数据操作将会写入到journal文件夹的文件里    |
| --journalOptions arg   | 启用日志诊断选项                                                  |
| --ipv6                 | 启用IPv6选项                                                      |
| --jsonp                | 允许JSONP形式通过HTTP访问（有安全影响）                           |
| --maxConns arg         | 最大同时连接数 默认2000                                           |
| --noauth               | 不启用验证                                                        |
| --nohttpinterface      | 关闭http接口，默认关闭27018端口访问                               |
| --noprealloc           | 禁用数据文件预分配(往往影响性能)                                  |
| --noscripting          | 禁用脚本引擎                                                      |
| --notablescan          | 不允许表扫描                                                      |
| --nounixsocket         | 禁用Unix套接字监听                                                |
| --nssize arg (=16)     | 设置信数据库.ns文件大小(MB)                                       |
| --objcheck             | 在收到客户数据,检查的有效性，                                     |
| --profile arg          | 档案参数 0=off 1=slow, 2=all                                      |
| --quota                | 限制每个数据库的文件数，设置默认为8                               |
| --quotaFiles arg       | number of files allower per db, requires --quota                  |
| --rest                 | 开启简单的rest API                                                |
| --repair               | 修复所有数据库run repair on all dbs                               |
| --repairpath arg       | 修复库生成的文件的目录,默认为目录名称dbpath                       |
| --slowms arg (=100)    | value of slow for profile and console log                         |
| --smallfiles           | 使用较小的默认文件                                                |
| --syncdelay arg (=60)  | 数据写入磁盘的时间秒数(0=never,不推荐)                            |
| --sysinfo              | 打印一些诊断系统信息                                              |
| --upgrade              | 如果需要升级数据库                                                |
| --serviceName          | 指定服务名称                                                      |
| --serviceDisplayNam    | 指定服务名称，有多个mongodb服务时执行。                           |
| --install              | 指定作为一个Windows服务安装。                                     |

- Replicaton 参数

| 参数            | 描述                                                                               |
|---------------|----------------------------------------------------------------------------------|
| --fastsync      | 从一个dbpath里启用从库复制服务，该dbpath的数据库是主库的快照，可用于快速启用同步 |
| --autoresync    | 如果从库与主库同步数据差得多，自动重新同步，                                     |
| --oplogSize arg | 设置oplog的大小(MB)                                                              |

- 主/从参数

| 参数             | 描述                       |
|------------------|------------------------|
| --master         | 主库模式                   |
| --slave          | 从库模式                   |
| --source arg     | 从库 端口号                |
| --only arg       | 指定单一的数据库复制       |
| --slavedelay arg | 设置从库同步主库的延迟时间 |
 
- Replica set(副本集)选项：

| 参数          | 描述           |
|-------------|--------------|
| --replSet arg | 设置副本集名称 |

- Sharding(分片)选项

| 参数             | 描述                                                             |
|----------------|----------------------------------------------------------------|
| --configsvr      | 声明这是一个集群的config服务,默认端口27019，默认录/data/configdb |
| --shardsvr       | 声明这是一个集群的分片,默认端口27018                             |
| --noMoveParanoia | 关闭偏执为moveChunk数据保存                                      |

**上述参数都可以写入 mongod.conf 配置文档里**
```
dbpath    = /data/db
logpath   = /data/log/mongod.log
logappend = true
port      = 27017
fork      = true
auth      = true
```

## 问题处理

如果上次没有正确关闭mongodb，会导致存放数据的文件被锁住，只需将\data\db中的mongod.lock文件删除掉。重新启动服务即可。

[Red Hat]: http://docs.mongodb.org/manual/tutorial/install-mongodb-on-red-hat-centos-or-fedora-linux/
[Ubuntu]: http://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/
[Debian]: http://docs.mongodb.org/manual/tutorial/install-mongodb-on-debian/
