title: Best of Vim Tips 中文版
date: 2014-01-26 17:48:52
categories: vim
tags: vim
---
这篇文章出自：<https://groups.google.com/d/msg/vim-cn/XCVyjj7svs4/AVGVRQa6L_cJ>
这是篇每个 Vim 用户都应该阅读的文章，原文在这里
<http://www.rayninfo.co.uk/vimtips.html>
这篇文章很早被翻译过，好像是一个清华的哥们翻译的。我再原来的基础上又整理     
和新增了些内容--这是两年前做的，后来没有再更新。有兴趣的人可以继续更新。    
<!-- more -->    
__BEGIN__    

----------------------------------------     
# searching 查找     
{% code %}
/joe/e                      : cursor set to End of match         
                              把光标定位在匹配单词最后一个字母处         
/joe/e+1                    : cursor set to End of match plus 1    
                              把光标定位在匹配单词最后一个字母的下一个字母处          
/joe/s-2                    : cursor set to Start of match minus 2    
                              把光标定位在匹配单词第一个字母往前数两个字母的位置          
/^joe.*fred.*bill/          : normal          
                              标准的正则表达式     
/^[A-J]\+/                  : search for lines beginning with one or more A-J     
                              查找以一个或多个 A-J 中的字母开头的行     
/begin\_.*end               : search over possible multiple lines     
                              查找在 begin 和 end 两个单词之间尽可能多的行     
/fred\_s*joe/i              : any whitespace including newline     
                              查找在 fred 和 joe 两个单词之间任意多的空格，包括新行     
/fred\|joe                  : Search for FRED OR JOE     
                              查找 fred 或 joe     
/\([^0-9]\|^\)%.*%          : Search for absence of a digit or beginning of line     
                              查找     
/.*fred\&.*joe              : Search for FRED AND JOE in any ORDER!     
                              查找同时包含 FRED 和 JOE 的行，不分前后顺序     
/\<fred\>/i              : search for fred but not alfred or frederick     
                              查找 fred, 而不是 alfred 或者 frederick，也就是全字匹配     
/\<\d\d\d\d\>            : Search for exactly 4 digit numbers     
                              查找4个数字的全字匹配     
/\D\d\d\d\d\D               : Search for exactly 4 digit numbers     
                              查找4个数字的全字匹配     
/\<\d\{4}\>              : same thing     
                              同上     
{% endcode %}
    
# finding empty lines 查找空行     
{% code %}
/^\n\{3}                    : find 3 empty lines     
                              查找 3 行空行     
{% endcode %}
    
# Specify what you are NOT searching for (vowels)     
# 指定不要查找什么     
{% code %}
/\c\v([^aeiou]&\a){4}       : search for 4 consecutive consanants     
{% endcode %}
    
# using rexexp memory in a search     
# 在查找中使用正则表达式存储     
{% code %}
/\(fred\).*\(joe\).*\2.*\1     
{% endcode %}
    
# Repeating the Regexp (rather than what the Regexp finds)     
# 重复正则表达式     
{% code %}
/^\([^,]*,\)\{8}     
{% endcode %}
    
# visual searching     
# 可视模式下的查找     
{% code %}
:vmap // y/<C-R>"<CR>       : search for visually highlighted text     
                                     查找被高亮显示的文本     
:vmap <silent> //    y/<C-R>=escape(@", '\\/.*$^~[]')<CR><CR> : with spec chars     
{% endcode %}
    
# searching over multiple lines \_ means including newline     
# 查找多行。\_ 表示包括新行     
{% code %}
/<!--\_p\{-}-->                : search for multiple line comments     
                                     查找多行注释     
/fred\_s*joe/i                    : any whitespace including newline     
                                     查找在 fred 和 joe 两个单词之间任意多的空     
格，包括新行     
/bugs\(\_.\)*bunny                : bugs followed by bunny anywhere in file     
                                     bugs 后任意位置含有 bunny 单词的多个行     
:h \_                             : help     
                                     帮助     
{% endcode %}
    
# search for declaration of subroutine/function under cursor     
# 查找光标下子程序/函数的声明     
{% code %}
:nmap gx yiw/^\(sub\<bar>function\)\s\+<C-R>"<CR>     
{% endcode %}
    
# multiple file search     
# 在多个文件中查找     
{% code %}
:bufdo /searchstr     
:argdo /searchstr     
{% endcode %}
    
# How to search for a URL without backslashing     
# 如何不使用反斜线查找 URL     
{% code %}
? http://www.vim.org/        : search BACKWARDS!!! clever huh!     
{% endcode %}
----------------------------------------     
# substitution     
# 替换     
{% code %}
:%s/fred/joe/igc            : general substitute command     
                               普通替换命令     
:%s/\r//g                   : Delete DOS returns ^M     
                               删除 DOS 回车符 ^M     
{% endcode %}
    
# Is your Text File jumbled onto one line? use following     
# 你的文本文件是否乱七八糟的排成一行？使用如下命令     
{% code %}
:%s/\r/\r/g                 : Turn DOS returns ^M into real returns     
                               转换 DOS 回车符 ^M 为真正的回车符     
:%s=  *$==                  : delete end of line blanks     
                               删除行尾空格     
:%s= \+$==                  : Same thing     
                               同上     
:%s#\s*\r\?$##              : Clean both trailing spaces AND DOS returns     
                               删除行尾空格和 DOS 回车符     
:%s#\s*\r*$##               : same thing     
                               删除行尾空格和 DOS 回车符     
{% endcode %}
    
# deleting empty lines     
# 删除空行     
{% code %}
:%s/^\n\{3}//               : delete blocks of 3 empty lines     
                               删除三行空行     
:%s/^\n\+/\r/               : compressing empty lines     
                              压缩多行空行为一行     
{% endcode %}
    
# IF YOU ONLY WANT TO KNOW ONE THING     
# 如果你只想明白一件事情     
{% code %}
:'a,'bg/fred/s/dick/joe/igc : VERY USEFUL     
                               非常有用     
{% endcode %}
    
# duplicating columns     
# 复制列     
{% code %}
:%s= [^ ]\+$=&&=            : duplicate end column     
                               复制最后一列     
:%s= \f\+$=&&=              : same thing     
                               同上     
:%s= \S\+$=&&               : usually the same     
                               同上     
{% endcode %}

# memory     
# 记忆，或叫引用     
{% code %}
:s/\(.*\):\(.*\)/\2 : \1/   : reverse fields separated by :     
                               反转以 : 分隔的字段     
:%s/^\(.*\)\n\1/\1$/        : delete duplicate lines     
                               删除重复的行     
{% endcode %}
    
# non-greedy matching \{-}     
# 非贪婪匹配 \{-}     
{% code %}
:%s/^.\{-}pdf/new.pdf/      : delete to 1st pdf only     
                               只删除到第一个 pdf     
{% endcode %}
    
# use of optional atom \?     
{% code %}
:%s#\<[zy]\?tbl_[a-z_]\+\>#\L&#gc : lowercase with optional leading characters     
                                        不懂     
{% endcode %}
    
# over possibly many lines     
# 匹配尽可能多的行     
{% code %}
:%s/<!--\_.\{-}-->//        : delete possibly multi-line comments     
                                  删除尽可能多的注释     
:help /\{-}                 : help non-greedy     
                               非贪婪匹配的帮助     
{% endcode %}
    
# substitute using a register     
# 使用寄存器替换     
{% code %}
:s/fred/<c-r>a/g         : sub "fred" with contents of register "a"     
                               用"a"寄存器里的内容替换"fred"     
:s/fred/\=@a/g              : better alternative as register not displayed     
                               更好的方法，不用显示寄存器内容     
{% endcode %}
    
# multiple commands on one line     
# 写在一行里的复杂命令     
{% code %}
:%s/\f\+\.gif\>/\r&\r/g | v/\.gif$/d | %s/gif/jpg/     
{% endcode %}
    
