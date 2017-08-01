title: eclipse小技巧
date: 2014-02-08 15:51:44
categories: Eclipse
tags: [Eclipse, 软件]
---
## 代码提示

不进行设置的话，eclipse可以使用快捷键`Alt+/`打开代码提示。

1. 自动提示

    打开window->Preferences->Java->Editor->Content Assist， 找到Auto Activation下面的 Auto activation triggers for Java: 在输入框中输入`.abcdefghijklmnopqrstuvwxyz` 这样在输入这些字符时，就会自动触发代码提示。

2. `Alt+/`没有代码提示

    打开window->Preferences->Java->Editor->Content Assist->Advanced   上面的选项卡在 Select the proposal kinds contained in the 'default' content assist list: 列表中把 Java Proposals 选项打上勾就可以了。

<!-- more -->

## api提示

打开window->Preferences->Java->Installed JREs
选中默认jdk，点击Edit，JRE system libraries列表中选择rt.jar，点击Javadoc Location。然后设置java api所在目录(此目录下有package-list和index.html两个文件)就可以了。

## 设置模板

打开window->Preferences->Java->Code Style->Code Templates
在这里可以设置代码模板

## Eclipse代码复制到Word无格式

把所有的折叠代码展开，然后再复制到Word就可以显示格式了。

## 显示行号

打开window->Preferences->General->Editors->Text Editors，Show line numbers前面打钩

## 转向声明

想知道方法、变量或者类是在哪声明的吗？这个很简单，按住ctrl键，然后点击方法、变量或者类

## 快捷键

- `Alt+/`：代码提示
- `Ctrl+/`：注释一行
- `Shift+Ctrl+/`：块注释
- `Shift+Ctrl+\`：移除块注释
- `Shift+Ctrl+F`：格式化代码
- `Shift+Alt+R`：重构

## 插件

- viPlugin: eclipse的vim插件
- WindowBuidler: 用来设计界面

## eclipse版本号

安装目录下.eclipseproduct中有

## 添加依赖项目

一个项目可能依赖于另一个项目，在eclipse中可以这样设置：在工程上，按右键，弹出菜单中选择Properties，选择侧边栏的 Java Build Path，选择Projects选项卡，点Add添加一个依赖的工程。如果运行时发现抛出找不到类之类的异常，打开工程的Properties设置窗口，侧边栏选择Deployment Assembly，添加依赖的工程，并且这个工程所依赖的jar包也要加进来。
