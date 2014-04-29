layout: post
title: vim插入表格(Vim Table Mode)
date: 2014-04-29 17:23:20
tags:
- vim
categories:
- vim
description: vim table mode，vim 表格
---
hexo升级后，对GFM有了更好的支持，现在可以方便地使用GFM的表格了。为了方便在Vim里用markdown写博客，就想找一个好用的vim插件，搜了一下，有不少这类插件，比如[vim-rst-tables],[RST-Tables-CJK],[rst_tables 改进版]等，但是都对 python 有依赖。找了老半天，最后还真找到一个不需要依赖 python 的： [VIM Table Mode]。下面简单介绍一下这个插件。

<!-- more -->

## 安装

如果你使用的是vundle的话，在你的配置里添加`Bundle 'dhruvasagar/vim-table-mode'`，然后`:BundleInstall`就好了。没有使用类似的插件管理工具的话，直接下载解压到vim目录就ok。

## 配置

不用配置也可以使用，但是我根据需要添加了下面的配置。

```vim
" Use this option to define the table corner character
let g:table_mode_corner = '|'
" Use this option to define the delimiter which used by
let g:table_mode_delimiter = ' '
```

更多配置请`:h table-mode.txt`

## 使用

它的命令前缀是`<Leader>t`，可以通过 `g:table_mode_map_prefix` 来更改。

- `<Leader>tm`   table mode 开关                               
- `<Leader>tt`   使用g:table_mode_delimiter定义的分隔符插入表格
- `<Leader>T`    使用用户输入的分隔符插入表格                  
- `<Leader>tr`   重新对齐                                      
- `[|`           移动到前一个表格                              
- `]|`           移动到下一个表格                              
- `{|`           移动到上面一个表格                            
- `}|`           移动到下面一个表格                            
- `||`           插入表头边框                                  
- `<Leader>tdd`  删除一行                                      
- `<Leader>tdc`  删除一列                                      

其它命令请`:h table-mode-mappings`

[hexo]: http://hexo.io
[vim-rst-tables]: https://github.com/nvie/vim-rst-tables
[RST-Tables-CJK]: https://github.com/vim-scripts/RST-Tables-CJK
[rst_tables 改进版]: http://lilydjwg.is-programmer.com/2013/8/5/rst_tables-improved.40237.html
[VIM Table Mode]: https://github.com/dhruvasagar/vim-table-mode