# ORing     
{% code %}
:%s/suck\|buck/loopy/gc     : ORing (must break pipe)     
                               不懂     
{% endcode %}

# Calling a VIM function     
# 调用 Vim 函数     
{% code %}
:s/__date__/\=strftime("%c")/ : insert datestring     
                                插入日期     
{% endcode %}
    
# Working with Columns sub any str1 in col3     
# 处理列，替换所有在第三列中的 str1     
{% code %}
:%s:\(\(\w\+\s\+\)\{2}\)str1:\1str2:     
{% endcode %}
    
# Swapping first & last column (4 columns)     
# 交换第一列和最后一列 (共4列)     
{% code %}
:%s:\(\w\+\)\(.*\s\+\)\(\w\+\)$:\3\2\1:     
{% endcode %}
    
# filter all form elements into paste register     
# 把所有的form元素（就是html里面的form啦）放到register里     
{% code %}
:redir @*|sil exec 'g#<\(input\|select\|textarea\|/\=form\)\>#p'|redir END     
:nmap ,z :redir @*<Bar>sil exec     
'g@<\(input\<Bar>select\<Bar>textarea\<Bar>/\=form\)\>@p'<Bar>redir END<CR>     
{% endcode %}
    
# increment numbers by 6 on certain lines only     
# 不懂     
{% code %}
:g/loc\|function/s/\d/\=submatch(0)+6/     
{% endcode %}
    
# better     
# 更好的方法     
{% code %}
:%s#txtdev\zs\d#\=submatch(0)+1#g     
:h /\zs     
{% endcode %}
    
# increment only numbers gg\d\d  by 6 (another way)     
# 不懂     
{% code %}
:%s/\(gg\)\@<=\d\+/\=submatch(0)+6/     
:h zero-width     
{% endcode %}
    
# find replacement text, put in memory, then use \zs to simplify substitute     
# 查找需替换的文本，保存，然后使用 \zs 命令简单替换     
{% code %}
:%s/"\([^.]\+\).*\zsxx/\1/     
{% endcode %}
    
# Pull word under cursor into LHS of a substitute     
# 不懂     
{% code %}
:nmap <leader>z :%s#\<<c-r>=expand("<cword>")<cr>\>#     
{% endcode %}
    
# Pull Visually Highlighted text into LHS of a substitute     
# 不懂     
{% code %}
:vmap <leader>z :<C-U>%s/\<<c-r>*\>/     
{% endcode %}
    
----------------------------------------     
    
# all following performing similar task, substitute within substitution     
# Multiple single character substitution in a portion of line only     
{% code %}
:%s,\(all/.*\)\@<=/,_,g     : replace all / with _ AFTER "all/"     
{% endcode %}
    
# Same thing     
{% code %}
:s#all/\zs.*#\=substitute(submatch(0), '/', '_', 'g')#     
{% endcode %}
    
# Substitute by splitting line, then re-joining     
{% code %}
:s#all/#&^M#|s#/#_#g|-j!     
{% endcode %}
    
# Substitute inside substitute     
{% code %}
:%s/.*/\='cp '.submatch(0).' all/'.substitute(submatch(0),'/','_','g')/     
{% endcode %}
----------------------------------------     
# global command display (see tip 227)     
# 全局命令显示（参见 tip 227)     
{% code %}
:g/fred.*joe.*dick/         : display all lines fred,joe & dick     
                              显示所有包含fred,joe 和 dick 的行     
:g/\<fred\>/             : display all lines fred but not freddy     
                               显示所有全字匹配 fred 的行     
:g/<pattern>/z#.5        : display with context     
                               显示上下文     
:g/<pattern>/z#.5|echo "=========="  : display beautifully     
                                           显示得很漂亮     
:g/^\s*$/d                  : delete all blank lines     
                               删除所有的空行     
:g!/^dd/d                   : delete lines not containing string     
                               删除所有行首不是 dd 的行     
:v/^dd/d                    : delete lines not containing string     
                              同上     
:g/fred/,/joe/d             : not line based (very powerfull)     
                               并不基于行(非常强大)     
:g/{/ ,/}/- s/\n\+/\r/g     : Delete empty lines but only between {...}     
                               删除在 {...} 只见的空行     
:v/./.,/./-1join            : compress empty lines     
                               压缩空行     
:g/^$/,/./-j                : compress empty lines     
                               压缩空行     
:g/<input\|<form/p    : ORing     
                               不懂     
:g/^/pu _                   : double space file (pu = put)     
                               把文件中空行增加一倍     
:g/^/m0                     : Reverse file (m = move)     
                               翻转文件     
:g/fred/t$                  : copy lines matching fred to EOF     
                               把匹配 fred 的行拷贝到文件最后     
:g/stage/t'a                : copy lines matching stage to marker a     
                               把匹配 stage 的行做标记a     
:%norm jdd                  : delete every other line     
                               隔一行删除一行     
{% endcode %}
    
# incrementing numbers (type <c-a> as 5 characters)     
{% code %}
:.,$g/^\d/exe "norm! \<c-a>": increment numbers     
                                  增加每行行首的数字     
:'a,'bg/\d\+/norm! ^A          : increment numbers     
                                  增加标记 a 到标记 b 只见每行行首的数字     
{% endcode %}
    
# storing glob results (note must use APPEND)     
# 保存全局命令的结果 (注意必须使用添加模式)     
{% code %}
:g/fred/y A                 : append all lines fred to register a     
                               添加所有为fred所匹配的行到register a     
:'a,'b g/^Error/ . w >> errors.txt     
{% endcode %}
    
# duplicate every line in a file wrap a print '' around each duplicate     
# 复制每一行，然后在复制出来的每一行两侧加上一个 print '复制出来的内容'     
{% code %}
:g/./yank|put|-1s/'/"/g|s/.*/Print '&'/     
{% endcode %}
    
# replace string with contents of a file, -d deletes the "mark"     
# 用文件中的内容替换字符串，-d 表示删除“标记”     
{% code %}
:g/^MARK$/r tmp.ex | -d     
{% endcode %}
    
----------------------------------------     
    
# Global combined with substitute (power editing)     
# 全局命令和替换命令联姻 (强大的编辑能力)     
{% code %}
:'a,'bg/fred/s/joe/susan/gic :  can use memory to extend matching     
                                 可以使用反向引用来匹配     
:g/fred/,/joe/s/fred/joe/gic :  non-line based (ultra)     
{% endcode %}
    
----------------------------------------     
    
# Find fred before beginning search for joe     
# 先找fred，然后找joe     
{% code %}
:/fred/;/joe/-2,/sid/+3s/sally/alley/gIC     
{% endcode %}
    
----------------------------------------     
    
# Absolutely essential     
# 基础     
    
----------------------------------------     
{% code %}
* # g* g#           : find word under cursor (<cword>) (forwards/backwards)     
                       寻找光标处的狭义单词(<cword>) (前向/后向)     
%                   : match brackets {}[]()     
                       括号配对寻找 {}[]()     
.                   : repeat last modification     
    
matchit.vim         : % now matches tags <tr><td><script> <?php etc     
                       使得 % 能够配对标记 <tr><td><script> <?php 等等     
<C-N><C-P>          : word completion in insert mode     
                             插入模式下的单词自动完成     
<C-X><C-L>          : Line complete SUPER USEFUL     
                             行自动完成(超级有用)     
/<C-R><C-W>         : Pull <cword> onto search/command line     
                             把狭义单词 <cword> 写到 搜索命令行     
/<C-R><C-A>         : Pull <CWORD> onto search/command line     
                             把广义单词 <cWORD> 写到 搜索命令行     
:set ignorecase     : you nearly always want this     
                       搜索时忽略大小写     
:syntax on          : colour syntax in Perl,HTML,PHP etc     
                       在 Perl,HTML,PHP 等中进行语法着色     
