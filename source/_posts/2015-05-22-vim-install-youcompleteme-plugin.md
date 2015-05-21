title: Vim 自动补全插件 YouCompleteMe 安装与配置
date: 2015-05-22 20:31:12
tags: Vim
categories: Vim
description: Vim 自动补全；Vim YouCompleteMe 安装；Vim YouCompleteMe 配置；
---

## 概述

对于代码自动补全，之前一直使用的是Shougo/neocomplcache和Shougo/neosnippet。早就听说过YouCompleteMe的大名，一直想尝试一下YCM，但是还是拖到了现在。YCM和其它Vim插件的安装有些不同，可能需要折腾一下。之所以安装稍微会麻烦些，是因为YCM 后端调用 libclang(以获取AST,当然还有其他语言的语义分析库)、前端由 C++ 开发(以提升补全效率)、外层由 python 封装(以成为 vim 插件),它可能是安装最复杂的 vim 插件了。YCM是Client-sever架构的，Vim这部分的YCM只是很小的一个客户端，与具有大量逻辑和功能的ycmd HTTP+JSON交互。server在你开启或关闭Vim是自动开启或关闭。

其它自动补全的插件基本上是基于文本的，也就是说它们基本上是使用正则去猜。区别于其它Vim的自动补全插件，YCM基于语义引擎（比如C家族的libclang）提供了语义补全，是通过分析源文件，经过语法分析之后进行补全。对于C家族的语言这种基于语义的自动补全依赖于clang/llvm，其他语言 ,会调用vim设置的omnifunc来匹配，可以查看[github](https://github.com/Valloric/YouCompleteMe#semantic-completion-for-other-languages)

* Java/Ruby [eclim](http://eclim.org/)
* Python [Jedi](https://github.com/davidhalter/jedi)
* Go [Gocode](https://github.com/nsf/gocode)
* C# [OmniSharp](https://github.com/nosami/OmniSharpServer)
* JavaScript [Tern for Vim](https://github.com/marijnh/tern_for_vim)

YCM不是基于前缀补全的，而是子序列，所以输入 abc 可以补全 xaybgc，它对于大小写的补全也非常智能。对于C家族的语言和Python支持跳转到定义处。此外还可以对文件路径进行补全，和ultisnips也很好结合。

<!-- more -->

## 安装

### 完全安装

**如果用Vundle更新YCM，yum_support_lib库API改变了，YCM会提醒你重新编译它。**

1. 确保Vim版本至少是7.3.584，并且支持python2脚本。

    在Vim中输入`:version`可以查看版本。如果版本已经高于7.4了，那么OK。版本是7.3。那么继续往下看，看到`包含版本:1-Z`，如果Z小于584就需要重装了。Ubuntu的话可以通过[PPA](http://linuxg.net/how-to-install-vim-7-4-on-ubuntu-13-10-13-04-12-04-linux-mint-16-15-13-and-debian-sid/)安装高版本的。否则就要从源码编译安装了。
    查看是否支持python2：进入vim,命令:echo has('python')，输出为1,则表示支持。如果为0,则需要重新编译安装vim，在编译时添加python支持。

2. 通过Vundle安装YCM，在你的vimrc中添加`Plugin 'Valloric/YouCompleteMe'`，然后执行`:PluginInstall`

3. 如果不需要对C家族的语言进行语义补全支持，则跳过这一步。

    下载最新版的libclang。Clang是一个开源编译器，能够编译C/C++/Objective-C/Objective-C++。Clang提供的libclang库是用于驱动YCM对这些语言的语义补全支持。YCM需要版本至少为3.6的libclang，但是理论上3.2+版本也行。也可以使用系统libclang，如果确定是3.3版本或者更高。推荐下载<llvm.org>官网的[二进制文件](http://llvm.org/releases/download.html)。确保选对适合自己系统的包。

4. 编译YCM需要的ycm_support_libs库。YCM的C++引擎通过这些库来获取更快的补全速度。
    需要cmake，如果未安装，安装之：`sudo apt-get install build-essential cmake`（也可以下载安装<http://www.cmake.org/cmake/resources/software.html>）。确保python头文件已安装：`sudo apt-get install python-dev`。假设你已经通过Vundle装好YCM了，那么它应该位于`~/.vim/bundle/YouCompleteMe`。我们新建一个目录用来放置编译文件，并切换到此目录下`cd ~;mkdir ycm_build;cd ycm_build;`
    下一步生成makefile，这一步很重要，有点复杂。
    * 如果不需要C族语言的语义支持，在ycm_build目录下执行：`cmake -G "Unix Makefiles" . ~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp`
    * 如果需要C族语言的语义支持，还得分几种情况：
        * 假如你从llvm的官网下载了LLVM+Clang，然后解压到：~/ycm_temp/llvm_root_dir （该目录下有 bin, lib, include 等文件夹），然后执行：`cmake -G "Unix Makefiles" -DPATH_TO_LLVM_ROOT=~/ycm_temp/llvm_root_dir . ~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp`
        * 如果想用系统的libclang：`cmake -G "Unix Makefiles" -DUSE_SYSTEM_LIBCLANG=ON . ~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp`
        * 如果想用自定义的libclang：`cmake -G "Unix Makefiles" -DEXTERNAL_LIBCLANG_PATH=/path/to/libclang.so . ~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp`。/path/to/libclang.so这部分填入你自己的路径。
    makefiles生成后执行：`make ycm_support_libs`

我是从llvm网站下载的二进制文件，安装的，安装过程中也没遇到什么问题。

### Ubuntu Linux X64 超快安装

最好还是完整安装，这种快速安装未必适合所有人。安装之前，同样也要确定满足以上所述的vim版本、python支持等条件。和上面一样使用Vundle安装YCM，安装CMake和python头文件。

编译YCM，如果需要对C-family的语义支持：
```
cd ~/.vim/bundle/YouCompleteMe
./install.sh --clang-completer
```
如果不需要对C-family的语义支持：
```
cd ~/.vim/bundle/YouCompleteMe
./install.sh
```
如果需要支持C#，添加 `--omnisharp-complete`。如果需要支持Go添加`--gocode-completer`

## 配置

YCM使用TAB键接受补全，一直按TAB则会循环所有的匹配补全项。shift+TAB则会反向循环。注意：如果使用控制台Vim（非GVim或MacVim等），控制台不会将shift+Tab传递给Vim，因此会无反应，需要重新映射按键。此外，如果同时使用ultisnaps，可能会有冲突，需要进行一些设置。可以使用Ctrl+Space来触发补全，不过会和输入法冲突，也需要设置。

YCM会寻找当前打开的文件的同级目录下或上级目录中的`ycm_extra_conf.py`这个文件，找到后会加载为Python模块，且只加载一次。YCM调用该模块中的FlagsForFile方法。该模块必须提供带有编译当前文件的必要信息的这个方法。需要修改`.ycm_extra_conf.py`文件中的flags部分，使用-isystem添加系统的头文件进行解析，使用-I添加第三方的头文件进行解析，在flags部分后添加如下内容：

```
'-isystem',
'/usr/include',
```

使用命令`:YcmDiags`可以打开location-list查看警告和错误信息。

```
set completeopt=longest,menu	"让Vim的补全菜单行为与一般IDE一致(参考VimTip1228)
autocmd InsertLeave * if pumvisible() == 0|pclose|endif	"离开插入模式后自动关闭预览窗口
inoremap <expr> <CR>       pumvisible() ? "\<C-y>" : "\<CR>"	"回车即选中当前项
"上下左右键的行为 会显示其他信息
inoremap <expr> <Down>     pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <expr> <Up>       pumvisible() ? "\<C-p>" : "\<Up>"
inoremap <expr> <PageDown> pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<PageDown>"
inoremap <expr> <PageUp>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<PageUp>"
" 跳转到定义处
nnoremap <leader>jd :YcmCompleter GoToDefinitionElseDeclaration<CR>
nnoremap <F6> :YcmForceCompileAndDiagnostics<CR>	"force recomile with syntastic
" nnoremap <leader>lo :lopen<CR>	"open locationlist
" nnoremap <leader>lc :lclose<CR>	"close locationlist
inoremap <leader><leader> <C-x><C-o>

let g:ycm_global_ycm_extra_conf = '~/.vim/data/ycm/.ycm_extra_conf.py'
" 不显示开启vim时检查ycm_extra_conf文件的信息  
let g:ycm_confirm_extra_conf=0
" 开启基于tag的补全，可以在这之后添加需要的标签路径  
let g:ycm_collect_identifiers_from_tags_files=1
"注释和字符串中的文字也会被收入补全
let g:ycm_collect_identifiers_from_comments_and_strings = 0
" 输入第2个字符开始补全
let g:ycm_min_num_of_chars_for_completion=2
" 禁止缓存匹配项,每次都重新生成匹配项
let g:ycm_cache_omnifunc=0
" 开启语义补全
let g:ycm_seed_identifiers_with_syntax=1	
"在注释输入中也能补全
let g:ycm_complete_in_comments = 1
"在字符串输入中也能补全
let g:ycm_complete_in_strings = 1
" 设置在下面几种格式的文件上屏蔽ycm
let g:ycm_filetype_blacklist = {
      \ 'tagbar' : 1,
      \ 'nerdtree' : 1,
      \}
"youcompleteme  默认tab  s-tab 和 ultisnips 冲突
let g:ycm_key_list_select_completion = ['<Down>']
let g:ycm_key_list_previous_completion = ['<Up>']
" 修改对C函数的补全快捷键，默认是CTRL + space，修改为ALT + ;
let g:ycm_key_invoke_completion = '<M-;>'

" SirVer/ultisnips 代码片断
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
let g:UltiSnipsListSnippets="<c-e>"
"定义存放代码片段的文件夹，使用自定义和默认的，将会的到全局，有冲突的会提示
let g:UltiSnipsSnippetDirectories=["bundle/vim-snippets/UltiSnips"]

" 参考https://github.com/Valloric/YouCompleteMe/issues/36#issuecomment-62941322
" 解决ultisnips和ycm tab冲突，如果不使用下面的办法解决可以参考
" https://github.com/Valloric/YouCompleteMe/issues/36#issuecomment-63205056的配置
" begin
" let g:ycm_key_list_select_completion=['<C-n>', '<Down>']
" let g:ycm_key_list_previous_completion=['<C-p>', '<Up>']
" let g:UltiSnipsExpandTrigger="<Tab>"
" let g:UltiSnipsJumpForwardTrigger="<Tab>"                                           
" let g:UltiSnipsJumpBackwardTrigger="<S-Tab>"
" end
" UltiSnips completion function that tries to expand a snippet. If there's no
" snippet for expanding, it checks for completion window and if it's
" shown, selects first element. If there's no completion window it tries to
" jump to next placeholder. If there's no placeholder it just returns TAB key 
function! g:UltiSnips_Complete()
    call UltiSnips#ExpandSnippet()
    if g:ulti_expand_res == 0
        if pumvisible()
            return "\<C-n>"
        else
            call UltiSnips#JumpForwards()
            if g:ulti_jump_forwards_res == 0
               return "\<TAB>"
            endif
        endif
    endif
    return ""
endfunction

au BufEnter * exec "inoremap <silent> " . g:UltiSnipsExpandTrigger . " <C-R>=g:UltiSnips_Complete()<cr>"

" Expand snippet or return
let g:ulti_expand_res = 1
function! Ulti_ExpandOrEnter()
    call UltiSnips#ExpandSnippet()
    if g:ulti_expand_res
        return ''
    else
        return "\<return>"
endfunction

" Set <space> as primary trigger
inoremap <return> <C-R>=Ulti_ExpandOrEnter()<CR>
```

## YCM & Eclim

YCM配合Eclim可以实现对Java代码的自动提示，首先需要下载[Eclim](http://eclim.org/install.html)，下载好后执行`java -jar eclim_2.4.1.jar`，卸载的话，后面再加个参数`uninstaller`就行。按提示一步步安装就好了，安装好后首先要启动eclimd，它存放在eclipse的根目录下。

对不同的自动补全插件eclim都提供了[配置方法](http://eclim.org/vim/code_completion.html)，对于YCM我们只需要在vimrc中添加一行`let g:EclimCompletionMethod = 'omnifunc'`就可以了。

打开vim执行`:ProjectCreate /path/to/project -n java`创建一个新的工程。这个工程的结构和eclipse类似。`:ProjectList`命令可以查看工程列表。

这个插件很有意思，可以在eclipse中嵌入vim，又可以在vim中享受eclipse一样的自动补全。对于Java来说，提供了一些以`Java`，`Project`，`New`，`Mvn`为前缀的命名。可以输入`:Java`按Tab键尝试一下。不过，我觉得还是使用eclipse配合viPlugin插件更方便些。

参考：
1. [Vim自动补全插件----YouCompleteMe安装与配置](http://www.cnblogs.com/zhongcq/p/3630047.html)
2. [Vim智能补全插件YouCompleteMe安装](http://blog.csdn.net/leaf5022/article/details/21290509)
