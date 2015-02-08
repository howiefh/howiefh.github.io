title: jQuery 插件使用记录
date: 2014-12-24 15:20:47
tags: 
- JavaScript
- jQuery
categories:
- JavaScript
- jQuery
description: dragsort; Validform; bootstrap-datetimepicker; highcharts; jQuery File Upload; uploadify; Plupload; Dropzonejs; Web Uploader; zyFile;
---

记录几个自己了解到的jQuery插件: dragsort、Validform、bootstrap-datetimepicker、highcharts、jQuery File Upload、uploadify、Plupload、Dropzonejs、Web Uploader、zyFile。

<!-- more -->

## dragsort

### 下载地址：http://dragsort.codeplex.com/

### 使用方法

```
$("ul").dragsort({
    dragSelector: "li",
    dragEnd: function() { },
    dragBetween: false,
    placeHolderTemplate: "<li></li>"
});
```

jquery list dragsort列表拖动插件参数说明
* dragSelector
    CSS选择器内的元素的列表项的拖动手柄。默认值是“li”。
* dragSelectorExclude
    CSS选择器的元素内的dragSelector不会触发dragsort的。默认值是“input, textarea, a[href]”。
* dragEnd
    拖动结束后将被调用的回调函数.
* dragBetween
    设置为“true”，如果你要启用多组列表之间拖动选定的列表。 默认值是false。
* placeHolderTemplate
    拖动列表的HTML部分。默认值是`<li></li>`.
* scrollContainer
    CSS选择器的元素，作为滚动容器，例如溢出的div设置为自动。 默认值是“窗口“.
* scrollSpeed
    一个数字，它代表了速度，页面拖动某一项时，将滚动容器外，较高使用价值的是速度和较低的值是较慢的。 如果设置为“0”以禁用滚动。默认值是“5”.

### 一个table示例 

下载的压缩包中提供了ul的示例，下面是一个table的示例

```
<table  id='tableid'>
        <tr>
            <td>999999</td>
            <td>923123</td>
        </tr>
        <tr>
            <td>123123</td>
            <td>123123</td>
        </tr>
</table>

<script type="text/javascript">
    $("#tableid").dragsort({
    dragSelector : "tr",  //可以不用设置，他会根据$("#tableid")的类型来决定是tr还是li
    dragEnd : function(){
        console.log($(this));  //拖动完成的回调函数，$(this)当前拖动对象
    },
    scrollSpeed:0,  //默认为5，数值越大拖动的速度越快，为0则拖动时页面不会滚动
});
</script>
```

## Validform

Validform：一行代码搞定整站的表单验证！

### 下载地址：http://validform.rjboy.cn/

### 使用方法