:h regexp<C-D>      : type control-D and get a list all help topics containing     
                          按下 control-D 键即可得到包含有 regexp 的帮助主题的列表     
                       regexp (plus use TAB to Step thru list)     
                       (使用TAB可以实现帮助的自动补齐)     
{% endcode %}
----------------------------------------     
# MAKE IT EASY TO UPDATE/RELOAD _vimrc     
# 使更新 _vimrc 更容易     
{% code %}
:nmap ,s :source $VIM/_vimrc     
          # 译释：nmap 是绑定一个在normal模式下的快捷键     
:nmap ,v :e $VIM/_vimrc     
          # 译释：在normal模式下，先后按下 ,s 两个键执行_vimrc，而 ,v 则是编辑_vimrc     
{% endcode %}
    
----------------------------------------     
    
#VISUAL MODE (easy to add other HTML Tags)     
# visual 模式 (例子是：轻松添加其他的 HTML Tags)     
{% code %}
:vmap sb "zdi<b><C-R>z</b><ESC>  : wrap <b></b> around VISUALLY selected Text     
                                                在visual模式下选中的文字前后分别     
加上<b>和</b>     
:vmap st "zdi<?= <C-R>z ?><ESC>  : wrap <?=   ?> around VISUALLY selected Text     
                                             在visual模式下选中的文字前后分别加     
上<?= 和 ?>     
{% endcode %}
    
----------------------------------------     
    
# Exploring     
# 文件浏览     
{% code %}
:Exp(lore)                      : file explorer note capital Ex     
                                   开启目录浏览器，注意首字母E是大写的     
:Sex(plore)                     : file explorer in split window     
                                   在一个分割的窗口中开启目录浏览器     
:ls                             : list of buffers     
                                   显示当前buffer的情况     
:cd ..                          : move to parent directory     
                                   进入父目录     
:args                           : list of files     
                                   显示目前打开的文件     
:lcd %:p:h                      : change to directory of current file     
                                   更改到当前文件所在的目录     
:autocmd BufEnter * lcd %:p:h   : change to directory of current file     
automatically (put in _vimrc)     
                                   自动更改到当前文件所在的目录 (放到 _vimrc)     
{% endcode %}
    
----------------------------------------     
    
# Buffer Explorer (Top Ten Vim Script)     
# 缓冲区(buffer)浏览器 (第三方的一个最流行的脚本)     
{% code %}
# needs bufexplorer.vim   http://www.vim.org/script.php?script_id=42     
# 需要下载 bufexplorer.vim     
\be                             : buffer explorer list of buffers     
                                   在缓冲区浏览器中打开缓冲区列表     
\bs                             : buffer explorer (split window)     
                                   以分割窗口的形式打开缓冲区浏览器     
{% endcode %}
    
----------------------------------------     
    
# Changing Case     
{% code %}
guu                             : lowercase line     
                                   行小写     
gUU                             : uppercase line     
                                   行大写     
Vu                              : lowercase line     
                                   行小写     
VU                              : uppercase line     
                                   行大写     
g~~                             : flip case line     
                                   行翻转     
vEU                             : Upper Case Word     
                                   字大写(狭义字)     
vE~                             : Flip Case Word     
                                   字翻转(狭义字)     
ggguG                           : lowercase entire file     
                                   把整个文章全部小写     
{% endcode %}
    
# Titlise Visually Selected Text (map for .vimrc)     
{% code %}
vmap ,c :s/\<\(.\)\(\k*\)\>/\u\1\L\2/g<CR>     
{% endcode %}

# Uppercase first letter of sentences     
# 大写所有句子的第一个字母     
{% code %}
:%s/[.!?]\_s\+\a/\U&\E/g     
{% endcode %}
    
----------------------------------------     
    
{% code %}
gf                              : open file name under cursor (SUPER)     
                                   取当前光标处的广义字作为文件名，然后试图打开它！     
ga                              : display hex,ascii value of char under cursor     
                                   显示光标处字符的ascii,hex,oct,...     
ggVGg?                          : rot13 whole file     
                                   用rot13编码整个文件     
ggg?G                           : rot13 whole file (quicker for large file)     
                                   用rot13编码整个文件(对大文件更快一些)     
:8 | normal VGg?                : rot13 from line 8     
                                   从第8行开始，用rot13编码后面的文本     
:normal 10GVGg?                 : rot13 from line 8     
                                   从第8行开始，用rot13编码后面的文本     
{% endcode %}
    
# 【关于rot13——谁让英文是偶数个字母啊】     
 ROT13 是一种简单的编码，它把字母分成前后两组，每组13个，编码和解码     
 的算法相同，仅仅交换字母的这两个部分，即：[a..m] --> [n..z] 和 [n..z]     
 --> [a..m] 。 ROT13 用简易的手段使得信件不能直接被识别和阅     
 读，也不会被搜索匹配程序用通常的方法直接找到。经常用于 USENET 中发表一     
 些攻击性或令人不快的言论或有简单保密需要的文章。     
 由于 ROT13 是自逆算法，所以，解码和编码是同一个过程。     
    
{% code %}
<C-A>,<C-X>               : increment,decrement number under cursor     
                                   增加,减少 光标处的狭义字所表示的数字     
                                   win32 users must remap CNTRL-A     
                                   Win32的用户可能需要重新定义一下Ctrl-A     
<C-R>=5*5                    : insert 25 into text (mini-calculator)     
                                   插入25 (一个迷你计算器)     
{% endcode %}
    
----------------------------------------     
    
# Makes all other tips superfluous     
{% code %}
:h 42            : also http://www.google.com/search?q=42     
:h holy-grail     
:h!     
{% endcode %}
    
----------------------------------------     
    
# Markers & moving about     
# 标记和移动     
{% code %}
'.               : jump to last modification line (SUPER)     
                    跳到最后修改的那一行 (超级有用)     
