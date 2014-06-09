title: mongodb笔记(七) 进阶指南
date: 2014-06-04 09:43:00
tags:
- mongodb
categories:
- database
- mongodb
description: mongodb advanced topics, mongodb 进阶
---

## 数据库命令

### 命令工作原理

```
db.test.drop()
```
实际运行的是drop命令:
```
db.runCommand({"drop":"test"})
```
<!-- more -->

MongoDB中的命令其实是作为一种特殊类型的查询来实现的。这些查询是针对$cmd集合来执行。runCmmand命令就是接受一个命令文档，来执行等价的查询操作。因此drop调用实际上是这样：
```
db.$cmd.findOne({"drop":"test"})
```
mongodb服务器得到查询$cmd集合的请求时，会启动一套特殊的逻辑来处理，而不是交给普通的查询代码来执行。

访问有些命令需要管理员权限，必须在admin数据库里运行。

### 命令参考

MongoDB支持超过75个命令，我们可以在shell中运行：db.listCommands()，或者从驱动程序中运行等价的命令listCommands。

浏览器管理员接口：`http://localhost:28017/_commands`

- buildInfo

    管理专用命令，返回MongoDB服务器的版本号和主机等
    `{"buildinfo":1}`
 
- collStats

    返回指定集合的统计信息
    `{"collStats":"coll"}`
 
- distinct

    返回指定集合中满足条件的文档的指定键的所有不同值
    `{"distinct":"coll","key":"key","query":"query"}`
 
- drop

    删除集合的所有数据
    `{"drop":"coll"}`
 
- dropDatabase

    删除当前数据库的所有数据
    `{"dropDatabase":1}`
 
- dropIndexes

    删除集合里面名称为name的索引，如果名称为*，则代表删除全部。
    `{"dropIndexes":"coll","index":"name"}`
 
- findAndModify

    用法在第3章有记录
 
- getLastError

    查看对本集合执行的最后一次操作的信息。在w台服务器复制集合的最后操作之前，这个命令会阻塞(超时的毫秒数)
    `{"getLastError":1 [,"w":w[,"wtimeout": timeout]]}`
 
- isMaster

    检查本服务器是主服务器还是从服务器
    `{"isMaster":1}`
 
- ListCommands

    返回所有可以在服务器上运行的命令及相关信息
    `{"ListCommands":1}`
 
- listDatabases

    管理专用命令，列出服务器上所有的数据库
    `{"listDatabases":1}`

- ping

    检查服务器连接是否正常。
    `{"ping":1}`
 
- renameCollection

    将集合a重命名为b，其中a和b都必须是完整的集合命名空间(例如"foo.bar"表示foo数据库中的bar集合)
    `{"renameCollection":a,"to":b}`
 
- repairDatabase

    修复并压缩当前数据库
    `{"repairDatabase":1}`
 
- serverStatus

    返回服务器的管理统计信息
    `{"serverStatus":1}`

## 固定集合

前面提到的所有集合，都是动态创建的。这种集合会随着数据的增多而自动扩容。MongoDB同时还支持另外一种集合--固定集合。这种集合的特征就是，需要提前创建，并且大小固定。对于大小固定，我们可以想象其就像一个环形队列，当集合空间用完后，再插入的元素就会覆盖最初始的头部的元素。

### 属性

插入快速、按照插入顺序查询也快，自动淘汰最早的数据。

### 创建固定集合

```
db.createCollection("my_Coll", {"capped" : true, "size" : 100000, "max" : 100} );
```
上面，我们创建了名称为my_Coll的固定集合，其固定大小为100000字节，最多放置文档数目为100个。当指定了数量上限时，必须同时指定size，淘汰机制只有在size没有达到上限时，以max来控制文档数量，当size达到上限时，以size为准。

可以使用命令convertToCapped，将一个普通集合转化为一个固定集合：
```
db.runCommand({"convertToCapped" : "test", "size" : 10000});
```

### 自然排序

固定集合有种特殊的排序方法，是自然排序。自然排序就是文档在磁盘上的顺序。因为固定集合的文档总是按照插入顺序存储的，自然排序就与此相同。

{"$natural":1}排序表示与默认的排序一样，{"$natural":-1}插入顺序的倒叙，非固定集合用自然排序的意义不大。
```
db.coll.find().sort({"$natural":1})
```

### 尾部游标

尾部游标是一种特殊的持久游标，这类游标会不断的获取最新结果，是受linux中tail -f 命令的启发开发出来的。但是注意mongo shell不支持尾部游标，所以我们看一个php例子：

```php
$cursor = $coll->find()->tailable();
while(true){
    If( !$cursor->hasNext() ){
        If( $cursor->dead() ){
            break;
        }
        sleep(1);
    }else{
        while( $cursor->hasNext() ){
            do_stuff($cursor->getNext());
        }
    }
}
```

## GridFS:存储文件

### 开始使用GridFS:mongofiles

Mongofiles内置在MongoDB发布版中，可以用来在GridFS中上传，下载，列示，查找或删除文件。像执行其他命令行工具一样，执行mongofiles --help可以查看可用选项。

