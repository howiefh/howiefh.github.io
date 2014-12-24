title: mongodb笔记(九) 复制
date: 2014-06-05 23:13:04
tags:
- MongoDB
categories:
- Database
- MongoDB
description: mongodb replication, mongodb 复制
---

## 主从复制

运行mongod --master就启动了主服务器。运行mongod --slave --source master_address则启动了从服务器，其中master_address就是上面的主节点地址。

<!-- more -->

生产环境下应该有多台服务器的，下面简化一下在一台机器上试验。首先，给主节点建立数据目录，绑定端口(10000)
```
mkdir -p ~/dbs/master
./mongod --dbpath ~/dbs/master --port 10000 --master
```
设置从节点，切记选择不同的目录和端口，并且用--source为从节点指定主节点地址
```
mkdir -p ~/dbs/slave
./mongod --dbpath ~/dbs/slave --port 10001 --slave --source localhost:10000
```
一般，不超过12个节点的集群就可以运转良好。

### 选项

- --only 

    在从节点上指定复制某个数据库（默认复制所有数据库）
- --slavedelay
    
    用在从节点上，当应用主节点的操作时增加延时（秒）。对于错误的删除或者插入垃圾数据等事故，通过延缓执行，可以有个恢复的时间差。
- --fastsync
    
    以主节点的数据快照为基础启动从节点，如果数据目录一开始是主节点的数据快照，从节点用这个选项启动要比完整同步快多了
- --autoresync
    
    如果从节点与主节点不同步，则自动重新同步
- --oplogSize
    
    主节点oplog的大小（MB）

### 添加及删除源

启动从节点时，可以用--source指定主节点，也可以在shell中配置这个选项。

假设主节点绑定了localhost:27017。启动从节点时可以不添加源，而是随后向sources集合添加主节点信息。
```
./mongod --slave --dbpath ~/dbs/slave --port 27018
```
现在可以在shell中运行如下命令，将localhost:27017作为源添加到从节点上：
```
use local
db.sources.insert({"host":"localhost:27017"})
```
假设在生产环境下，想更改从节点的配置，改为prod.example.com为源，则可以用insert和remove来完成。
```
db.sources.insert({"host","prod.example.com"})
db.sources.remove({"host","localhost:27017"})
```
可以看到，sources集合可以当做普通集合进行操作，而且为管理从节点提供了很大的灵活性。

注：要是切换的两个主节点有相同的集合名，则MongoDB会尝试合并，但不能保证正确合并，要是使用一个从节点对应多个不同的主节点，最好使用不同的命名空间。

## 副本集

副本集就是有自动故障恢复功能的主从集群。主从集群和副本集最为明显的区别就是副本集没有固定的主节点。可以把副本集当做一个集群，整个集群会选出一个主节点，当其不能正常工作时则会激活其他节点。

### 初始化副本集

设置副本集比主从稍微复杂点，我们从2个服务器开始：

注意不能用localhost作为地址成员，需要找到主机名，`cat /etc/hostname`(主机名是morton) 。然后为每一个服务器创建数据目录，选择端口，`mkdir -p ~/dbs/node1 ~/dbs/node2` 。

在启动之前，我们需要给副本集一个名字，这里命名为blort 。之后我们用 --replSet选项，作用是让服务器知晓在这个blort副本集还有别的同伴。
```
./mongod --dbpath ~/dbs/node1 --port 10001 --replSet blort/morton:10002
./mongod --dbpath ~/dbs/node2 --port 10002 --replSet blort/morton:10001
```
如果想添加第三台：
```
./mongod --dbpath ~/dbs/node3 --port 10003 --replSet blort/morton:10001,morton:10002
```
 
现在我们启动一个服务器morton:10001，并进行初始化设置
```
./mongo morton:10001/admin
db.runCommand({"replSetInitiate":{
"_id" : "blort",
"members" : [
{
"_id" : 1,
"host" : "morton:10001"
},
{
"_id" : 2,
"host" : "morton:10002"
}
]
}})
```
 
### 副本集中的节点

- standard
    
    常规节点，它存储一份完整的数据副本，参与选举投票可以成为活跃节点。
- passive
    
    被动节点。存储了完整的数据副本，参与投票，不能成为活跃节点。
- arbiter
    
    仲裁者只参与投票，不能接受复制数据，也不能成为活跃节点。
    
每个参与节点（非仲裁者）都有个优先权，优先权为0是被动的，不能成为活跃节点，优先值不为0，则按照大小选出活跃节点。如果2个值一样，则数据最新的为活跃节点。
 
 
在节点配置中修改priority键，来配置成标准节点或被动节点。
```
member.push({
"_id":3,
"host":"morton:10003",
"priority":40
})
```
默认优先级是1，可以是0~1000(含)
 
