title: mongodb笔记(三) 创建、更新、删除文档
date: 2014-05-04 11:21:38
tags:
- MongoDB
categories:
- Database
- MongoDB
description: mongodb 创建，mongodb 删除，mongodb 更新，mongodb 文档
---
## 插入并保存文档

### 批量插入

可以使用`batchInsert()`进行批量插入，如果是导入原始数据可以使用`mongoimport`。批量插入只能插入一个集合，不能插入一次对多个集合操作。

当前版本mongodb接收的最大消息长度为16MB，所以使用批量插入会有所限制。不过一些驱动会将消息拆分为48MB。

<!-- more -->

```
db.foo.batchInsert([{"_id":0},{"_id":1},{"_id":2},{"_id":3}])
db.foo.batchInsert([{"_id":0},{"_id":1},{"_id":1},{"_id":2}])
```

第二条只能插入两个文档，可以使用`continueOnError`选项继续插入，如果使用该选项，第二条命令将会插入三个文档。shell不支持该选项，但是驱动支持。

### 插入原理

插入数据只对是否包含"_id"和文档是否超过16MB进行检查。主流语言的驱动在插入数据时都会进行有效性检查。插入并不执行代码，可以预防注入攻击。

## 删除文档

```
db.foo.remove({})
db.foo.remove({"bar":"hello"})
```

第一条命令会删除集合foo中所有文档，但是不删除集合。第二条命令删除所有bar为hello的文档。删除是永久的，不能撤销，也不能恢复。

### 删除速度

使用`db.foo.drop()`代替`db.foo.remove();db.findOne();`要快很多，但是不能有限制条件，连同索引整个集合都被删除。

## 更新文档

### 文档替换

update要做的首先是查询，然后是替换。
```
{
"_id" : ObjectId("4b2b9f67a1f631733d917a7a"),
"name" : "joe",
"friends" : 32,
"enemies" : 2
}
```
对于上面文档要把friends和enemies放在relationships里，可以执行
```
var joe = db.users.findOne({"name" : "joe"});
joe.relationships = {"friends" : joe.friends, "enemies" : joe.enemies};
joe.username = joe.name;
delete joe.friends;
delete joe.enemies;
delete joe.name;
db.users.update({"name" : "joe"}, joe);
```
现在执行一次find，文档变成了
```
{
"_id" : ObjectId("4b2b9f67a1f631733d917a7a"),
"username" : "joe",
"relationships" : {
"friends" : 32,
"enemies" : 2
}
}
```
但有时update查询时可能会有多个匹配
```
{"_id" : ObjectId("4b2b9f67a1f631733d917a7b"), "name" : "joe", "age" : 65},
{"_id" : ObjectId("4b2b9f67a1f631733d917a7c"), "name" : "joe", "age" : 20},
{"_id" : ObjectId("4b2b9f67a1f631733d917a7d"), "name" : "joe", "age" : 49},
```
执行下面命令更新年龄
```
joe = db.people.findOne({"name" : "joe", "age" : 20});
joe.age++;
db.people.update({"name" : "joe"}, joe);
```
会报`E11001 duplicate key on update`的错误，原因是update先找到了第一个65的joe，要更新的时候，因为已经有了一个相同`_id`所以报错了。最好的做法就是在更新的时候使用每个文档都唯一的`_id`进行查询。

### 使用修改器

- `$set`
    用来指定一个键的值。如果这个键不存在，则创建它。用$set甚至可以修改键的数据类型。也可以用$set修改内嵌文档。
```
db.users.update({"name" : "joe"}, {"$set" : {"favorite book" : ["Cat's Cradle", "Foundation Trilogy", "Ender's Game"]}})
```

- `$unset`
    将键完全删除。
```
db.users.update({"name" : "joe"}, {"$unset" : {"favorite book" : 1}})
```

- `$inc`
    用来增加已有键的值，或者在键不存在时创建一个键。$inc只能用于整数、长整数或双精度浮点数。要是用在其他类型的数据上就会导致操作失败。另外$inc键的值必须是数字。
```
db.games.update({"game" : "pinball", "user" : "joe"},{"$inc" : {"score" : 50}})
```

- `$push`
    会向已有的数组末尾加入一个元素，要是没有就会创建一个新的数组。
    比如向博客中添加评论，如果数组comments不存在，下面语句会创建这个数组，如果存在，则是向数组末尾再添加一个评论
```
db.blog.posts.update({"title" : "A blog post"}, {"$push" : {"comments" :{"name" : "joe", "email" : "joe@example.com","content" : "nice post."}}})
```
    和`$each`一起使用，可以一次想数组添加几个元素
