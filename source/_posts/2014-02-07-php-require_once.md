title: php中require_once的问题
date: 2014-02-07 22:24:45
categories: php
tags: php
---
先看个例子。目录结构./c.php，./a.php，./demo/b.php。

<!-- more -->
c.php 的内容  
```php
//c.php
require_once(“a.php”);
require_once(“demo/b.php”);
```
a.php 的内容  
```php
//a.php
class A
{
}
```
b.php的内容比较有意思，把a.php引入进去
```php
require_once(“../a.php”);
```
结果会提示错误
```
Warning: require_once(../a.php) [function.require-once]: failed to open stream: No such file or directory in D:\PortableApps\xampp\htdocs\test\demo\b.php on line 2
Fatal error: require_once() [function.require]: Failed opening required ‘../a.php’ (include_path=’.;D:\PortableApps\xampp\php5\pear’) in D:\PortableApps\xampp\htdocs\test\demo\b.php on line 2
```

这是为什么呢？实际c.php 中require_once语句实际引用两次a.php。一次是c.php中本身引用的，一次是由于引用了b.php 而b.php 又引用了a.php，所以c.php 中会出现
```php
require_once(“a.php”);
require_once(“../a.php”);
```

在使用php的include/require/include_once/require_once时有时会碰到路径困扰，尤其是重复包含或嵌套包含时，可以通过绝对路径来解决。有效的一个办法是定义文件“根”，如：

```php
if (!defined('ROOT')) {
	define('ROOT', dirname(__FILE__) . '/');
}
```
