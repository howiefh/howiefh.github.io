title: 恢复七牛云过期域名图片并用Github Pages替换
date: 2020-05-05 22:42:16
tags: ['Hexo', 'Github Pages']
categories: Hexo
description: Hexo, Qiniu
---
有很长时间没有更新博客了，五一抽空打理了一下博客，更新了一些主题插件还有文章。之前七牛的临时域名很早就过期，刚开始图片还是可以显示的，也不知道从什么时候开始就不能显示，应该有挺长时间了，这次也解决了一下这个问题。如果要继续使用七牛就得绑定域名，但是去弄域名还得备案什么的，挺麻烦的，嫌麻烦那就得换一个图床了，最好还是免费的，看了一些介绍，最后还是决定就放GitHub好了，跟博客放一块也好管理。

<!-- more -->

首先我需要把之前放七牛的图片找回来，可气的是七牛管理平台已经看不到下载按钮了，图片也看不到，只能看到一个文件名。求助万能的Google，还真有方法找回来，需要下载一个工具 [qshell](https://github.com/qiniu/qshell)，此外我们还要新建一个新的空间，新空间会绑定一个临时域名，有效期30天，我们把原空间的文件迁移至新空间，然后通过新空间下载。

步骤：

1. 绑定账户 

  ```shell
  $ qshell account <Your AccessKey> <Your SecretKey> <Your Name>
  ```

  其中name表示该账号的名称, 如果AccessKey, SecretKey, Name首字母是"-", 需要使用如下的方式添加账号, 这样避免把该项识别成命令行选项:

  ```shell
  $ qshell account -- <Your AccessKey> <Your SecretKey> <Your Name>
  ```
  
  qshell 这个命令对于mac平台是qshell_darwin_x64。


2. 导出图片列表：

  ```shell
  qshell listbucket <原Bucket> -o origin_list.txt
  ```

  原Bucket是指你原来存储图片空间的名字.

  使用awk获取第一列：

  ```shell
  cat origin_list.txt | awk '{print $1}' > final_origin_list.txt 
  ```

3. 将原空间中图片迁移到新空间

  ```shell
  qshell batchcopy <原Bucket> <新Bucket> -i final_origin_list.txt
  ```

4. 下载所有图片

  ```shell
  qshell qdownload config.json
  ```

  config.json配置信息需要做修改

  ```json
  {
      "dest_dir"   :   "/xxx/xxx/xxx/本地目标路径/",
      "bucket"     :   "新bucket名",
      "cdn_domain" :   "新bucket临时域名",
      "referer"    :   "http://www.qiniu.com"
  }
  ```

5. 上传至GitHub

  找回图片之后就可以在GitHub新建一个仓库存放图片了，这个过程就不细说了，就是新建仓库，然后把图片提交、push到GitHub。这样还可以使用jsDelivr加速访问，`https://cdn.jsdelivr.net/gh/GitHub用户名/图床仓库名/图片路径`
  。另外有个工具[PicGo](https://github.com/Molunerfinn/PicGo) 可以管理图床。

  jsDelivr url 格式： /gh/user/repo@version/file.js

参考：
[七牛云临时域名过期后图片找回](http://blog.whiterabbitxyj.com/2018/12/13/qiniu/)