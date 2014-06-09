title: mongodb笔记(四) 查询
date: 2014-05-08 21:48:34
tags:
- mongodb
categories:
- database
- mongodb
description: mongodb querying, mongodb 查询
---
## find 

### 指定返回的键

可以在find中通过多个键值对进行查询会被解释成and，多个键值对之间是且的关系

通过find的第二个参数可以指定返回的键
```
db.users.find({},{"username":1,"email":1})
db.users.find({},{"username":1,"email":1,"_id":0})
```
第一条语句将返回_id,username,email,_id总是被返回。如果不想返回_id指定为0

<!-- more -->

### 限制

查询文档的值必须是常量。也就是说不能引用文档其它键的值。
```
db.stock.find({"in_stock":this.num_sold}) // 这是不可行的
```

## 查询条件

### 查询条件

"$ne","$lt","$lte","$gt"和"$gte"分别对应"!=","<","<=",">"和">="。

```
db.users.find({"age":{"$gte":18,"$lte":30}})
```

### OR查询

有两种OR查询，"$in"可以用来查询一个键的多个值。"$or"用来完成多个键值的任意给定值。

"$in"可以指定不同的类型的条件和值。和"$in"相对的就是"$nin"
```
db.raffle.find({"ticket_no":{"$in":[725,542,390]}})
db.users.find({"user_id":{"$in":[12345,"joe"]}})
```

如果数组中仅含有一个值，那么就相当于是"="

```
db.users.find({"user_id":{"$in":[12345]}})
```

"$or" 接受一个包含所有可能条件的数组作为参数。也可以包含其它条件句。

```
db.raffle.find({"$or":[{"ticket_no":{"$in":[725,542,390]}]},{"winner":true})
```

### $not

"$mod"会将查询的值除以第一个给定的值，若玉树等于第二个给定的值则返回该结果。
```
db.users.find({"id_num":{"$mod":[5,1]}})
db.users.find({"id_num":{"$not":{"$mod":[5,1]}}})
```
第一个将返回"id_num"值为1,6,11,16等的用户，第二个将会返回"id_num"值为2,3,4,5,7,8,9,10,12等的用户。

### 条件句的规则

查询条件句"$lt"等是在内层文档，而修改器是在外层文档。
```
db.users.find({"age":{"$lt":30,"$gt":20}})
db.users.update({"name" : "joe"}, {"$unset" : {"favorite book" : 1}})
```
同一个键不能对应多个更新修改器，但是查询条件句没有这个限制。
```
{"$inc":{"age":1},"$set":{age:40}}  //这是不可行的
```

## 特定于类型的查询

### null

如果查询键值为null的，它不仅仅可以匹配到自身，而且匹配不存在的。
```
db.c.find({"z":null})
```
则"z"键为null或者"z"键不存在的都会被返回。
如果仅仅想匹配键值为null的文档，可以配合"$exists"来查询。
```
db.c.find({"z":{"$in":[null],"$exists":true}})
```

### 正则表达式

mongodb使用perl兼容的正则表达式(PCRE)来匹配正则表达式。

- mongodb 可以为前缀型正则表达式(如/^joey/)查询创建索引，所以这种类型的查询会非常高效。
- 正则表达式也可以匹配自身。
```
db.foo.insert({"bar":/baz/})
db.foo.find({"bar":/baz/})
```

### 查询数组
数组大多数情况下可以这样理解，每个元素都是整个键的值。
```
db.food.insert({"fruit":["apple","banana","peach"]})
db.food.find({"fruit":"banana"})
```
第二条语句能够成功匹配插入的文档。

- $all

    通过多个元素匹配数组，就需要`$all`。
```
db.food.insert({"fruit":["apple","banana","peach"]})
db.food.insert({"fruit":["apple","kumquat","orange"]})
db.food.insert({"fruit":["cherry","banana","apple"]})
```
    要查找既有"apple"又有"banana"的文档，就用"$all" 来查询。
```
db.food.find({fruit:{$all:["apple","banana"]}})
```
    这种方式并不关心顺序，所以apple在banana前或者后都可以匹配到。

    可以使用下面语句精确匹配文档。将返回第一条文档。
```
db.food.find({"fruit":["apple","banana","peach"]})
```
    但是下面两条语句不会返回任何文档。