现在我们向GridFS上传文件，列出文件和下载文件。
```
$ echo "hello,word" > foo.txt
$ ./mongofiles put foo.txt #上传文件
$ ./mongofiles list #列出文件
$  rm foo.txt #删除本地文件
$ ./mongofiles get foo.txt #下载文件
$ cat foo.txt
$ ./mongofiles search foo.txt #查询文件
$ ./mongofiles delete foo.txt #删除Grid上的文件
```
 
### 内部原理

GridFS的块有个单独的集合，默认情况下，都会使用fs.chunks集合，结构如下：

- _id #块的唯一键
- n #块编号，也就是这个块在原文件中的编号
- data #包含组成文件块的二进制数据
- files_id #包含这个块原数据的文件文档 "_id"
 
文件的原数据都放在另一个集合中，fs.files里面。结构如下：
- _id #文件的唯一id,对应files_id
- length #文件内容的字节数
- chunkSize #每块的大小，以字节为单位，默认是256K
- updateDate #文件存入GridFS的时间戳
- md5 #文件内容的md5校验和，由服务器端生成
 
我们可以使用distinct命令获取GridFS中不重复的文件名列表。
```
db.fs.files.distinct("filename")
```

## 服务器端脚本

## db.eval

使用db.eval函数可以在服务器端执行javascript脚本。这个函数先将给定的javascript字符串传给MongoDB，然后返回结果。

发送代码有两种选择，或者封装进一个函数，或者不封装。下面两行代码是等价的。

```
db.eval("return 1;")
db.eval("function(){return 1;}")
``` 

只有传递参数时需要封装成一个函数，参数通过db.eval的第二个参数传递，不过要写成一个数组的形式。例如传递给函数username。
```
db.eval("function(u){print('hello'+ u +'!');}",[username])
```
有必要的话，可以传递多个参数，例如要计算3个数之和。
```
db.eval("function(x,y,z){return x+y+z;}",[num1,num2,num3])
```
 
### 存储Javascript

每个MongoDB的数据库中都有个特殊的集合，叫做system.js，用来存放Javascript变量。这些变量可以在任何MongoDB的javascript上下文中调用，包括$where字句，db.eval调用，MapReduce作业。用insert可以将变量加入到system.js之中。
```
db.system.js.insert({"_id":"x","value":1})
```
 
System.js还可以存入Javascript代码。如用javascript写一个日志函数，将其放在system.js中。
```
db.system.js.insert({"_id":"log","value":function(msg,level){
var levels = ['DEBUG','WARNING','ERROR','FATAL'];
level = level ? level : 0 ;
var now = new Date();
print(now + " " + levels[level] + msg );
}})
```
现在我们可以调用这个函数：
```
db.eval("x='hello';log('x is'+x,1);");
```
 
### 安全性

```
func = "function(){print('Hello,"+username+"!');}"
```
上面代码可以实现打印欢迎信息，但如果username是`"');db.dropDatabase();print('"`,上面代码就变成了
```
func = "function(){print('Hello,');db.dropDatabase();print('!');}"
```
数据库被清空了

为了避免这种情况，要限定作用域，PHP中代码如下：
```
$func=new MongoCode("function(){
print('hello,"+username+"!');
}",array("username" => $username))
```

## 数据库引用

MongoDB最鲜为人知的功能就是数据库引用，也叫DBRef。DBRef就像Url，唯一确定一个到文档的引用。它加载的方式如同浏览器加载url一样。

DBRef是个内嵌文档，下面有几个是DBRef的必选键,注意必须建的顺序不能改变。

```
{"$ref":collection,"$id":id_value}
$ref #指定集合
$id #指定文档的 _id
```
 
如果想用另外一个数据的文档，还有个$db键，这个键是可选的
```
{"$ref":collection,"$id":id_value,"$db":database}
```

### 示例模式

users集合：
```
{"_id","mike","display_name":"Mike D"}
{"_id","kristina","display_name":"Kristina C"}
```
notes集合：
```
{"_id":5,"author":"mike","text":"mongodb is fun"}
{"_id":25,"author":"kristina","text":" DBREF ", "references"[{"$ref":"users","$id":"mike"},{"$ref":"notes","$id":5}]}
```
第二个笔记包含一些对其它文档的引用，每一条都作为一个DBRef存储。
```
var note = db.notes.findOne({"_id":20})
note.references.forEach(function(ref){
    printjson(db[ref.$ref].findOne({"_id":ref.$id}))
});
```

### 驱动对DBRef的支持

下面是使用PyMongo中的DBRef类型。
```
note = {"_id":25,"author":"kristina","text":" DBREF ", "references":[DBRef("users","mike"),DBRef("notes",5)]}
```

### 什么时候使用

存储一些对不同集合的文档的引用时，最好使用DBRef，就像前面的例子。或者想使用驱动程序或者工具中DBRef特有的功能，只能使用DBRef了。否则，最好存储"_id"作为引用来使用，因为这样更精简，也更容易操作。

