title: 让tagbar支持markdown
date: 2013-05-17 18:12:11
categories: vim
tags: [vim, markdown]
---
### 编辑ctags.cnf文件

在vimfiles目录下新建ctags.cnf文件并添加以下内容
```
--langdef=markdown
--langmap=markdown:.mkd
--regex-markdown=/^#[ \t]+(.*)/\1/h,Heading_L1/
--regex-markdown=/^##[ \t]+(.*)/\1/i,Heading_L2/
--regex-markdown=/^###[ \t]+(.*)/\1/k,Heading_L3/
```

### 在vimrc中添加以下内容

```
let g:tagbar_type_markdown = {
	\ 'ctagstype' : 'markdown',
	\ 'kinds' : [
		\ 'h:Heading_L1',
		\ 'i:Heading_L2',
		\ 'k:Heading_L3'
	\ ]
\ }
```

<!--more-->
由于用tagbar替换了taglist，原来的txtbrowser不能再生成目录结构了，和上面类似的  
   
### 编辑ctags.cnf

向ctags.cnf文件再添加以下内容
```
--langdef=txt 
--langmap=txt:.txt
--regex-txt=/^([0-9]+\.?[ \t]+)(.+$)/\1\2/c,content/
--regex-txt=/^(([0-9]+\.){1}([0-9]+\.?)[ \t]+)(.+$)/.   \1\4/c,content/
--regex-txt=/^(([0-9]+\.){2}([0-9]+\.?)[ \t]+)(.+$)/.       \1\4/c,content/
--regex-txt=/^[ \t]+(table[ \t]+[0-9a-zA-Z]+([.: ]([ \t]*.+)?)?$)/\1/t,tables/i
--regex-txt=/^[ \t]+(figure[ \t]+[0-9a-zA-Z]+([.: ]([ \t]*.+)?)?$)/\1/f,figures/i
```

### 在vimrc中再添加以下内容
```
let g:tagbar_type_txt = {
    \ 'ctagstype': 'txt',
    \ 'kinds' : [
        \'c:content',
		\'t:tables',
		\'f:figures'
    \],
	\ 'sort'    : 0
\}
```
