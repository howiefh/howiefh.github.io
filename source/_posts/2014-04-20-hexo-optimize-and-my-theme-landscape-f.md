layout: post
title: hexo优化及主题Landscape-F
date: 2014-04-20 21:45:47
tags: Hexo
categories: Hexo
description: hexo Landscape-F, hexo 优化，hexo 博客，hexo 主题，hexo 七牛，hexo 多说，hexo theme，hexo github，hexo 图片，hexo 返回顶部, hexo 日历, hexo 友情链接, hexo about me, hexo 分享，hexo 彩色标签云, hexo 文章目录, hexo 最近更新, hexo 评论, hexo 技巧，hexo 教程
---
自从去年装好[Hexo]后就没有更新过，直到最近才把[Hexo]从1.1.3更新到了2.5.2。发现有了不少的变化，插件比过去多了，还有了新的默认主题，[文档]也比过去更详细了。但是默认主题有一些我需要的东西还没有，比如文章目录、返回顶部按钮、多说评论，百度分享等等。在网上找了不少[Hexo主题]，最后还是觉得默认主题比较不错，还有一个[Pacman]感觉也挺好的。于是就在[Landscape]基础上主要参考[Pacman]对默认主题进行了一些优化，这样我的主题[Landscape-F]就诞生了。

<!-- more -->
## 安装指南
### 安装

```bash
$ git clone https://github.com/howiefh/hexo-theme-landscape-f.git themes/landscape-f
```
[Landscape-F]需要安装Hexo 2.4 或以上版本

### 启用

修改你的博客根目录下的`_config.yml`配置文件中的`theme`属性，将其设置为`landscape-f`。

### 更新

升级前最好先备份原来的`_config.yml` 文件

```bash
cd themes/landscape-f
git pull
```

## 配置指南

下面是本主题的配置文件内容，你也可以更改`source/css/_variables.styl`中的一些配色或图片，对主题进行微调。

``` yml
# Header
menu:
  Home: /
  Archives: /archives
rss: /atom.xml
github: https://github.com/howiefh

# Content
excerpt_link: Read More
fancybox: true

# Sidebar
sidebar: right
widgets:
- about_me
- category
- tag
- tagcloud
- archive
- calendar
- recent_posts
- duoshuo_recent_comments
- links

# display widgets at the bottom of index pages (pagination == 2)
index_widgets:
# - category
# - tagcloud
# - archive

# widget behavior
archive_type: 'monthly'
show_count: true

# Miscellaneous
google_analytics:
baidu_tongji:
favicon: /favicon.ico

twitter:
google_plus:
fb_admins:
fb_app_id:

# Toc
toc:
  article: true   ## show contents in article.
  aside: true     ## show contents in aside.
# Scroll to top
go_top: true

# duoshuo
duoshuo_shortname:

# baidu share
baidushare: true

# blogroll
links:
- name: 404 page
  link: http://yibo.iyiyun.com/js/yibo404/key/1

# about me
about_me:
  title: ABOUT ME
  gravatar: a@abc.com
  avatar: /images/github.jpg
  texts:
  - Hi,I'm howiefh.

# display updated
display_updated: true

# 不蒜子
busuanzi: true
```

- **menu** - 导航菜单
- **rss** - rss 链接
- **github** - github 链接
- **excerpt_link** - "Read More" 链接. 设置为`false`可以隐藏
- **fancybox** - 启用 [Fancybox]
- **sidebar** - 侧边栏样式. 可以选择 `left`, `right`, `bottom` or `false` 进行设置.
- **widgets** - 侧边栏显示的小工具
- **google_analytics** - Google Analytics ID
- **baidu_tongji** - 百度统计ID
- **favicon** - Favicon 路径
- **twitter** - Twiiter ID
- **google_plus** - Google+ ID
- **toc** - 在文章和侧边栏显示文章目录（侧边栏的文章目录默认隐藏，按返回顶部下面的按钮可以显示）
- **go_top** - 返回顶部
- **duoshuo_shortname** - 多说short name
- **baidushare** - 在文章中激活百度分享，如果设置为`false`将在文章中显示默认分享工具,首页仍旧使用默认分享工具。
- **links** - 在侧边栏显示友情链接，name链接名称，link链接地址
- **about_me** - 在侧边栏显示关于我。优先使用gravatar，如果没有填写gravatar，将使用设置的avatar图片。texts 可以是一些介绍的文字。
- **display_updated** - 在文章底部显示文章更新时间
- **busuanzi** - 是否启用不蒜子统计访问量

### 侧边栏

[Landscape-F]提供了9种小工具。

- category
- tag
- tagcloud
- archive
- recent_posts
- about_me
- calendar
- duoshuo_recent_comments
- links

相比默认主题增加了About Me、日历、多说最近评论、友情链接，并且对tags、tagcloud、categories、archive 的样式做了调整，比如数字的显示。

## 优化总结
### 返回顶部按钮

在文章的页面右下方会显示返回顶部的按钮。

### 在侧边栏和文章中显示文章目录

默认会在侧边栏和文章中显示文章目录，侧边栏文章目录默认隐藏，可以通过文章目录按钮来进行开关侧边栏的文章目录。

### 多说评论

使用了多说评论系统，在侧边栏会显示最近的评论，在主页面文章的右下方显示评论数。

### 百度分享

