title: Ubuntu软件列表
date: 2013-05-09 22:36:50
categories: ubuntu
tags: [ubuntu, 软件] 
---
记录一下我的Ubuntu中安装的软件

- 系统
    - [Ubuntu Tweak](http://ubuntu-tweak.com)
<!--more-->
    - Typing Break(drwright)
        安装
        {% codeblock %}
        sudo add-apt-repository ppa:drwright/stable
        sudo apt-get update
        sudo apt-get install drwright
        {% endcodeblock %}

        之后在系统设置里就能找到了。
    - workrave(可以替代drwright)
    - [搜狗输入法](http://pinyin.sogou.com/linux/?r=pinyin)
    - GDebi
    - Wine
	- [marlin](http://blog.51osos.com/linux/ubuntu-12-04-marlin)
        {% codeblock %}
        sudo add-apt-repository ppa:marlin-devs/marlin-daily
        sudo apt-get update
        sudo apt-get install marlin light-themes-marlinesque
        {% endcodeblock %}
- 图形
    - [XnView](http://www.xnview.com/)
    - GIMP
	- [dia](http://blog.ubuntusoft.com/dia-flowcharts-linux-under-visio.html) (visio 的替代品)
        {% codeblock %}
        sudo apt-get install dia
        {% endcodeblock %}
- 媒体
    - VLC
    - SMPlayer
    - [OSD Lybric](https://github.com/osdlyrics/osdlyrics) [RhythmBox-OSD-Lyrics](https://github.com/tonychee7000/RhythmBox-OSD-Lyrics)
- 教育
    - GoldenDict
- 互联网
    - Chromium
- 办公
    - [WPS](http://linux.wps.cn/)
    - [Foxit Reader](http://www.foxitsoftware.com/)
    - GVim
    - ReText
- 附件
    - Shutter
    - VirtualBox
    - AllTray
    - ChmSee
    - xChm(可以替代chmsee)
	- [plank docky](http://blog.ubuntusoft.com/plank-lightweight-and-fast-dock.html)
        {% codeblock %}
        sudo apt-add-repository ppa:ricotz/docky
        sudo apt-get update
        sudo apt-get install plank
        {% endcodeblock %}
	- [Guake terminal](http://www.ubuntuhome.com/guake-terminal-0-4-3-released.html)
        {% codeblock %}
        sudo apt-get install guake
        {% endcodeblock %}
	- [Diodon](http://www.ubuntuhome.com/diodon-clipboard-manager.html)
        {% codeblock %}
        sudo add-apt-repository ppa:diodon-team/daily
        sudo apt-get update
        sudo apt-get install diodon
        {% endcodeblock %}
	- [Synapse](http://www.ubuntuhome.com/synapse%E5%88%B0%E6%9D%A5%E2%80%94%E2%80%94%E6%9C%80%E6%96%B0%E6%9C%80%E5%BF%AB%E7%9A%84gnome-do%E6%9B%BF%E4%BB%A3%E6%96%B9%E6%A1%88.html)
        {% codeblock %}
        sudo apt-add-repository ppa:synapse-core/ppa
        sudo apt-get update && sudo apt-get install synapse
        {% endcodeblock %}
- 主题
	- [malys - rought](http://mefanr.lofter.com/post/b8397_2e8a62)
        {% codeblock %}
        sudo add-apt-repository ppa:upubuntu-com/gtk3 
        sudo apt-get update
        sudo apt-get install malys-rough-theme
        {% endcodeblock %}
	- [Faenza Icon Theme](http://wowubuntu.com/faenza-11.html)
        {% codeblock %}
        sudo add-apt-repository ppa:tiheum/equinox
        sudo apt-get update
        sudo apt-get install faenza-icon-theme
        {% endcodeblock %}
	- [elementary-dark-theme](http://toozhao.com/2012/09/ubuntu-install-elementary3-gtk-theme/)
        {% codeblock %}
        sudo add-apt-repository ppa:noobslab/themes
        sudo apt-get update
        sudo apt-get install elementary-theme
        {% endcodeblock %}
