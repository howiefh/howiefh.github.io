title: 逻辑删除
date: 2015-07-25 12:08:47
tags: Database
categories: Database
description: 逻辑删除; 软删除; logical delete; soft delete; tombstone;
---

* 物理删除，又称硬删除、真删除，即删除操作是将数据记录直接从数据库删除。
* 逻辑删除，又称软删除、假删除，通过添加删除标记或者将要删除的数据记录移动到另一张表的方式实现。好处就是对于误操作，数据被删除了，可以很方便地将数据恢复。

<!-- more -->

流水记录可以考虑物理删除，关键业务数据逻辑删除。如果根本不考虑将来需要恢复的问题，直接删就好了。

逻辑删除大致又有两种可行方案：做标记；转移数据。

对于添加标记字段，通过更新语句直接更新一个字段就可以了。但是如果表中有unique字段，就无法再添加相同内容了，解决方案是将删除标记也列入唯一索引中，如`<删除标记,唯一字段>`。如果数据量大的话，删除操作又比较频繁，这种方法在查询时都要再加一个标记判断，相对效率会比较低。使用视图可以解决每个查询语句添加额外判断的问题，通过创建设定过滤条件索引对查询效率低的问题可能会有所帮助（不是所有数据库都支持过滤索引，而且使用过滤索引也会带来更新索引的代价）。

对于将要删除的数据移动到另一张表，可以通过`CREATE TABLE table_name_archive SELECT * FROM table_name WHERE 1 = 2;ALTER TABLE table_name_archive ADD PRIMARY KEY (id);ALTER TABLE table_name_archive ADD delete_date datetime NOT NULL COMMENT '删除时间';`创建一张表结构相同的表，然后通过触发器实现数据的转移，相对来说可能这种做法效率会略差，一次删除实际上执行了两次操作，同时使用触发器可能也会加重数据库的负担。

```
DELIMITER $$

DROP TRIGGER IF EXISTS table_name_trigger $$

CREATE TRIGGER table_name_trigger
AFTER DELETE ON table_name
FOR EACH ROW
BEGIN
    INSERT INTO table_name_archive
    SELECT *, now()
    FROM OLD;
END;
$$
```

参考：

http://weblogs.asp.net/fbouma/soft-deletes-are-bad-m-kay
