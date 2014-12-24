title: vsftpd 配置虚拟用户
date: 2014-07-26 11:46:40
tags: 
- FTP
- Vsftpd
categories:
- FTP
description: vsftpd 虚拟用户, vsftpd 配置
---
## 基础

安装，执行命令：
```
sudo apt-get install vsftpd
```
<!-- more -->
查看是否打开21端口: 
```
sudo netstat -npltu | grep 21
```

以standalone方式运行(另一种是super daemon): `sudo service vsftpd start`

重启： `sudo service vsftpd restart`

停止： `sudo service vsftpd stop`

ftp 默认目录位置: `/srv/ftp`

## 配置

查阅配置文件详细信息:
```
man 5 vsftpd.conf
```

配置文件位置: `/etc/vsftpd.conf`

备份配置文件:
```
cp /etc/vsftpd.conf /etc/vsftpd.conf_orig
cat /dev/null > /etc/vsftpd.conf
vi /etc/vsftpd.conf
```

将下面内容写入配置文件
```
#使用当地时间
use_localtime=YES
#这个选项必须指定一个空的数据夹且任何登入者都不能有写入的权限，当vsftpd 不需要file system 的权限时，就会将使用者限制在此数据夹中。默认值为/var/run/vsftpd/empty
secure_chroot_dir=/var/run/vsftpd/empty
#预设 RSA 加密的凭证档案所在
rsa_cert_file=/etc/ssl/private/vsftpd.pem
#login时的欢迎信息
ftpd_banner=Welcome to FTP service.
#显示欢迎信息
banner_file=/etc/vsftpd/welcome.txt
#允许匿名访问？YES/NO
anonymous_enable=NO
#设定本地用户可以访问。默认.注意：主要是为虚拟宿主用户，如果该项目设定为NO那么所有虚拟用户将无法访问
local_enable=YES
#可写 
write_enable=NO
#上传后文件的权限掩码 默认
local_umask=022
#开启目录标语，默认
dirmessage_enable=YES
#开启日志，默认
xferlog_enable=YES
#设定vsftpd的服务日志保存路径 将前面的#注释
xferlog_file=/var/log/xferlog
#生成的日志格式 默认
xferlog_std_format=YES
#如果启用该选项，将生成两个相似的日志文件，默认在 /var/log/xferlog 和 /var/log/vsftpd.log 目录下。前者是 wu-ftpd 类型的传输日志，可以利用标准日志工具对其进行分析；后者是Vsftpd类型的日志。
dual_log_enable=YES
#在用xferlog文件记录服务器上传下载情况的同时，vsftpd_log_file所指定的文件，即/var/log/vsftpd.log，也将用来记录服务器的传输情况。
vsftpd_log_file=/var/log/vsftpd.log
#设定连接端口20 不是ftp端口
connect_from_port_20=YES
#会话超时，客户端连接到ftp但未操作
idle_session_timeout=600
#支持异步传输功能，默认是注释掉的，去掉注释
async_abor_enable=YES
#支持ASCII模式的下载功能，默认是注释掉的，去掉注释
ascii_upload_enable=YES
#支持ASCII模式的上传功能，默认是注释掉的，去掉注释
ascii_download_enable=YES
#在预设的情况下，是否要将使用者限制在自己的家目录之内(chroot)？如果是 YES 代表用户默认就会被 chroot，如果是 NO， 则预设是没有 chroot。不过，实际还是需要底下的两个参数互相参考才行。为了安全性，这里应该要设定成 YES 才好。
chroot_local_user=YES
#禁止本地用户登出自己的FTP主目录 去掉注释，这个非常重要
# chroot_list_enable=YES
#上个选项开启 这个文件才生效 不过不存在需要你手工创建
# chroot_list_file=/etc/vsftpd/chroot_list
#监听IPV4
listen=YES
#ftp监听端口 默认21 原始配置中没有
listen_port=21
#设定pam服务下vsftpdd的验证配置文件名，不用改
pam_service_name=vsftpd
#限制主机对VSFTP服务器的访问，不用改（通过/etc/hosts.deny和/etc/hosts.allow这两个文件来配置）原始配置中没有
tcp_wrappers=YES
#设定启用虚拟用户功能
guest_enable=YES
#指定虚拟用户的宿主用户。-CentOS中已经有内置的ftp用户了
guest_username=vsftpduser
#设定虚拟用户的权限符合他们的宿主用户(虚拟用户与宿主用户具有相同的权限)
virtual_use_local_privs=YES
#设定虚拟用户个人vsftp的配置文件存放路径。存放虚拟用户个性的配置文件(配置文件名=虚拟用户名)
user_config_dir=/etc/vsftpd/vconf
# 是否藉助 vsftpd 的抵挡机制来处理某些不受欢迎的账号，与底下的参数设定有关；
userlist_enable=YES
# 当 userlist_enable=YES 时才会生效的设定，若此设定值为 YES 时，则当使用者账号被列入到某个档案时， 在该档案内的使用者将无法登入 vsftpd 服务器！该档案文件名与下列设定项目有关。
userlist_deny=YES
# 若上面 userlist_deny=YES 时，则这个档案就有用处了！在这个档案内的账号都无法使用 vsftpd 喔！
userlist_file=/etc/vsftpd/user_list
#可接受的最大client数目
max_clients=100
#每个ip的最大client数目
max_per_ip=5
#本地用户的传输比率(bytes/s)
local_max_rate=1310720
```
更改配置后，重启vsftpd使配置生效。

