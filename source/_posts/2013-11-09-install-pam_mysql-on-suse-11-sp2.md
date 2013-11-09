title: 在SUSE 11 SP2 中安装pam_mysql
date: 2013-11-09 10:52:17
categories: suse
tags: [suse, pam_mysql]
---
近期项目中需要在SUSE服务器中安装vsftpd，并且需要设置虚拟用户，使用mysql来管理虚拟用户，这就需要安装pam_mysql了。在ubuntu下，安装软件很轻松，但是在SUSE下就不太方便了，最要命的是上网还不太方便。折腾了小半天，终于算是装上了，好了，现在总结一下安装的过程和遇到的问题吧。   
<!-- more -->
下载 [pam_mysql-0.7RC1.tar.gz](http://sourceforge.net/projects/pam-mysql/files/pam-mysql/)。 
```shell
tar zxvf pam_mysql-0.7RC1.tar.gz
cd pam_mysql-0.7RC1
./configure  --with-openssl
```
这时候有问题了:  
configure: error: Cannot locate mysql client library. Please check your mysql installation.  
缺少mysql client 库文件  
这时需要安装[libmysqlclient-devel-5.0.94-0.2.4.1.x86_64.rpm](http://www.convirture.com/repos/deps/SLES/11.x/x86_64/libmysqlclient-devel-5.0.94-0.2.4.1.x86_64.rpm)  
这个包还有两个依赖：  
[zlib-devel-1.2.3-106.34.x86_64.rpm](http://www.convirture.com/repos/deps/SLES/11.x/x86_64/zlib-devel-1.2.3-106.34.x86_64.rpm)  
[libopenssl-devel-0.9.8j-0.26.1.x86_64.rpm](http://www.convirture.com/repos/deps/SLES/11.x/x86_64/libopenssl-devel-0.9.8j-0.26.1.x86_64.rpm)  
下载这些包然后执行：
```shell
rpm -ivh zlib-devel-1.2.3-106.34.x86_64.rpm
rpm -ivh libopenssl-devel-0.9.8j-0.26.1.x86_64.rpm
rpm -ivh libmysqlclient-devel-5.0.94-0.2.4.1.x86_64.rpm
```
再执行 `./configure --with-openssl` 又有提示:  
configure: error: Cannot find pam headers. Please check if your system is ready for pam module development.  
是缺少pam 头文件。   
下载[pam-devel-1.1.5-0.10.17.x86_64.rpm](http://occonnect.dk/repo/$RCE/SLE11-SDK-SP2-Core/sle-11-x86_64/rpm/x86_64/pam-devel-1.1.5-0.10.17.x86_64.rpm),安装`rpm -ivh pam-devel-1.1.5-0.10.17.x86_64.rpm`
至此pam_mysql 可以安装了。  
之后执行:
```shell
./configure --with-openssl  
make && make install
```
OK! 