Validform是国人写的插件，[中文文档](http://validform.rjboy.cn/document.html)很详细。下面介绍一下基本使用方法。

1. 引入css

    请查看下载文件中的style.css，把里面Validform必须部分复制到你的css中（文件里这个注释 "/*==========以下部分是Validform必须的===========*/" 之后的部分是必须的）。之前发现有部分网友把整个style.css都引用在了页面里，然后发现样式冲突了。

2. 引入js （jquery 1.4.3 以上版本都可以，官网写的是1.4.3以上版本，但是需要调用外部插件datepicker的话，最新的jQuery貌似不行，最好使用它使用的1.6.2版本的）

    {% codeblock %}
    <script type="text/javascript" src="http://validform.rjboy.cn/wp-content/themes/validform/js/jquery-1.6.2.min.js"></script>
    <script type="text/javascript" src="http://validform.rjboy.cn/Validform/v5.1/Validform_v5.1_min.js"></script>
    {% endcodeblock %}

3. 给需要验证的表单元素绑定附加属性

    {% codeblock %}
    <form class="demoform">
    <input type="text" value="" name="name" datatype="s5-16" errormsg="昵称至少5个字符,最多16个字符！" />
    </form>
    {% endcodeblock %}

4. 初始化，就这么简单

    {% codeblock %}
    $(".demoform").Validform();
    {% endcodeblock %}

### 绑定附加属性

* datatype
    内置基本的datatype类型有： `* | *6-16 | n | n6-16 | s | s6-18 | p | m | e | url`。最新版本可以直接绑定正则：如可用这样写`datatype="/\w{3,6}/i"`，并且网站提供了一个datatype扩展文件[Validform_Datatype]。
* nullmsg
    当表单元素值为空时的提示信息，不绑定，默认提示"请填入信息！"。5.3+会自动查找class为Validform_label下的文字作为提示文字
* sucmsg 5.3+
    当表单元素通过验证时的提示信息，不绑定，默认提示"通过信息验证！"。
* errormsg
    输入内容不能通过验证时的提示信息，默认提示"请输入正确信息！"。
* ignore
    绑定了ignore="ignore"的表单元素，在有输入时，会验证所填数据是否符合datatype所指定数据类型，没有填写内容时则会忽略对它的验证；
* recheck
    表单里面经常需要检查两次密码输入是否一致，recheck就是用来指定需要比较的另外一个表单元素。
* ajaxurl
    指定ajax实时验证的后台文件的地址。Ajax中会POST过来变量param和name。param是文本框的值，name是文本框的name属性。
    {% codeblock %}
    var demo=$(".formsub").Validform()
    demo.config({
        ajaxurl:{
            //可以传入$.ajax()能使用的，除dataType外的所有参数;
        }
    })
    {% endcodeblock %}
    后台返回json格式的数据:`{status:"y",info:"tip"}`，如果status是y则提示成功，n则提示失败。
* plugin
    指定需要使用的插件。
    5.3版开始，对于日期、swfupload和密码强度检测这三个插件，绑定了plugin属性即可以初始化对应的插件，可以不用在validform初始化时传入空的usePlugin了。

### 参数说明

* tiptype
    可用的值有：1、2、3、4和function函数，默认tiptype为1。 3、4是5.2.1版本新增
    1=> 自定义弹出框提示；
    2=> 侧边提示(会在当前元素的父级的next对象的子级查找显示提示信息的对象，表单以ajax提交时会弹出自定义提示框显示表单提交状态)；
    3=> 侧边提示(会在当前元素的siblings对象中查找显示提示信息的对象，表单以ajax提交时会弹出自定义提示框显示表单提交状态)；
    4=> 侧边提示(会在当前元素的父级的next对象下查找显示提示信息的对象，表单以ajax提交时不显示表单的提交状态)；
    {% codeblock %}
    $(function(){
        $(".registerform").Validform({
            tiptype:function(msg,o,cssctl){
                //msg：提示信息;
                //o:{obj:*,type:*,curform:*}, obj指向的是当前验证的表单元素（或表单对象），type指示提示的状态，值为1、2、3、4， 1：正在检测/提交数据，2：通过验证，3：验证失败，4：提示ignore状态, curform为当前form对象;
                //cssctl:内置的提示信息样式控制函数，该函数需传入两个参数：显示提示信息的对象 和 当前提示的状态（既形参o中的type）;
                if(!o.obj.is("form")){//验证表单元素时o.obj为该表单元素，全部验证通过提交表单时o.obj为该表单对象;
                    var objtip=o.obj.siblings(".Validform_checktip");
                    cssctl(objtip,o.type);
                    objtip.text(msg);
                }else{
                    var objtip=o.obj.find("#msgdemo");
                    cssctl(objtip,o.type);
                    objtip.text(msg);
                }
            },
            ajaxPost:true
        });
    })
    {% endcodeblock %}
* ajaxPost
    可用值： true | false。
    默认为false，使用ajax方式提交表单数据，将会把数据POST到config方法或表单action属性里设定的地址；
* datatype
    传入自定义datatype类型，可以是正则，也可以是函数。
    {% codeblock %}
    datatyp:{
        "zh2-4":/^[\u4E00-\u9FA5\uf900-\ufa2d]{2,4}$/
    }
    {% endcodeblock %}
* callback
    在使用ajax提交表单数据时，数据提交后的回调函数。返回数据data是Json对象：{"info":"demo info","status":"y"}。后台可以返回额外的数据供处理

### 公用对象

$.Showmsg(msg)
调用Validform自定义的弹出框。
参数msg是要显示的提示文字。
如$.Showmsg("这是提示文字"); //如果不传入信息则不会有弹出框出现，像$.Showmsg()这样是不会弹出提示框的。
    
## bootstrap-datetimepicker

用Google搜索可以搜到三个不同的同名插件

1. http://eonasdan.github.io/bootstrap-datetimepicker/
2. http://www.bootcss.com/p/bootstrap-datetimepicker/ bootstrap中文网有详细介绍
3. http://tarruda.github.io/bootstrap-datetimepicker/ 作者是neovim项目的发起者，这个项目fork自eonasdan，已经很久没更新了

简单介绍一下第一个，首先需要引入一下这些文件

```
<link rel="stylesheet" type="text/css" href="css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="css/bootstrap-datetimepicker.min.css">
<script type="text/javascript" src="js/jquery-1.8.2.min.js"></script>
<script type="text/javascript" src="js/bootstrap.min.js"></script>
<script type="text/javascript" src="js/moment.js"></script>
<script type="text/javascript" src="js/bootstrap-datetimepicker.min.js"></script>
```

```
<!-- 需要给input添加一个属性  data-date-format 设置日期的格式 -->
<input type="text" class="form-control" id="datetimepicker2" data-date-format="YYYY-MM-DD HH:mm:ss">
<script>
$('input[data-date-format]').datetimepicker({
	useSeconds: true     //设置时间时可以设置秒
});
</script>
```
## highcharts

功能强大、开源、美观、图表丰富、兼容绝大多数浏览器的纯js图表库

### 下载地址: http://code.highcharts.com/

### 中文网: http://www.hcharts.cn/

## 上传文件

这类组件比较多，下面列出我搜到的几个还不错的。

### [jQuery File Upload]

jQuery File Upload 是一个Jquery图片上传组件，支持多文件上传、取消、删除，上传前缩略图预览、列表显示图片大小，支持上传进度条显示；支持各种动态语言开发的服务器端。
jQuery File Upload有多个文件选择，拖放上传控件拖放支持，进度条，验证和预览图像，音频和视频 。
支持跨域，分块和可恢复的文件上传和客户端图像大小调整。适用于任何服务器端平台（PHP, Python, Ruby on Rails, Java, Node.js, Go etc.） ，支持标准的HTML表单文件上传。

两篇可以参考的博客
[jQuery File Upload 与SpringMVC结合](http://blog.csdn.net/huangcongjie/article/details/38793909)
[最适合中国国情的jquery file upload 批量上传改版插件,结合spring mvc](http://www.yihaomen.com/article/java/416.htm)

### [Uploadify]

1、高度地定义化，参数、方法和事件丰富
2、支持Flash和html两种版本
3、强大的社区支持
4、支持多文件上传和进度显示

### [Plupload]

Plupload这个JavaScript控件可以让你选择Adobe Flash、Google Gears、HTML5、Microsoft Silverlight、Yahoo BrowserPlus或正常表单Form等多种方法进行文件上传。Plupload还提供其它功能包括：上传进度提醒、图片缩小、多文件上传，拖拽文件到上传控件，文件类型过滤和Chunked上传等。这些功能在不同的上传方式中支持情况会受到限制。

### [DropzoneJS]

特点是Dropzone 不依赖其它框架（比如jQuery)。提供 AJAX 异步上传功能。

### [Web Uploader]

WebUploader是由Baidu WebFE(FEX)团队开发的一个简单的以HTML5为主，FLASH为辅的现代文件上传组件。在现代的浏览器里面能充分发挥HTML5的优势，同时又不摒弃主流IE浏览器，沿用原来的FLASH运行时，兼容IE6+，iOS 6+, android 4+。两套运行时，同样的调用方式，可供用户任意选用。
采用大文件分片并发上传，极大的提高了文件上传效率。

### [zyFile]

zyFile特点是简单，中文注释挺全，可以修改一下满足自己的需求。

[Validform_Datatype]:http://validform.rjboy.cn/Validform/Validform_Datatype.js
[jQuery File Upload]:https://github.com/blueimp/jQuery-File-Upload
[Plupload]:http://www.plupload.com/
[Uploadify]:http://www.uploadify.com/
[Web Uploader]:http://fex.baidu.com/webuploader/
[DropzoneJS]:https://github.com/enyo/dropzone
[zyFile]:http://www.czlqibu.com/show.html?id=190