## Vsftpd虚拟用户设置(通过MySQL) 

### 安装 libpam-mysql

```
sudo apt-get install libpam-mysql
```

### 添加禁止登录系统的用户

```
sudo useradd vsftpduser -d /srv/ftp -s /sbin/nologin -g nogroup
```

> /sbin/nologin和/bin/false的区别:

> 都不允许登录系统，/bin/false不允许使用ftp等服务。如果要使/bin/false能不允许登录系统，同时允许ftp等服务，可以在/etc/shells里增加一行/bin/false。

> 创建/etc/nologin文件，则除root用户外，其它用户无法登录，可以在维护服务器的时候使用。

> 删除用户（userdel命令）: `userdel  [-r]  [要删除的用户的名称]` 

设置密码: `passwd vsftpduser`

在配置文件 vsftpd.conf加入
```
#设定启用虚拟用户功能
guest_enable=YES
#指定虚拟用户的宿主用户。-CentOS中已经有内置的ftp用户了
guest_username=vsftpduser
```

### 创建用户名密码数据库

创建test数据库
```
create database test;
use test;
```
建用户表:
```
create table user(
id int unsigned not null auto_increment,
name varchar(40) not null,
password varchar(128) not null,
primary key(id),
unique key(name)
);
```
插入用户:
```
insert into user values (null,'user1','123456');
insert into user values (null,'user2','123456');
insert into user values (null,'user3','123456');
```
分配权限,把123456换成你的密码： 
```
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP ON test.* TO 'vsftpduser'@'localhost' IDENTIFIED BY '123456';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP ON test.* TO 'vsftpduser'@'localhost.localdomain' IDENTIFIED BY '123456';
FLUSH PRIVILEGES;
```

### 配置PAM认证模块

先备份PAM认证文件
```
cp /etc/pam.d/vsftpd /etc/pam.d/vsftpd_orig
cat /dev/null > /etc/pam.d/vsftpd
vi /etc/pam.d/vsftpd
```
修改/etc/pam.d/vsftpd 内容如下：
```
auth required /lib/security/pam_mysql.so user=vsftpduser passwd=123456 host=localhost db=test table=user usercolumn=name passwdcolumn=password crypt=0
account required /lib/security/pam_mysql.so user=vsftpduser passwd=123456 host=localhost db=test table=user usercolumn=name passwdcolumn=password crypt=0
```

- user=vsftpduser    刚才添加的mysql用户名
- passwd=123456 刚才添加的用户名密码
- host=localhost mysql服务器名，我是做在本机所以……。
- db=test 与这个对应create databases test，是存储用户名的mysql库名
- table=user    存储用户名的mysql库中的表名
- usercolumn=name 与mysql数据库中用户名对应的键
- passwdcolumn=password 与mysql数据库中用户密码对应的键
- crypt=0 加密方式，0表示明文，1表示unix方式crypt()函数加密，2表示mysql中的password函数加密,3表示md5加密的。MySQL和libpam-mysql有兼容问题,采用crypt=0

