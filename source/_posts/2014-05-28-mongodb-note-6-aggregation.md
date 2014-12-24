title: mongodb笔记(六) 聚合
date: 2014-05-28 10:11:50
tags:
- MongoDB
categories:
- Database
- MongoDB
description: mongodb aggregation, mongodb 聚合
---

## count

返回集合中的文档数量
```
db.foo.count()
db.foo.count({"x":1}) //也可以传递查询，但会使count变慢
```

<!-- more -->

## distinct

找出给定键的所有不同的值，使用时必须指定集合和键

假设现在有如下文档：
```
{"name":"ada","age":20}
{"name":"pred","age":35}
{"name":"susan","age":60}
{"name":"andy","age":35}
```
吐过对"age"键使用distinct，会获得不同的年龄
```
db.runCommand({"distinct":"people","key","name"})
```
## group

group做的聚合稍微复杂一些。先选定分组所依据的键，而后MongoDB就会将集合依据选定的键值的不同分成若干组。

```
{"day" : "2010/10/03", "time" : "10/3/2010 03:57:01 GMT-400", "price" : 4.23}
{"day" : "2010/10/04", "time" : "10/4/2010 11:28:39 GMT-400", "price" : 4.27}
{"day" : "2010/10/03", "time" : "10/3/2010 05:00:23 GMT-400", "price" : 4.10}
{"day" : "2010/10/06", "time" : "10/6/2010 05:27:58 GMT-400", "price" : 4.30}
{"day" : "2010/10/04", "time" : "10/4/2010 08:34:50 GMT-400", "price" : 4.01}
```
想获得的每天最后的价格列表

```
[
{"time" : "10/3/2010 05:00:23 GMT-400", "price" : 4.10},
{"time" : "10/4/2010 11:28:39 GMT-400", "price" : 4.27},
{"time" : "10/6/2010 05:27:58 GMT-400", "price" : 4.30}
]
```
先把集合按照天分组，然后在每一组里取包含最新时间戳的文档。
```
db.runCommand({"group" : {
"ns" : "stocks",
"key" : "day",
"initial" : {"time" : 0},
"$reduce" : function(doc, prev) {
 if (doc.time > prev.time) {
 prev.price = doc.price;
 prev.time = doc.time;
 }
}}})
```
"ns" : "stocks"
指定要进行分组的集合
"key" : "day"
指定文档分组依据的键。day值相同的文档被划分到一组
"initial" : {"time" : 0}
每一组reduce函数调用的初始时间，会作为初始文档传递给后续过程。每一组的所有成员都会使用这个累加器，所以改变会保留
"$reduce" : function(doc, prev) { ... }
每个文档都对应一次这个调用。有两个参数，当前文档和累加器文档（本组当前的结果）。每一组都有独立的累加器。

```
db.runCommand({"group" : {
"ns" : "stocks",
"key" : "day",
"initial" : {"time" : 0},
"$reduce" : function(doc, prev) {
 if (doc.time > prev.time) {
 prev.price = doc.price;
 prev.time = doc.time;
 }},
"condition" : {"day" : {"$gt" : "2010/09/30"}}
}})
```
添加"condition" 可以获得最近30天的价格。"condition"和"cond"及"q"键完全一样。

最后返回由30个文档返回的数组，每个组一个文档。魅族还有分组依据的键以及这组最终的prev值。如果有的文档没有依据的键，就都会被分到一组，相应的部分就会使用"day:null"。在"condition"中加入`"day":{"$exists":true}`可以去掉。

### 使用完成器

完成器用于精简从数据库传到用户的数据。
```
db.runCommand({"group" : {
"ns" : "posts",
"key" : {"day" : true},
"initial" : {"tags" : {}},
"$reduce" : function(doc, prev) {
 for (i in doc.tags) {
 if (doc.tags[i] in prev.tags) {
 prev.tags[doc.tags[i]]++;
 } else {
 prev.tags[doc.tags[i]] = 1;
 }
 },
"finalize" : function(prev) {
 var mostPopular = 0;
 for (i in prev.tags) {
 if (prev.tags[i] > mostPopular) {
 prev.tag = i;
 mostPopular = prev.tags[i];
 }
 }
 delete prev.tags
}}})
```
finalize附带一个函数，在每组结果传递到客户端之前被调用一次。
如果没有 finalize 键，将会返回每天各个标签的个数。而不是每天最多的标签。