```
db.stock.ticker.update({"_id" : "GOOG"}, {"$push" : {"hourly" : {"$each" : [562.776, 562.790, 559.123]}}})
````
    可以通过`$sort`排序，然后通过`$slice`取出前十
```
db.movies.find({"genre" : "horror"}, {"$push" : {"top10" : { "$each" : [{"name" : "Nightmare on Elm Street", "rating" : 6.6}, {"name" : "Saw", "rating" : 4.3}], "$slice" : -10, "$sort" : {"rating" : -1}}}})
```

- `$addToSet`
    可以避免重复。和$each组合起来，可以添加多个不同的值。
    如果把数组当做集合，里面的值就不能相同了，这时可以用`$push`和`$ne`，`db.papers.update({"authors cited" : {"$ne" : "Richie"}}, {$push : {"authors cited" : "Richie"}})` ，如果不存在 Richie,则会插入，但是有些情况，`$ne`就不能很好工作了。
    只有当数组emails中不存在joe@gmail.com时，才会添加进去。
```
db.users.update({"_id" : ObjectId("4b2d75476cc613d5ee930164")}, {"$addToSet" : {"emails" : "joe@gmail.com"}})
db.users.update({"_id" : ObjectId("4b2d75476cc613d5ee930164")}, {"$addToSet" : {"emails" : {"$each" : ["joe@php.net", "joe@example.com", "joe@python.org"]}}})
```

- `$pop`
    这个修改器可以从数组任何一端删除元素。{$pop:{key:1}}从数组末尾删除一个元素，{$pop:{key:-1}}从头部删除。

- `$pull`
    会将所有匹配的部分删除。
```
db.lists.insert({"todo" : ["dishes", "laundry", "dry cleaning"]})
db.lists.update({}, {"$pull" : {"todo" : "laundry"}})
```

- `$`定位操作符
    可以直接指定数组下标，但是有时候并不是直接就知道下标，所以可以使用定位操作符，它的作用就是定位已经匹配的元素。
```
db.blog.update({"post" : post_id}, {"$inc" : {"comments.0.votes" : 1}})
db.blog.update({"comments.author" : "John"}, {"$set" : {"comments.$.author" : "Jim"}})
```
- 修改器速度
    如果修改器操作后集合大小会改变，速度会稍慢一些。如果是很大的数组，速度也会比较慢。有时候可以考虑将内嵌数组独立到一个集合中。

### upsert

upsert是一种特殊的更新。当没有符合条件的文档，就以这个条件和更新文档为基础创建一个新的文档，如果找到匹配的文档就正常的更新。
使用upsert，既可以避免竞态问题，也可以减少代码量（update的第三个参数就表示这个upsert，参数为true时）
```
db.users.update({"rep" : 25}, {"$inc" : {"rep" : 3}}, true)
```
执行命令之后rep为28

### save shell帮助程序
save是shell函数，可以在文档不存在时插入，存在时更新。只有一个参数文档。如果文档含有`_id`，save就会调用upsert。否则，调用插入。
```
var x = db.foo.findOne()
x.num = 42
db.foo.save(x)
```
最后一条语句和
```
db.foo.update({"_id":x._id},x)
```
效果一样

### 更新多个文档

update第四个参数为true就是对多个文档更新，默认参数将来可能改变，所以最好总是指定此参数。
```
db.count.update({x : 1}, {$inc : {x : 1}}, false, true)
db.runCommand({getLastError : 1})
```
第一条命令对所有x为1的加一，第二条命令查看更新了多少条。

### 返回已更新文档

将执行命令前的文档赋值给ps
```
ps = db.runCommand({"findAndModify" : "processes","query" : {"status" : "READY"}, "sort" : {"priority" : -1}, "update" : {"$set" : {"status" : "RUNNING"}})
```
将匹配到的文档从集合删除
```
ps = db.runCommand({"findAndModify" : "processes",
"query" : {"status" : "READY"},
"sort" : {"priority" : -1},
"remove" : true}).value
do_something(ps)
```
- findAndModify
    字符串, 集合名
- query
    查询文档; 用来检索文档的条件
- sort
    排序结果的条件
- update
    修改器文档，对所找到的文档执行更新。
- remove
    布尔类型，表示是否删除文档
- new
    布尔类型，表示返回的是更新前的还是更新后的文档，默认是更新前的。
- fields
    文档返回的字段(可选)
- upsert
    布尔类型，是否执行upsert，默认false
remove和update必须有一个。
执行会慢一些。如果多个线程之间有竞争关系，使用findAndModify是很有必要的。

## 设置写问题

在2012年mongodb改变了默认的写数据的安全设置。之前默认是没有应答的，现在有。如果驱动中有一个MongoClient类，那么他默认写是安全的。

## 连接

mongodb为每一个连接创建一个队列，如果有两个线程，一个线程刚执行完插入操作，另一个线程不一定能够立刻查询到刚刚插入到内容。但这种情况很难手动模拟。很多驱动程序都由一个连接来处理一系列的请求。
