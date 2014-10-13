title: 解决git在Windows下的乱码问题 
date: 2014-10-11 20:20:42
tags: git
categories: git
description: git 乱码;git encoding 
---

在Linux及托管网站上默认的编码都是utf-8，而Windows系统默认编码不是采用utf-8，所以Git 客户端在Windows下总是会有一些问题。一个解决方案就是通过设置git编码为utf-8。

<!-- more -->

## 设置 Git 支持 utf-8 编码

在命令行下输入以下命令：

```
$ git config --global core.quotepath false          # 显示 status 编码
$ git config --global gui.encoding utf-8            # 图形界面编码
$ git config --global i18n.commit.encoding utf-8    # 提交信息编码
$ git config --global i18n.logoutputencoding utf-8  # 输出 log 编码
$ export LESSCHARSET=utf-8
# 最后一条命令是因为 git log 默认使用 less 分页，所以需要 bash 对 less 命令进行 utf-8 编码
```
以上命令等效于：
在 etc\gitconfig 中添加
```
[core]
    quotepath = false
[gui]
    encoding = utf-8
[i18n]
    commitencoding = utf-8
    logoutputencoding = utf-8
```

在etc\profile 中添加
```
export LESSCHARSET=utf-8
```

说明：
1. gui.encoding = utf-8 解决在 $ git gui 和 gitk 里中文乱码。如果发现代码中的注释显示乱码，可以设置项目根目录中.git/config文件添加
    {% codeblock %}
    [gui]
        encoding = utf-8
    {% endcodeblock %}
2. i18n.commitencoding = utf-8 设置 commit log 提交时使用 utf-8 编码，可避免服务器上乱码，同时与Unix上的提交保持一致！
3. i18n.logoutputencoding = gbk 使得在 $ git log 时编码设置为 utf-8 
4. `export LESSCHARSET=utf-8`使得 $ git log 可以正常显示中文（配合i18n.logoutputencoding 的设置)


## 让 ls 命令可以显示中文名称

修改 etc\git-completion.bash 文件：

```
alias ls="ls --show-control-chars --color"
```
这样设置后，基本可以解决中文显示的问题。

本文参考了[解决 Git 在 windows 下中文乱码的问题](https://gist.github.com/nightire/5069597)和[MsysGit乱码与跨平台版本管理](http://bbs.csdn.net/topics/350266540)
