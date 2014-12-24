title: Ubuntu下重置忘记的MySql root密码
date: 2013-04-29 18:32:33
categories:
- Database
- MySQL
tags: [MySQL, Ubuntu]
---
有时，我们可能会忘记mysql root密码，这时我们就需要重置它。  
下面就讲下具体操作:

<!--more-->
## 停止mysql进程
```
sudo /etc/init.d/mysql stop
```
或者
```
sudo service mysql stop
```
## 用–skip-grant-tables选项启动mysql进程
```
sudo /usr/sbin/mysqld --skip-grant-tables --skip-networking &
```
## 启动mysql客户端
```
mysql -u root
```
## 刷新MySQL的系统权限相关表，重置密码
```
FLUSH PRIVILEGES;
USE mysql;
UPDATE user SET Password = PASSWORD('new_password') WHERE Host = 'localhost' AND User = 'root';
```
## 刷新MySQL的系统权限相关表，重启mysql进程
```
FLUSH PRIVILEGES;
exit;
sudo /etc/init.d/mysql restart
```

参考：[Reset lost/forgot MYSQL root password ubuntu](http://chetansingh.me/2012/07/01/reset-lostforgot-mysql-root-password-ubuntu/)