`.               : jump to exact spot in last modification line     
                    不仅跳到最后修改的那一行，还要定位到修改点     
g;               : cycle thru recent changes (oldest first) (new in vim6.3)     
                    循环跳转修改点(从最老的修改点开始) (vim6.3中新增)     
g,               : reverse direction (new in vim6.3)     
                    反向循环跳转修改点 (vim6.3中新增)     
    
:changes     
:h changelist    : help for above     
<C-O>            : retrace your movements in file (starting from most recent)     
                       依次沿着你的跳转记录向回跳 (从最近的一次开始)     
<C-I>            : retrace your movements in file (reverse direction)     
                       依次沿着你的跳转记录向前跳     
:ju(mps)         : list of your movements     
                    列出你跳转的足迹     
:help jump-motions     
:history         : list of all your commands     
                    列出历史命令记录     
:his c           : commandline history     
                    命令行命令历史     
:his s           : search history     
                    搜索命令历史     
q/               : Search history Window     
                    搜索命令历史的窗口     
q:               : commandline history Window     
                    命令行命令历史的窗口     
:<C-F>        : history Window     
                    历史命令记录的窗口     
{% endcode %}
----------------------------------------     
# Abbreviations & maps     
# 缩写和键盘映射     
{% code %}
:map   <f7>   :'a,'bw! c:/aaa/x     
                  # 译释：map是映射一个normal模式下的键     
                  # 这里是把F7键映射成把标记a到标记b中间的内容另存为一个文件/aaa/x     
                  # 标记(mark)的方法：把光标移动到需要标记的地方，输入m，然后输     
入标记名，例如a     
                  # 引用标记的方法：'a ，即：单引号加标记名     
:map   <f8>   :r c:/aaa/x     
                  # 译释：把F8键映射成在当前位置插入文件/aaa/x的内容     
:map   <f11>  :.w! c:/aaa/xr<CR>     
                  # 译释：.（点号）表示当前行     
                  # 所以F11就是把当前行存为/aaa/xr     
                  # 最后的<CR>表示一个回车     
:map   <f12>  :r c:/aaa/xr<CR>     
:ab php          : list of abbreviations beginning php     
                    列出php表示的缩写     
                  # 译释：定义一个缩写使用：:iab hm hmisty     
                  # 一个有趣的现象是，它列出的会是php和它的前子串开头的缩写     
                  # 例如，有这么几个缩写：     
                  # h => hmisty1 , hm => hmisty2 , hmi => hmisty3, m => hmisty4     
                  # 那么使用 :ab hm会显示这么几个缩写：hm 和 h     
                  # 而不是你想象中的 hm 和 hmi     
    
:map ,           : list of maps beginning ,     
                    列出以逗号开始的键盘映射     
{% endcode %}
    
# allow use of F10 for mapping (win32)     
# 允许 F10 的映射用法 (win32)     
{% code %}
set wak=no       : :h winaltkeys     
                    参见 :h winaltkeys     
{% endcode %}
    
# For use in Maps     
# 在键盘映射中常用的表示     
{% code %}
<CR>             : carriage Return for maps     
                       回车     
<ESC>            : Escape     
                       ESC     
<LEADER>         : normally \     
                       转义符号 \     
<BAR>            : | pipe     
                       管道符号     
<BACKSPACE>      : backspace     
                       退格符号     
{% endcode %}
    
# display RGB colour under the cursor eg #445588     
# 显示光标下数值的 RGB 颜色     
{% code %}
:nmap <leader>c :hi Normal guibg=#<c-r>=expand("<cword>")<cr><cr>     
{% endcode %}
    
----------------------------------------     
    
# Using a register as a map (preload registers in .vimrc)     
{% code %}
:let @m=":'a,'bs/"     
:let @s=":%!sort -u"     
{% endcode %}
    
----------------------------------------     
# List your Registers     
# 列出寄存器(Registers)     
{% code %}
:reg             : display contents of all registers     
                   显示所有寄存器的内容     
:reg a           : display content of individual registers     
                    显示 a 寄存器的内容     
"1p....          : retrieve numeric registers one by one     
:let @y='yy@"'   : pre-loading registers (put in .vimrc)     
{% endcode %}
    
----------------------------------------     
    
# Useful tricks     
# 有用的窍门     
{% code %}
"ayy@a           : execute "Vim command" in a text file     
                    把当前行作为一个Vim命令来执行     
yy@"             : same thing using unnamed register     
                    同上，不过是用匿名寄存器     
u@.              : execute command JUST typed in     
                    只执行键入的命令     
{% endcode %}
    
----------------------------------------     
    
# Get output from other commands (requires external programs)     
# 从其他程序获取输出 (需要外部程序)     
{% code %}
:r!ls.exe        : reads in output of ls     
                    读取ls的输出到当前位置     
!!date           : same thing (but replaces/filters current line)     
                    读取date的输出 (但是会替换当前行的内容)     
                  # 译释：其实你输入了!!后，vim就自动转换到 :.! 等待你继续输入     
{% endcode %}

# Sorting with external sort     
# 使用外部程序sort进行排序(sort是Unix标准命令，ls,date也是)     
{% code %}
:%!sort -u       : use an external program to filter content     
                    使用sort程序排序整个文件（用结果重写文件）     
                  # 译释：%表示整个文件的所有行     
                  # !sort表示执行外部命令sort     
                  # -u是sort的参数，man sort看看，这个参数的意义是合并相同的行     
                  # u就是unique,如果两行内容相同，则结果中只保留一行的说     
:'a,'b!sort -u   : use an external program to filter content     
                    对mark a 到mark b中间的内容进行排序     
!1} sort -u      : sorts paragraph (note normal mode!!)     
                    排序当前段落 (只能在normal模式下使用!!)     
                  # 译释：!表示使用filter，1}表示filter的对象是从当前行开始向后     
数一段     
                  # 段落指到空行处结束，不包括空行     
                  # 其实你一旦输入 !1}，vim就自动计算当前段落应该到那一行(eg.+     
5)，然后生成     
                  # :.,.+5! 等待之后输入sort -u，回车，完成操作     
                  # .表示当前行，.+5当然就是当前行向后数5行     
{% endcode %}
    
----------------------------------------     
    
# Multiple Files Management (Essential)     
# 多文档操作 (基础)     
{% code %}
:bn              : goto next buffer     
                    跳转到下一个buffer     
:bp              : goto previous buffer     
                    跳转到上一个buffer     
:wn              : save file and move to next (super)     
                    存盘当前文件并跳转到下一个     
:wp              : save file and move to previous     
                    存盘当前文件并跳转到上一个     
:bd              : remove file from buffer list (super)     
                    把这个文件从buffer列表中做掉     
:bun             : Buffer unload (remove window but not from list)     
                    卸掉buffer (关闭这个buffer的窗口但是不把它从列表中做掉)     
:badd file.c     : file from buffer list     
                    把文件file.c添加到buffer列表     
:b 3             : go to buffer 3     
                    跳到第3个buffer     
:b main          : go to buffer with main in name eg main.c (ultra)     
                    跳到一个名字中包含main的buffer,例如main.c     
:sav php.html    : Save current file as php.html and "move" to php.html     
                    把当前文件存为php.html并打开php.html     
:sav! %<.bak  : Save Current file to alternative extension     
                    换一个后缀保存     
:sav! %:r.cfm    : Save Current file to alternative extension     
    
:e!              : return to unmodified file     
                    返回到修改之前的文件(修改之后没有存盘)     
:w c:/aaa/%      : save file elsewhere     
                    把文件存到一个地儿     
:e #             : edit alternative file     
                    编辑标记为#的buffer(这个buffer必须含有一个可编辑的文件)     
                 # 用ls命令就能看到哪一个buffer有#     
                  # %a表示当前正在编辑的buffer     
                  # u 表示不能编辑或者已经被做掉的buffer     
:rew             : return to beginning of editted files list (:args)     
                    回到第一个可编辑的文件     
:brew            : buffer rewind     
                    回到第一个buffer     
:sp fred.txt     : open fred.txt into a split     
                    在一个水平分割的窗口中打开文件fred.txt # 译注：vs fred.txt可     
以实现垂直分割     
:sball,:sb       : Split all buffers (super)     
                    把当前所有含有可编辑文件的buffer显示到一个分割窗口中     
:scrollbind      : in each split window     
:map   <F5> :ls<CR>:e # : Pressing F5 lists all buffer, just type number     
                                 在normal模式下按F5键，则会显示所有含有一个     
                                 可编辑文件的buffer，然后提示你输入buffer的序号，     
                                 输入后回车，则编辑这个buffer     
:set hidden      : Allows to change buffer w/o saving current buffer     
                    允许不保存buffer而切换buffer (w/o=without)     
{% endcode %}
----------------------------------------     
# Quick jumping between splits     
# 在分割窗口中快速切换     
{% code %}
:map <C-J> <C-W>j<C-W>_     
# 这是一个键盘绑定，把Ctrl-J定义成切换到下一个窗口并最大化     
:map <C-K> <C-W>k<C-W>_     
# 这是一个键盘绑定，把Ctrl-K定义成切换到上一个窗口并最大化     
{% endcode %}
    
----------------------------------------     
# Recording (BEST TIP of ALL)     
# 命令录制 (最佳技巧)     
{% code %}
qq  # record to q     
       录制到q     
your complex series of commands  # 输入一系列复杂的指令     
q   # end recording     
       再次按q停止录制     
@q  # to execute     
       执行q中存储的指令     
@@  # to Repeat     
       重复执行     
5@@ # to Repeat 5 times     
       重复执行5遍     
{% endcode %}
    
# editing a register/recording     
# 编辑寄存器/录制     
{% code %}
"qp            :display contents of register q (normal mode)     
                 显示寄存器 q 的内容 (普通模式)     
<ctrl-R>q   :display contents of register q (insert mode)     
                显示寄存器 q 的内容 (插入模式)     
{% endcode %}
    
# you can now see recording contents, edit as required     
# 你现在可以看到记录内容，随便编辑     
{% code %}
"qdd           :put changed contacts back into q     
@q             :execute recording/register q     
                 执行记录/寄存器 q     
{% endcode %}
    
# Operating a Recording on a Visual BLOCK     
# 在可视块中运行记录     
{% code %}
1) define recording/register     
1) 定义记录/寄存器     
qq:s/ to/ from/g^Mq     
2) Define Visual BLOCK     
2) 定义可视块     
V}     
3) hit : and the following appears     
3) 键入 : 将显示下面信息     
:'<,'>     
4)Complete as follows     
4) 完成如下操作     
:'<,'>norm @q     
{% endcode %}
----------------------------------------     
# Visual is the newest and usually the BEST editting mode     
# 可视模式是最新也通常是最好的编辑模式     
# Visual basics     
# 可视模式基础     
{% code %}
v              : enter visual mode     
                  进入可视模式     
V              : visual mode whole line     
                  整行的可视模式     
<C-V>       : enter VISUAL BLOCK mode     
                  进入可视块模式     
gv             : reselect last visual area     
                  重新选取最新的可视区域     
o              : navigate visual area     
                  浏览可视区域     
"*y            : yank visual area into paste buffer     
                  复制可视区域到剪贴板     
V%             : visualise what you match     
                  ???     
V}J            : Join Visual block (great)     
                  连接可视块     
{% endcode %}
    
----------------------------------------     
    
# Delete first 2 characters of 10 successive lines     
# 删除连续10行中每行的头2个字符     
{% code %}
0<c-v>10j2ld     
{% endcode %}
    
----------------------------------------     
    
# how to copy a set of columns using VISUAL BLOCK     
# 如何用可视块拷贝几列     
# visual block (AKA columnwise selection) (NOT BY ordinary v command)     
# 可视块(并非通常的 v 命令)     
{% code %}
<C-V> then select "column(s)" with motion commands (win32 <C-Q>)     
<C-V>，然后通过移动命令选择列 (win32 <C-Q>)     
then c,d,y,r etc     
然后执行 c,d,y,r 等命令     
{% endcode %}
    
----------------------------------------     
# _vimrc essentials     
# _vimrc基础     
{% code %}
:set incsearch : jumps to search word as you type (annoying but excellent)     
                  实时匹配你输入的内容     
:set wildignore=*.o,*.obj,*.bak,*.exe : tab complete now ignores these     
                                         tab键的自动完成现在会忽略这些     
:set shiftwidth=3                     : for shift/tabbing     
                                         自动缩进设为4个字符     
                                       # 译注：一个tab位通常是8个字符     
                                       # 所以，我们还要设定 :set tabstop=4，这     
样，所有的缩进都是4字符了     
:set vb t_vb=".                       : set silent (no beep)     
                                         沉默方式(不要叫beep！)     
:set browsedir=buffer                 : Maki GUI File Open use current directory     
                                         设置 GUI 版本文件打开时，使用当前路径     
{% endcode %}
----------------------------------------     
# launching Win IE     
# 加载 IE 浏览器     
{% code %}
:nmap ,f :update<CR>:silent !start c:\progra~1\intern~1\iexplore.exe file://%:p<CR>     
:nmap ,i :update<CR>: !start c:\progra~1\intern~1\iexplore.exe <cWORD><CR>     
{% endcode %}

 译释：nmap是做一个normal模式下的键盘绑定     
 这里绑定了一个逗号命令 ,f     
 :update是写这个文件，与:w不同，它只有当文件被修改了的时候才写     
 :silent别让弹出窗口报告执行结果     
 !...后面就是执行windows命令了。呵呵，去问bill gates什么意思吧。     
    
----------------------------------------     
    
# FTPing from VIM     
# 用 VIM 通过 ftp 编辑文件     
{% code %}
:cmap ,r  :Nread ftp://209.51.134.122/public_html/index.html     
:cmap ,w  :Nwrite ftp://209.51.134.122/public_html/index.html     
gvim ftp://209.51.134.122/public_html/index.html     
# 译注：cmap是命令(command)模式绑定     
{% endcode %}
    
----------------------------------------     
    
# appending to registers (use CAPITAL)     
# 附加到一个register (用大写的register名字)     
{% code %}
"a5yy   #复制5行到a中     
10j     #下移10行     
"A5yy   #再添加5行到a中     
{% endcode %}
    
----------------------------------------     
    
{% code %}
[I     : show lines matching word under cursor <cword> (super)     
          显示光标处的狭义字可以匹配的行(高级指令)     
        # 译注：# 可以全文查找与光标处的狭义字相匹配的字，     
        # 这在查找函数原型和实现，或者变量使用的时候很有用     
{% endcode %}
    
----------------------------------------     
    
# Conventional Shifting/Indenting     
# 常规缩进     
{% code %}
:'a,'b>>   # 把mark a到mark b之间的内容缩进两次     
{% endcode %}

# visual shifting (builtin-repeat)     
# 在visual模式下缩进 (无限可重复)     
{% code %}
:vnoremap < <gv     
# 译释：:vnoremap 重定义了visual模式下 < 符号的含义     
# 把它定义成 <gv     
# 即：先<向外缩进，然后gv重新选择上一次选择了的区域     
# 这样在visual模式下就可以实现连续按<而连续缩进了     
:vnoremap > >gv     
# 同里，内缩     
{% endcode %}
    
# Block shifting (magic)     
# 块缩进     
{% code %}
 >i{     
 >a{     
# also     
 >% and <%     
{% endcode %}
----------------------------------------     
# Redirection & Paste register *     
# 重定向到剪贴板和从剪贴板粘贴     
{% code %}
:redir @*                    : redirect commands to paste buffer     
                                重定向命令的输出结果（最下方命令行上的结果）     
:redir END                   : end redirect     
                                结束重定向     
:redir >> out.txt            : redirect to a file     
                                重定向到一个文件     
{% endcode %}

# Working with Paste buffer     
# 操作剪贴板     
{% code %}
"*yy                         : yank to paste     
                                复制到剪贴板中     
"*p                          : insert from paste buffer     
                                从剪贴板中粘贴     
{% endcode %}

# yank to paste buffer (ex mode)     
# 拷贝到剪贴板 (ex 模式)     
{% code %}
:'a,'by*                     : Yank range into paste     
                                把标记a到标记b见的内容拷贝到剪贴板     
:%y*                         : Yank whole buffer into paste     
                                把整个文件拷贝到剪贴板     
{% endcode %}

# filter non-printable characters from the paste buffer     
# 从剪贴板上过滤非可打印字符     
# useful when pasting from some gui application     
# 当从一些 GUI 程序粘贴时会有用处     
{% code %}
:nmap <leader>p :let @* = substitute(@*,'[^[:print:]]','','g')<cr>"*p     
{% endcode %}
----------------------------------------     

# Re-Formatting text     
# 重新格式化文本     
{% code %}
gq}                          : Format a paragraph     
                                格式化一个段落     
ggVGgq                       : Reformat entire file     
                                重新格式化整个文件     
Vgq                          : current line     
                                格式化当前行     
{% endcode %}

# break lines at 70 chars, if possible after a ;     
# 在70列的时候换行     
{% code %}
:s/.\{,69\};\s*\|.\{,69\}\s\+/&\r/g     
{% endcode %}
----------------------------------------     

# Operate command over multiple files     
# 对多个文档实施命令     
{% code %}
:argdo %s/foo/bar/e          : operate on all files in :args     
                                对所有:args列表中的文档执行命令     
:bufdo %s/foo/bar/e     
:windo %s/foo/bar/e     
:argdo exe '%!sort'|w!       : include an external command     
                                使用外部命令     
:bufdo /foo/     
{% endcode %}
----------------------------------------     

# Command line tricks     
# 命令行上的技巧     
{% code %}
gvim -h                    : help     
                              启动帮助     
ls | gvim -                : edit a stream!!     
                              编辑一个数据流     
cat xx | gvim - -c "v/^\d\d\|^[3-9]/d " : filter a stream     
gvim -o file1 file2        : open into a split     
                              以分割窗口打开两个文件     
{% endcode %}
    
# execute one command after opening file     
# 指出打开之后执行的命令     
{% code %}
gvim.exe -c "/main" joe.c  : Open joe.c & jump to "main"     
{% endcode %}
    
# execute multiple command on a single file     
# 对一个文件执行多个命令     
{% code %}
vim -c "%s/ABC/DEF/ge | update" file1.c     
{% endcode %}
    
# execute multiple command on a group of files     
# 对一组文件执行多个命令     
{% code %}
vim -c "argdo %s/ABC/DEF/ge | update" *.c     
{% endcode %}
    
# remove blocks of text from a series of files     
# 从一组文件中删除文本块     
{% code %}
vim -c "argdo /begin/+1,/end/-1g/^/d | update" *.c     
{% endcode %}
    
# Automate editting of a file (Ex commands in convert.vim)     
# 自动编辑文件 (编辑命令序列Ex commands已经包含在convert.vim中了)     
{% code %}
vim -s "convert.vim" file.c     
{% endcode %}
    
#load VIM without .vimrc and plugins (clean VIM)     
# 不要加载.vimrc和任何plugins (启动一个干净的VIM)     
{% code %}
gvim -u NONE -U NONE -N     
{% endcode %}
    
# Access paste buffer contents (put in a script/batch file)     
# 读取剪贴板内容 (放到脚本或批处理文件中)     
{% code %}
gvim -c 'normal ggdG"*p' c:/aaa/xp     
{% endcode %}
    
# print paste contents to default printer     
# 把剪贴板内容打印到默认打印机     
{% code %}
gvim -c 's/^/\=@*/|hardcopy!|q!'     
{% endcode %}
----------------------------------------     
# GVIM Difference Function (Brilliant)     
{% code %}
gvim -d file1 file2        : vimdiff (compare differences)     
                              vimdiff (比较不同)     
dp                         : "put" difference under cursor to other file     
                              把光标处的不同放到另一个文件     
do                         : "get" difference under cursor from other file     
                              在光标处从另一个文件取得不同     
{% endcode %}
----------------------------------------     
# Vim traps     
# Vim陷阱     
{% code %}
In regular expressions you must backslash + (match 1 or more)     
In regular expressions you must backslash | (or)     
In regular expressions you must backslash ( (group)     
In regular expressions you must backslash { (count)     
# 在vim的正则表达式中， + | ( { 前都必须加转义符 \     
/fred\+/                   : matches fred/freddy but not free     
                              匹配fred或freddy但是不匹配free     
/\(fred\)\{2,3}/           : note what you have to break     
                              ???     
{% endcode %}
----------------------------------------     
# \v or very magic (usually) reduces backslashing     
# \v ，或叫做very magic (通常都是这么叫)可以取消转义符     
{% code %}
/codes\(\n\|\s\)*where  : normal regexp     
                           普通的正则表达式     
/\vcodes(\n|\s)*where   : very magic     
{% endcode %}
----------------------------------------     
# pulling objects onto command/search line (SUPER)     
# 把东西送到命令行/搜索行 (SUPER)     
{% code %}
<C-R><C-W> : pull word under the cursor into a command line or search     
                    送一个狭义词     
<C-R><C-A> : pull WORD under the cursor into a command line or search     
                    送一个广义词     
<C-R>-                  : pull small register (also insert mode)     
                             送一个小型寄存器 (插入模式下也有效)     
<C-R>[0-9a-z]           : pull named registers (also insert mode)     
                              送一个命名寄存器 (插入模式下也有效)     
<C-R>%                  : pull file name (also #) (also insert mode)     
                              送文件名过去 (#也行) (插入模式下也有效)     
{% endcode %}
----------------------------------------     
# manipulating registers     
# 操作寄存器     
{% code %}
:let @a=@_              : clear register a     
                           清空寄存器a     
:let @a=""              : clear register a     
                           同上     
:let @*=@a              : copy register a to paste buffer     
                           拷贝寄存器 a 的内容到剪贴板     
map   <f11> "qyy:let @q=@q."zzz"     
{% endcode %}
    
----------------------------------------     
    
# help for help     
# 关于帮助的帮助     
{% code %}
:h quickref             : VIM Quick Reference Sheet (ultra)     
                           VIM 快速参考手册 (ultra)     
:h tips                 : Vim's own Tips Help     
                           Vim自己的tips     
:h visual<C-D><tab>     : obtain  list of all visual help topics     
                                得到一个关于visual关键字的帮助列表     
                         : Then use tab to step thru them     
                        : 然后用tab键去选择     
:h ctrl<C-D>         : list help of all control keys     
                           显示所有关于Ctrl的帮助     
:helpg uganda           : Help grep     
                           显示 grep 帮助     
:h :r                   : help for :ex command     
                           :ex冒号命令     
:h CTRL-R               : normal mode     
                           普通模式命令     
:h /\r                  : what's \r in a regexp (matches a <CR>)     
                           \r在正则表达式中是什么意思呢？     
:h \\zs                 : double up backslash to find \zs in help     
:h i_CTRL-R             : help for say <C-R> in insert mode     
                           insert模式下的Ctrl-R     
:h c_CTRL-R             : help for say <C-R> in command mode     
                           命令行(command-line)模式下的Ctrl-R     
:h v_CTRL-V             : visual mode     
                           visual模式下的Ctrl-V     
:h tutor                : VIM Tutor     
                           VIM 指南     
<C-[>, <C-T>      : Move back & Forth in HELP History     
                           在帮助历史中，向前/后移动     
gvim -h                 : VIM Command Line Help     
                           关于 VIM 命令的帮助     
{% endcode %}
----------------------------------------     
# where was an option set     
# 选项设置在哪里？     
{% code %}
:scriptnames            : list all plugins, _vimrcs loaded (super)     
                           列出所有加载的 plugins, _vimrcs     
:verbose set history?   : reveals value of history and where set     
                           显示history的值并指出设置文件的位置     
:function               : list functions     
                           列出所有函数     
:func SearchCompl       : List particular function     
                          列出指定的函数     
{% endcode %}
    
----------------------------------------     
    
# making your own VIM help     
# 制作你自己的VIM帮助     
{% code %}
:helptags /vim/vim63/doc  : rebuild all *.txt help files in /doc     
                             重建 /doc 中所有的 *.txt 帮助文件     
:help add-local-help     
{% endcode %}
    
----------------------------------------     
# running file thru an external program (eg php)     
# 用外部程序来运行程序 (例如 php)     
{% code %}
map   <f9>   :w<CR>:!c:/php/php.exe %<CR>     
map   <f2>   :w<CR>:!perl -c %<CR>     
{% endcode %}
----------------------------------------     
# capturing output of current script in a separate buffer     
# 在另一个buffer中，捕捉当前脚本的输出     
{% code %}
:new | r!perl #                   : opens new buffer,read other buffer     
                                     新建一个buffer，从另一个buffer中读入结果     
:new! x.out | r!perl #            : same with named file     
                                    同上，并指定一个新文件名     
{% endcode %}
    
----------------------------------------     
    
# Inserting DOS Carriage Returns     
# 插入DOS换行符     
{% code %}
:%s/nubian/<C-V><C-M>&/g          :  that's what you type     
:%s/nubian/<C-Q><C-M>&/g          :  for Win32     
                                            对于Win32应该这样     
dn_t ... @yahoo.ca     
:%s/nubian/^M&/g                  :  what you'll see where ^M is ONE character     
                                      你看到的^M是一个字符     
:%s/nubian/\r&/g                  :  better     
                                      更好的形式     
{% endcode %}
    
----------------------------------------     
    
# automatically delete trailing Dos-returns,whitespace     
# 自动删除行尾 Dos回车符和空格     
{% code %}
autocmd BufRead * silent! %s/[\r \t]\+$//     
autocmd BufEnter *.php :%s/[ \t\r]\+$//e     
{% endcode %}
----------------------------------------     
# perform an action on a particular file or file type     
# 对指定文件或文件类型执行某个动作     
{% code %}
autocmd VimEnter c:/intranet/note011.txt normal! ggVGg?     
autocmd FileType *.pl exec('set fileformats=unix')     
{% endcode %}
----------------------------------------     

# Retrieving last command line command for copy & pasting into text     
# 把最后一个命令贴到当前位置     
{% code %}
i<c-r>:     
{% endcode %}

# Retrieving last Search Command for copy & pasting into text     
# 把最后一个搜索指令贴到当前位置     
{% code %}
i<c-r>/     
{% endcode %}

 译释：i是进入insert模式，     
 Ctrl-r是开启插入模式下register的引用     
 :和/分别引用了两个register的内容     
----------------------------------------     

# more completions     
# 更多的完成功能     
{% code %}
<C-X><C-F>     :insert name of a file in current directory     
                      插入当前目录下的一个文件名到当前位置     
{% endcode %}

# 在insert模式下使用     
# 然后用 Ctrl-P/Ctrl-N 翻页     
    
----------------------------------------     

# Substituting a Visual area     
# 替换一个visual区域     
# select visual area as usual (:h visual) then type :s/Emacs/Vim/ etc     
# 选择一个区域，然后输入 :s/Emacs/Vim/ 等等，vim会自动进入:模式     
{% code %}
:'<,'>s/Emacs/Vim/g               : REMEMBER you dont type the '<.'>     
                                        前面的'<,'>是vim自动添加的     
gv                                : Re-select the previous visual area (ULTRA)     
                                     重新选择前一个可视区域 (ULTRA)     
{% endcode %}
----------------------------------------     

# inserting line number into file     
# 在文件中插入行号     
{% code %}
:g/^/exec "s/^/".strpart(line(".")."    ", 0, 4)     
:%s/^/\=strpart(line(".")."     ", 0, 5)     
:%s/^/\=line('.'). ' '     
{% endcode %}
----------------------------------------     

#numbering lines VIM way     
# 用VIM的方式来编号行     
{% code %}
:set number                       : show line numbers     
                                     显示行号     
:map <F12> :set number!<CR>       : Show linenumbers flip-flop     
:%s/^/\=strpart(line('.')."        ",0,&ts)     
    
{% endcode %}

#numbering lines (need Perl on PC) starting from arbitrary number     
#从任意行开始编号(需要perl)     
{% code %}
:'a,'b!perl -pne 'BEGIN{$a=223} substr($_,2,0)=$a++'     
{% endcode %}
    
# Produce a list of numbers     
# 产生数字列表     
#Type in number on line say 223 in an empty file     
{% code %}
qqmnYP`n^Aq                       : in recording q repeat with @q     
{% endcode %}

