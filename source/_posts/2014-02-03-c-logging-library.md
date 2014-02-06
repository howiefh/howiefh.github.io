title: C语言日志系统库
date: 2014-02-03 17:25:10
categories: c
tags: [c, log]
---
本文要介绍两个C语言日志系统库:log4c和zlog。主要介绍下载安装，简单配置以及封装使用的步骤。
# log4c
## 下载
下载源码<http://sourceforge.net/projects/log4c/>，解压 （假定位置是~/log4c-1.2.4）

<!-- more -->
## 编译安装log4c
```shell
cd ~
tar -zxvf log4c-1.2.4.tar.gz
cd log4c-1.2.4
mkdir build; cd build
../configure
make
sudo make install
```

## 配置log4c的lib所在目录
安装完之后为了让你的程序能找到log4c动态库
```shell
$ sudo vi /etc/ld.so.conf
/usr/local/lib
$ sudo ldconfig
```

## 配置文件及封装
假定在~/logtest中   
创建~/logtest/log4crc   
输入配置：
```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE log4c SYSTEM "">

<log4c version="1.2.4">

        <config>
                <bufsize>0</bufsize>
                <debug level="2"/>
                <nocleanup>0</nocleanup>
				<reread>1</reread>
        </config>

        <!-- root category ========================================= -->
        <category name="root" priority="notice"/>
		<category name="mycat" priority="debug" appender="stdout"/>
		<category name="file" priority="debug" appender="logfile"/>

        <!-- default appenders ===================================== -->
        <appender name="stdout" type="stream" layout="basic"/>
        <appender name="logfile" type="rollingfile" layout="dated" rollingpolicy="RollingPolicy"/>
        <appender name="stderr" type="stream" layout="dated"/>
        <appender name="syslog" type="syslog" layout="basic"/>

        <!-- default layouts ======================================= -->
        <layout name="basic" type="basic"/>
        <layout name="dated" type="dated"/>
		
         <!--sizewin表示达到最大值后新建日志文件  值由maxsize设定，单位Bytes     maxnum为最大文件数目 maxsize=5mb -->  
		<rollingpolicy name="RollingPolicy" type="sizewin" maxsize="5000000" maxnum="32767" />
</log4c>
```
详细一点的配置文件讲解：
<http://xueqi.iteye.com/blog/1570013>  
对log4c 进行封装
```c
// ===  FILE  ======================================================================
//         Name:  log.h
//  Description:  LOG_DEBUG 记录debug日志
//				  LOG_ERROR 记录error日志
//				  LOG_FATAL 记录fatal日志
//				  LOG_INFO 记录info日志
//				  LOG_NOTICE 记录notice日志
//				  LOG_WARN 记录warn日志
//				  LOG_TRACE 记录trace日志
// =====================================================================================
#ifndef __LOG_H_
#define __LOG_H_

#include <string.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C"
{
#endif

#include "log4c.h"

#ifdef __cplusplus
}
#endif

#define LOG_PRI_FATAL		LOG4C_PRIORITY_FATAL
#define LOG_PRI_ERROR 		LOG4C_PRIORITY_ERROR
#define LOG_PRI_WARN 		LOG4C_PRIORITY_WARN
#define LOG_PRI_NOTICE 		LOG4C_PRIORITY_NOTICE
#define LOG_PRI_INFO		LOG4C_PRIORITY_INFO
#define LOG_PRI_DEBUG 		LOG4C_PRIORITY_DEBUG
#define LOG_PRI_TRACE 		LOG4C_PRIORITY_TRACE

extern int log_init(const char *category);
extern void log_message(int priority , 
		const char *file, int line, const char *fun, 
		const char *fmt , ...);
extern int log_fini();

#define LOG_FATAL(fmt,args...) 		\
	log_message(LOG_PRI_FATAL,__FILE__ , __LINE__ , __FUNCTION__ , fmt , ##args)
#define LOG_ERROR(fmt , args...)	\
	log_message(LOG_PRI_ERROR,__FILE__ , __LINE__ , __FUNCTION__ , fmt, ##args)
#define LOG_WARN(fmt, args...)		\
	log_message(LOG_PRI_WARN,__FILE__ , __LINE__ , __FUNCTION__ , fmt , ##args)
#define LOG_NOTICE(fmt , args...)	\
	log_message(LOG_PRI_NOTICE,__FILE__ , __LINE__ , __FUNCTION__ , fmt , ##args)
#define LOG_INFO(fmt,args...) 		\
	log_message(LOG_PRI_INFO,__FILE__ , __LINE__ , __FUNCTION__ , fmt , ##args)
#define LOG_DEBUG(fmt , args...)	\
	log_message(LOG_PRI_DEBUG,__FILE__ , __LINE__ , __FUNCTION__ , fmt , ##args)
#define LOG_TRACE(fmt,args...) 		\
	log_message(LOG_PRI_TRACE, __FILE__ , __LINE__ , __FUNCTION__ , fmt ,##args)

#endif
```
log.c:
```c
// ===  FILE  ======================================================================
//         Name:  log.c 
//  Description:  log_init 初始化logger
//				  log_fini 关闭打开的资源
//			      log_message 记录日志信息
// =====================================================================================
#include <log4c.h>
#include <assert.h>
#include "log.h"


static log4c_category_t *log_category = NULL;

// ===  FUNCTION  ======================================================================
//         Name:  log_init
//  Description:  从配置文件"log4crc"中读取配置信息到内存,使用分类category初始化logger
//  @param category [in]: 分类
// =====================================================================================
int log_init(const char *category)
{
    if (log4c_init() == 1)
    {
        return -1;
    }
    log_category = log4c_category_get(category);
    return 0 ;
}

// ===  FUNCTION  ======================================================================
//         Name:  log_message
//  Description:  记录日志信息
//  @param priority [in]: 日志类别
//  @param file [in]: 文件
//  @param line [in]: 行
//  @param fun [in]: 函数
//  @param fmt [in]: 格式化参数
// =====================================================================================
void log_message(int priority , 
			const char *file, int line, const char *fun, 
			const char *fmt , ...)
{
	char new_fmt[2048];
	const char * head_fmt = "[file:%s, line:%d, function:%s]"; 
	va_list ap;
	int n;
	
	assert(log_category != NULL);
	n = sprintf(new_fmt, head_fmt , file , line , fun);
	strcat(new_fmt + n , fmt);

	va_start(ap , fmt);
	log4c_category_vlog(log_category , priority, new_fmt , ap);
	va_end(ap);
}

// ===  FUNCTION  ======================================================================
//         Name:  log_fini
//  Description:  清理所有申请的内存，关闭它们打开的文件
// =====================================================================================
int log_fini()
{
    return (log4c_fini());
}
```
测试代码：
```c
//test-log.c
#include <stdio.h>
#include "log.h"

int main(void)
{
	log_init("file");
	while (1) {
		LOG_ERROR("error");
		LOG_WARN("warn");
		LOG_NOTICE("notice");
		LOG_DEBUG("debug");
		LOG_INFO("info");
		LOG_FATAL("fatal");
		LOG_TRACE("trace");
	}
	log_fini();
	return 0;
}
```

