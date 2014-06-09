title: mongodb笔记(八) 管理
date: 2014-06-05 09:20:02
tags:
- mongodb
categories:
- database
- mongodb
description: mongodb administration, mongodb 管理
---

启动和停止MongoDB在第一部分已经有记录了。

## 监控

### 使用管理接口

默认情况下，启动mongod时还会启动一个HTTP服务器。打开http://localhost:28017 可以看见管理接口。可以看到断言、锁、索引和复制等相关信息。

<!-- more -->

要想利用好管理接口（比如访问命令列表），需要用--rest 选项开启REST支持；也可以在启动mongod时使用--nohttpinterface关闭管理接口。

### serverStatus

```
db.runCommand({"serverStatus":1})
```
获取mongodb服务器统计信息。也可以在http://localhost:28017/_status 查看。

- globalLock:表示全局写入锁占用了服务器多少时间（ms）
- mem:包含服务器内存映射了多少数据，服务器进程的虚拟内存和常驻内存的占用情况（单位MB）
- indexCounters:表示B树在磁盘检索（misses）和内存检索（hits）的次数；若此比值开始上升则需添加内存了，否则系统性能就会收到影响
- backgroudFlushing:表示后台做了多少次fsync以及用了多少时间
- opcounters:包含了每种主要操作的次数，如insert、query等
- asserts:统计断言的次数，如regular、warnning
- serverStatus结果中的所有计数都是在服务器启动时开始计算的，如果过大就会复位；当发生复位时，所有计数器都复位，asserts中的rollovers只会增加

### mongostat

- mongostat可实时查看serverStatus的结果，输出多列，分别是inserts/s、commands/s、vsize和% locked，与serverStatus的数据相对应
- 查看方法：mongostat --port 10000

### 第三方插件

Nagios、Munin、Ganglia、Cacti

## 安全和认证

每个MongoDB实例中的数据库都有多个用户，如果开启了安全性检查，则只有数据库认证用户才能执行读或写操作。在认证的上下文中，MongoDB会将普通的数据作为admin数据库处理。admin数据库中的用户被视为超级用户。

在开启安全检查之前，一定要至少有个管理员账号。开始时shell连接的是没有开启安全检查的服务器。
```
use admin
db.addUser("root","abcd");
use test
db.addUser("test_user","abcd");
db.addUser("read_only","abcd",true);
```
上面添加了管理员root，在test数据库添加了两个普通账号，其中一个是只读权限的，不能对数据库写入。在shell中创建只读用户只需要将addUser的第三个参数设置为true即可。

addUser 还可以修改用户口令或只读状态。

现在我们重启服务器，这次加入 --auth 命令选项，开启安全检查。
```
use test
db.test.find(); //这样会报错，因为没有登录
db.auth('read_only','abcd'); //用户登录
db.test.find()
db.test.insert({"x":2})   //只读权限，不能插入数据
db.auth('test_user','abcd'); //用户登录
db.test.insert({"x":2})
db.test.find()
show dbs  //报错,不是管理员
use admin
db.auth("root","abcd")
show dbs
```

### 认证的工作原理

数据库的用户账户以文档的形式存储在system.users集合里面，文档的结构是
```
{"user":username,"readonly":true,"pwd":password hash}
```
如果需要删除用户，和删除文档一样：
```
db.system.users.remove({"user":"username"})
```
 
### 其他安全考虑

建议将MongoDB服务器布置在防火墙后或者布置在只有应用服务器能访问的网络中。但要是MongoDB必须能被外面访问到的话，建议使用 --bindip 选项，可以指定mongod绑定到本地IP地址。

例如，只能从本机应用服务器访问。Mongod --bindip localhost

--nohttpinterface:关闭HTTP管理接口
--noscripting:完全禁止服务端Javascript的执行

## 备份和修复

### 数据库文件备份

属于冷备份。关闭服务器，然后备份数据，只要简单的创建数据目录中所有文件的副本就可以了。

- 优点：可以完全保证数据一致性
- 缺点：需要数据库引擎离线
 
### mongodump和mongorestore

属于热备份。mongodump是一种能在运行时备份的方法。mongodump对运行的MongoDB做查询，然后将所有查到的文档写入磁盘。

mongodump也可以通过运行 --help 选项查看所有选项。
 
mongorestore可以获取mongodump的输出结果，并将备份的数据插入到运行的MongoDB实例中。下面的例子演示了从数据库test到backup目录的热备份。

```
./mongodump -d test -o backup
./mongorestore -d foo --drop backup/test/
```
-d指定了要恢复的数据库，--drop代表在恢复前删除集合，否则数据就会与现有集合数据合并。

- 优点：数据库引擎无需离线
- 缺点：不能保证数据完整性，操作时会降低MongoDB性能

### fsync和锁

虽然mongodump和mongorestore能不停机备份，但是我们失去了获取实时数据视图的能力。fsync能够在MongoDB运行时复制数据目录还不会损坏数据。我们还可以选择上锁阻止对数据库的进一步写入。

```
use admin
db.runCommand({"fsync":1,"lock":1});
```
上锁了，备份成功之后，我们就要解锁。
```
db.$cmd.sys.unlock.findOne(); //解锁
db.currentOp(); //确保已经解锁
```

- 优点：备份灵活，不用停止服务器，也不用牺牲备份的实时特性
- 缺点：一些写入操作被暂时阻塞了
 
### 从属备份

创建主从复制机制，配置完成后数据会自动同步

- 优点：可以保持MongoDB处于联机状态，不影响性能
- 缺点：在数据写入密集的情况下可能无法保持数据完整性
 
### 修复

在启动的时候 mongod --repair 修复数据。修复数据还能起到压缩数据的作用。
修复正在运行中的服务器上的数据库，要在shell中用repairDatabase。
```
use test
db.repairDatabase()
```