# increment existing numbers to end of file (type <c-a> as 5 characters)     
# 递增已存在数字到文件末     
{% code %}
:.,$g/^\d/exe "normal! \<c-a>"     
{% endcode %}

# advanced incrementing     
# 高级递增，参见：     
http://vim.sourceforge.net/tip_view.php?tip_id=150     

----------------------------------------     

# advanced incrementing (really useful)     
# 高级递增 (真的很有用)     
{% code %}
" put following in _vimrc     
" 把下面几句放到 _vimrc #vimrc脚本用 " 做行注释符     
let g:I=0     
function! INC(increment)     
let g:I =g:I + a:increment     
return g:I     
endfunction     
" eg create list starting from 223 incrementing by 5 between markers a,b     
" 例如从mark a 到mark b 递增，从223开始，步长为5     
:let I=223     
:'a,'bs/^/\=INC(5)/     
" create a map for INC     
cab viminc :let I=223 \| 'a,'bs/$/\=INC(5)/     
{% endcode %}

----------------------------------------     

# editing/moving within current insert (Really useful)     
# 在当前插入模式下编辑/移动 (真得很有用)     
{% code %}
<C-U>                             : delete all entered     
                                        删除全部     
<C-W>                             : delete last word     
                                        删除最后一个单词     
<HOME><END>                       : beginning/end of line     
                                           移动到行首/行尾     
