title: 鲜为人知的Linux命令
date: 2013-11-17 17:16:56
categories: Linux 
tags: Linux
---
1. sudo !! 命令  
使用sudo命令执行上一条命令

2. python命令  
下面的命令生产一个通过HTTP显示文件夹(家目录)结构树的简单网页，可以通过浏览器在端口8000访问，直到发出中断信号。  
```shell
python -m SimpleHTTPServer
```
<!-- more -->
3. mtr命令  
将ping和traceroute两个命令合二为一
```shell
mtr google.com
```

4. ctrl+x+e命令  
打开编辑器(请确定你的bash是在emacs模式)

5. nl命令  
将文本以每行加行号的方式显示
```shell
nl one.txt
```

6. shuf命令  
随机从一个文件或文件夹中选择行/文件/文件夹
```shell
ls | shuf
ls | shuf -n1
ls | shuf -n2
```

7. ss命令  
“ss”表示socket统计。这个命令调查socket，显示类似netstat命令的信息。它可以比其他工具显示更多的TCP和状态信息。

8. last 命令  
“last”命令显示的是上次登录用户的历史信息。这个命令通过搜索文件“/var/log/wtmp”，显示logged-in和logged-out及其tty‘s的用户列表。

9. curl ifconfig.me  
获取外部IP地址
```shell
curl ifconfig.me
```

10. tree命令  
以树式的格式得到当前文件夹的结构。

11. pstree命令  
这个命令显示当前运行的所有进程及其相关的子进程，输出的是类似‘tree’命令的树状格式。

12. <空格>命令  
在每个命令之前输入一个或多个空格，这样命令就不会被history命令记录了。

13. stat命令  
加文件名作为参数，能够显示文件的全部信息。

14. `<alt>`+.和`<esc>`+.  
上面的组合键事实上不是一个命令，而是传递最后一个命令参数到提示符后的快捷键，以输入命令的倒序方式传递命令。按住 Alt或Esc再按一下 “.”。  
得在bash是emacs模式下使用。还有在emacs模式下（没有使用set -o vi），ctrl+a跳转到命令第一个字母，ctrl+e跳转到命令的最后一个字母。

15. pv命令  
在电影里尤其是好莱坞电影你可能已经看见过模拟文本了，像是在实时输入文字，你可以用pv命令仿照任何类型模拟风的文本输出，包括流水线输出。
```shell
echo "Tecmint [dot] com is the world's best website for qualitative Linux article" | pv -qL 20
```

16. mount | colum -t  
上面的命令用一个很不错的格式与规范列出了所有挂载文件系统。

17. ctrl+l  
清屏

18. screen命令  
screen命令能断开一个会话下的一个长时间运行的进程并能再次连接，如有需要，也提供了灵活的命令选项  
要运行一个长时间的进程，我们通常执行  
```shell
./long-unix-script.sh
```
缺乏灵活性，需要用户持续当前的会话，但是如果我们执行上面的命令是：
```shell
screen ./long-unix-script.sh
```
它能在不同会话间断开或重连。当一个命令正在执行时按“Ctrl + A”然后再按“d”来断开。  
重新连接运行：  
```shell
screen -r 4980.pts-0.localhost
```
注解：在这里，这个命令的稍后的部分是screen id，你能用‘screen -ls’命令查看  

19. file  
显示文件类型信息

20. id  
打印真正有效的用户和组的id

更具体的解释参看：  
<http://linux.cn/thread/11925/1/1/>  
<http://linux.cn/thread/11931/1/1/>  

