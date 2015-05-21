title: FreeMarker-XML处理笔记
date: 2015-05-03 09:20:51
tags: FreeMarker
categories: 
- Java
- FreeMarker
description: FreeMarker;Java模板引擎;XML处理
---

## 揭示XML文档

test.xml
```
<book>
    <title>Test Book</title>
    <chapter>
        <title>Ch1</title>
        <para>p1.1</para>
        <para>p1.2</para>
        <para>p1.3</para>
    </chapter>
    <chapter>
        <title>Ch2</title>
        <para>p2.1</para>
        <para>p2.2</para>
    </chapter>
</book>
```

* 根节点是“文档”而不是book
* 如果 B 是 A 的直接后继，我们说 B 节点是 A 节点的 child 子节点，A节点是B节点的parent父节点。
* 元素，文本，注释，处理指令都是DOM树的节点

<!-- more -->

### 将XML放到数据模型中

```
Map root = new HashMap();
root.put("doc", freemarker.ext.dom.NodeModel.parse(new File("test.xml")));
```

* parse 方法默认移除注释和处理指令节点。参见 API 文档获取详细信息。
* NodeModel 也允许你直接包装 org.w3c.dom.Node。首先你也许想用静态的实用方法清空 DOM 树，比如 NodeModel.simplify 或你自定义的清空规则。

## 必要的XML处理

### 通过例子来学习

```
<h1>${doc.book.title}</h1>
```
尝试访问有子元素的元素将导致错误
```
<h1>${doc.book}</h1>
```
doc.book.chapter是存储两个元素节点的序列
```
<h2>${doc.book.chapter[0].title}</h2>
<h2>${doc.book.chapter[1].title}</h2>

<#list doc.book.chapter as ch>
    <h2>${ch.title}</h2>
</#list>
```
就算只有一个元素节点，也可以当做一个序列
```
<h1>${doc.book[0].title[0]}</h1>
```

如果 book 没有 chapter，那么book.chapter 就是一个空序列，所以 doc.book.chapter 就不会是 false，它就一直是 true！类似地，`<#if doc.book.somethingTotallyNonsense??></#if>`也不会是false。来检查是否有子节点，可以使用doc.book.chapter[0]??（或doc.book.chapter?size == 0）。当然你可以使用类似所有的控制处理操作符（比如 doc.book.author[0]!"Anonymous"），只是不要忘了那个[0]。

一个完整示例
```
<#assign book = doc.book>
<h1>${book.title}</h1>
<#list book.chapter as ch>
    <h2>${ch.title}</h2>
    <#list ch.para as p>
        <p>${p}
    </#list>
</#list>
```

得到所有的para
```
<#list doc.book.chapter.para as p>
<p>${p}
</#list>
```

### 访问属性

如果test.xml中title是属性而不是元素，只需在其前加@即可。
```
<#assign book = doc.book>
<h1>${book.@title}</h1>
<#list book.chapter as ch>
    <h2>${ch.@title}</h2>
    <#list ch.para as p>
        <p>${p}
    </#list>
</#list>
```
如果你很好奇是否 foo 含有属性 bar，那么你不得不写 foo.@bar[0]??来验证。（ foo.@bar??是不对的，因为它总是返回 true）。类似地，如果你想要一个bar属性的默认值，那么你就不得不写 foo.@bar[0]!"theDefaultValue"。

### 探索DOM

枚举所有book的子元素
```
<#list doc.book?children as c>
- ${c?node_type} <#if c?node_type = 'element'>${c?node_name}</#if>
</#list>
```
children：子元素序列
node_type：节点类型，"element"， "text"， "comment"， "pi"
node_name：节点名称

```
<book foo="Foo" bar="Bar" baaz="Baaz">
```
可以通过元素的自变量@@获取元素的属性序列

```
<#list doc.book.@@ as attr>
- ${attr?node_name} = ${attr}
</#list>
```

返回元素的子节点序列可以用*

```
<#list doc.book.* as c>
- ${c?node_name}
</#list>
```
可以使用内建函数 parent 来获得元素的父节点。你可以使用内建函数 root 来快速返回到文档节点
```
<#assign e = doc.book.chapter[0].para[0]>
${e?node_name}
${e?parent?node_name}
${e?parent?parent?node_name}
${e?parent?parent?parent?node_name}
${e?root?node_name}
```


### 使用XPath表达式

XPath 表达式仅在 Jaxen（推荐使用，但是使用至少 Jaxen 1.1-beta-8 版本，不能再老了） 或 Apache Xalan 库可用时有效。

