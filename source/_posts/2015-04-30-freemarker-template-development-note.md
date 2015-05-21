title: FreeMarker-模板开发笔记
date: 2015-04-30 09:19:31
tags: FreeMarker
categories: 
- Java
- FreeMarker
description: FreeMarker;Java模板引擎;模板开发
---
    
## 概览

### if
```
Welcome ${user}<#if user == "Big Joe">, our beloved leader</#if>!
```
### list
```
<#list animals as being>
<tr><td>${being.name}<td>${being.price} Euros
</#list>
```
### include
```
<#include "/copyright_footer.html">
```
<!-- more -->

## 数值和类型

### 支持的类型

* 标量：
  * 字符串
  * 数字
  * 布尔值
  * 日期
* 容器：
  * 哈希表
  * 序列
  * 集
* 子程序：
  * 方法和函数：方法是来自于数据模型（它们反射了 Java 对象的方法），而函数是定义在模板内的（使用了函数指令-这也是高级主题），但二者可以用同一种方式来使用。内置的方法`${avg(6, 10, 20)}`
  * 用户自定义指令：按经验来说，如果能够实现，请先用自定义指令而不要用函数/方法。 `<@box title="Attention!"> hello </@box>`
* 其它/很少使用：
  * 节点

## 模板

模板（ FTL 编程）是由如下部分混合而成的：

* Text 文本：文本会照着原样来输出。
* Interpolation 插值： 这部分的输出会被计算的值来替换。插值由${和}所分隔（或者#{和}，这种风格已经不建议再使用了）。
* FTL tags 标签： FTL 标签和 HTML 标签很相似，但是它们却是给 FreeMarker 的指示， 而且不会打印在输出内容中。
* Comments 注释： FTL 的注释和 HTML 的注释也很相似，但它们是由`<#--`和`-->`来分隔的。注释会被 FreeMarker 所忽略，更不会在输出内容中显示。

FTL 标签不可以在其他 FTL 标签和插值中使用。下面这样写就是错的：
```
<#if <#include 'foo'>='bar'>...</#if>
```
注释可以放在 FTL 标签和插值中间。
插值可以在文本区域和字符串中出现，但是不能在标签中使用
```
<#if ${isBig}></>
```
上面的就是错误的，正确的应该这样写
```
<#if isBig></if>
```

FreeMarker可以忽略标签、插值内的空格，但是`<`、`<\`和指令之间的空格不能忽略

### 快速浏览

* 直接指定值
  * 字符串： "Foo" 或者 'Foo' 或者 "It's \"quoted\"" 或者
r"C:\raw\string"
  * 数字： 123.45
  * 布尔值： true, false
  * 序列： ["foo", "bar", 123.45], 1..100
  * 哈希表： {"name":"green mouse", "price":150}
* 检索变量
  * 顶层变量： user
  * 从哈希表中检索数据： user.name, user[“name”]
  * 从序列中检索： products[5]
  * 特殊变量： .main  。 特殊变量是由 FreeMarker 引擎本身定义的，为了使用它们，可以按照如下语法形式来进行： .variable_name。
* 字符串操作
  * 插值（ 或连接）： "Hello ${user}!"（或"Free" + "Marker"）
  * 获取一个字符： name[0]
* 序列操作
  * 连接： users + ["guest"]
  * 序列切分： products[10..19] 或 products[5..]
* 哈希表操作
  * 连接： passwords + {"joe":"secret42"}
* 算数运算: (x * 1.5 + 10) / 2 - y % 100
* 比较运算 ： `x == y, x != y, x < y, x > y, x >= y, x <= y, x &lt; y,` 等等
* 逻辑操作： !registered && (firstVisit || fromEurope)
* 内建函数： name?upper_case
* 方法调用： repeat("What", 3)
* 处理不存在的值
  * 默认值： name!"unknown" 或者(user.name)!"unknown" 或者
name! 或者 (user.name)!
  * 检测不存在的值： name?? 或者(user.name)??
* 运算符的优先级

最高优先级运算符:  [subvarName][subStringRange].?(methodParams)
一元前缀运算符: +expr -expr !expr
乘除法，求模: * / %
加减法: + -
关系运算符: `< > <= >= (相当于: gt, lt, 等)`
相等，不等: == (也可以是: =) !=
逻辑与: &&
逻辑或: ||
数字范围: ..

### 字符串

可以使用转义字符`\\`、`\"`等。一种特殊的字符串就是原生字符串。在原生字符串中，反斜杠和${没有特殊的含义，它们被视为普通的字符。 为了表明字符串是原生字符串，在开始的引号或单引号之前放置字母 r，例如：
```
${r"${foo}"}
${r"C:\foo\bar"}
```
将会打印：
```
${foo}
C:\foo\bar
```

