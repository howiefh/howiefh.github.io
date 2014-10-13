title: 小米2连接Ubuntu12.04进行调试
date: 2013-04-29 15:32:38
categories: ubuntu
tags: [小米, ubuntu]
---
## 运行lsusb
打开终端，在未连接小米的情况下运行lsusb，之后连接小米再运行lsusb，比较两次的输出应该会发现多出这样一行：
```
Bus 001 Device 007: ID 2717:xxxx
```
其中`xxxx`应该是因人而异的，这个ID就是咱们的小米了。请记下这个ID，之后会用到。
<!--more-->  
  
## 编辑/etc/udev/rules.d/50-android.rules中的规则
```
sudo vi  /etc/udev/rules.d/50-android.rules
```
在打开的文件中增加以下文本：
```
SUBSYSTEM=="usb", SYSFS{idVendor}=="2717", MODE=="0666"
SUBSYSTEM=="usb_device", SYSFS{idVendor}=="2717", MODE=="0666"
SUBSYSTEM=="usb", ATTR{idVendor}=="2717", ATTR{idProduct}=="xxxx", SYMLINK+="android_adb"
```
替换`ATTR{idProduct}=="xxxx"`中的`xxxx`为你之前显示的结果。  
50-android.rules 文件名应该是随意的，如99-android.rules ，54-android.rules应该也可以。    
注意 `SUBSYSTEM=="usb", SYSFS{idVendor}=="2717", MODE=="0666"`这句是给 ubuntu 7.01 以后的系统识别用的。  
而`SUBSYSTEM=="usb_device", SYSFS{idVendor}=="2717", MODE=="0666"`是给 Ubuntu 7.01之前的系统识别用的。    

## 变更权限
```
sudo chmod a+rx /etc/udev/rules.d/50-android.rules
```

## 重启udev服务
```
sudo service udev restart
```

## 杀死adb正在运行的服务，查看连接的设备  
cd到你的sdk目录下的platform-tools中，执行：
```
sudo ./adb kill-server
sudo ./adb devices
```
如果List of devices attached下没有设备。请执行如下操作：
```
cd ~/.android/
vi adb_usb.ini
```
添加如下内容：
```
0x2717
```
这个 0x2717 就是我们得到的设备号码。  
保存，退出，之后再切换到platform-tools，执行：
```
sudo ./adb kill-server
sudo ./adb devices
```
这时List of devices attached下应该有设备了。之后就可以在eclipse里调试了。

本文参考：<http://www.cnblogs.com/loulijun/archive/2012/12/18/2823272.html>