```
db.food.find({"fruit" : ["banana", "apple"]})
db.food.find({"fruit" : ["banana", "apple", "peach"]})
```
    如果想查找数组指定位置的元素，则需使用key.index语法指定下标。
```
db.food.find({"fruit.2":"peach"}) //下标从0开始
```

- $size

    查询指定长度的数组。
```
db.food.find({"fruit":{"$size":3}})
```
    "$size"不能与其他查询子句组合(如"$gt")。可以通过在文档中添加"size"键来实现。这样在添加新元素的时候需要同时增加"size"的值。
```
db.food.update(criteria,{"$push":{"fruit":"strawberry"}}) //这种更新就需要变成下面这样。
db.food.update(criteria,{"$push":{"fruit":"strawberry"},"$inc":{"size":1}})
```
```
db.food.find({"size":{"$gt":3}})
```
    但是这种技巧不能和"$addToSet"操作符一起使用。

- $slice

    返回数组的一个子集合
```
// 返回前十个评论
db.blog.posts.findOne(criteria, {"comments" : {"$slice" : 10}})
// 返回后十个评论
db.blog.posts.findOne(criteria, {"comments" : {"$slice" : -10}})
// 跳过前面23个评论，返回第24个到第33个评论
db.blog.posts.findOne(criteria, {"comments" : {"$slice" : [23, 10]}})
```
    别的键的说明符都是默认不返回未提及的键，"$slice"返回文档中的所有键。

### 范围查询

假设有下面的文档。要查找x大于10小于20的文档。

```
{"x" : 5}
{"x" : 15}
{"x" : 25}
{"x" : [5, 25]}
```
```
db.test.find({"x" : {"$gt" : 10, "$lt" : 20}})
```
这样将会返回`{"x" : 15} {"x" : [5, 25]}` 因为5满足小于20，25满足大于10。

如果使用`$elemMatch`则只会匹配数组。非数组元素不会匹配。
```
db.test.find({"x" : {"$elemMatch" : {"$gt" : 10, "$lt" : 20}})
```
使用下面的查询，则会返回{"x":15}
```
db.test.find({"x" : {"$gt" : 10, "$lt" : 20}).min({"x" : 10}).max({"x" : 20})
```

## 查询内嵌文档

假设有文档如下
```
{
"name" : {
"first" : "Joe",
"last" : "Schmoe"
},
"age" : 45
}
```
```
db.people.find({"name" : {"first" : "Joe", "last" : "Schmoe"}})
db.people.find({"name" : {"last" : "Schmoe", "first" : "Joe"}})
db.people.find({"name.first" : "Joe", "name.last" : "Schmoe"})
```
上面的几条语句，第一条会成功返回这个文档，第二条则什么也不会返回，这是因为这种查询是与顺序相关的(数组，内嵌文档都与顺序有关)。第三条查询相对是比较好的，这样即使Joe又增加了其它键，依然可以匹配到。

现在有下面的文档，我们要查找joe评分大于等于5的文档。
```
{
"content" : "...",
"comments" : [
{
"author" : "joe",
"score" : 3,
"comment" : "nice post"
},
{
"author" : "mary",
"score" : 6,
"comment" : "terrible post"
}
]
}
```
不能使用下面的语句查询，内嵌文档要求匹配整个文档，这里没有`comment`键。
```
db.blog.find({"comments.author" : "joe", "comments.score" : {"$gte" : 5}})
```
下面语句会返回之前的文档，第一条评论满足author为joe，第二条评论满足score大于等于5。
```
db.blog.find({"comments.author" : "joe", "comments.score" : {"$gte" : 5}})
```
下面的语句能够正确返回查询结果，要指定一组查询条件，而又不指定每个键，需要使用`$elemMatch`
```
db.blog.find({"comments" : {"$elemMatch" : {"author" : "joe", "score" : {"$gte" : 5}}}})
```

## $where查询

```
db.foo.insert({"apple" : 1, "banana" : 6, "peach" : 3})
db.foo.insert({"apple" : 8, "spinach" : 4, "watermelon" : 4})
```
通过$where语句可以查询两种水果数量相同的文档。
```
db.foo.find({"$where" : function () {
for (var current in this) {
 for (var other in this) {
 if (current != other && this[current] == this[other]) {
 return true;
 }
 }
}
return false;
}});
```
无非必要，不要使用$where，因为它会把文档从BSON转换成javascript对象。然后通过$where表达式运行。所以速度会比较慢。可以使用常规的查询先过滤一部分结果，再由$where处理。