<C-LEFTARROW><C-RIGHTARROW>       : jump one word backwards/forwards     
                                           向前/后移动一个单词     
<C-X><C-E>,<C-X><C-Y>             : scroll while staying put in insert     
{% endcode %}

----------------------------------------     

#encryption (use with care: DON'T FORGET your KEY)     
# 加密(小心使用，不要忘了密码)     
{% code %}
:X                                : you will be prompted for a key     
                                     vim会提示你输入密码     
:h :X     
{% endcode %}

----------------------------------------     

# modeline (make a file readonly etc) must be in first/last 5 lines     
# 模式行 (使文件只读等)，必须在前/后 5行内     
{% code %}
// vim:noai:ts=2:sw=4:readonly:     
# vim:ft=html:                    : says use HTML Syntax highlighting     
                                     使用 HTML 语法高亮     
:h modeline     
{% endcode %}

----------------------------------------     

# Creating your own GUI Toolbar entry     
# 建立你自己的菜单项     
{% code %}
amenu  Modeline.Insert\ a\ VIM\ modeline <Esc><Esc>ggOvim:ff=unix ts=4     
ss=4<CR>vim60:fdm=marker<esc>gg     
{% endcode %}
    
----------------------------------------     
    
# A function to save word under cursor to a file     
# 一个保存当前光标下的狭义字到一个文件的函数     
{% code %}
function! SaveWord()     
    normal yiw     
    exe ':!echo '.@0.' >> word.txt'     
