title: vim编辑markdown时实现预览
date: 2013-05-16 23:39:12
categories: Vim
tags: [Vim, Markdown, Chrome]
---
现在使用hexo+vim+markdown+github来写博客。但是在用vim编辑markdown文件的时候，感觉缺个实时预览的功能。在不用任何插件的情况下，可以这样来做：首先，`hexo new "your title"`；然后，编辑你的markdown文件，保存；之后`hexo server`，打开<http://localhost:4000/>，之后你可以继续在vim里继续编辑，然后保存，再手动刷新页面来预览结果。
<!--more-->   

这样只是达到手动预览的效果，当然还不是我想要的，google了一下，关于vim编辑markdown实时预览还真有几个:
   
- [vim-instant-markdown](https://github.com/suan/vim-instant-markdown)
- [python-vim-instant-markdown](https://github.com/isnowfy/python-vim-instant-markdown)
- [vim-instant-markdown-py](https://github.com/isnowfy/python-vim-instant-markdown)
- [md-server](https://github.com/chemzqm/md-server)
   
以上这些都实现了实时预览，但是你必须先处理好它们的依赖关系，安装比较麻烦。后来发现chrome下有个插件[Markdown Preview Plus](https://chrome.google.com/webstore/detail/markdown-preview-plus/febilkbfcbhebfnokafefeacimjdckgl)，此插件在github的项目地址：[markdown-preview](https://github.com/volca/markdown-preview)。
   
这个插件是在[Markdown Preview](https://chrome.google.com/webstore/detail/markdown-preview/jmchmkecamhbiokiopfpnfgbidieafmd)基础上做了部分改进。
   
## 改进的部分
   
- 支持自动加载，这个选项默认是关闭的，可在options中设置。
- 支持本地、http和https的markdown文件预览。
- 支持部分css样式，例如Github，TopMarks，Clearness，ClearnessDark。还可以自己添加样式。
- 新的0.2.1版本已经支持对每个md文件设置样式，这个可以覆盖全局的样式设置
   
## 使用方法 
   
- 从chrome的[webstore](https://chrome.google.com/webstore/detail/markdown-preview-plus/febilkbfcbhebfnokafefeacimjdckgl)安装Markdown Preview Plus插件
- 打开chrome://extensions/，在设置页中勾选 “允许访问文件网址” 
- 在chrome中打开本地markdown文件，http/https也是可以支持的
- 你会看到已经转换成html的内容
  
在chrome中打开markdown文件，用vim编辑markdown，保存后页面就会自动刷新，实现预览。虽然不像一些工具一样是实时的，但是保存后再预览，这样我觉得也挺好。再在vimrc中加入以下内容：
{% codeblock %}
autocmd BufRead,BufNewFile *.{md,mdown,mkd,mkdn,markdown,mdwn} map <Leader>p :!start "C:\Program Files\Google\Chrome\Application\chrome.exe" "%:p"<CR>
{% endcodeblock %}
以后，需要预览时再`\p`打开浏览器预览。