arbiterOnly键可以指定仲裁节点
```
member.push({
"_id":4,
"host":"morton:10004",
"arbiterOnly":true
})
``` 

### 故障切换和活跃点选举

如果活跃几点坏了，其它节点会选一个新的活跃节点出来(新比较优先级，优先级相同的，各个节点判断哪个数据最新，就会投哪个)。

当前活跃节点失效，包括两种情况：
- 当前活跃节点宕机或本身异常。
- 当前活跃节点会通过心跳跟踪集群中多少节点对其可见，如果数量小于集群服务器数量的一半，会自动降级为备份节点。

任何时候，活跃节点的数据会被认为是最新的,当重新确定了活跃节点后，所有其他节点都要重新进行完整同步(数据可能发生回滚)。 

## 在从服务器上执行操作

### 读扩展

用mongodb扩展读取的一种方式就是将查询放在从节点上。这样主节点的负载就减轻了。一般来说，当负载是读取密集型时这是非常不错的方案。要是写入密集型，则要参见第十章用分片来进行扩展。

扩展读取本身很简单，和往常一样设置主从复制，连接从服务器处理请求，唯一的技巧是告诉从服务器是否可以处理请求（默认是不可以的）。这个选项叫做slaveOkay。
 
### 用从节点做数据处理

我们可以使用--master参数启动一个普通的从节点。同时使用--slave和--master有点矛盾，其实这意味着如果对从节点进行写入，则把从节点就当做普通的MongoDB。其实它还是会不断的复制主节点的数据，这样就可以对节点执行阻塞操作而不影响主节点性能。

注意：用这种技术的时候，一定要确保不能对正在复制的主节点的从节点进行数据库插入。而且从节点第一次启动时也不能有正被复制的数据库。

## 工作原理

### Oplog

主节点的操作记录称为oplog(operation log)。oplog存储在一个特殊的数据库中，叫做local。oplog就在其中的oplog.$main集合里面。oplog中的每个文档都代表主节点执行的一个操作。

- ts
    
    操作的时间戳
- op
    
    操作的类型,只有1字节代码（如i代表插入）
- ns

    执行操作的命令空间
- o
    
    进一步指定要执行的操作的文档，对插入来说，就是要插入的文档

oplog不记录查询操作，oplog存储在固定集合里面，所以它们会自动替换旧的操作。启动服务器时可以用--oplogSize指定这个大小（单位是MB）

### 同步

从节点跟不上同步时，可以用{"resync":1}命令手动执行重新同步，也可以在启动从节点的时候用--autoresync选项让其自动重新同步。为避免从节点跟不上，一定要确保主节点oplog足够大，默认oplog的大小是剩余磁盘空间的5%。
 
### 复制状态和本地数据库

本地数据库（local）用来存放所有内部复制状态。其内容不会被复制，确保了一个MongoDB服务器只有一个本地数据库。

主节点上的复制状态还包括从节点的列表，这个列表存放在slaves集合中。
```
db.slaves.find()
```
从节点也在本地数据库中存放状态。在me集合存放从节点唯一标识符，在sources集合存放源或节点的列表。
```
db.sources.find()
```

### 阻塞复制

可以用getLastError的"w"参数来确保数据的同步性。
```
db.runCommand({getLastError:1,w:N})
```
如果没有N，或者小于2，命令就会立刻返回。如果N等于2，主节点要等到至少一个从节点复制了上一个操作才会响应命令(主节点本身也包括在N里面)。指定"w"选项后，还可以使用"wtimeout"选项，表示以毫秒为单位的超时。getLastError就能在上一个操作复制到N个节点超时时的错误。将N设为2或3就能效率与安全兼备了。

## 管理

### 诊断

当连接到主节点后，使用db.printReplicationInfo()函数
```
db.printReplicationInfo(); 
```
这些信息是oplog的大小和oplog中操作的时间范围。

当连接到从节点时，用db.printSlaveReplicationInfo()函数，能得到从节点的一些信息。
 
### 变更oplog的大小

若发现oplog大小不适合，最简单的方法是停掉主节点，删除local数据库的文件，用新的设置(--oplogSize)重新启动。
```
rm /data/db/local.*
./mongod --master --oplogSize <size>
```
重启主节点后，所有的从节点要用--autoresync重启，否则需要手动同步更新。

### 复制的认证问题

在主节点和从节点都需要在本地数据库添加用户，每个节点的用户名和口令都是相同的。

从节点连接主节点时，会用存储在local.system.users中的用户进行认证。最先尝试"repl"用户，若没有此用户，则用local.system.users中的第一个可用用户。所以按如下步骤配置主节点和从节点。
```
use local
db.addUser("repl",password)
```