endfunction     
map ,p :call SaveWord()     
{% endcode %}
    
----------------------------------------     
    
# function to delete duplicate lines     
# 删除重复行的函数     
{% code %}
function! Del()     
  if getline(".") == getline(line(".") - 1)     
    norm dd     
  endif     
endfunction     
    
:g/^/ call Del()  #使用该函数的一个例子     
{% endcode %}
    
----------------------------------------     
    
# Digraphs (non alpha-numerics)     
# 双字节编码 (non alpha-numerics)     
{% code %}
:digraphs                         : display table     
                                     显示编码表     
:h dig                            : help     
                                     帮助     
i<C-K>e'                          : enters     
                                        输入 é     
i<C-V>233                         : enters (Unix)     
                                       输入 é (Unix)     
i<C-Q>233                         : enters (Win32)     
                                        输入 é (Win32)     
ga                                : View hex value of any character     
                                     查看字符的hex值     
{% endcode %}
    
# Deleting non-ascii characters (some invisible)     
# 删除非 ascii 字符     
{% code %}
:%s/[<C-V>128-<C-V>255]//gi       : where you have to type the Control-V     
:%s/[€- ]//gi                     : Should see a black square & a dotted y     
:%s/[<C-V>128-<C-V>255<C-V>01-<C-V>31]//gi : All pesky non-asciis     
:exec "norm /[\x00-\x1f\x80-\xff]/"        : same thing     
#Pull a non-ascii character onto search bar     
yl/<C-R>"                         :     
{% endcode %}
----------------------------------------     
# All file completions grouped (for example main_c.c)     
# 文件名自动完成 (例如 main_c.c)     
{% code %}
:e main_<tab>                     : tab completes     
                                        tab 键完成     
gf                                : open file under cursor  (normal)     
                                     打开光标处广义字命名的文件 (normal模式)     
