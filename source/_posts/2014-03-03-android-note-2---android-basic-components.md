title: Android应用的基本组件介绍
date: 2014-03-03 20:41:44
categories: android
tags: android
---
Android应用通常由一个或多个组件组成，而最常用的组件是Activity，另外还包括Service、BroadcastReceiver、ContentProvider、Intent 。
 
 <!-- more -->
## Activity 和View
Activity 是Android 应用中负责与用户交互的组件，如果大家学过Swing 可以和JFrame 比较，JFrame 本身可以设置布局管理器，不断地想JFrame 中添加组件，但Activity 只能通过setContentView(View) 来显示指定组件。

View 组件是所有UI 控件、容器控件的基类，View 组件就是Android 应用中用户可以看到的部分。但View 最贱需要放到容器组件中或者使用Activity 将它显示出来。如果需要通过某个Activity 把指定View 显示出来，调用Activity 的setContentView() 方法即可。
 
setContentView 可以接受一个View 对象作为参数：
```java
//创建一个线性布局管理器, LinearLayout是ViewGroup的子类，ViewGroup又是View的子类  
LinearLayout layout = new LinearLayout(this);  
//设置该Activity显示layout  
Super.setContentView(layout);  
```
 
setContentView 可以接受一个布局管理资源的ID 作为参数：
```java
//设置该Activity显示main.xml文件定义的View  
setContentView(R.layout.main);  
```
 
Activity 为Android 应用提供了可视化用户界面，可以理解成一个基本的组成单元，如果该Android 应用需要多个用户界面，那么这个Activity 应用将会包含多个Activity ，通过这些程序可以完成一个个的界面显示及事件处理，多个Activity 组成Activity 栈，当前活动的Activity 位于栈顶。
 
Activity 包含一个setTheme(int resid) 方法来设置其窗口的风格，如果我们希望窗口不显示标题、以对话框形式显示窗口，都可以通过该方法来实现。
 
## Service
Service 与Activity 的地位是并列的，它也代表一个单独的Android 组件。Service 与Activity 的区别在于Service 通常位于后台运行，它一般不需要与用户交互，因此Service 组件没有图形用界面。

与Activity 组件需要继承Activity 基类相似，Service 组件需要继承Service 基类。一个Service 组件被运行起来之后，它将拥有自己独立的生命周期，Service 组件通常用于为其他组件提供后台服务或监控其他组件的运行状态。
 
## BroadcastReceiver
BroadcastReceiver 代表广播消息接收器。如果我们从代码实现角度来看，BroadcastReceiver 非常类似于事件编程中的监听器，与普通事件监听器不同的是：普通事件监听器监听的事件源是程序中的对象，而BroadcastReceiver 监听的事件源是Android 应用中的其他组件。

使用BroadcastReceiver 组件只要实现自己的BroadcastReceiver 子类，并重写onReceive(Context context,Intent intent) 方法即可。当其他组件通过sendBroadcast() 、sendStickyBroadcast() 或sendOrderedBroadcast() 方法发送广播消息时，如该BroadcastReceiver 也对该消息“感兴趣”（通过IntentFilter 配置），BroadcastReceiver 的onReceive(Context context,Intent intent) 方法将会被触发。

我们是实现了自己的BroadcastReceiver 之后，通常有两种方式来注册这个系统级的“事件监听器”：

1. 在Java 代码中通过Context.registReceiver() 方法注册BroadcastReceiver ；
2. 在AndroidManifest.xml 文件中使用<receiver> 元素完成注册；
 
## ContentProvider
我们知道，对于Android 应用而言，它们必须相互独立，各自运行在自己的Dalvik 虚拟机实例中，如果这些Android 应用之间需要实现实时的数据交换。例如我们开发了一个发送短信的程序，当发送短信时需要从联系人管理应用中读取指定联系人的数据，这就需要多个应用程序之间进行实时的数据交换。

Android 系统为这种跨应用的数据交换提供了一个标准：ContentProvider 。当用户实现自己的ContentProvider 时，需要实现如下几个抽象方法：

1. `insert(Uri,ContentValues)` ：向ContentProvider 插入数据
2. `delete(Uri,ContentValues)` ：删除ContentProvider 中指定数据
3. `update(Uri,ContentValues,String,String[])` ：更新ContentProvider 中指定数据
4. `query(Uri,Stirng[],String,String[],String)`：从ContentProvider 查询数据。

通常与ContentProvider 结合使用的是ContentResolver ，一个应用程序使用ContentProvider 暴露自己的数据，而另一个应用程序通过ContentResolver 来访问数据。
 
## Intent 和IntentFilter
严格来说，Intent 并不是Android 应用的组件，但是它对于Android 应用的作用非常之大，它是Android 应用内不同组件之间通信的载体。当Android 运行时需要连接不同的组件时，这时就需要Intent 了。Intent 可以启动应用中另一个Activity ，也可以启动一个Service 组件，还可以发送一条广播消息来触发系统中的BroadcastReceiver ，即Activity 、Service 、BroadcastReceiver 三种组件之间的通信都以Intent 作为载体，只是不同组件使用Intent 的机制略有区别而已。

1. 当需要启动一个Activity 时，可调用Context 的startActivity(Intent intent) 方法，该方法中的Intent 参数封装了需要启动的目标Activity 的信息；
2. Service 时，可调用Context 的startService(Intent intent) 方法或bindService(Intent service,ServiceConnection conn,int flags) 方法，这两个方法中的Intent 参数封装了需要启动的目标Service 信息；
3. 当需要触发一个BroadcastReceiver 时，可调用Context 的sendBroadcast(Intent intent) 、sendStickyBroadcast(Intent intent) 或sendOrderedBroadcast(Intent intent,String receiverPermission) 方法来发送广播消息，这三个方法中的Intent 参数封装了需要触发的目标BroadcastReceiver 的信息。

通过上面可以发现Intent 都是封装了需要启动或触发的目标组件的信息，所有很多资料上都将Intent 翻译为“意图”。
当一个组件通过Intent 表示了启动或触发另一个组件的“意图”后，这个意图可分为两类：

1. 显式Intent ：显式Intent 明确指定需要启动或触发的组件的类名；
2. 隐式Intent ：隐式Intent 只是指定需要启动或触发的组件应满足的条件；

对于显示Intent 而言，Android 系统无须对该Intent 做任何解析，系统直接找到指定的目标组件，启动或触发即可。

对于隐式Intent 而言，Android 系统需要对该Intent 进行解析，解析出它的条件，然后再去系统中查找与之匹配的目标组件，如果找到符合条件的组件，就启动或触发他们。

那么Android 系统如果判断被调用组件是否符合隐式Intent 呢？这就需要靠IntentFilter 来实现了，被调用组件可通过IntentFilter 来声明自己所满足的条件，也就是声明自己到底能处理哪些隐式Intent 。