### 将函数作为键使用

如果按类别分组要消除大小写的影响，就要定义一个函数来确定文档所依据的键。
```
db.posts.group({"ns" : "posts",
"$keyf" : function(x) { return x.category.toLowerCase(); },
"initializer" : ... })
```
使用$keyf就能依据各种复杂的条件进行分组了

## MapReduce

MapReduce 是一个可以轻松并行化到多个服务器的聚合方法。它会拆分问题，再将各个部分发送到不同的机器上，让每台机器都完成一部分。当所有机器都完成的时候，再把结果汇集起来形成最终完整的结果。

分为几个步骤。最开始是映射(map)，将操作映射到集合中的每个文档。这个操作要么“无作为”，要么“产生一些键和x个值”。然后就是中间环节，称作洗牌(shuffle)，按照键分组，并将产生的键值组成列表放到对应的键中。化简(reduce)则把列表中的值化简成一个单值。这个值被返回，然后接着进行洗牌，知道每个键的列表只有一个值为止，这个值也就是最后的结果。

### 找出集合中的所有键

map函数使用函数emit返回处理的值。emit会给MapReduce一个键和一个值。这里用emit将文章某个键的计数(count)返回。
这样就有了许许多多{count:1}文档，每个都与集合中的一个键相关。这种由一个或多个{count:1}文档组成的数组，会传递给reduce函数。reduce函数有两个参数，一个是key，也就是emit返回的第一个值，还有另外一个数组，由一个或者多个对应于键{count:1}文档组成
```
map = function() {
for (var key in this) {
emit(key, {count : 1});
}};
reduce = function(key, emits) {
total = 0;
for (var i in emits) {
 total += emits[i].count;
}
return {"count" : total};
}
mr = db.runCommand({"mapreduce" : "foo", "map" : map, "reduce" : reduce})
{
"result" : "tmp.mr.mapreduce_1266787811_1",
"timeMillis" : 12,
"counts" : {
"input" : 6
"emit" : 14
"output" : 5
},
"ok" : true
}
```

- "result" : "tmp.mr.mapreduce_1266787811_1"
    
    存放MapReduce结果的集合名，是个临时集合，MapReduce连接关闭后自动就被删除了。
- "timeMillis" : 12
    
    操作花费时间，单位是毫秒
- "counts" : { ... }
    
    这个内嵌文档包含3个键
- "input" : 6
    
    发送到map函数的文档个数
- "emit" : 14
    
    在map函数中emit被调用的次数
- "output" : 5
    
    结果集合中创建的文档数量

reduce一定要能被反复调用，不论是映射环节还是前一个简化环节。所以reduce返回的文档必须能作为reduce的第二个参数的一个元素。
```
> r1 = reduce("x", [{count : 1, id : 1}, {count : 1, id : 2}])
{count : 2}
> r2 = reduce("x", [{count : 1, id : 3}])
{count : 1}
> reduce("x", [r1, r2])
{count : 3}
```

### 网页分类

MapReduce找出哪个主题最为热门，热门与否由最近的投票决定。
首先，建立一个map函数，发出（emit）标签和一个基于流行度和新近程度的值。然后化简同一个标签的所有值，形成这个标签的分数。
```
map = function() {
for (var i in this.tags) {
var recency = 1/(new Date() - this.date);
var score = recency * this.score;
emit(this.tags[i], {"urls" : [this.url], "score" : score});
}
};
reduce = function(key, emits) {
var total = {urls : [], score : 0}
for (var i in emits) {
emits[i].urls.forEach(function(url) {
total.urls.push(url);
}
total.score += emits[i].score;
}
return total;
};
```

### MongoDB和MapReduce

mapreduce除了map和reduce之外的其它键

- "finalize" : function

    将reduce的结果发送给这个键，这是处理过程的最后一步
- "keeptemp" : boolean

    连接关闭时临时结果集合是否保存
- "out" : string

    结果集合的名字，设定该项则隐藏含着keeptemp:true
- "query" : document
    
    会在发往map函数前，先用指定条件过滤文档
- "sort" : document
    
    在发往map前先给文档排序
- "limit" : integer

    发往map函数的文档数量的上限
- "scope" : document

    javascript代码中要用到的变量
- "verbose" : boolean
    
    是否产生更加详尽的服务器日志


