title: 用vim的方式操作你的软件
date: 2012-03-17 23:03:09
tags: Vim
categories: Vim
description: vim-like, vim plugins, vim 插件
---

## Visual Studio中的Vim插件

### ViEmu（收费）

地址：http://www.viemu.com/

![ViEmu](http://www.viemu.com/viemu-movie.gif "ViEmu")

还有可以在Word，Outlook和SQL Server Management Studio中使用的ViEmu。

<!-- more -->

### VsVim（免费）

地址：https://github.com/jaredpar/VsVim/

以上两个插件基本命令都有了，不过还是ViEmu更强。

### visual_studio.vim（免费）

地址：http://www.vim.org/scripts/script.php?script_id=864

支持Visual Studio 2003, 2005 and 2008

这个没用过，只是当时在官网上看到过。

### VisVim（免费）

以上都只是支持Visual Studio，如果还在用VC6.0可以考虑一下这个，此插件是打开vim来编辑当前文件的，并且vim得是OLE的GUI版本才行。

使用方法可以参考http://blog.csdn.net/absurd/article/details/1164127

## Eclipse中的vim插件

### viPlugin（收费）

地址：http://www.viplugin.com/

不错的插件，功能上比其他的要好，不过要收费。

### Vrapper（免费）

地址：http://vrapper.sourceforge.net

Vrapper也比较不错，但是比上面那位还是弱点。

已知的问题有当要删的词位于行末时dw会连换行符也删掉，搜索结果不高亮。

### VimPlugin（免费）

地址：http://sourceforge.net/projects/vimplugin/

VimPlugin需要gvim的支持。

使用方法可以参考：http://akunamotata.iteye.com/blog/324637

### eclim（免费）

eclim是直接调用了vim，而不是模拟。

地址：http://eclim.org/

项目主页：http://eclim.sourceforge.net/

关于eclipse中的插件还可以参考：http://paddy-w.iteye.com/blog/969366

## Netbeans IDE中的Vim插件：Jvi

地址：http://jvi.sourceforge.net/

jVi是Vim一些基本功能的JAVA版实现。在netbeans里面可以很方便地启用和禁用jVi编辑器。jVi目前支持超过200个vim命令：

http://jvi.sourceforge.net/vimhelp/help.txt.html#reference_toc

## JetBrains 中的Vim插件：IdeaVIM

地址：https://plugins.jetbrains.com/plugin/164

按ctrl+alt+v 可启用此Vim模拟器。

## Chrome

### Vimium

地址：https://chrome.google.com/webstore/detail/dbepggeogbaibhgnhhndojpepiihcmeb

用这个插件的人貌似比较多，？可以查看可以使用的命令。

具体使用可以参考http://kejibo.com/chrome-vimium/

### Vrome

地址：https://chrome.google.com/webstore/detail/godjoomfiimiddapohpmfklhgmbfffjj

最近才发现另一个不错的插件 Vrome，前身是Vimlike Smooziee，作者是国人，支持一下。感觉功能比Vimium强，不过似乎不太火。

特色：

缩放网页

C-y 缩短当前网址，并且复制缩短后的地址到剪贴板（此功能需要设置，此插件设置很不错，可以像配置vim一样简单配置下）

C-i  使用外部编辑器编辑等。

具体可以参考：http://linuxtoy.org/archives/vimlike-smooziee-chrome-vim-extension.html#comment-133032

## Firefox

### Pentadactyl

地址：https://addons.mozilla.org/en-US/firefox/addon/pentadactyl/

### Vimperator

地址：https://addons.mozilla.org/en-US/firefox/addon/vimperator/

不怎么用火狐，感兴趣的话可以参考：http://xbeta.info/vimperator.htm

## 在bash中使用vi

Bash中默认是emacs模，你可以用命令`set -o vi`来设置为vi模式。如果想一直使用vi模式，你可以把`set -o vi`加入到家目录下的配置文件`.bashrc`中。

其实还可以用autohotkey来在别的软件中实现vim模式的，有人已经写了一个叫Vim_Mode的脚本，有兴趣的可以下载使用：http://pan.baidu.com/s/1nt9W6oh
