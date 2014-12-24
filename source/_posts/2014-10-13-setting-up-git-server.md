title: 搭建git服务器
date: 2014-10-13 21:01:58
tags: Git
categories: Git
description: 搭建git服务器;set up git server;gitblit;
---

目前 GitHub 作为代码托管库，拥有上百万的用户，已经成为了管理软件开发以及发现已有代码的首选方法。如今也有很多开源的软件可供我们搭建自己的git服务器用来托管自己或者团队的代码，如GitLab，Gitblit、GitStack、Gitolite。

简单起见，我选择Gitblit的Go分支来搭建自己的git服务器。由于gitblit需要java环境运行，所以应该先搭建好java运行环境。

<!-- more -->

## 安装

从官网 http://gitblit.com/ 下载最新版本的Gitblit Go，解压即可。 

## 配置

打开配置文件(位置[gitblit根目录]/data/gitblit.properties)，需要配置的配置项有：

* 配置代码库的位置
    `git.repositoriesFolder= ${baseFolder}/git`，其中`${baseFolder}`即data目录。你可以根据自己的情况设置代码库的位置。


* 配置访问的端口号
    {% codeblock %}
    server.httpPort = 8083
    server.httpsPort = 8443
    {% endcodeblock %}

* 配置http和https访问的接口，如果想要从其它电脑访问，赋空值就可以。
    {% codeblock %}
    server.httpBindInterface=
    server.httpsBindInterface=
    {% endcodeblock %}

## 运行

双击gitblit.cmd即可启动服务。

在浏览器(请使用Firefox或Chrome，IE可能会有些问题)中浏览托管网站。输入http://[your ip]:8083或http://[your ip]:8443即可访问。默认用户名和账号都是admin，登陆后可以更改密码，新建用户。data目录下的users.conf文件中也可以配置用户信息。

## 以Windows Service方式启动Gitblit

编辑installService.cmd。

* 修改ARCH
    32位：ARCH = X86
    64位：ARCH = amd64
* 添加CD为gitblit位置
    `SET CD=[你的实际目录]`
* 修改StartParams里的启动参数，这里我们设置`StartParams=""`，使用 gitblit.properties里的配置即可。

以管理员身份运行installservice.cmd，之后在服务中应该就可以找到gitblit了，默认会自动启动该服务。