连接
```
${"Hello ${user}!"}
${"${user}${user}${user}${user}"}
```
和
```
${"Hello " + user + "!"}
${user + user + user + user}
```
效果上是一样的

可以使用${user[0]}获取某个字符，也可以使用${user[2..5]}和${user[2..]}获取子串

### 数字

数值文字 08, +8, 8.00 和 8 是完全相等的，它们都是数字 8。因此${08}, ${+8}, ${8.00}和${8}打印的都是相同的。

### 序列

```
<#list ["winter", "spring", "summer", "autumn"] as x>
${x}
</#list>
```
列表中的项目是表达式，那么也可以这样做： [2 + 2, [1, 2, 3, 4], "whatnot"]，其中第一个子变量是数字 4，第二个子变量是一个序列，第三个子变量是字符串”whatnot”。
也可以用 start..end 定义存储数字范围的序列，这里的 start 和 end 是处理数字值表达式，比如 2..5 和[2, 3, 4, 5]是相同的，但是使用前者会更有效率（ 内存占用少而且速度快）。

序列的连接可以使用+号来进行
```
<#list ["Joe", "Fred"] + ["Julia", "Kate"] as user>
- ${user}
</#list>
```
序列切分
使用 [firstindex..lastindex] 可以获取序列中的一部分，这里的firstindex 和lastindex 表达式的结果是数字。

### 哈希表

在模板中指定一个哈希表，就可以遍历用逗号分隔开的“键/值”对，把列表放到花括号内。键和值成对出现并以冒号分隔。看这个例子：{"name":"green mouse", "price":150}。注意到名字和值都是表达式，但是用来检索的名字就必须是字符串类型的。

两种方式从哈希表中检索数据:
```
book.name
book["name"]
```

哈希表也可以使用+连接，如果有相同键，+后面出现的会覆盖之前的
```
<#assign ages = {"Joe":23, "Fred":25} + {"Joe":30, "Julia":18}>
```

### `+`、`-`、`*`、`/`、`%`

内建函数int可以取出整数部分`${(x/2)?int}`

### 比较

为了避免大于、小于被当做标签处理，可以用圆括号包含表达式`<#if (x>y)></if>`。也可以用lt、
lte、gt、gte来比较

## 内建函数

内建函数以?形式提供变量的不同形式或者其他信息。

* 字符串使用的内建函数：
  * html: 字符串中所有的特殊 HTML 字符都需要用实体引用来代替（比如`<`代替&lt;）。
  * cap_first:字符串的第一个字母变为大写形式
  * lower_case:字符串的小写形式
  * upper_case:字符串的大写形式
  * trim:去掉字符串首尾的空格
* 序列使用的内建函数：
  * size：序列中元素的个数
* 数字使用的内建函数：
  * int:数字的整数部分（比如-1.9?int 就是-1）

## 方法调用

* avg求均值
* repeat重复输出3次What
```
${repeat("What", 3)}
${avg(1,2,3)}
```

## 处理不存在的变量