main_<C-X><C-F>                   : include NAME of file in text (insert mode)     
                                           文件名自动完成(insert模式)     
{% endcode %}
----------------------------------------     
# Complex Vim     
# Vim复杂使用     
# swap two words     
# 交换两个单词     
{% code %}
:%s/\<\(on\|off\)\>/\=strpart("offon", 3 * ("off" == submatch(0)), 3)/g     
{% endcode %}
# swap two words     
# 交换两个单词     
{% code %}
:vnoremap <C-X> <Esc>`.``gvP``P     
{% endcode %}
----------------------------------------     
# Convert Text File to HTML     
# 把text文件转换成html文件(oh,ft)     
{% code %}
:runtime! syntax/2html.vim        : convert txt to html     
                                    转换 txt 成 html     
:h 2html     
{% endcode %}
----------------------------------------     
# VIM has internal grep     
# VIM 有一个内部自带的 grep 命令     
{% code %}
:grep some_keyword *.c            : get list of all c-files containing keyword     
                                     得到一个包含some_keyword的c文件名列表     
:cn                               : go to next occurrence     
                                     去下一个出现的位置     
{% endcode %}
----------------------------------------     
# Force Syntax coloring for a file that has no extension .pl     
# 强制无扩展名的文件的语法着色方式     
{% code %}
:set syntax=perl     
{% endcode %}
# Remove syntax coloring (useful for all sorts of reasons)     
# 取消语法着色 (很有用)     
{% code %}
:set syntax off     
{% endcode %}
# change coloring scheme (any file in ~vim/vim??/colors)     
# 改变色彩主题 (在~vim/vim??/colors中的任何文件)     
{% code %}
:colorscheme blue     
{% endcode %}
# Force HTML Syntax highlighting by using a modeline     
# 通过使用模式行强迫使用 HTML 语法高亮     
# vim:ft=html:     
----------------------------------------     
{% code %}
:set noma (non modifiable)        : Prevents modifications     
                                     防止修改     
:set ro (Read Only)               : Protect a file from unintentional writes     
                                     只读保护     
{% endcode %}
----------------------------------------     
# Sessions (Open a set of files)     
# 对话 (打开一堆文件)     
{% code %}
gvim file1.c file2.c lib/lib.h lib/lib2.h : load files for "session"     
                                            在"对话"中加载这些文件     
:mksession                        : Make a Session file (default Session.vim)     
                                     生成一个Session文件 (默认是Session.vim)     
:q     
gvim -S Session.vim               : Reload all files     
                                     重新加载所有文件     
{% endcode %}
----------------------------------------     
# tags (jumping to subroutines/functions)     
# 标记(tags) (跳转到子程序/函数)     
{% code %}
taglist.vim                       : popular plugin     
                                     很流行的插件     
:Tlist                            : display Tags (list of functions)     
                                     显示标记 (函数列表)     
<C-]>                             : jump to function under cursor     
                                        跳转到光标处的函数     
{% endcode %}
----------------------------------------     
# columnise a csv file for display only as may crop wide columns     
{% code %}
:let width = 20     
:let fill=' ' | while strlen(fill) < width | let fill=fill.fill | endwhile     
:%s/\([^;]*\);\=/\=strpart(submatch(1).fill, 0, width)/ge     
:%s/\s\+$//ge     
{% endcode %}
# Highlight a particular csv column (put in .vimrc)     
{% code %}
function! CSVH(x)     
     execute 'match Keyword /^\([^,]*,\)\{'.a:x.'}\zs[^,]*/'     
     execute 'normal ^'.a:x.'f,'     
endfunction     
command! -nargs=1 Csv :call CSVH(<args>)     
{% endcode %}
# call with     
{% code %}
:Csv 5                             : highlight fith column     
{% endcode %}
----------------------------------------     
# folding : hide sections to allow easier comparisons     
# 折叠：隐藏某些片断，是查看更容易     
{% code %}
zf}                               : fold paragraph using motion     
                                     使用动作命令折叠一个段落     
v}zf                              : fold paragraph using visual     
                                     使用可视模式折叠一个段落     
zf'a                              : fold to mark     
                                     折叠到一个标记上     
zo                                : open fold     
                                     打开折叠     
zc                                : re-close fold     
                                     重新关闭折叠     
{% endcode %}
----------------------------------------     
# displaying "invisible characters"     
# 显示"不可见字符"     
{% code %}
:set list     
:h listchars     
{% endcode %}
----------------------------------------     
# How to paste "normal commands" w/o entering insert mode     
# 如何在不进入插入模式的情况下粘贴"普通模式的命令"     
{% code %}
:norm qqy$jq     
{% endcode %}
----------------------------------------     
# manipulating file names     
# 处理文件名     
{% code %}
:h filename-modifiers             : help     
                                     帮助     
:w %                              : write to current file name     
                                     写入当前文件     
:w %:r.cfm                        : change file extention to .cfm     
                                     改变文件扩展名为 .cfm     
:!echo %:p                        : full path & file name     
                                     显示完整路径和文件名     
:!echo %:p:h                      : full path only     
                                     只显示完整路径     
<C-R>%                            : insert filename (insert mode)     
                                        插入文件名 (插入模式)     
"%p                               : insert filename (normal mode)     
                                    插入文件名 (普通模式)     
/<C-R>%                           : Search for file name in text     
                                        在文本中查找文件名     
{% endcode %}
----------------------------------------     
# delete without destroying default buffer contents     
# 删除，但不破坏 buffer 内容     
{% code %}
"_d                               : what you've ALWAYS wanted     
                                     你一直想要的东西     
"_dw                              : eg delete word (use blackhole)     
                                     例如：删除一个单词 (使用黑洞???)     
{% endcode %}
----------------------------------------     
# pull full path name into paste buffer for attachment to email etc     
# 送完整的路径名到剪贴板，用于邮件附件等     
{% code %}
nnoremap <F2> :let @*=expand("%:p")<cr> :unix     
nnoremap <F2> :let @*=substitute(expand("%:p"), "/", "\\", "g")<cr> :win32     
{% endcode %}
----------------------------------------     
# Simple Shell script to rename files w/o leaving vim     
# 不用离开 Vim 就能修改文件名的简单 shell 脚本     
{% code %}
$ vim     
:r! ls *.c     
:%s/\(.*\).c/mv & \1.bla     
:w !sh     
:q!     
{% endcode %}
----------------------------------------     
# count words in a text file     
# 在一个文本里计算单词数     
{% code %}
g<C-G>     
{% endcode %}
----------------------------------------     
# example of setting your own highlighting     
# 你自己设置高亮显示的例子     
{% code %}
:syn match DoubleSpace "  "     
:hi def DoubleSpace guibg=#e0e0e0     
{% endcode %}
----------------------------------------     
# Programming keys depending on file type     
# 根据文件类型映射快捷键     
{% code %}
:autocmd bufenter *.tex map <F1> :!latex %<CR>     
:autocmd bufenter *.tex map <F2> :!xdvi -hush %<.dvi&<CR>     
{% endcode %}
----------------------------------------     
# reading Ms-Word documents, requires antiword     
# 读取 MS-Word 文档，需要 antiword     
{% code %}
:autocmd BufReadPre *.doc set ro     
:autocmd BufReadPre *.doc set hlsearch!     
:autocmd BufReadPost *.doc %!antiword "%"     
{% endcode %}
----------------------------------------     
# Just Another Vim Hacker JAVH     
{% code %}
vim -c ":%s%s*%Cyrnfr)fcbafbe[Oenz(Zbbyranne%|:%s)[[()])-)Ig|norm Vg?"     
{% endcode %}
 译释：呵呵，谁来解释一下吧！     
 其实不过是在启动vim的时候执行了一个命令     
 先写入了 Just Another Vim Hacker 的rot13编码     
 然后再解码     

----------------------------------------     
__END__     
