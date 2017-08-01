title: 无法解读主机名
date: 2014-02-07 23:11:09
categories: Ubuntu
tags: Ubuntu
---
不知道为啥在执行sudo命令时，会提示sudo: unable to resolve host ，亦即无法解析主机。在网上搜了下，找到了解决方法：

<!-- more -->

```
sudo gedit /etc/hosts
```
找到如下行：
```
127.0.1.1       XXX
```
将其修改为：
```
127.0.1.1       （你现在的主机名）
```