一个不存在的变量和一个是 null 的变量， 对于 FreeMarker 来说是一样的，所以这里所指的丢失包含这两种情况。
就像下面的例子，当 user 从数据模型中丢失时，模板将会将user 的值表示为字符串”Anonymous”。（若 user 并没有丢失，那么模板就会表现
出”Anonymous”不存在一样）：
```
<h1>Welcome ${user!"Anonymous"}!</h1>
```
当然也可以在变量名后面通过放置??来询问 FreeMarker 一个变量是否存在。 将它和 if 指令合并，那么如果 user 变量不存在的话将会忽略整个问候代码段：
```
<#if user??><h1>Welcome ${user}!</h1></#if>
```
关于多级访问的变量，比 如 animals.python.price，书写代码：animals.python.price!0，仅当 animals.python 存在而仅仅最后一个子变量 price 可能不存在（这种情况下我们假设价格是 0）。 如果 animals 或者 python
不存在，那么模板处理过程将会以“未定义的变量”错误而停止。为了防止这种情况的发生，可以这样来书写代码(animals.python.price)!0。这种情况下当 animals 或
python 不存在时表达式的结果仍然是 0。 对于??也是同样用来的处理这种逻辑的

### 默认值

使用形式概览：unsafe_expr!default_expr 或 unsafe_expr! 或 (unsafe_expr)!default_expr 或(unsafe_expr)!

hits!0 或 colors!["red", "green", "blue"]

由于 FreeMarker 2.3.x 版本的源码中的小失误所以必须这么来做。 !（作为默认值操作）的优先级非常低。 这就意味着${x!1 + y}会被 FreeMarker 误解为${x!(1 + y)}，而真实的意义是${(x!1) + y}。 这个源码的错误在 FreeMarker 2.4 中会得到修正。

## 插值

字符串
```
<#escape x as x?html>
...
<p>Title: ${book.title}</p>
<p>Description:
<#noescape>${book.description}</#noescape></p>
<h2>Comments:</h2>
<#list comments as comment>
<div class="comment">
${comment}
</div>
</#list>
...
</#escape>
```
如果插值在文本区 （也就是说，不再字符串表达式中）， 如果 escapse 指令起作用了，即将被插入的字符串会被自动转义（将&转为&amp;）。如果你要生成 HTML，那么强烈建议你利用它来阻止跨站脚本攻击和非格式良好的 HTML 页面。使用 noescape 可以抵消 escape 的转义。如果你想把所有的输出为大写的话可以x.upper_case

数字

小数的分隔符是根据所在地的标准确定的，如匈牙利的分隔符是`,`。那么`{1.5}`会输出`1,5`

可以通过string内置函数来设置输出的格式。

## 其他
### 自定义指令

自定义指令可以使用 macro 指令来定义，这是模板设计者所关心的内容。 Java 程序员若不想在模板中实现定义指令，而是在 Java 语言中实现指令的定义， 这时可以使用freemarker.template.TemplateDirectiveModel 类来扩展

定义宏
```
<#macro greet>
<font size="+2">Hello Joe!</font>
</#macro>
```
使用自定义指令
```
<@greet></@greet>
```
或
```
<@greet/>
```

#### 参数

```
<#macro greet person>
<font size="+2">Hello ${person}!</font>
</#macro>
```
使用
```
<@greet person="Joe"/>
```
输出
```
<font size="+2">Hello Joe!</font>
```

使用自定义指令提供的参数必须与宏定义的参数对应，如果多于宏定义中的参数则报错；如果少于宏定义中的参数，并且宏中也没有指定有默认值的话，会报错，指定了默认值的话不会报错。


```
<#macro greet person color="red">
<font size="+2" color="${color}">Hello ${person}!</font>
</#macro>
```
使用下面的指令是对的，如果没有color="red"的话则会报错
```
<@greet person="Joe"/>
```
someParam=foo 和 someParam="${foo}"是不同的。第一种情况，是把变量 foo 的值作为参数的值来使 用。第二种情况则是使用插值形式的字符串，那么参数值就是字符串了

