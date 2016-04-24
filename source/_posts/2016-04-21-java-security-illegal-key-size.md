title: AES加密时报java.security.InvalidKeyException Illegal key size
date: 2016-04-21 14:41:09
tags: Java
categories: Java
description: AES加密；java.security.InvalidKeyException; Illegal key size
---

使用 AES 加密时，密钥大于128bit的话会抛出java.security.InvalidKeyException异常。因为密钥长度是受限的，根据网上一些博客中说的，这种限制是因为[美国对软件出口的控制](http://book.2cto.com/201311/37620.html)。解决办法很简单，下载对应版本的jce包，解压并覆盖 ${JAVA_HOME}/jre/lib/security/ 下的同名文件即可。

[Java Cryptography Extension (JCE) Unlimited Strength Jurisdiction Policy Files 6](http://www.oracle.com/technetwork/java/javase/downloads/jce-6-download-429243.html)

[Java Cryptography Extension (JCE) Unlimited Strength Jurisdiction Policy Files 7 Download](http://www.oracle.com/technetwork/java/javase/downloads/jce-7-download-432124.html)

[Java Cryptography Extension (JCE) Unlimited Strength Jurisdiction Policy Files 8 Download](http://www.oracle.com/technetwork/java/javase/downloads/jce8-download-2133166.html)