```
<#list doc["book/chapter[title='Ch1']/para"] as p>
<p>${p}
</#list>
${doc["book/chapter[title='Ch1']/para[1]"][0]}
${doc.book["chapter[title='Ch1']/para[1]"]}
```
注意 XPath 序列的项索引从 1 开始，而 FTL 的序列项索引是用 0 开始的。

如果使用 Jaxen 而不是 Xalan，那么 FreeMarker 的变量在使用 XPath 变量引用时是可见的
```
<#assign currentTitle = "Ch1">
<#list doc["book/chapter[title=$currentTitle]/para"] as p>
```
注意$currentTitle 不是 FreeMarker 的插值，因为那里没有{和}。那是 XPath 表达式。

一些 XPath 表达式的结果不是节点集，而是字符串，数字或者布尔值。获取para元素的总数
```
${x["count(//para)"]}
```

### XML命名空间

如果元素book是命名空间 http://example.com/ebook，那么你不得不关联一个前缀，要在模板的顶部使用 ftl 指令的 the ns_prefixes 参数：

```
<#ftl ns_prefixes={
"e":"http://example.com/ebook",
"f":"http://example.com/form",
"vg":"http://example.com/vectorGraphics"}
>
```
现在你可以编写如 doc["e:book"]的表达式。使用保留前缀D可以设置默认命名空间。XPath不支持默认命名空间

```
<#ftl ns_prefixes={"D":"http://example.com/ebook"}>
```
注意当你使用默认命名空间时，那么你可以使用保留前缀 N 来选择不属于任意节点空间的元素。比如 doc.book["N:foo"]。这对 XPath 表达式不起作用

### 转义

```
<#escape x as x?html>
<#assign book = doc.book>
<h1>${book.title}</h1>
<#list book.chapter as ch>
<h2>${ch.title}</h2>
<#list ch.para as p>
<p>${p}
</#list>
</#list>
</#escape>
```

## 声明的XML处理

最经常使用来处理声明方式的指令就是 recurse 指令，这个指令获取节点变量，并把它作为是参数，从第一个子元素开始，一个接一个地“访问”所有它的子元素。“访问”一个节点意味着它调用了用户自定义的指令（比如宏），它的名字和子节点（ ?node_name）的名字相同。我们这么说，用户自定义指令操作节点。使用用户自定义指令处理的节点作为特殊变量.node 是可用的。

```
<#recurse doc>
<#macro book>
    Book element with title ${.node.title}
    <#recurse>
    End book
</#macro>
<#macro title>
    Title element
</#macro>
<#macro chapter>
    Chapter element with title: ${.node.title}
</#macro>
```

如果你调用 recurse 而不用参数，那么它使用.node，也就是说，它访问现在处理这个节点的所有子节点。

所有文本节点的节点名字都是@text。转义HTML
```
<#macro @text>${.node?html}</#macro>
```

### 默认处理器

* 文本节点： 打印其中的文本。要注意，在很多应用程序中，这对你来说并不好，因为你应该在你发送它们到输出（使用?html 或?xml 或?rtf 等，这基于输出的格式）前转义这些文本。
* 处理指令节点： 如果你定义了自定义指令，可以通过调用处理器调用@pi，否则将什么都不做（忽略这些节点）。
* 注释节点，文档类型节点：什么都不做（忽略这些节点）。
* 文档节点：调用 recurse，也就是说，访问文档节点的所有子节点。

元素节点的情形，这意味着如果你定义了一个称为@element 的宏（或其他种类的用户自定义指令），没有其他特定的处理器时，那么它会捕捉所有元素节点。如果你没有@element 处理器，那么你必须为所有可能的元素定义处理器。

属性节点在 recurse 指令中不可见，所以不需要为它们编写处理器。

### 访问单独节点

使用visit指令你可以访问单独的节点

### XML 命名空间

```
<book xmlns="http://example.com/ebook">
```

考虑命名空间

```
<#ftl ns_prefixes={"e":"http://example.com/ebook"}>
<#recurse doc>
<#macro "e:book">
<html>
<head>
<title><#recurse .node["e:title"]></title>
</head>
<body>
<h1><#recurse .node["e:title"]></h1>
<#recurse>
</body>
</html>
</#macro>
<#macro "e:chapter">
<h2><#recurse .node["e:title"]></h2>
<#recurse>
</#macro>
<#macro "e:para">
<p><#recurse>
</#macro>
<#macro "e:title">
<#--
We have handled this element imperatively,
so we do nothing here.
-->
</#macro>
<#macro @text>${.node?html}</#macro>
```
设置为默认命名空间

```
<#ftl ns_prefixes={"D":"http://example.com/ebook"}>
<#recurse doc>
<#macro book>
...
```
