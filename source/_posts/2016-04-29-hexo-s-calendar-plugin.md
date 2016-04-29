title: Hexo的日历插件
date: 2016-04-29 21:10:44
tags: Hexo
categories: Hexo
description: Hexo 日历; Hexo Calendar; Hexo plugin; Calendar Plugin;
---

如果你在使用 [Hexo] 并且你在寻找一款 [Hexo] 下可用的日历插件，你还希望这款日历插件能像博客园或者WordPress的日历小工具一样，如果某天有文章，日期就会显示为文章链接，那么本文介绍的这个插件就是你所需要的。

实际上之前在 [Landscape-F] 主题中已经实现过一个日历插件（[hexo-calendar]）了，只不过当时这个插件很挫，打开一篇文章时，日历中才能显示文章链接，而且只能显示文章发表当月的文章的链接，你要查看其他月的日历时，就算有文章也不会在日历中显示，因为当时的做法是在生成页面直接在页面的日历中嵌入文章当月所有文章的链接，是完全静态的。现在我重新实现了日历插件（[hexo-generator-calendar]），很简单，就是在Hexo generator的时候，把所有文章的标题、链接、发布时间信息以json格式存入文件中，然后在前端用ajax方法请求日历数据，解析并生成日历表格。下面简单介绍下这个插件的安装和使用。

## 安装

执行下面的命令

```
cd <你的博客路径>
npm install --save git://github.com/howiefh/hexo-generator-calendar.git
```

## 配置

可以在博客根目录的`_config.yml`中配置这个插件

```
calendar:
    single: true
    root: calendar/
```
* single - 生成一个单独的json文件。 (默认: true)
* root - 当single的值是false时，这个值才会生效，用来指定按月份生成的多个json文件的根目录。 (默认: calendar/)

如果你在其他 [Hexo] 主题中想使用这个插件，你需要在相应目录中添加以下几个文件：

* [calendar.ejs]
* [languages.js]
* [calendar.js]
* [calendar.styl]

此外，你还需要在 [_variables.styl] 中添加以下内容

```
color-calendar-border = #d1d1d1
color-calendar-post-bg = #007acc
color-calendar-hover-bg = #686868
```

在 [after-footer.ejs] 中添加以下内容

```
<% if (theme.widgets.indexOf('calendar') != -1){ %>
    <%- js('js/languages') %>
    <%- js('js/calendar') %>

    <script type="text/javascript">
    $('#calendar').aCalendar('<%= config.language %>', {single:<%= config.calendar.single %>, root:'<%= config.calendar.root %>'});
    </script>
<% } %>
```

最后，希望大家喜欢这款插件O(∩_∩)O。

[Hexo]: https://github.com/hexojs/hexo
[Landscape-F]:http://howiefh.github.io/2014/04/20/hexo-optimize-and-my-theme-landscape-f/
[hexo-calendar]:https://github.com/howiefh/hexo-calendar
[hexo-generator-calendar]:https://github.com/howiefh/hexo-generator-calendar
[calendar.ejs]:https://github.com/howiefh/hexo-theme-landscape-f/blob/master/layout/_widget/calendar.ejs
[languages.js]:https://github.com/howiefh/hexo-theme-landscape-f/blob/master/source/js/languages.js
[calendar.js]:https://github.com/howiefh/hexo-theme-landscape-f/blob/master/source/js/calendar.js
[calendar.styl]:https://github.com/howiefh/hexo-theme-landscape-f/blob/master/source/css/_partial/calendar.styl
[_variables.styl]:https://github.com/howiefh/hexo-theme-landscape-f/blob/master/source/css/_variables.styl
[after-footer.ejs]:https://github.com/howiefh/hexo-theme-landscape-f/blob/master/layout/_partial/after-footer.ejs
