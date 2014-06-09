title: mongodb笔记(五) 索引
date: 2014-05-26 11:48:34
tags:
- mongodb
categories:
- database
- mongodb
description: mongodb indexing, mongodb 索引
---

## 索引简介

创建单键索引
```
db.ensureIndex({"date":1})
```
创建复合索引
```
db.ensureIndex({"date":1,"username":1})
```
ensureIndex的文档形式和sort类似。

<!-- more -->

创建下面索引
```
db.ensureIndex({"a":1,"b":1,"c":1,...,"z":1})
```
也就有了{"a":1}、{"a":1,"b":1}、{"a":1,"b":1,"c":1}等索引，但是{"b":1}、{"a":1,"c":1}等索引不存在。

mongodb查询优化器能够重排查询项的顺序，以便利用索引，比如查询{"x":"foo","y":"bar"}的时候，已经有了{"y":1,"x":1}的索引，mongodb会自己找到并利用它。

### 扩展索引

创建索引时应该考虑下面问题:
1. 会做什么样的查询？其中哪些键需要索引？
2. 每个键的索引方向是怎样的？
3. 如何应对扩展？有没有种不同的键的排列可以使常用数据更多地保留在内存中？

如果将索引{"user":1,"date":1}变为{"date":-1,"user":1}则数据库可以将最后几天的索引保存在内存中。

### 索引内建文档的键

可以由内嵌的"comments"文档组成的数组中对"date"键创建索引
```
db.blog.ensureIndex({"comments.date":1})
```

### 为排序创建索引

做无索引排序是有上限的，需要针对一些查询中的排序做索引。

### 索引名称

默认情况下，索引名类似keyname1_dir1_keyname2_dir2..._keynameN_dirN。
其中keynameX代表索引的键，dirX代表索引方向(1、-1)。可以指定索引名
```
db.foo.ensureIndex({"a":1,"b":1,"c":1,...,"z":1},{"name":"alphabet"})
```

## 唯一索引

唯一索引可以确保每个键都有唯一值。
```
db.people.ensureIndex({"username":1},{"unique":true})
```
如果没有对应的键，索引会将其作为null存储，如果对某个键建立了唯一索引，但插入了多个缺少该索引键的文档，则由于文档包含null值而导致失败。

### 消除重复

```
db.people.ensureIndex({"username":1},{"unique":true,"dropDups":true})
```
dropDups 可以保留发现的第一个文档，删除接下来的重复值的文档。

### 复合唯一索引

创建复合唯一索引的时候，单个键的值可以相同，只要组合起来不同就好了。

## 使用explain和hint

```
db.foo.find().explain()
```
可以获取查询的信息
- cursor: 有没有使用索引
- nscanned: 查找了多少文档
- n: 返回文档的个数
- millis: 查询时间

hint可以用来强制指定使用某个索引
```
db.c.find({"age":14,"username":/.*/}).hint({"username":1,"age":1})
```
但是多数情况下没有必要指定使用哪个索引，mongodb的查询优化器很智能。

## 索引管理

索引的元信息存储在每个数据库的system.indexes集合中。这是一个保留集合，不能对其插入或者删除文档。操作只能通过ensureIndex或者dropIndexes进行。

system.indexes集合包含每个索引的详细信息，同时system.namespaces集合也含有索引的名字。

### 修改索引

```
db.people.ensureIndex({"username":1},{"background":true})
```
向现有集合添加新的索引，可以通过使用background选项是任务在后台执行。

```
db.runCommand({"dropIndexes":"foo","index":"alphabet"})
db.runCommand({"dropIndexes":"foo","index":"*"})
```
通过dropIndexes可以删除索引，通过`*`删除所有索引

## 地理空间索引

```
db.map.ensureIndex({"gps":"2d"})
```
`gps`键的值必须是某种形式的一对值：一个包含两个元素的数组或者包含两个键的文档。
```
{"gps":[0,100]}
{"gps":{"x":-30,"y":30}}
{"gps":{"latitude":-100,"longitude":180}}
```
以上形式都是合法的。

默认情况下地理空间索引假设值的范围是-180~180。也可以指定最大最小值，下面创建了一个2000光年的空间索引
```
db.star.trek.ensureIndex({"light-years":"2d"},{"min":-1000,"max":1000})
```

### 两种方式查询

- $near

```
db.map.find({"gps":{"$near":{40,-73}}})
```
这会按照离点(40,-73)由近及远的方式将map的所有文档返回。

- geoNear

```
db.runCommand({geoNear:"map",near:[40,-73],num:10})
```
geoNear还会返回每个文档到查询点的距离。

### 按形状查询

对于矩形
```
db.map.find({"gps":{"$within":{"$box":[[10,20],[15,30]]}}})
```
第一元素是左下角坐标，第二个元素是右上角坐标。

对于圆
```
db.map.find({"gps":{"$within":{"$center":[[12,25],5]}}})
```
第一个元素是圆心坐标，第二个是半径

### 复合地理空间索引

如果查询附近所有咖啡馆，可以创建复合索引
```
db.ensureIndex({"location":"2d","desc":1})
```

然后查找最近的咖啡馆
```
db.map.find({"location":{"$near":[-70,30]},"desc":"coffeeshop"}).limit(1)
```