#### 嵌套内容

```
<#macro border>
<table border=4 cellspacing=0 cellpadding=4><tr><td>
<#nested>
</td></tr></table>
</#macro>
```
`<#nested>`指令执行位于开始和结束标记指令之间的模板代码段。
```
<@border>The bordered text</@border>
```
输出
```
<table border=4 cellspacing=0 cellpadding=4><tr><td>
The bordered text</td></tr></table>
```

nested可以多次被调用

```
<#macro do_thrice>
<#nested>
<#nested>
<#nested>
</#macro>
<@do_thrice>
Anything.
</@do_thrice>
```
输出
```
Anything.
Anything.
Anything.
```

嵌套的内容可以是任意有效的 FTL，包含其他的用户自定义指令，这样也是对的：
```
<@border>
<ul>
<@do_thrice>
<li><@greet person="Joe"/>
</@do_thrice>
</ul>
</@border>
```

```
<#macro repeat count>
<#local y = "test">
<#list 1..count as x>
${y} ${count}/${x}: <#nested>
</#list>
</#macro>
<@repeat count=3>${y!"?"} ${x!"?"} ${count!"?"}</@repeat>
```
在宏的外部，宏中的局部变量是不可见的

#### 宏和循环变量

自定义指令也可以有循环变量。比如我们来扩展先前例子中的 do_thrice 指令，就可以拿到当前的循环变量的值。

```
<#macro do_thrice>
<#nested 1>
<#nested 2>
<#nested 3>
</#macro>
<@do_thrice ; x> <#-- 用户自定义指令 使用";"代替"as" -->
${x} Anything.
</@do_thrice>
```
输出
```
1 Anything.
2 Anything.
3 Anything.
```

nested 指令（当然参数可以是任意的表达式）的参数。 循环变量的名称是在自定义指令的开始标记（ `<@...>`）的参数后面通过分号确定的。

```
<#macro repeat count>
<#list 1..count as x>
<#nested x, x/2, x==count>
</#list>
</#macro>
<@repeat count=4 ; c, halfc, last>
${c}. ${halfc}<#if last> Last!</#if>
</@repeat>
```
如果在分号后面指定了比 nested 指令还多的变量，那么最后的循环变量将不会被创建（在嵌套内容中不会被定义）。如果分号后的指定了比nested指令少的变量，没有问题。

#### 在模板中可以定义三种类型的变量

* 简单变量： 它能从模板中的任何位置来访问，或者从使用 include 指令引入的
模板访问。可以使用 assign 或 macro 指令来创建或替换这些变量。
* 局部变量： 它们只能被设置在宏定义体内，而且只在宏内可见。一个局部变量的生
存周期只是宏的调用过程。可以使用 local 指令在宏定义体内创建或替换局部变
量。
* 循环变量：循环变量是由指令（如 list）自动创建的，而且它们只在指令的开始
和结束标记内有效。宏的参数是局部变量而不是循环变量。

### 命名空间

当运行 FTL 模板时，就会有使用 assign 和 macro 指令创建的变量的集合（可能是空的），可以从前一章节来看如何使用它们。像这样的变量集合被称为 namespace 命名空间。在简单的情况下可以只使用一个命名空间，称之为 main namespace 主命名空间。

#### 创建一个库

```
<#macro copyright date>
<p>Copyright (C) ${date} Julia Smith. All rights reserved.</p>
</#macro>
<#assign mail = "jsmith@acme.com">
```
把上面的这些定义存储在文件 lib/my_test.ftl 中（目录是你存放模板的位置）。假设想在aWebPage.ftl中使用这个模板。如果在aWebPage.ftl 使用`<#include "/lib/my_test.ftl">`，那么就会在主命名空间中创建两个变量，所以就不得不使用import 指令来代替 include 了。它会为 lib/my_test.ftl 创建一个空的命名空间，然后在那里执行。在 aWebPage.ftl中就可以用下面的代码。如果在主命名空间中有一个变量，名为 mail 或 copyright， 那么就不会引起混乱了