### 为各个虚拟用户建立配置文件

在配置文件中添加
```
user_config_dir=/etc/vsftpd/vconf
```
现在，我们要把各个用户的配置文件放到目录/etc/vsftpd/vconf中
```
sudo mkdir /etc/vsftpd/vconf
cd /etc/vsftpd/vconf 
sudo touch user1 user2 user3
```
用户的根目录不能对别的用户开放写权限

user1文件中的内容如下
```
local_root=/srv/ftp/user1
write_enable=YES
```
user2文件中的内容如下
```
local_root=/srv/ftp/user2
write_enable=YES
```
user3文件中的内容如下
```
local_root=/srv/ftp/user3
write_enable=YES
```
这里要注意不能有空格，不然登录的时候会提示出错。

## Vsftpd虚拟用户设置(通过数据文件) 

### 安装db4-utils

```
sudo apt-get install db4-utils
```

### 创建用户密码文件

```
vi /etc/vsftpd/users.txt
```
一行用户名，一行密码写入到文件中
```
user1
123456
user2
123456
user3
123456
```

### 生成虚拟用户数据文件

```
db_load -T -t hash -f /etc/vsftpd/users.txt /etc/vsftpd/users.db
```

### 配置PAM认证文件

编辑/etc/pam.d/vsftpd
```
auth required /lib/security/pam_userdb.so db=/etc/vsftpd/users
account required /lib/security/pam_userdb.so db=/etc/vsftpd/users
```

### 添加禁止登录系统的用户

```
sudo useradd vsftpduser -d /srv/ftp -s /sbin/nologin -g nogroup
```

在配置文件 vsftpd.conf加入
```
#设定启用虚拟用户功能
guest_enable=YES
#指定虚拟用户的宿主用户。-CentOS中已经有内置的ftp用户了
guest_username=vsftpduser
```

## Chroot

### 限制所有

限制登录用户访问其他目录，改之前登录显示的路径比如是 ~ ，改之后则是 /。
注：我的本地用户(local user为fenghao,home directory为/home/fenghao)

```
root@ubuntu:~# ftp localhost
Connected to localhost.
220 (vsFTPd 2.3.2)
Name (localhost:fenghao): fenghao 

331 Please specify the password.
Password:
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> 
ftp> pwd
'''257 "/"'''
```

看上边，正常情况下，输入pwd时，应该是显示/home/fenghao.
由于我做了chroot.所以，/home/fenghao变成 /
```
chroot_local_user=YES
```

### 开放所有，限制特定

可指定一组用户限制
```
chroot_local_user=NO
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd/chroot_list
```

随后创建列表
```
sudo vi  /etc/vsftpd/chroot_list
```

一行一个用户名 重启vsftpd
```
sudo service vsftpd restart
```
chroot_list中的用户将被限制登录的根目录

### 限制所有，开放特定

上面的规则是限制 /etc/vsftpd/chroot_list 中的用户，反过来限制一切，只解禁 /etc/vsftpd/chroot_list 的用户。这样：
```
chroot_local_user=YES
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd/chroot_list
```

## 分析日志文件

安装weblizer(类似软件还有awstats)
```
sudo apt-get install weblizer
```
配置文件: 
```
sudo gedit /etc/webalizer/webalizer.conf
```
解决乱码: 
```
sudo mv /usr/share/locale/zh/LC_MESSAGES/webalizer.mo /home/fenghao/back
```
分析日志: 
```
sudo webalizer /var/log/xferlog -F ftp
```
自动分析日志:
```
#!/bin/bash
# update access statistics for ftp
# 需要设置/var/www/webalizer /var/log/xferlog 
if [ -s /var/log/xferlog ]; then
   exec /usr/bin/webalizer -Q -F ftp -o /var/www/webalizer /var/log/xferlog 
fi
```
把上面的复制粘贴到`webalizer_daily.sh`中。

编辑`/etc/crontab`
```
vi /etc/crontab
```
加入下面内容，则每天四点零二执行脚本
```
02  4  *  *  *   root      run-parts /home/fenghao/webalizer_daily.sh    # 每天
```
