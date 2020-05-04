title: 编辑器之神Vim
date: 2013-12-02 20:27:18
categories: Vim
tags: Vim
---
世界上有三种程序员，一种用Emacs，一种用Vi，剩下的是用其它编辑器的。Emacs是神的编辑器，[Vim](http://www.vim.org/)是编辑器之神。选择Vim还是Emacs，编辑器之争到今天也不曾有什么定论，也不可能有什么定论。有人说Emacs是伪装成编辑器的操作系统，这句话并不夸张，Emacs有一个强大的语言Lisp作支撑。Vim是由[Bram Moolenaar](http://www.moolenaar.net)发布的Vi的衍生版本，增加了非常多的新特性，也是最受欢迎的一个版本，现在有些Linux发行版本默认情况下会将Vi直接链接到Vim。相对来讲，Vim的脚本语言弱一些，Vim则更专注于做强大的编辑器。Vim 的设计则更符合UNIX哲学－－“Do one thing and do it well"。

<!-- more -->

大二才开始接触Linux，那时想找一个Linux下好用的编辑器，通过收集网上的资料，了解到原来编辑器里还有两个强大的神器。比较之下，还是更喜欢Vim的操作方式，而不是Emacs 的CTRL+xxx,ALT+xxx。用上Vim后，开始不断的学习，收集关于Vim的资料。到现在，可能使用一段时间Vim后还是能新发现一些好用的技巧，并会为此欣喜不已，这也是使用Vim的有趣之处。

## 模式
首先，区别于大多数编辑器，Vim是有模式的，[Vim具有6种基本模式和5种派生模式](http://zh.wikipedia.org/wiki/Vim#.E6.A8.A1.E5.BC.8F)。介绍一下基本模式吧。

1. Normal Mode(普通模式)
    默认进入vim之后，就处于这种模式。在这个模式下你可以快速的移动光标，删除，复制文字。

2. Visual Mode(可视模式)
    在这种模式下选定一些字符、行、多列。在普通模式下，可以按V\v进入。

3. Insert Mode(插入模式)
    其实就是指处在编辑输入的状态。普通模式下，可以按i\I，a\A，o\O进入，这几个进入插入模式后位置不同。

4. Select Mode(选择模式)
    这个模式和无模式编辑器的行为比较相似（Windows标准文本控件的方式）。这个模式中，可以用鼠标或者光标键高亮选择文本，不过输入任何字符的话，Vim会用这个字符替换选择的高亮文本块，并且自动进入插入模式。

5. Command-Line(命令行模式)
    在命令行模式中可以输入会被解释成并执行的文本。例如执行命令（":"键），搜索（"/"和"?"键）或者过滤命令（"!"键）。在命令执行之后，Vim返回到命令行模式之前的模式，通常是普通模式。

6. Ex Mode(Ex模式)
    普通模式下键入Q进入该模式，这和命令行模式比较相似，在使用":visual"命令离开Ex模式前，可以一次执行多条命令。

## 操作
这里所说操作是在普通模式下进行的。以下是一些入门级的操作，也是经常会用到的操作。

| 命令     | 说明                        |
|----------|-----------------------------|
| hjkl     | 光标左、下、上、右移动      |
| gg       | 光标移动到首行              |
| G        | 光标移动到末行              |
| +        | 光标移动到非空格符的下一行  |
| -        | 光标移动到非空格符的上一行  |
| n<space> | 光标向右移动这一行的n个字符 |
| H        | 移动到屏幕最上一行          |
| M        | 移动到屏幕中间一行          |
| L        | 移动到屏幕最下一行          |
| nG       | 移动到第n行                 |
| n<enter> | 向下移动n行                 |
| x/X      | 向后/向前删除一个字符       |
| dd       | 删除光标所在行              |
| dnG      | 删除光标所在行到第n行的数据 |
| yy       | 复制光标所在行              |
| ynG      | 复制光标所在行到第n行的数据 |
| p        | 粘贴复制的内容              |
| n<cmd>   | 重复执行n次命令             |

Vim 命令图表：
![](https://cdn.jsdelivr.net/gh/howiefh/assets/img/vim-shortcuts.png)

![](https://cdn.jsdelivr.net/gh/howiefh/assets/img/vim-cheat-sheet-for-programmers-print.png)

## 配置
```
syntax on                   " 自动语法高亮
colorscheme torte           "配置颜色方案
set number                  " 显示行号
set cursorline              " 突出显示当前行
set wildmenu				 "Turn on WiLd menu 在末行命令行敲tab键时会在状态栏显示选项
set whichwrap+=h,l			"Bbackspace and cursor keys wrap to 使指定的左右移动光标的键在行首或行尾可以移到前一行或者后一行
set shiftwidth=4            " 设定 << 和 >> 命令移动时的宽度为 4
set softtabstop=4           " 使得按退格键时可以一次删掉 4 个空格
set tabstop=4               " 设定 tab 长度为 4
set nobackup                " 覆盖文件时不备份
set autochdir               " 自动切换当前目录为当前文件所在的目录
```
使用Vim，有段时间就是在搜集别人的配置文件，然后将别人不错的配置加到自己的配置文件中。以上是简单的一些配置，是我配置文件的一部分内容。

一些配置文件：<http://amix.dk/vim/vimrc.html>（号称史上最强大的配置文件）；<http://www.cnblogs.com/ma6174/archive/2011/12/10/2283393.html>。我的配置文件：<https://github.com/howiefh/vimfiles>

## 插件
使用插件，可以让操作快捷一些。但是，Vim 有点缺憾就是插件增多后打开软件会变慢。下面介绍一些插件

* taglist
    用来提供单个源代码文件的函数列表之类的功能。另一个类似插件-tagbar.vim，也很不错。需要安装ctags

* NERD_commenter
    提供快速注释/反注释代码块的功能

* NERD_tree
    提供展示文件/目录列表的功能，比自带的文件浏览器要好很多

* fencviewa
    自动检测文件编码，也可以手动选择文件编码。

* neocomplcache配合neosnippet
    自动补全代码

更多插件可以参考：
* [经典vim插件功能说明、安装方法和使用方法介绍](http://blog.csdn.net/tge7618291/article/details/4216977)
* [滇狐收集和整理的一些有用的VIM 插件](http://edyfox.codecarver.org/html/vimplugins.html)
* [vim(gvim)相关插件整理](http://www.vimer.cn/2010/06/%E6%9C%AC%E5%8D%9A%E4%BD%BF%E7%94%A8%E7%9A%84vimgvim%E7%9B%B8%E5%85%B3%E6%8F%92%E4%BB%B6%E6%95%B4%E7%90%86.html)

## 一些小技巧
使用过程中也了解了Vim的一些小技巧，比方说在按v进入可视模式后再按o可以切换光标位置；再比方说在命令行模式下按`<ctrl-r><ctrl-w>`可以将文本中光标下的单词复制到命令行；`<ctrl-r>%`插入文件名；`:r !date`插入日期。

## 在其他软件中使用vim模式操作
* chrome -- vrome
* Firefox -- Vimperator
* Visual Studio -- ViEmu\VsVim
* Eclipse -- viPlugin\Vrapper
* Netbeans -- Jvi
* bash -- 使用命令`set -o vi`
* Sublime Text -- Vintage
* Emacs -- evil

现在你所看到的这篇文章即在vim中编写。

![](https://cdn.jsdelivr.net/gh/howiefh/assets/img/vim-godvim.png)

![](https://cdn.jsdelivr.net/gh/howiefh/assets/img/vim-success.jpg)

by FengHao
2013.12.02