## 游标

```
for(i=0; i<100; i++) {
 db.collection.insert({x : i});
}
var cursor = db.collection.find();
```
当调用find的时候，shell并不立即查询数据库，而是等待真正开始要求获得结果的时候才发送查询，这样在执行之前可以给查询附加额外选项。几乎所有游标对象的方法都返回游标本身，这样可以按任意顺序组成方法链。
```
var cursor = db.collection.find();
```
这时，查询并没有执行，当执行`cursor.hasNext()`的时候，查询被发送到服务器，shell立即获取前100个结果或者4mb数据(取最小)

### limit,skip和sort

```
db.c.find().limit(3)
```
截取查询结果的前三个
```
db.c.find().skip(3)
```
略过查询结果的前三个
```
db.c.find().sort({username:1,age:-1})
```
排序方向1是升序，-1是降序
```
db.stock.find({"desc" : "mp3"}).limit(50).sort({"price" : -1})
db.stock.find({"desc" : "mp3"}).limit(50).skip(50).sort({"price" : -1})
```
上面两句可以实现下一页功能。略过太多项的话会带来性能问题。
一个键的值可能是不同的类型。不同类型数据比较顺序:
1. 最小值
2. null
3. 数字
4. 字符串
5. 对象/文档
6. 数组
7. 二进制数据
8. 对象ID
9. 布尔型
10. 日期型
11. 时间戳
12. 正则表达式
13. 最大值

### 避免使用skip略过大量结果

- 不用skip对结果分页

   要尽量避免使用skip对结果分页。 
```
var page1 = db.foo.find().sort({"date" : -1}).limit(100)
var latest = null;
// display first page
while (page1.hasNext()) {
latest = page1.next();
display(latest);
}
// get next page
var page2 = db.foo.find({"date" : {"$gt" : latest.date}});
page2.sort({"date" : -1}).limit(100);
```
    像上面这种查询中就没有skip了。

- 随机选取文档
    
    如果先计算文档总数，然后从0到文档总数之间取一个随机数，再略过这个随机数那么多文档，这种方式效率是很低的。

    可以在文档中多加一个随机数的键。
```
db.people.insert({"name" : "joe", "random" : Math.random()})
db.people.insert({"name" : "john", "random" : Math.random()})
db.people.insert({"name" : "jim", "random" : Math.random()})
```
    取随机文档只需要再生成一个随机数，然后匹配就好了。
```
var random = Math.random()
result = db.foo.findOne({"random" : {"$gt" : random}})
```

### 高级查询选项

查询分为普通的和包装的
```
var cursor = db.foo.find({"foo" : "bar"})
sort:
var cursor = db.foo.find({"foo" : "bar"}).sort({"x" : 1})
```
第一条就是普通的，第二条是包装的。实际shell会将其转换为
```
{"$query" : {"foo" : "bar"}, "$orderby" : {"x" : 1}}.
```
可以向查询添加选项

- $maxscan : integer

    指定查询最多扫描的文档数量
```
db.foo.find(criteria)._addSpecial("$maxscan", 20)
```
- $min : document

    查询的开始条件
- $max : document
    
    查询的结束条件
- $showDiskLoc : true
    
    显示查询结果在磁盘中的位置
```
> db.foo.find()._addSpecial('$showDiskLoc',true)
{ "_id" : 0, "$diskLoc" : { "file" : 2, "offset" : 154812592 } }
{ "_id" : 1, "$diskLoc" : { "file" : 2, "offset" : 154812628 } }
```
    第一项是结果所在文件，建设数据是test，那么查询结果在test.2中，第二项是结果在文件中的偏移量。

- $hint : document
    
    指定服务器使用哪个索引来进行查询

- $explain : boolean
    
    获取查询执行的细节(用到的索引、结果数量、耗时等)，并非真正执行查询

- $snapshot : boolean
    
    确保查询的结果是在查询执行的那一刻的一致快照

### 获取一致结果

```
db.foo.find().snapshot()
```
    使用快照可以获取一致结果

## 数据库命令

```
> db.runCommand({"drop" : "test"});
> use temp
switched to db temp
> db.runCommand({shutdown:1})
{ "errmsg" : "access denied; use admin db", "ok" : 0 }
> db.adminCommand({"shutdown" : 1})
```
