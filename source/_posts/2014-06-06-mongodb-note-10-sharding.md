title: mongodb笔记(十) 分片
date: 2014-06-06 16:45:46
tags:
- mongodb
categories:
- database
- mongodb
description: mongodb sharding, mongodb 分片
---

## 分片简介

分片是指将数据拆分，将其分散存在不同的机器上的过程。

<!-- more -->

## MongoDB中的自动分片

没有分片的时候，客户端连接mongod。分片时客户端会连接到mongos，mongos对应用隐藏了分片的细节。
 
何时分片 

1. 机器的磁盘不够用了
2. 单个mongod已经不能满足写数据的性能需要了。
3. 想将大量的数据放在内存中提高性能。

一般来说，先从不分片开始，然后在需要时将其转换成分片。
 
## 片键

在设置分片时，需要从集合里面选一个键，用该键的值作为数据拆分的依据。这个键就是片键。

例如我有个文档集合表示人员，如果选择名字(name)为片键，第一片可存放A~F开头的文档，第二片存放G~P的文档，第三片存放Q~Z的文档。

选择片键并创建片键很像索引，因为二者原理类似。事实上，片键也是最常用的索引。
 
片键对操作的影响
```
db.people.find(({"name":"Susan"}))   //mongos会将这个查询直接发送给Q~Z片
db.people.find({"name":{"$lt":"L"}})    //mongos会将这个查询先后发送给A~F和G~P片
db.people.find({"email":"joe@example.com"})   //mongos不跟踪email键，所以不知道应该讲查询发给谁，就向所有片发送查询
```

## 建立分片

建立分片只有两步：启动实际的服务器，然后决定怎么切分数据。
分片一般有3个组成部分：
- 片
    
    就是保存子集合数据的容器。片可以是单个mongod服务器，也可以是副本集。所以即使一片内有多台服务器，也只能有一个主服务器。
- Mongos
    
    是MongoDB各版本中配的路由器进程。它路由所有请求，然后将结果聚合。它本身并不存储数据或者配置信息（但会缓存配置服务器的信息）。
- 配置服务器
    
    存储了集群的配置信息，数据和分片的对应关系。Mongos不永久存放数据，所以需要个地方存放分片配置，它会从配置服务器获取同步数据。
 
 
### 启动服务器

首先启动配置服务器和mongos。配置服务器需要先启动，因为mongos会用到配置信息。配置服务器的启动就像普通的mongod一样。
```
mkdir -p ~/dbs/config
./mongod --dbpath ~/dbs/config --port 20000
```
建立mongos进程，这种路由服务器连接数据目录都不需要，但一定要指明配置服务器的位置。
```
./mongos --port 30000 --configdb localhost:20000
```

添加片

片就是普通的mongod实例（或者副本集）
```
mkdir -p ~/dbs/shard1
./mongod --dbpath ~/dbs/shard1 --port 10000
```
现在连接刚才启动的mongos，为集群添加一个片。启动shell，连接mongos
```
./mongo localhost:30000/admin
db.runCommand({
"addshard" : "localhost:10000",
"allowLocal" : true
})
```
当在localhost上运行片时，得设定allowLocal键。
 
 
### 切分数据

MongoDB不会将存储的每一条数据都直接发布，得先在数据库和集合的级别将分片功能打开。下面例子我们以"_id"为基准切分foo数据库的bar集合。
首先开启数据库foo的分片功能：
```
db.runCommand({"enablesharding":"foo"})
```
然后开启集合bar的分片功能并以_id为片键
```
db.runCommand({
"shardcollection":"foo.bar",
"key":{"_id":1}
})
```
 
## 生产配置

成功地构建分片需要如下条件：
- 多个配置服务器
- 多个mongos服务器
- 每个片都是副本集
- 正确设置w (有关w和复制的信息在上一章)
 
### 健壮的配置

```
mkdir -p ~/dbs/config1 ~/dbs/config2 ~/dbs/config3
./mongod --dbpath ~/dbs/config1 --port 20001
./mongod --dbpath ~/dbs/config2 --port 20002
./mongod --dbpath ~/dbs/config3 --port 20003
```
创建配置服务器如上，现在启动mongos的时候应将其连接到这3个配置服务器。
```
./mongos --configdb localhost:20001,localhost:20002,localhost:20003
```
配置服务器使用的是两步提交机制，不是普通的MongoDB的异步复制，来维护集群配置的不同副本。这样能保证集群状态的一致性。这意味着某台配置服务器宕掉了后，集群配置信息将是只读的。但是客户端还是能够读写的，只有所有配置服务器备份了以后才能重新均衡数据。
 
### 多个mongos

mongos的数量不受限制，建议针对一个应用服务器只运行一个mongos进程。这样每个应用服务器就可以与mongos进行本地会话。
 
### 健壮的片

生产环境中，每个片都应是副本集。这样单个服务器坏了，就不会导致整个片失效。用addshard命令就可以讲副本集作为片添加，添加时只要指定副本集的名字和种子就好了。

比如现在添加副本集foo，其中包含一个服务器prod.example.com:27017 (还有别的服务器)，就可以使用下列命令将其添加到集群里。
```
db.runCommand({"addshard":"foo/prod.example.com:27017"})
```
如果prod.example.com挂了，则mongos会知道它所连接的是哪个副本集，并去寻找新的主节点。

### 物理服务器

不把所有配置服务器放到一台机器，不把所有mongos放到一台机器，不把副本集放到一台机器，但是可以把一个配置服务器，一些mongos进程和副本集的一个节点放到一台服务器上。
 
## 管理分片

分片的信息主要存放在config数据库上，这样就能被任何连接到mongos的进程访问到了。

### 配置集合

下面的代码都假设已经在shell中连接了mongos，并且已经运行了use config。
 
1. 片

    可以在shards集合中查到所有的片`db.shards.find()`
 
2. 数据库
    
    databases集合含有已经在片上的数据库列表和一些相关信息。
```
db.databases.find()
```
    - "_id" ： 表示数据名
    - "partitioned" ： 是否启用分片功能
    - "primary" ：这个值与"_id"对应，表示这个数据的大本营在哪里。也就是开始创建数据库文件的位置
 
3. 块
    
    块信息保存在chunks集合中，你可以看到数据到底是怎么切分到集群的。
```
db.chunks.find()
```
 
### 分片命令

1. 获得概要

    db.printShardingStatus() 给出前面说的那些集合的概要
 
2. 删除片
    
    用removeshard就能从集群中删除片，removeshard会把给定片上的所有块都挪到其他片上。
```
db.runCommand({"removeshard":"localhost:10000"})
```