```
<#import "/lib/my_test.ftl" as my>
<#-- 被称为"my"的哈希表就会是那个"大门" -->
<@my.copyright date="1999-2002"/>
${my.mail}
```

#### 命名空间和数据模型

数据模型中的变量在任何位置都是可见的。数据模型user在lib/my_test.ftl和aWebPage.ftl 都能访问。

```
<#macro copyright date>
<p>Copyright (C) ${date} ${user}. All rights reserved.</p>
</#macro>
<#assign mail = "${user}@acme.com">
```

在模板的命名空间（可以使用 assign 或 macro 指令来创建的变量）中的变量有着比数据模型中的变量更高的优先级，可以覆盖数据模型。如果想在模板中创建任何命名空间都能访问的变量，那么可以使用global指令

#### 命名空间的生命周期

命名空间由使用的 import 指令中所写的路径来识别。如果想多次 import 这个路径，那么只会为第一次的 import 引用创建命名空间执行模板。 后面相同路径的 import 只是创建一个哈希表当作访问相同命名空间的“门”。

```
<#import "/lib/my_test.ftl" as my>
<#import "/lib/my_test.ftl" as foo>
<#import "/lib/my_test.ftl" as bar>
${my.mail}, ${foo.mail}, ${bar.mail}
<#assign mail="jsmith@other.com" in my>
${my.mail}, ${foo.mail}, ${bar.mail}
```

还要注意命名空间是不分层次的，它们相互之间是独立存在的。那么，如果在命名空间N1 中 import 命名空间 N2，那 N2 也不在 N1 中， N1 只是可以通过哈希表来访问 N2。 这和在主命名空间中 importN2，然后直接访问命名空间 N2 是一样的过程。

每一次模板执行工作都是一个分离且有序的过程，它们仅仅存在一段很短的时间， 同时页面用以呈现内容，然后就和所有填充过的命名空间一起消失了。

#### 编写类库

命名和Java包命名规范相似，存放路径一般是

/lib/example.sourceforge.net/example.ftl 或
/lib/geocities.com/jsmith/example.ftl

### 空白处理

FreeMarker 提供下面的工具来处理这个问题：

* 忽略某些模板文件的空白的工具（ 解析阶段空白就被移除了）：
    * 剥离空白： 这个特性会自动忽略在 FTL 标签周围多余的空白。这个特性可以通过模板来随时使用和禁用。
    * 微调指令： t， rt 和 lt， 使用这些指令可以明确地告诉 FreeMarker 去忽略某些空白。可以阅读参考手册来获取更多信息。
    * FTL 参数 strip_text：这将从模板中删除所有顶级文本。对模板来说这很有用，它只包含某些定义的宏（还有以他一些没有输出的指令），因为它可以移除宏定义和其他顶级指令中的换行符，这样可以提高模板的可读性。
* 从输出中移除空白的工具（移除临近的空白）：
    * compress 指令

### 替换（方括号）语法

这个特性从 FreeMarker 2.3.4 版本后才可用。
FreeMarker 支持一个替换的语法。就是在 FreeMarker 的指令和注释中用[和]来代替`<`和`>`，例如下面这个例子：
* 调用预定义指令： [#list animals as being]...[/#list]
* 调用自定义指令： [@myMacro /]
* 注释： [#-- the comment --]

为了使用这种语法从而代替默认语法，从模板开始，使用 ftl 指令都要使用这用语法。[#ftl]

2.4 版本中的默认配置将会自动检测，也就是说第一个 FreeMarker 标签决定了语法形式（它可以是任意的，而不仅仅是 ftl）。