使用了百度分享，默认启用，如果禁用，文章中使用默认的分享工具。

### 友情链接

侧边栏添加友情链接

### 日历

侧边栏添加日历，如果当月某天发布过博客，对应日期将会显示为链接，仅限当月。需要使用[hexo-calendar]

### 顶部添加github链接

顶部github 链接可以在`_config`中设置

### 默认分享工具添加微博和人人

### 改变侧栏样式

### 调整头部高度和判断banner-url是否为空

可以在`source/css/_variables`设置banner和背景图片。

### 调整侧边栏样式

在archive页面仅显示archive小工具

### 修改article title样式

### 文章底部添加更新时间

### 添加语言文件

### 修改滚动条样式

### 添加不蒜子统计访问量

## 其它

### 图床

如果图片很多的话，把图片都放在github感觉不大明智，使用图床就很有必要了，推荐使用[七牛]做图床，访问速度极快，支持日志、防盗链和水印。不光是图片，你甚至可以将生成的静态文件放在[七牛]上。
标准用户有每月10GB流量+总空间10GB+PUT/DELETE 10万次请求+GET 100万次请求，应该足够了。

### 404页面

我使用的是益云404公益页面<http://yibo.iyiyun.com/Index/web404>。把404.html放在`landscape-f/source`下就可以了。

### hexo文档

在stylus文件中可以使用 hexo-config('title') 获得配置文件的配置
[tag plugins](http://hexo.io/docs/tag-plugins.html)
[variables](http://hexo.io/docs/variables.html)
[Model](http://hexo.io/api/warehouse/classes/Model.html)
常用方法
```
site.posts.each()
site.posts.sort()
site.posts.toArray()
```
可以在`layout/_widget/tagcloud.ejs`中使用`<%- tagcloud({start_color: '#7dc3de', end_color: '#800080',color: true}) %>`替换原有对应内容,实现彩色的标签云。

## 修改记录

- 返回顶部按钮

```
modified:   layout/_partial/after-footer.ejs
modified:   source/css/_variables.styl
modified:   source/css/style.styl
add layout/_partial/bottomBtn.ejs
add source/css/_partial/bottombtn.styl
add source/js/gotop.js
```

- 文章目录

```
modified:   layout/_partial/after-footer.ejs
modified:   layout/_partial/sidebar.ejs
modified:   layout/_partial/article.ejs
modified:   source/css/_variables.styl
modified:   source/css/style.styl
add layout/_partial/bottom-btn.ejs
add source/css/_partial/bottom-btn.styl
add	source/css/_partial/toc.styl
add	source/js/toc_aside_toggle.js
```

- 多说

```
modified:   layout/_partial/after-footer.ejs
modified:   layout/_partial/article.ejs
layout/_partial/article.ejs中的div 一定要有class="ds-thread" 注意中间的不是下划线,直接在disqus上改的,改完不显示评论纠结半天
多加了显示评论数的代码<a href="<%- post.permalink %>#ds_thread" class="ds-thread-count article-comment-link" data-thread-key="<%- config.root %><%- post.path%>">暂无评论</a>
```

- 百度分享

```
modified:   layout/_partial/article.ejs
modified:   layout/_partial/after-footer.ejs
```

- 最近评论

```
add layout/_widget/duoshuo_recent_comments.ejs
```

- 友情链接

```
add layout/_widget/links.ejs
```

- about me

```
add layout/_widget/about_me.ejs
add source/css/_partial/about-me.styl
```

- 日历

参考<http://www.cnblogs.com/focuslgy/p/3260975.html>

```
add layout/_widget/calendar.ejs
add source/css/_partial/calendar.styl
add helper plugin hexo-calendar
```

- github 链接

```
modified:layout/_partial/header.ejs
modified:source/css/_partial/header.styl
```

- 默认分享添加 微博和人人

```
modified:layout/_partial/article.ejs
modified:source/css/_partial/article.styl
modified:source/css/_variables.styl
modified:source/js/script.js
```

- 改变侧栏样式

```
modified:source/css/_partial/sidebar.styl
modified: helper plugin list.js
```

- 调整头部高度和判断banner-url是否为空

```
modified:source/css/_partial/header.styl
modified:source/css/_variables.styl
```

- 修改sidebar

当页面是archives时只显示sidebar只显示archives

```
modified:layout/_partial/sidebar.ejs
```

- 修改article title 样式,显示左侧边框

```
modified:layout/_partial/article.ejs
```

- 修改滚动条样式

```
added:source/css/_partial/scrollbar.styl
```

- 文章底部添加更新时间

```
modified:layout/_partial/article.ejs
modified:layout/_partial/post/date.ejs
modified:source/css/_partial/article.styl
```

- 语言文件

```
add languages/
```

[Hexo]: https://github.com/tommy351/hexo
[Hexo主题]: http://github.com/tommy351/hexo/wiki/Themes
[Pacman]: https://github.com/A-limon/pacman
[Fancybox]: http://fancyapps.com/fancybox/
[Landscape]: https://github.com/hexojs/hexo-theme-landscape
[文档]: http://hexo.io
[Landscape-F]: https://github.com/howiefh/hexo-theme-landscape-f
[hexo-calendar]: https://github.com/howiefh/hexo-calendar
[七牛]: https://portal.qiniu.com/signup?code=3llacy35or5ua