## 编译执行
```shell
gcc test-log.c log.c -o test-log -llog4c
./test-log
```

# zlog
## 下载
下载源码<https://github.com/HardySimpson/zlog/releases>，解压 （假定位置是~/zlog）

## 编译安装zlog
```shell
cd ~
tar -zxvf zlog-latest-stable.tar.gz
cd zlog-latest-stable/
make 
sudo make install
```

## 配置zlog的lib所在目录
安装完之后为了让你的程序能找到zlog动态库
```shell
$ sudo vi /etc/ld.so.conf
/usr/local/lib
$ sudo ldconfig
```

## 配置文件及封装
假定在~/logtest中   
创建~/logtest/log.conf
输入配置：
```ini
[rules]
my_cat.NOTICE   "./log/log", 5MB ~ "./log/back/log-%d(%Y%m%d %H%M).#2s.log"
my_cat.DEBUG	>stdout;
```
对zlog 进行封装
```c
#ifndef __LOG_H_
#define __LOG_H_

#include <string.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C"
{
#endif

#include "zlog.h"

#ifdef __cplusplus
}
#endif

extern zlog_category_t * log_category;
// ===  FUNCTION  ======================================================================
//         Name:  log_init
//  Description:  ¿?¿?¿?¿?¿?"log.conf"¿?¿?¿?¿?¿?¿?¿?¿?¿?¿?,¿?¿?¿?¿?category¿?¿?¿?logger
//  @param category [in]: ¿?¿?
// =====================================================================================
extern int log_init(const char *category);
// ===  FUNCTION  ======================================================================
//         Name:  log_fini
//  Description:  ¿?¿?¿?¿?¿?¿?¿?¿?¿?¿?¿?¿?¿?¿?¿?¿?¿?¿?¿?
// =====================================================================================
extern void log_fini();
//¿?¿?¿?
#define LOG_FATAL(fmt,args...) 		\
	zlog(log_category, __FILE__, sizeof(__FILE__)-1, \
	__func__, sizeof(__func__)-1, __LINE__, \
	ZLOG_LEVEL_FATAL, fmt, ##args)
#define LOG_ERROR(fmt , args...)	\
	zlog(log_category, __FILE__, sizeof(__FILE__)-1, \
	__func__, sizeof(__func__)-1, __LINE__, \
	ZLOG_LEVEL_ERROR, fmt, ##args)
#define LOG_WARN(fmt, args...)		\
	zlog(log_category, __FILE__, sizeof(__FILE__)-1, \
	__func__, sizeof(__func__)-1, __LINE__, \
	ZLOG_LEVEL_WARN, fmt, ##args)
#define LOG_NOTICE(fmt , args...)	\
	zlog(log_category, __FILE__, sizeof(__FILE__)-1, \
	__func__, sizeof(__func__)-1, __LINE__, \
	ZLOG_LEVEL_NOTICE, fmt, ##args)
#define LOG_INFO(fmt,args...) 		\
	zlog(log_category, __FILE__, sizeof(__FILE__)-1, \
	__func__, sizeof(__func__)-1, __LINE__, \
	ZLOG_LEVEL_INFO, fmt, ##args)
#define LOG_DEBUG(fmt , args...)	\
	zlog(log_category, __FILE__, sizeof(__FILE__)-1, \
	__func__, sizeof(__func__)-1, __LINE__, \
	ZLOG_LEVEL_DEBUG, fmt, ##args)

#endif
```
log.c:
```c
// ===  FILE  ======================================================================
//         Name:  log.c 
//  Description:  log_init 初始化logger
//				  log_fini 关闭打开的资源
//				  LOG_DEBUG 记录debug日志
//				  LOG_ERROR 记录error日志
//				  LOG_FATAL 记录fatal日志
//				  LOG_INFO 记录info日志
//				  LOG_NOTICE 记录notice日志
//				  LOG_WARN 记录warn日志
// =====================================================================================
#include <zlog.h>
#include <assert.h>
#include "log.h"

zlog_category_t * log_category = NULL;

// ===  FUNCTION  ======================================================================
//         Name:  log_init
//  Description:  从配置文件"log.conf"中读取配置信息到内存,使用分类category初始化logger
//  @param category [in]: 分类
// =====================================================================================
int log_init(const char *category)
{
	//初始化.配置文件名是固定的log.conf
    if (zlog_init("log.conf") == 1)
    {
        return -1;
    }
	//找到分类,在配置文件中的category
    log_category = zlog_get_category(category);
	if (!log_category) {
		printf("get cat fail\n");
		zlog_fini();
		return -2;
	}
    return 0 ;
}

// ===  FUNCTION  ======================================================================
//         Name:  log_fini
//  Description:  清理所有申请的内存，关闭它们打开的文件
// =====================================================================================
void log_fini()
{
	zlog_fini();
}
```
测试代码：
```c
//test-log.c
#include <stdio.h>
#include "log.h"

int main()
{
	log_init("my_cat");
	while (1) {
		LOG_ERROR("error");
		LOG_WARN("warn");
		LOG_NOTICE("notice");
		LOG_DEBUG("debug");
		LOG_INFO("info");
		LOG_FATAL("fatal");
	}
	log_fini();
	return 0;
}
```

## 编译执行
```shell
gcc test-log.c log.c -o test-log -lzlog
./test-log
```
zlog 有更加详细的文档可以参考：<http://hardysimpson.github.io/zlog/UsersGuide-CN.html>
