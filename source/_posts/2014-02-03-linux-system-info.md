title: Linux系统信息
date: 2014-02-03 15:59:04
categories: linux
tags: linux
---
## 查看cpu详细情况    
cpu 个数
```
cat /proc/cpuinfo | grep "physical id" | sort | uniq | wc -l
```
cpu core 个数
```
cat /proc/cpuinfo | grep "cpu cores" | uniq 
```
逻辑cpu 个数
```
cat /proc/cpuinfo | grep "processor" | uniq 
```
逻辑cpu个数不等于cpu 个数乘以 cpu 核个数，说明支持超线程。

<!-- more -->
## 查看内存使用情况    
```
free -m
```
-buffers/cache = used - buffers - cached    
+buffers/cache = used + buffers + cached    
可用内存=free+buffers+cached    

## 查看硬盘使用情况    

* 查看硬盘及分区信息    
```
fdisk -l
```
* 查看文件系统的磁盘空间占用情况    
```
df -h 
```
* 查看I/O性能    
```
iostat -d -x -k 1 10
```
* 查看Linux某目录大小    
```
du -sh /root
```
找出占用空间最多的前十个文件或目录
```
du -cks * | sort -rn | head -n 10
```
* 把指定输入文件复制到指定输出文件    
制作iso镜像时（也可以用mkisofs）
```
dd if=/dev/cdrom of=/root/cd.iso
```

## 查看Linux的平均负载    
uptime    
w命令查看用户    
top命令    

## 监控Linux其他参数    
* 监控Linux整体性能
```
vmstat 1 4
```
* 查看系统内核
```
uname -a 
uname -r
```
查看系统是32位还是64位
```
ls -1F / | grep / $
file /sbin/init
```
* Linux发行版相关信息
```
lsb_release -a
```
* 查看系统已载入的相关模块
```
lsmod | grep ip_vs
```
* 查找PCI设置
```
lspci | grep Ether
```
