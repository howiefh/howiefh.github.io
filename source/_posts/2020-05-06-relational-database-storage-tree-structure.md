title: 关系型数据库存储树形结构
date: 2020-05-06 00:02:01
tags: 
- 设计
- SQL
- 树
categories:
- Database
- 设计
description: SQL Anti-patterns, 关系型数据库 树
---

一般比较普遍的就是四种方法：（具体见 SQL Anti-patterns这本书）

- 邻接表（Adjacency List）：每一条记录存parent_id，设计实现简单，但是查询子树复杂。
- 枚举路径（Path Enumerations）：每一条记录存整个tree path经过的node枚举，增删改查都较简单，查需要使用like，不能无限扩展。
- 嵌套表（Nested Sets）：每一条记录存 nleft 和 nright，不直观，设计实现都非常复杂。
- 闭包表（Closure Table）：维护一个表，所有的tree path作为记录进行保存。比较折中的一种设计。

![四种方法比较](https://cdn.jsdelivr.net/gh/howiefh/assets/img/sql-anti-patterns-tree-design-diff-cn.png)

<!-- more -->

## 邻接表

邻接表是最方便的设计，它的结构看起来是这样子的：

comment_id | parent_id 
---        |---        
000        | null
001        | 000
002        | 000
003        | 001

查询一个节点的所有后代时会非常困难，如果你使用的数据库支持WITH或者CONNECT BY PRIOR的递归查询，那能使得邻接表的查询更为高效。

当然也可以把所有数据查出后，应用程序根据 parent_id 构造出整棵树，但是这是非常低效的。

增加叶子节点，和更新移动节点的操作都比较简单，删除节点时比较复杂，你需要先把被删节点的子树查出来删除。

当需求不是很复杂时邻接表是很不错的，比如说只有简单的父子关系。

## 枚举路径

用一个字段来存储整个路径的节点，看起来是下面这个样子

comment_id | path
---        |---        
000        | 000/
001        | 000/001
002        | 000/002
003        | 000/001/003

查询003的祖先：
```
select * from comments where '000/001/003' like path || '%'
```
查询000的后代：
```
select * from comments where path like '000/' || '%'
```

增加叶子结点很简单，修改或者删除节点，需要把子树的所有节点path字段更新，也较简单。

枚举路径能够很直观地展示出祖先到后代之间的路径，但同时由于它不能确保引用完整性，使得这个设计非常地脆弱。枚举路径也使得数据的存储变得比较冗余。并且也需要树的深度是可控的，不能无限扩展，这样path字段长度可以受控。

一般地址信息可以使用这种方式，在实践中，可能会和邻接表相结合，同时增加 parent_id 和 path。

## 嵌套表

嵌套表的方案是存储子孙节点的相关信息，而不是节点的子孙节点，更不是祖先节点。使用两个字段来存储子孙节点相关信息，可以将这两字段称为 nsleft 和 nsright。nsleft 的数值小于该节点所有后代的 ID 值, 同时 nsright 的值大于该节点所有后代的 ID 值，这两值跟节点 ID 并没有任何关联。

这种设计比较复杂，查询子树或者祖先比较简单，但是查询直接父节点或者增加、删除节点都比较复杂。最好在一个查询性能要求很高而对其他需求要求一般的场合来使用它。

[树形结构的数据库表Schema设计](https://blog.csdn.net/monkey_d_meng/article/details/6647488) 详细介绍了这种设计。

网上还有一种类似思路的方式 [基于前序遍历的无递归的树形结构的数据库表设计](https://my.oschina.net/drinkjava2/blog/1818631)，不同的是存储的是深度遍历的顺序和数节点深度。

## 闭包表

闭包表是一种优雅而简单都解决方案，当然为此需要增加一张表用来记录所有节点间的关系。这张表看起来是这样的：

ancestor_id | descendant_id | depth
---         |---            |---
000         | 000           | 0
000         | 001           | 1
001         | 001           | 0
000         | 003           | 2
001         | 003           | 1
003         | 003           | 0
000         | 002           | 1
002         | 002           | 0

查询评论 000 的后代

```
select c.* from comments c join tree_path t on c.comment_id = t.ancestor_id where t.ancestor_id = '000' and t.depth != 0;
```

查询评论 003 的祖先

```
select c.* from comments c join tree_path t on c.comment_id = t.descendant_id where t.descendant_id = '003' and t.depth != 0;
```

插入 001 的一个子节点 004

```
insert into tree_path (ancestor_id, descendant_id, depth)
select t.ancestor_id, '004', t.depth + 1
from tree_path
where t.descendant_id = '001'
union all
select '004', '004', 0
```

删除001子树

```
delete from tree_path
where descendant_id in (
  select descendant_id from tree_path where ancestor_id = '001'
)
```

移动节点，可以先删后插入

闭包表是最通用的设计，并且本章所描述的设计中只有它能允许一个节点属于多棵树。它要求一张额外的表来存储关系，使用空间换时间的方案减少操作过程中由冗余的计算所造成的消耗。
