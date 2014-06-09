title: 连接数据库失败
date: 2014-02-07 23:02:09
categories:
- database
- mysql
tags: mysql
---
1. ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock' (2)  
出现以上问题，搜索后参考下面的一个回答解决
<http://askubuntu.com/questions/291054/cant-connect-to-local-mysql-server-through-socket-var-run-mysqld-mysqld-sock>
```shell
$ sudo service mysql stop
$ sudo /etc/init.d/apparmor reload
$ sudo service mysql start
```

2. mysql.sock缺失，因为改了配置文件my.cnf。加了log-bin，修改/var/log/mysql文件夹的权限drwxr-s---  2 mysql.mysql
