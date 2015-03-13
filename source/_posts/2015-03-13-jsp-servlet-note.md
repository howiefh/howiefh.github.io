title: JSP/Servlet及相关技术笔记
date: 2015-03-13 10:04:54
tags: [JSP,Servlet]
categories: 
- JavaEE
- JSP
description: JSP/Servlet及相关技术笔记
---

## web应用

```
`<webDemo>` : web应用名称
|--WEB-INF
|   |--classes : 保存单个`*.class`文件
|   |--lib     : 保存jar包
|   |--web.xml : 配置描述符，servlet3.0后不再是必须
|--`<a.jsp>` : jsp页面
```

## java脚本

`<% %>`中的内容即java脚本，会被系统编译在Servlet类中的service方法中。
每个jsp页面其实还是servlet

<!-- more -->

## jsp注释

`<%-- 注释内容 --%>`不会被输出到浏览器中

## jsp声明

`<%! 声明部分 %>`声明部分用于声明变量和方法。声明的变量和方法对应于编译后Servlet类中的成员变量和方法。

jsp页面会编译成Servlet类，每个Servlet在容器中只有一个实例：在jsp中声明的变量是成员变量，成员变量，成员变量只在创建实例时初始化，该变量的值将一直保存，直到实例销毁。

## 输出jsp表达式

`<%= 表达式 %>` 不可以有分号，编译时会转换为Servlet中的输出语句。

## jsp 3个编译指令

* page：该指令是针对当前页面的指令
* include：用于指定包含另一个页面
* taglib：用于定义和访问自定义标签

编译指令的语法格式

```
<%@ 编译指令名 属性名="属性值"... %>
```
### page指令

* language：声明当前jsp页面使用的脚本语言种类，默认是java。
* extends：指定jsp页面编译所产生的java类所继承的父类，或所实现的接口。
* import：用于导入包，`java.lang.*、javax.servlet.*、javax.servlet.jsp.*、javax.servlet.http.*`
* session：设定这个jsp页面是否需要http session
* buffer：指定输出缓存区大小，jsp内部对象：out用于缓存jsp页面对客户端浏览器的输出。默认值为8kb，可以设置为none，也可设为其它值，单位kb。
* autoFlush：当缓存即将溢出时，是否需要强制输出缓存区的内容。设置为true时为正常输出；如果设置为false，则会在溢出时产生异常。
* info：设置jsp程序的信息，课调用getServletInfo()方法获取该值，因为jsp页面实质就是Servlet。
* errorPage：指定错误处理页面。如果本页面产生异常或错误，而该jsp页面没有对应处理代码，将会自动调用指定的页面。实质是jsp的异常处理机制，jsp脚本不要求强制处理异常，即使是受检查的。
* isErrorPage：设置本jsp页面是否为错误处理程序，如果该页面已经是错误处理页面，则无需errorPage属性。
* contentType：用于设定生成网页的文件格式和编码字符集，即MIME类型和页面字符集类型，默认MIME类型是text/html，默认的字符集类型为ISO-8859-1。
* pageEncoding：指定生成网页的编码字符集。

### include指令

include指令会将包含的页面加入到本页面，融合成一个页面，因此被包含页面甚至不需要是一个完整的页面，可以是静态页面，也可以是动态的jsp页面。

语法

```
<%@include file="relativeUrlSpec"%>
```

注意，静态include会将包含页面的编译指令也包含进来，如果两个页面的编译指令冲突，那么页面就会出错。

## jsp7个动作指令

* jsp:forward：执行页面转向，将请求的处理转发到下一个页面。
* jsp:param：用于传递参数，必须与其他支持参数的标签一起使用。
* jsp:include：用于动态引入一个jsp页面。
* jsp:plugin：用于下载JavaBean或Applet到客户端执行。很少会用到。
* jsp:useBean：创建一个JavaBean实例。
* jsp:setProperty：设置JavaBean实例的属性。
* jsp:getProperty：获取JavaBean实例的属性。

### forward指令

既可以转发到静态的html页面，也可以转发到动态的jsp页面，或者转发到容器中的Servlet。

jsp1.0：

```
<jsp:forward page="{relativeURL|<%=expression%>}"/>
```

jsp1.1

```
<jsp:forward page="{relativeURL|<%=expression%>}">
{<jsp:param name="name" value="value"/>}
</jsp:forward>
```

第二种用于转发时添加额外的请求参数。

执行forward指令时，用户请求的地址依然没有发生改变，但页面内容却完全变为被forward目标页的内容。

执行forward指令时，客户端请求参数不会丢失。

实际上forward并没有重新向新页面发送请求，它只是完全采用了新页面来对用户生成响应--请求依然是一次，所以请求参数、属性没丢失。

### include指令

动态include指令，也用于包含某个页面，它不会导入include页面的编译指令，仅仅将被导入页面的body内容插入本页面。

语法

```
<jsp:forward page="{relativeURL|<%=expression%>}" flush="true"/>
//或
<jsp:forward page="{relativeURL|<%=expression%>}" flush="true">
<jsp:param name="name" value="value"/>
</jsp:forward>
```
编译为servlet后，只是使用一个include方法来插入目标页面内容，而不是将目标页面完全融入本页面中。

静态导入和动态导入的三点区别：

* 静态导入是将导入页面的代码完全融入，两个页面融合成一个整体servlet；而动态导入则在servlet中使用include方法来引入被导入页面的内容。
* 静态导入时被导入页面的编译指令会起作用；而动态导入时被导入页面的编译指令则失去作用，只是插入被导入页面的body内容。
* 动态包含还可以增加额外的参数。

forward 指令和 include 指令动作十分相似。forward 指令使用_jspx_page_context的forward() 方法来引入目标页面。include用JspRuntimeLibrary 的include()方法引入目标页面。区别在于：forward拿目标页面代替原有页面，而include则拿目标页面插入原有页面。

### useBean、setProperty、getProperty指令

这三个指令都是与JavaBean相关的指令，其中useBean指令用于在JSP页面中初始化一个Java实例；setProperty指令用于为JavaBean实例的属性设置值；getProperty指令用于输出JavaBean实例的属性。

useBean语法格式如下：

```
<jsp:useBean id="name" class="classname" scope="page|request|session|application"/>
```

其中id是JavaBean的实例名，class属性确定JavaBean的实现类。Scope属性用于指定JavaBean实例的作用范围：

page：仅在该页面有效。
request：在本次请求有效。
session：在本次session内有效。
application：在本次应用内一直有效。

setProperty语法格式如下：

```
<jsp:setProperty property="ProtertyName" name="BeanName" value="value"/>
```
name属性是需要设定JavaBean的实例名；property属性确定需要设置的属性名；value属性则确定需要设置的属性值。

getProperty语法格式如下：

```
<jsp:getProperty property="ProtertyName" name="BeanName" />
```
name属性确定需要输出的JavaBean的实例名，property属性确定需要输出的属性名。

```
<body>
<!-- 创建lee.Person 实例，该实例的名称是p1-->
<jsp:useBean id="p1" class="Person" scope="page"/>
<jsp:setProperty name="p1" property="name" value="waw"/>
<jsp:setProperty name="p1" property="age" value="29"/>

<jsp:getProperty name="p1" property="name" />
<jsp:getProperty name="p1" property="age" />
</body>
```
不使用这三个标签，也可以通过jsp脚本完成相同功能。

### param指令

和jsp:include、jsp:forward、jsp:plugin指令结合使用，语法：

```
<jsp:param name="paramName" value="paramValue" />
```

## jsp脚本中的9个内置对象

jsp页面对应的Servlet的`_jspService()`方法来创建内置对象。

* application：javax.servlet.ServletContext的实例，该实例代表JSP所属的Web应用本身，可用于JSP页面，或者Servlet之间交换信息。常用的方法有getAttribute(String attName)、setAttribute(String attName , String attValue)和getInitParameter(String paramName)等。
* config：javax.servlet.ServletConfig的实例，该实例代表该JSP的配置信息。常用的方法有getInitParameter(String paramName)和getInitParameternames()等方法。事实上，JSP页面通常无须配置，也就不存在配置信息。因此，该对象更多地在Servlet中有效。
* exception：java.lang.Throwable的实例，该实例代表其他页面中的异常和错误。只有当页面是错误处理页面，即编译指令page的isErrorPage属性为true时，该对象才可以使用。常用的方法有getMessage()和printStackTrace()等。
* out：javax.servlet.jsp.JspWriter的实例，该实例代表JSP页面的输出流，用于输出内容，形成HTML页面。
* page：代表该页面本身，通常没有太大用处。也就是Servlet中的this，其类型就是生成的Servlet类，能用page的地方就可用this。
* pageContext：javax.servlet.jsp.PageContext的实例，该对象代表该JSP页面上下文，使用该对象可以访问页面中的共享数据。常用的方法有getServletContext()和getServletConfig()等。
* request：javax.servlet.http:HttpServletRequest的实例，该对象封装了一次请求，客户端的请求参数都被封装在该对象里。这是一个常用的对象，获取客户端请求参数必须使用该对象。常用的方法有getParameter(String paramName)、getParameterValues(String paramName)、setAttribute(String atttName,Object attrValue)、getAttribute(String attrName)和setCharacterEncoding(String env)等。
* response：javax.servlet.http.HttpServletResponse的实例，代表服务器对客户端的响应。通常很少使用该对象直接响应，而是使用out对象，除非需要生成非字符响应。而response对象常用于重定向，常用的方法有getOutputStream()、sendRedirect(java.lang.String location)等。
* session：javax.servlet.http.HttpSession的实例，该对象代表一次会话。当客户端浏览器与站点建立连接时，会话开始；当客户端关闭浏览器时，会话结束。常用的方法有：getAttribute(String attrName)、setAttribute(String attrName, Object attrValue)等。

request、response是`_jspService()`方法的形参，其它都是其局部变量。

由于jsp内置对象都是在`_jspService()`方法中完成初始化的，因此只能在jsp脚本、jsp输出表达式中使用这些内置变量。千万不要在jsp声明中使用它们。

### application

对于每次客户端请求而言，Web服务器大致需要完成如下几个步骤：

* 启动单独的线程。
* 使用I/O流读取用户的请求数据。
* 从请求数据中解析参数。
* 处理用户请求。
* 生成响应数据。
* 使用IO流向客户端发送请求数据。

在上面6个步骤中，第1、2和6步是通用的，可以由Web服务器来完成，但第3、4和5步则存在差异：因为不同请求里包含的请求参数不同，处理用户请求的方式也不同，所生成的响应自然也不同。Web服务器会调用Servlet的`_jspService()`方法来完成第3、4和5步，当我们编写JSP页面时，页面里的静态内容、JSP脚本都会转换成`_jspService()`方法的执行代码，这些执行代码负责完成解析参数、处理请求、生成响应等业务功能，而Web服务器则负责完成多线程、网络通信等底层功能。

为了解决JSP、Servlet之间如何交换数据的问题，几乎所有Web服务器（包括Java、ASP、PHP、Ruby等）都会提供4个类似Map的结构，分别是application、session、request、page，并允许JSP、Servlet将数据放入这4个类似Map的结构中，并允许从这4个Map结构中取出数据。这4个Map结构的区别是范围不同。

* application：对于整个Web应用有效，一旦JSP、Servlet将数据放入application中，该数据将可以被该应用下其他所有的JSP、Servlet访问。
* session：仅对一次会话有效，一旦JSP、Servlet将数据放入session中，该数据将可以被本次会话的其他所有的JSP、Servlet访问。
* request：仅对本次请求有效，一旦JSP、Servlet将数据放入request中，该数据将可以被该次请求的其他JSP、Servlet访问。
* page：仅对当前页面有效，一旦JSP、Servlet将数据放入page中，该数据只可以被当前页面的JSP脚本、声明部分访问。

application对象通常有如下两个作用：

* 在整个Web应用的多个JSP、Servlet之间共享数据。
* 访问Web应用的配置参数。

1. 让多个jsp、servlet共享数据

    application通过setAttribute(String attrName,Object value)方法将一个值设置成application的attrName属性，该属性的值对整个Web应用有效，因此该Web应用的每个JSP页面或Servlet都可以访问该属性，访问属性的方法为getAttribute(String attrName)。
    由于在Servlet中并没有application内置对象，所以可以通过`ServletContext sc = getServletConfig().getServletContext()`显式获取了该Web应用的ServletContext实例，每个Web应用只有一个ServletContext实例，在JSP页面中可通过application内置对象访问该实例，而Servlet中则必须通过代码获取。
    编译Servlet时可能由于没有添加环境出现异常，如果安装了Java EE 6 SDK，只需将Java EE 6 SDK路径的javaee.jar文件添加到CLASSPATH环境变量中；如果没有安装Java EE SDK，可以将Tomcat 7的lib路径下的jsp-api.jar、servlet-api.jar两个文件添加到CLASSPATH环境变量中。
    虽然使用application（即ServletContext实例）可以方便多个JSP、Servlet共享数据，但不要仅为了JSP、Servlet共享数据就将数据放入application中！由于application代表整个Web应用，所以通常只应该把Web应用的状态数据放入application里。

2. 获得Web应用配置参数

    一些配置信息可以放在web.xml文件中，使用context-param元素配置，每个<context-param…/>元素配置一个参数，该元素下有如下两个子元素。
    * param-name：配置Web参数名。
    * param-value：配置Web参数值。
    {% codeblock %}
    <!-- 配置第一个参数：user --> 
    <context-param> 
        <param-name>user</param-name> 
        <param-value>root</param-value> 
    </context-param> 
    <!-- 配置第二个参数：pass --> 
    <context-param> 
        <param-name>pass</param-name> 
        <param-value>32147</param-value> 
    </context-param> 
    {% endcodeblock %}
    之后可以通过application的 getInitParameter(String paramName)方法获取配置参数。
    {% codeblock %}
    <%
    String user = application.getInitParameter("user");
    String pwd = application.getInitParameter("pass");
    out.println(user + " " + pwd);
    %>
    {% endcodeblock %}

### config

config对象代表当前JSP配置信息，但JSP页面通常无须配置，因此也就不存在配置信息。该对象在JSP页面中比较少用，但在Servlet中则用处相对较大，因为Servlet需要在web.xml文件中进行配置，可以指定配置参数。

在jsp输出config的getServletName()方法的返回值为jsp，所有的JSP页面都有相同的名字：jsp

config对象是ServletConfig的实例，该接口用于获取配置参数的方法是getInitParameter(String paramName)

配置JSP也是在web.xml文件中进行的，JSP被当成Servlet配置，为Servlet配置参数使用init-param元素，该元素可以接受param-name和param-value两个子元素，分别指定参数名和参数值。

```
<servlet> 
    <!-- 指定Servlet名字 --> 
    <servlet-name>config</servlet-name> 
    <!-- 指定将哪个JSP页面配置成Servlet --> 
    <jsp-file>/configTest2.jsp</jsp-file> 
    <!-- 配置名为name的参数，值为yeeku --> 
    <init-param> 
        <param-name>name</param-name> 
        <param-value>yeeku</param-value> 
    </init-param> 
    <!-- 配置名为age的参数，值为30 --> 
    <init-param> 
        <param-name>age</param-name> 
        <param-value>30</param-value> 
    </init-param> 
</servlet> 
<servlet-mapping> 
    <!-- 指定将config Servlet配置到/config路径 --> 
    <servlet-name>config</servlet-name> 
    <url-pattern>/config</url-pattern> 
</servlet-mapping> 
```

上面的配置文件片段为该Servlet（其实是JSP）配置了2个参数：name和age。上面的配置片段把configTest2.jsp页面配置成名为config的Servlet，并将该Servlet映射到/config处，这就允许我们通过/config来访问该页面。

通过config可以访问到web.xml文件中的配置参数。实际上，我们也可以直接访问configTest2.jsp页面。

如果希望JSP页面可以获取web.xml配置文件中的配置信息，则必须通过为该JSP配置的路径来访问该页面，因为只有这样访问JSP页面才会让配置参数起作用。

### exception

exception对象是Throwable的实例，代表JSP脚本中产生的错误和异常，是JSP页面异常机制的一部分。

exception对象仅在异常处理页面中才有效，即isErrorPage为true时。

编译为servlet后，这些脚本已经处于`_jspService()`方法的try块中。一旦try块捕捉到JSP脚本的异常，并且`_jspx_page_context`不为null，就会由该对象来处理该异常，如上面粗体字代码所示。`_jspx_page_context`对异常的处理也非常简单：如果该页面的page指令指定了errorPage属性，则将请求forward到errorPage属性指定的页面，否则使用系统页面来输出异常信息。只有jsp脚本、输出表达式才会对应于`_jspService()`方法里的代码，所以这两部分的代码无须处理checked异常。但是jsp的异常处理机制对jsp声明不起作用。

### out

out对象代表一个页面输出流，通常用于在页面上输出变量值及常量。一般在使用输出表达式的地方，都可以使用out对象来达到同样效果。

### pageContext

这个对象代表页面上下文，该对象主要用于访问JSP之间的共享数据。使用pageContext可以访问page、request、session、application范围的变量。

pageContext是PageContext类的实例，它提供了如下两个方法来访问page、request、session、application范围的变量。

* getAttribute(String name)：取得page范围内的name属性。
* getAttribute(String name,int scope)：取得指定范围内的name属性，其中scope可以是如下4个值。

    * PageContext.PAGE_SCOPE：对应于page范围。
    * PageContext.REQUEST_SCOPE：对应于request范围。
    * PageContext.SESSION_SCOPE：对应于session范围。
    * PageContext.APPLICATION_SCOPE：对应于application范围。

与getAttribute()方法相对应，PageContext也提供了2个对应的setAttribute()方法，用于将指定变量放入page、request、session、application范围内。

pageContext还可用于获取其他内置对象，pageContext对象包含如下方法。

* ServletRequest getRequest()：获取request对象。
* ServletResponse getResponse()：获取response对象。
* ServletConfig getServletConfig()：获取config对象。
* ServletContext getServletContext()：获取application对象。
* HttpSession getSession()：获取session对象。

因此一旦在JSP、Servlet编程中获取了pageContext对象，就可以通过它提供的上面方法来获取其他内置对象。

### request

request对象是获取请求参数的重要途径。除此之外，request可代表本次请求范围，所以还可用于操作request范围的属性。

1. 获取请求头/请求参数

    request是HttpServletRequest接口的实例，它提供了如下几个方法来获取请求参数。

    * String getParameter(String paramName)：获取paramName请求参数的值。
    * Map getParameterMap()：获取所有请求参数名和参数值所组成的Map对象。
    * Enumeration getParameterNames()：获取所有请求参数名所组成的Enumeration对象。
    * String[] getParameterValues(String name)：paramName请求参数的值，当该请求参数有多个值时，该方法将返回多个值所组成的数组。

    HttpServletRequest提供了如下方法来访问请求头。

    * String getHeader(String name)：根据指定请求头的值。
    * java.util.Enumeration<String> getHeaderNames()：获取所有请求头的名称。
    * java.util.Enumeration<String> getHeaders(String name)：获取指定请求头的多个值。
    * int getIntHeader(String name)：获取指定请求头的值，并将该值转为整数值。

    对于开发人员来说，请求头和请求参数都是由用户发送到服务器的数据，区别在于请求头通常由浏览器自动添加，因此一次请求总是包含若干请求头；而请求参数则通常需要开发人员控制添加，让客户端发送请求参数通常分两种情况。

    GET方式的请求：直接在浏览器地址栏输入访问地址所发送的请求或提交表单发送请求时，该表单对应的form元素没有设置method属性，或设置method属性为get，这几种请求都是GET方式的请求。GET方式的请求会将请求参数的名和值转换成字符串，并附加在原URL之后，因此可以在地址栏中看到请求参数名和值。且GET请求传送的数据量较小，一般不能大于2KB。

    POST方式的请求：这种方式通常使用提交表单（由form HTML元素表示）的方式来发送，且需要设置form元素的method属性为post。POST方式传送的数据量较大，通常认为POST请求参数的大小不受限制，但往往取决于服务器的限制，POST请求传输的数据量总比GET传输的数据量大。而且POST方式发送的请求参数以及对应的值放在HTML HEADER中传输，用户不能在地址栏里看到请求参数值，安全性相对较高。

    对比上面两种请求方式，由此可见我们通常应该采用POST方式发送请求。

    并不是每个表单域都会生成请求参数的，而是有name属性的表单域才生成请求参数。关于表单域和请求参数的关系遵循如下4点：

    * 每个有name属性的表单域对应一个请求参数。
    * 如果有多个表单域有相同的name属性，则多个表单域只生成一个请求参数，只是该参数有多个值。
    * 表单域的name属性指定请求参数名，value指定请求参数值。
    * 如果某个表单域设置了disabled="disabled"属性，则该表单域不再生成请求参数。

    如果发送请求的表单页采用gb2312字符集，该表单页发送的请求也将采用gb2312字符集，所以本页面需要先执行如下方法。 `setCharacterEncoding("gb2312")`：设置request编码所用的字符集。
    使用GET方法，如果请求参数值里包含非西欧字符，那么是不是应该先调用setCharacterEncoding()来设置request编码的字符集呢？读者可以试一下。答案是不行，如果GET方式的请求值里包含了非西欧字符，则获取这些参数比较复杂。为了获取GET请求里的中文参数值，必须借助于java.net.URLDecoder类。
    {% codeblock %}
    <%
    //获取请求里包含的查询字符串  
    String rawQueryStr = request.getQueryString();  
    out.println("原始查询字符串为：" + rawQueryStr + "<hr/>");  
    //使用URLDecoder解码字符串  
    String queryStr = java.net.URLDecoder.decode(rawQueryStr , "gbk"); 
    out.println("解码后的查询字符串为：" + queryStr + "<hr/>");
    %>
    {% endcodeblock %}
    可通过如下代码来取得name请求参数的参数值。
    {% codeblock %}
    <%
    //获取原始的请求参数值  
    String rawName = request.getParameter("name");  
    //将请求参数值使用ISO-8859-1字符串分解成字节数组  
    byte[] rawBytes = rawName.getBytes("ISO-8859-1");  
    //将字节数组重新解码成字符串  
    String name = new String(rawBytes , "gb2312"); 
    %>
    {% endcodeblock %}

2. 操作request范围的属性

    HttpServletRequest还包含如下两个方法，用于设置和获取request范围的属性。
    * setAttribute(String attName , Object attValue)：将attValue设置成request范围的属性。
    * Object getAttribute(String attName)：获取request范围的属性。
    当forward用户请求时，请求的参数和请求属性都不会丢失。通过`setAttribute`方法设置的属性也不会丢失。

3. 执行forward或include

    request还有一个功能就是执行forward和include，也就是代替JSP所提供的forward和include动作指令。
    HttpServletRequest类提供了一个getRequestDispatcher (String path)方法，其中path就是希望forward或者include的目标路径，该方法返回RequestDispatcher，该对象提供了如下两个方法。

    * forward(ServletRequest request, ServletResponse response)：执行forward。
    * include(ServletRequest request, ServletResponse response)：执行include。

    使用request的getRequestDispatcher(String path)方法时，该path字符串必须以斜线开头。
    
### response

response代表服务器对客户端的响应。大部分时候，程序无须使用response来响应客户端请求，因为有个更简单的响应对象--out，它代表页面输出流，直接使用out生成响应更简单。

但out是JspWriter的实例，JspWriter是Writer的子类，Writer是字符流，无法输出非字符内容。假如需要在JSP页面中动态生成一幅位图、或者输出一个PDF文档，使用out作为响应对象将无法完成，此时必须使用response作为响应输出。

除此之外，还可以使用response来重定向请求，以及用于向客户端增加Cookie。

1. response响应生成非字符响应

    response是HttpServletResponse接口的实例，该接口提供了一个getOutputStream()方法，该方法返回响应输出字节流。下面的方法可以输出图像。
    {% codeblock %}
    <%-- 通过contentType属性指定响应数据是图片 --%> 
    <%@ page contentType="image/jpeg" language="java"%> 
    <%@ page import="java.awt.image.*,javax.imageio.*,java.io.*,java.awt.*"%> 
    <%  
    //创建BufferedImage对象  
    BufferedImage image = new BufferedImage(340 , 160, BufferedImage.TYPE_INT_RGB);  
    //以Image对象获取Graphics对象  
    Graphics g = image.getGraphics();  
    //使用Graphics画图，所画的图像将会出现在image对象中  
    g.fillRect(0,0,400,400);  
    //设置颜色：红  
    g.setColor(new Color(255,0,0));  
    //画出一段弧  
    g.fillArc(20, 20, 100,100, 30, 120);  
    //设置颜色：绿  
    g.setColor(new Color(0 , 255, 0));  
    //画出一段弧  
    g.fillArc(20, 20, 100,100, 150, 120);  
    //设置颜色：蓝  
    g.setColor(new Color(0 , 0, 255));  
    //画出一段弧  
    g.fillArc(20, 20, 100,100, 270, 120);  
    //设置颜色：黑  
    g.setColor(new Color(0,0,0));  
    g.setFont(new Font("Arial Black", Font.PLAIN, 16));  
    //画出三个字符串  
    g.drawString("red:climb" , 200 , 60);  
    g.drawString("green:swim" , 200 , 100);  
    g.drawString("blue:jump" , 200 , 140);  
    g.dispose();  
    //将图像输出到页面的响应  
    ImageIO.write(image , "jpg" , response.getOutputStream());  
    %> 
    {% endcodeblock %}

2. 重定向

    重定向是response的另外一个用处，与forward不同的是，重定向会丢失所有的请求参数和request范围的属性，因为重定向将生成第二次请求，与前一次请求不在同一个request范围内，所以发送一次请求的请求参数和request范围的属性全部丢失。

    HttpServletResponse提供了一个sendRedirect(String path)方法，该方法用于重定向到path资源，即重新向path资源发送请求。

    forward和redirect对比

    执行redirect后生成第二次请求，而forward依然是上一次请求。
    redirect的目标页面不能访问原请求的请求参数，因为是第二次请求了，所有原请求的请求参数、request范围的属性全部丢失。forward的目标页面可以访问原请求的请求参数，因为依然是同一次请求，所有原请求的请求参数、request范围的属性全部存在。
    地址栏改为重定向的目标URL。相当于在浏览器地址栏里输入新的URL后按回车键。而forward地址栏里请求的URL不会改变 

3. 增加Cookie

    Cookie与session的不同之处在于：session会随浏览器的关闭而失效，但Cookie会一直存放在客户端机器上，除非超出Cookie的生命期限。

    增加Cookie也是使用response内置对象完成的，response对象提供了如下方法。
    void addCookie(Cookie cookie)：增加Cookie。
    增加Cookie请按如下步骤进行。

    * 创建Cookie实例，Cookie的构造器为Cookie(String name, String value)。
    * 设置Cookie的生命期限，即该Cookie在多长时间内有效。
    * 向客户端写Cookie。
    {% codeblock %}
    <%
    //增加cookie
    String name = request.getParameter("name");  
    //以获取到的请求参数为值，创建一个Cookie对象  
    Cookie c = new Cookie("username" , name);  
    //设置Cookie对象的生存期限  
    c.setMaxAge(24 * 3600);  
    //向客户端增加Cookie对象  
    response.addCookie(c);  
    %> 
    {% endcodeblock %}
    访问客户端Cookie使用request对象，request对象提供了getCookies()方法，该方法将返回客户端机器上所有Cookie组成的数组，遍历该数组的每个元素，找到希望访问的Cookie即可。
    使用Cookie对象必须设置其生存期限，否则Cookie将会随浏览器的关闭而自动消失。
    默认情况下，Cookie值不允许出现中文字符，如果我们需要值为中文内容的Cookie怎么办呢？同样可以借助于java.net.URLEncoder先对中文字符串进行编码，将编码后的结果设为Cookie值。当程序要读取Cookie时，则应该先读取，然后使用java.net.URLDecoder对其进行解码。

### session

session对象也是一个非常常用的对象，这个对象代表一次用户会话。一次用户会话的含义是：从客户端浏览器连接服务器开始，到客户端浏览器与服务器断开为止，这个过程就是一次会话。

session通常用于跟踪用户的会话信息，如判断用户是否登录系统，或者在购物车应用中，用于跟踪用户购买的商品等。

session对象是HttpSession的实例，HttpSession有如下两个常用的方法。

setAttribute(String attName，Object attValue)：设置session范围内attName属性的值为attValue。
getAttribute(String attName)：返回session范围内attName属性的值。

关于session还有一点需要指出，session机制通常用于保存客户端的状态信息，这些状态信息需要保存到Web服务器的硬盘上，所以要求session里的属性值必须是可序列化的，否则将会引发不可序列化的异常。

session的属性值可以是任何可序列化的Java对象。

## servlet介绍

### Servlet的开发

前面介绍的JSP的本质就是Servlet，Servlet通常被称为服务器端小程序，是运行在服务器端的程序，用于处理及响应客户端的请求。

Servlet是个特殊的Java类，这个Java类必须继承HttpServlet。每个Servlet可以响应客户端的请求。Servlet提供不同的方法用于响应客户端请求。

* doGet：用于响应客户端的GET请求。
* doPost：用于响应客户端的POST请求。
* doPut：用于响应客户端的PUT请求。
* doDelete：用于响应客户端的DELETE请求。

事实上，客户端的请求通常只有GET和POST两种，Servlet为了响应这两种请求，必须重写doGet()和doPost()两个方法。如果Servlet为了响应4个方式的请求，则需要同时重写上面的4个方法。

大部分时候，Servlet对于所有请求的响应都是完全一样的。此时，可以采用重写一个方法来代替上面的几个方法：只需重写service()方法即可响应客户端的所有请求。

另外，HttpServlet还包含两个方法。

* init(ServletConfig config)：创建Servlet实例时，调用该方法的初始化Servlet资源。
* destroy()：销毁Servlet实例时，自动调用该方法的回收资源。

通常无须重写init()和destroy()两个方法，除非需要在初始化Servlet时，完成某些资源初始化的方法，才考虑重写init方法。如果需要在销毁Servlet之前，先完成某些资源的回收，比如关闭数据库连接等，才需要重写destroy方法。

不用为Servlet类编写构造器，如果需要对Servlet执行初始化操作，应将初始化操作放在Servlet的init()方法中定义。如果重写了init(ServletConfig config)方法，则应在重写该方法的第一行调用super.init(config)。该方法将调用HttpServlet的init方法。

Servlet和JSP的区别在于：

* Servlet中没有内置对象，原来JSP中的内置对象都必须由程序显式创建。
* 对于静态的HTML标签，Servlet都必须使用页面输出流逐行输出。

普通Servlet类里的service()方法的作用，完全等同于JSP生成Servlet类的`_jspService()`方法。因此原JSP页面的JSP脚本、静态HTML内容，在普通Servlet里都应该转换成service()方法的代码或输出语句；原JSP声明中的内容，对应为在Servlet中定义的成员变量或成员方法。

### servlet的配置

编辑好的Servlet源文件需编译成class文件才能响应用户请求。将编译后的.class文件放在WEB-INF/classes路径下，如果Servlet有包，则还应该将class文件放在对应的包路径下。

如果需要直接采用javac命令来编译Servlet类，则必须将Servlet API接口和类添加到系统的CLASSPATH环境变量里。也就是将Tomcat 7安装目录下lib目录中servlet-api. jar和jsp-api.jar添加到CLASSPATH环境变量中。

为了让Servlet能响应用户请求，还必须将Servlet配置在Web应用中。配置Servlet时，需要修改web.xml文件。

从Servlet 3.0开始，配置Servlet有两种方式：

* 在Servlet类中使用@WebServlet Annotation进行配置。
* 通过在web.xml文件中进行配置。

上面开发Servlet类时使用了@WebServlet Annotation修饰该Servlet类，使用@WebServlet时可指定如表所示的常用属性。

属    性          | 是否必需 | 说    明
asyncSupported    | 否       | 指定该Servlet是否支持异步操作模式。关于Servlet的异步调用请参考2.15节
displayName       | 否       | 指定该Servlet的显示名
initParams        | 否       | 用于为该Servlet配置参数
loadOnStartup     | 否       | 用于将该Servlet配置成 load-on-startup的Servlet
name              | 否       | 指定该Servlet的名称
urlPatterns/value | 否       | 这两个属性的作用完全相同。都指定该Servlet处理的URL

如果打算使用Annotation来配置Servlet，有两点需要指出：

* 不要在web.xml文件的根元素（`<web-app.../>`）中指定metadata-complete="true"。
* 不要在web.xml文件中配置该Servlet。

如果打算使用web.xml文件来配置该Servlet，则需要配置如下两个部分。

* 配置Servlet的名字：对应web.xml文件中的`<servlet/>`元素。
* 配置Servlet的URL：对应web.xml文件中的`<servlet-mapping/>`元素。这一步是可选的。但如果没有为Servlet配置URL，则该Servlet不能响应用户请求。

```
<!-- 配置Servlet的名字 --> 
<servlet>     
<!-- 指定Servlet的名字，相当于指定@WebServlet的name属性 -->     
<servlet-name>firstServlet</servlet-name>     
<!-- 指定Servlet的实现类 -->     
<servlet-class>lee.FirstServlet</servlet-class> </servlet> 
<!-- 配置Servlet的URL --> 
<servlet-mapping>     
<!-- 指定Servlet的名字 -->     
<servlet-name>firstServlet</servlet-name>     
<!-- 指定Servlet映射的URL地址，相当于指定@WebServlet的urlPatterns属性-->    <url-pattern>/aa</url-pattern> 
</servlet-mapping> 
```

通过注解
```
@WebServlet(name="firstServlet", urlPatterns={"/firstServlet"}) 
```

### JSP/Servlet的生命周期

创建Servlet实例有两个时机。

* 客户端第一次请求某个Servlet时，系统创建该Servlet的实例：大部分的Servlet都是这种Servlet。
* Web应用启动时立即创建Servlet实例，即load-on-startup Servlet。

每个Servlet的运行都遵循如下生命周期。

1. 创建Servlet实例。
2. Web容器调用Servlet的init方法，对Servlet进行初始化。
3. Servlet初始化后，将一直存在于容器中，用于响应客户端请求。如果客户端发送GET请求，容器调用Servlet的doGet方法处理并响应请求；如果客户端发送POST请求，容器调用Servlet的doPost方法处理并响应请求。或者统一使用service()方法处理来响应用户请求。
4. Web容器决定销毁Servlet时，先调用Servlet的destroy方法，通常在关闭Web应用之时销毁Servlet。

### load-on-startup Servlet

配置load-on-startup的Servlet有两种方式：

* 在web.xml文件中通过`<servlet.../>`元素的`<load-on-startup.../>`子元素进行配置。
* 通过@WebServlet Annotation的loadOnStartup属性指定。

```
<servlet>     
<!-- Servlet名 -->     
<servlet-name>timerServlet</servlet-name>     
<!-- Servlet的实现类 -->     
<servlet-class>lee.TimerServlet</servlet-class>     
<!-- 配置应用启动时，创建Servlet实例，相当于指定@WebServlet的loadOnStartup属性-->     
<load-on-startup>1</load-on-startup> 
</servlet>
```
通过注解
```
@WebServlet(loadOnStartup=1) 
```

### 访问Servlet的配置参数

为Servlet配置参数有两种方式：

* 通过@WebServlet的initParams属性来指定。
* 通过在web.xml文件的`<servlet.../>`元素中添加`<init-param.../>`子元素来指定。

访问Servlet配置参数通过ServletConfig对象完成，ServletConfig提供如下方法。
java.lang.String getInitParameter(java.lang.String name)：用于获取初始化参数。
JSP的内置对象config就是此处的ServletConfig。

```
<servlet> 
    <!-- 配置Servlet名 --> 
    <servlet-name>testServlet</servlet-name> 
    <!-- 指定Servlet的实现类 --> 
    <servlet-class>lee.TestServlet</servlet-class> 
    <!-- 配置Servlet的初始化参数：user --> 
    <init-param> 
        <param-name>user</param-name> 
        <param-value>root</param-value> 
    </init-param> 
    <!-- 配置Servlet的初始化参数：pass --> 
    <init-param> 
        <param-name>pass</param-name> 
        <param-value>32147</param-value> 
    </init-param> 
</servlet> 
<servlet-mapping> 
    <!-- 确定Servlet名 --> 
    <servlet-name>testServlet</servlet-name> 
    <!-- 配置Servlet映射的URL --> 
    <url-pattern>/testServlet</url-pattern> 
</servlet-mapping> 
```
通过注解
```
@WebServlet(name="testServlet" 
    , urlPatterns={"/testServlet"}  
    , initParams={  
        @WebInitParam(name="user", value="root"),  
        @WebInitParam(name="pass", value="32147")})  
```

### 使用Servlet作为控制器

在标准的MVC模式中，Servlet仅作为控制器使用。Java EE应用架构正是遵循MVC模式的，对于遵循MVC模式的Java EE应用而言，JSP仅作为表现层（View）技术，其作用有两点：

* 负责收集用户请求参数。
* 将应用的处理结果、状态数据呈现给用户。

Servlet则仅充当控制器（Controller）角色，它的作用类似于调度员：所有用户请求都发送给 Servlet，Servlet调用Model来处理用户请求，并调用JSP来呈现处理结果；或者Servlet直接调用JSP将应用的状态数据呈现给用户。

Model通常由JavaBean来充当，所有业务逻辑、数据访问逻辑都在Model中实现。实际上隐藏在Model下的可能还有很多丰富的组件，例如DAO组件、领域对象等。

下面是MVC中各个角色的对应组件。

M：Model，即模型，对应JavaBean。
V：View，即视图，对应JSP页面。
C：Controller，即控制器，对应Servlet。

## JSP 2的自定义标签

在JSP 2中开发标签库只需如下几个步骤。

* 开发自定义标签处理类；
* 建立一个`*.tld`文件，每个`*.tld`文件对应一个标签库，每个标签库可包含多个标签；
* 在JSP文件中使用自定义标签。

### 开发自定义标签类

自定义标签类应该继承一个父类：javax.servlet.jsp.tagext.SimpleTagSupport，除此之外，JSP自定义标签类还有如下要求：

* 如果标签类包含属性，每个属性都有对应的getter和setter方法。
* 重写doTag()方法，这个方法负责生成页面内容。

### 建立TLD文件

TLD是Tag Library Definition的缩写，即标签库定义，文件的后缀是tld，每个TLD文件对应一个标签库，一个标签库中可包含多个标签。TLD文件也称为标签库定义文件。

标签库定义文件的根元素是taglib，它可以包含多个tag子元素，每个tag子元素都定义一个标签。

```
<?xml version="1.0" encoding="GBK"?> 
<taglib xmlns="http://java.sun.com/xml/ns/j2ee" 
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"     
xsi:schemaLocation="http://java.sun.com/xml/ns/j2ee web-jsptaglibrary_2_0.xsd"     
version="2.0">     
<tlib-version>1.0</tlib-version>     
<short-name>mytaglib</short-name>     
<!-- 定义该标签库的URI -->     
<uri>http://www.crazyit.org/mytaglib</uri>     
<!-- 定义第一个标签 -->     
<tag>         
<!-- 定义标签名 -->         
<name>helloWorld</name>         
<!-- 定义标签处理类 -->         
<tag-class>lee.HelloWorldTag</tag-class>         
<!-- 定义标签体为空 -->         
<body-content>empty</body-content>     
</tag> 
</taglib> 
```

taglib下有如下三个子元素。

* tlib-version：指定该标签库实现的版本，这是一个作为标识的内部版本号，对程序没有太大的作用。
* short-name：该标签库的默认短名，该名称通常也没有太大的用处。
* uri：这个属性非常重要，它指定该标签库的URI，相当于指定该标签库的唯一标识。如上面斜体字代码所示，JSP页面中使用标签库时就是根据该URI属性来定位标签库的。

除此之外，taglib元素下可以包含多个tag元素，每个tag元素定义一个标签，tag元素下允许出现如下常用子元素。

* name：该标签库的名称，这个子元素很重要，JSP页面中就是根据该名称来使用此标签的。
* tag-class：指定标签的处理类，毋庸置疑，这个子元素非常重要，它指定了标签由哪个标签处理类来处理。
* body-content：这个子元素也很重要，它指定标签体内容。该子元素的值可以是如下几个。
    * tagdependent：指定标签处理类自己负责处理标签体。
    * empty：指定该标签只能作为空标签使用。
    * scriptless：指定该标签的标签体可以是静态HTML元素、表达式语言，但不允许出现JSP脚本。
    * JSP：指定该标签的标签体可以使用JSP脚本。
    * dynamic-attributes：指定该标签是否支持动态属性。只有当定义动态属性标签时才需要该子元素。

因为JSP 2规范不再推荐使用JSP脚本，所以JSP 2自定义标签的标签体中不能包含JSP脚本。所以，实际上body-content元素的值不可以是JSP。

定义了上面的标签库定义文件后，将标签库文件放在Web应用的WEB-INF路径或任意子路径下，Java Web规范会自动加载该文件，则该文件定义的标签库也将生效。

### 使用标签库

在JSP页面中确定指定的标签需要两点。

* 标签库URI：确定使用哪个标签库。
* 标签名：确定使用哪个标签。

使用标签库分成以下两个步骤。

* 导入标签库：使用taglib编译指令导入标签库，就是将标签库和指定前缀关联起来。
* 使用标签：在JSP页面中使用自定义标签。

taglib的语法格式如下：
```
<%@ taglib uri="tagliburi" prefix="tagPrefix" %>
```

其中uri属性确定标签库的URI，这个URI可以确定一个标签库。而prefix属性指定标签库前缀，即所有使用该前缀的标签将由此标签库处理。

```
<%@ page contentType="text/html; charset=GBK" language="java" errorPage="" %> 
<!-- 导入标签库，指定mytag前缀的标签，由http://www.crazyit.org/mytaglib的标签库处理 --> 
<%@ taglib uri="http://www.crazyit.org/mytaglib" prefix="mytag"%> 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
<html xmlns="http://www.w3.org/1999/xhtml"> 
<head><title>自定义标签示范</title></head> 
<body bgcolor="#ffffc0"> 
<h2>下面显示的是自定义标签中的内容</h2> 
<!-- 使用标签 ，其中mytag是标签前缀，根据taglib的编译指令，mytag前缀将由http://www.crazyit.org/mytaglib的标签库处理 --> 
<mytag:helloWorld/><br/> 
</body> </html> 
```

### 带属性的标签

带属性标签必须为每个属性提供对应的setter和getter方法。

对于有属性的标签，需要为`<tag.../>`元素增加`<attribute.../>`子元素，每个attribute子元素定义一个标签属性。`<attribute.../>`子元素通常还需要指定如下几个子元素。

* name：设置属性名，子元素的值是字符串内容。
* required：设置该属性是否为必需属性，该子元素的值是true或false。
* fragment：设置该属性是否支持JSP脚本、表达式等动态内容，子元素的值是true或false。

```
<tag> 
    <!-- 定义标签名 --> 
    <name>tagname</name> 
    <!-- 定义标签处理类 --> 
    <tag-class>lee.Tag</tag-class> 
    <!-- 定义标签体为空 --> 
    <body-content>empty</body-content> 
    <!-- 配置标签属性:user --> 
    <attribute> 
        <name>user</name> 
        <required>true</required> 
        <fragment>true</fragment> 
    </attribute> 
    <!-- 配置标签属性:pass --> 
    <attribute> 
        <name>pass</name> 
        <required>true</required> 
        <fragment>true</fragment> 
    </attribute> 
</tag> 
```
JSTL是Sun提供的一套标签库，这套标签库的功能非常强大。另外，DisplayTag是Apache组织下的一套开源标签库，主要用于生成页面并显示效果。

### 带标签体的标签

带标签体的标签，可以在标签内嵌入其他内容（包括静态的HTML内容和动态的JSP内容），通常用于完成一些逻辑运算，例如判断和循环等。下面以一个迭代器标签为示例，介绍带标签体标签的开发过程。

```
public class IteratorTag extends SimpleTagSupport  {
    //标签属性，用于指定需要被迭代的集合
    private String collection;
    //标签属性，指定迭代集合元素，为集合元素指定的名称
    private String item;
    //省略collection属性的setter和getter方法      ...      
    //省略item属性的setter和getter方法      ...      
    //标签的处理方法，简单标签处理类只需要重写doTag方法      
    public void doTag() throws JspException, IOException{
        //从page scope中获取属性名为collection的集合
        Collection itemList = (Collection)getJspContext().getAttribute(collection);
        //遍历集合          
        for (Object s : itemList)
        { 
            //将集合的元素设置到page 范围
            getJspContext().setAttribute(item, s );
            //输出标签体              
            getJspBody().invoke(null);
        }      
    }  
} 
```
标签处理类的doTag方法首先从page范围内获取了指定名称的Collection对象，然后遍历Collection对象的元素，每次遍历都调用了getJspBody()方法，该方法返回该标签所包含的标签体：JspFragment对象，执行该对象的invoke()方法，即可输出标签体内容。该标签的作用是：遍历指定集合，每遍历一个集合元素，即输出标签体一次。

mytaglib.tld:
```
<tag>     
<!-- 定义标签名 -->
<name>iterator</name>
<!-- 定义标签处理类 -->
<tag-class>lee.IteratorTag</tag-class>
<!-- 定义标签体不允许出现JSP脚本 -->
<body-content>scriptless</body-content>
<!-- 配置标签属性:collection -->
<attribute>
    <name>collection</name>
    <required>true</required>
    <fragment>true</fragment>
</attribute>
<!-- 配置标签属性:item -->
<attribute>
    <name>item</name>
    <required>true</required>
    <fragment>true</fragment>
</attribute> 
</tag> 
```

iteratorTag.jsp:
```
<%@ page contentType="text/html; charset=GBK" language="java" errorPage="" %> 
<%@ page import="java.util.*"%>
<!-- 导入标签库，指定mytag前缀的标签，由http://www.crazyit.org/mytaglib的标签库处理 -->
<%@ taglib uri="http://www.crazyit.org/mytaglib" prefix="mytag"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<body>
<h2>带标签体的标签-迭代器标签</h2><hr/>
<%
//创建一个List对象
List<String> a = new ArrayList<String>();
a.add("疯狂Java");
a.add("www.crazyit.org");
a.add("java");
//将List对象放入page范围内
pageContext.setAttribute("a" , a); 
%>
<table border="1" bgcolor="#aaaadd" width="300">
<!-- 使用迭代器标签，对a集合进行迭代 -->
<mytag:iterator collection="a" item="item">
<tr>
<td>${pageScope.item}</td>
<tr>         
</mytag:iterator>
</table> 
</body>
```

### 以页面片段作为属性的标签

JSP 2规范的自定义标签还允许直接将一段"页面片段"作为属性，这种方式给自定义标签提供了更大的灵活性。

以"页面片段"为属性的标签与普通标签区别并不大，只有两个简单的改变：

* 标签处理类中定义类型为JspFragment的属性，该属性代表了"页面片段"。
* 使用标签库时，通过`<jsp:attribute.../>`动作指令为标签库属性指定值。

```
public class FragmentTag extends SimpleTagSupport {
    private JspFragment fragment;     
    //fragment属性的setter和getter方法
    public void setFragment(JspFragment fragment) {
        this.fragment = fragment;
    }
    public JspFragment getFragment(){
        return this.fragment;
    }
    @Override
    public void doTag() throws JspException, IOException {
        JspWriter out = getJspContext().getOut();
        out.println("<div style='padding:10px;border:1px solid black'>");
        out.println("<h3>下面是动态传入的JSP片段</h3>");
        //调用、输出"页面片段"
        fragment.invoke( null );
        out.println("</div");
    }
}
```
mytaglib.tld:
```
<tag>
<!-- 定义标签名 -->
<name>fragment</name>
<!-- 定义标签处理类 -->
<tag-class>lee.FragmentTag</tag-class>
<!-- 指定该标签不支持标签体 -->
<body-content>empty</body-content>
<!-- 定义标签属性：fragment -->
<attribute>
    <name>fragment</name>
    <required>true</required>
    <fragment>true</fragment>
</attribute>
</tag>
```
fragmentTag.jsp:
```
<h2>下面显示的是自定义标签中的内容</h2>
<mytag:fragment>
    <!-- 使用jsp:attribute标签传入fragment参数 -->
    <jsp:attribute name="fragment">
        <!-- 下面是动态的JSP页面片段 -->
        <mytag:helloWorld/>
    </jsp:attribute>
</mytag:fragment>
<br/>
<mytag:fragment>
    <jsp:attribute name="fragment">
        <!-- 下面是动态的JSP页面片段 -->
        ${pageContext.request.remoteAddr}
    </jsp:attribute> 
</mytag:fragment> 
```

### 动态属性的标签

前面介绍带属性标签时，那些标签的属性个数是确定的，属性名也是确定的，绝大部分情况下这种带属性的标签能处理得很好，但在某些特殊情况下，我们需要传入自定义标签的属性个数是不确定的，属性名也不确定，这就需要借助于动态属性的标签了。

动态属性标签比普通标签多了如下两个额外要求：

* 标签处理类还需要实现DynamicAttributes接口。
* 配置标签时通过`<dynamic-attributes.../>`子元素指定该标签支持动态属性。

DynaAttributesTag.java
```
public class DynaAttributesTag extends SimpleTagSupport implements DynamicAttributes {
    //保存每个属性名的集合
    private ArrayList<String> keys = new ArrayList<String>();
    //保存每个属性值的集合
    private ArrayList<Object> values = new ArrayList<Object>();
    @Override
    public void doTag() throws JspException, IOException {
        JspWriter out = getJspContext().getOut();
        //此处只是简单地输出每个属性
        out.println("<ol>");
        for( int i = 0; i < keys.size(); i++ ) {
            String key = keys.get( i );
            Object value = values.get( i );
            out.println( "<li>" + key + " = " + value + "</li>" );
        }
        out.println("</ol>");
    }
    @Override
    public void setDynamicAttribute( String uri, String localName, Object value ) throws JspException {
        //添加属性名
        keys.add( localName );
        //添加属性值
        values.add( value );
    }
} 
```

mytaglib.tld

```
<!-- 定义接受动态属性的标签 -->
<tag>
    <name>dynaAttr</name>
    <tag-class>lee.DynaAttributesTag</tag-class>
    <body-content>empty</body-content>
    <!-- 指定支持动态属性 -->
    <dynamic-attributes>true</dynamic-attributes>
</tag> 
```

dynaAttrTag.jsp

```
<!-- 导入标签库，指定mytag前缀的标签，由http://www.crazyit.org/mytaglib的标签库处理 --> 
<%@ taglib uri="http://www.crazyit.org/mytaglib" prefix="mytag"%>
<h2>下面显示的是自定义标签中的内容</h2>
<h4>指定两个属性</h4>
<mytag:dynaAttr name="crazyit" url="crazyit.org"/>
<br/> 
<h4>指定四个属性</h4>
<mytag:dynaAttr 书名="疯狂Java讲义" 价格="99.0" 出版时间="2008年" 描述="Java图书"/>
<br/>
```

## Filter介绍

Filter可认为是Servlet的一种"加强版"，它主要用于对用户请求进行预处理，也可以对HttpServletResponse进行后处理，是个典型的处理链。Filter也可对用户请求生成响应，这一点与Servlet相同，但实际上很少会使用Filter向用户请求生成响应。使用Filter完整的流程是：Filter对用户请求进行预处理，接着将请求交给Servlet进行处理并生成响应，最后Filter再对服务器响应进行后处理。

Filter有如下几个用处。

* 在HttpServletRequest到达Servlet之前，拦截客户的HttpServletRequest。
* 根据需要检查HttpServletRequest，也可以修改HttpServletRequest头和数据。
* 在HttpServletResponse到达客户端之前，拦截HttpServletResponse。
* 根据需要检查HttpServletResponse，也可以修改HttpServletResponse头和数据。

Filter有如下几个种类。

* 用户授权的Filter：Filter负责检查用户请求，根据请求过滤用户非法请求。
* 日志Filter：详细记录某些特殊的用户请求。
* 负责解码的Filter：包括对非标准编码的请求解码。
* 能改变XML内容的XSLT Filter等。
* Filter可负责拦截多个请求或响应；一个请求或响应也可被多个Filter拦截。

创建一个Filter只需两个步骤：

* 创建Filter处理类。
* web.xml文件中配置Filter。

### 创建Filter类

创建Filter必须实现javax.servlet.Filter接口，在该接口中定义了如下三个方法。

* void init（FilterConfig config）：用于完成Filter的初始化。
* void destroy()：用于Filter销毁前，完成某些资源的回收。
* void doFilter（ServletRequest request，ServletResponse response,FilterChain chain）：实现过滤功能，该方法就是对每个请求及响应增加的额外处理。

### 配置Filter

前面已经提到，Filter可以认为是Servlet的"增强版"，因此配置Filter与配置Servlet非常相似，都需要配置如下两个部分：

* 配置Filter名。
* 配置Filter拦截URL模式。

区别在于，Servlet通常只配置一个URL，而Filter可以同时拦截多个请求的URL。因此，在配置Filter的URL模式时通常会使用模式字符串，使得Filter可以拦截多个请求。与配置Servlet相似的是，配置Filter同样有两种方式：

* 在Filter类中通过Annotation进行配置。
* 在web.xml文件中通过配置文件进行配置。

@WebFilter(filterName="log", urlPatterns={"/*"})
@WebFilter修饰一个Filter类，用于对Filter进行配置，它支持如表所示的常用属性

@WebFilter支持的常用属性

属    性          | 是否必需 | 说    明
asyncSupported    | 否       | 指定该Filter是否支持异步操作模式。关于Filter的异步调用请参考2.15节
dispatcherTypes   | 否       | 指定该Filter仅对那种dispatcher模式的请求进行过滤。该属性支持ASYNC、ERROR、FORWARD、INCLUDE、REQUEST 这5个值的任意组合。默认值为同时过滤5种模式的请求
displayName       | 否       | 指定该Filter的显示名
filterName        |          | 指定该Filter的名称
initParams        | 否       | 用于为该Filter配置参数
servletNames      | 否       | 该属性值可指定多个Servlet的名称，用于指定该Filter仅对这几个Servlet执行过滤
urlPatterns/value | 否       | 这两个属性的作用完全相同。都指定该Filter所拦截的URL

在web.xml文件中配置Filter与配置Servlet非常相似，需要为Filter指定它所过滤的URL，并且也可以为Filter配置参数。

```
<!-- 定义Filter -->
<filter>
    <!-- Filter的名字，相当于指定@WebFilter的filterName属性 -->
    <filter-name>log</filter-name>
    <!-- Filter的实现类 -->
    <filter-class>lee.LogFilter</filter-class>
</filter>
<!-- 定义Filter拦截的URL地址 -->
<filter-mapping>
    <!-- Filter的名字 -->
    <filter-name>log</filter-name>
    <!-- Filter负责拦截的URL，相当于指定@WebFilter的urlPatterns属性 -->
    <url-pattern>/*</url-pattern>
</filter-mapping> 
```

实际上Filter和Servlet极其相似，区别只是Filter的doFilter()方法里多了一个FilterChain的参数，通过该参数可以控制是否放行用户请求。

假设系统有包含多个Servlet，这些Servlet都需要进行一些的通用处理：比如权限控制、记录日志等，这将导致在这些Servlet的service方法中有部分代码是相同的--为了解决这种代码重复的问题，我们可以考虑把这些通用处理提取到Filter中完成，这样各Servlet中剩下的只是特定请求相关的处理代码，而通用处理则交给Filter完成。

由于Filter和Servlet如此相似，所以Filter和Servlet具有完全相同的生命周期行为，且Filter也可以通过<init-param.../>元素或@WebFilter的initParams属性来配置初始化参数，获取Filter的初始化参数则使用FilterConfig的getInitParameter()方法。

对于Java Web应用来说，要实现伪静态非常简单：可以通过Filter拦截所有发向*.html请求，然后按某种规则将请求forward到实际的*.jsp页面即可。现有的URL Rewrite开源项目为这种思路提供了实现，使用URL Rewrite实现网站伪静态也很简单。

下载URL Rewrite应下载其src项（urlrewritefilter-3.2.0-src.zip），下载完成后得到一个urlrewritefilter-3.2.0-src.zip文件，将该压缩文件解压缩，得到如下文件结构。

* api：该路径下存放了URL Rewrite项目的API文档。
* lib：该路径下存放了URL Rewrite项目的编译和运行所需的第三方类库。
* manual：该路径下存放了URL Rewrite项目使用手册。
* src：该路径下存放了URL Rewrite项目的源代码。
* webapp：该路径是一个URL Rewrite的示例应用。
* LICENSE.txt等杂项文档。

web.xml
```
<!-- 配置Url Rewrite的Filter -->
<filter>
<filter-name>UrlRewriteFilter</filter-name>
<filter-class>org.tuckey.web.filters.urlrewrite.UrlRewriteFilter</filter-class>
</filter>
<!-- 配置Url Rewrite的Filter拦截所有请求 -->
<filter-mapping>
<filter-name>UrlRewriteFilter</filter-name>
<url-pattern>/*</url-pattern>
</filter-mapping> 
```
上面的配置片段指定使用URL Rewrite Filter拦截所有的用户请求。

在应用的WEB-INF路径下增加urlrewrite.xml文件，该文件定义了伪静态映射规则，这份伪静态规则是基于正则表达式的。

下面是本应用所使用的urlrewrite.xml伪静态规则文件。

```
<?xml version="1.0" encoding="GBK"?>
<!DOCTYPE urlrewrite PUBLIC "-//tuckey.org//DTD UrlRewrite 3.2//EN" "http://tuckey.org/res/dtds/urlrewrite3.2.dtd">
<urlrewrite>
<rule>
<!-- 所有配置如下正则表达式的请求 -->
<from>/userinf-(\w*).html</from>
<!-- 将被forward到如下JSP页面，其中$1代表上面第一个正则表达式所匹配的字符串 -->
<to type="forward">/userinf.jsp?username=$1</to>
</rule>
</urlrewrite> 
```

上面的规则文件中只定义了一个简单的规则：所有发向/userinf-(\w*).html的请求都将被forward到user.jsp页面，并将(\w*)正则表达式所匹配的内容作为username参数值。根据这个伪静态规则，我们应该为该应用提供一个userinf.jsp页面，该页面只是一个模拟了一个显示用户信息的页面

userinf.jsp

```
<%@ page contentType="text/html; charset=GBK" language="java" errorPage="" %>
<%
//获取请求参数
String user = request.getParameter("username");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title> <%=user%>的个人信息 </title></head>
<body>
<%
//此处应该通过数据库读取该用户对应的信息
//此处只是模拟，因此简单输出：
out.println("现在时间是：" + new java.util.Date() + "<br/>");
out.println("用户名：" + user);  %>
</body> </html> 
```

## Listener 介绍

当Web应用在Web容器中运行时，Web应用内部会不断地发生各种事件：如Web应用被启动、Web应用被停止，用户session开始、用户session结束、用户请求到达等，通常来说，这些Web事件对开发者是透明的。

实际上，Servlet API提供了大量监听器来监听Web应用的内部事件，从而允许当Web内部事件发生时回调事件监听器内的方法。

使用Listener只需要两个步骤：

* 定义Listener实现类。
* 通过Annotation或在web.xml文件中配置Listerner。

### 实现Listenner类

常用的Web事件监听器接口有如下几个。

* ServletContextListener：用于监听Web应用的启动和关闭。
* ServletContextAttributeListener：用于监听ServletContext范围（application）内属性的改变。
* ServletRequestListener：用于监听用户请求。
* ServletRequestAttributeListener：用于监听ServletRequest范围（request）内属性的改变。
* HttpSessionListener：用于监听用户session的开始和结束。
* HttpSessionAttributeListener：用于监听HttpSession范围（session）内属性的改变。

下面先以ServletContextListener为例来介绍Listener的开发和使用，ServletContextListener用于监听Web应用的启动和关闭。该Listener类必须实现ServletContextListener接口，该接口包含如下两个方法。

* contextInitialized(ServletContextEvent sce)：启动Web应用时，系统调用Listener的该方法。
* contextDestroyed(ServletContextEvent sce)：关闭Web应用时，系统调用Listener的该方法。

### 配置Listener

为Web应用配置Listener也有两种方式：

* 使用@WebListener修饰Listener实现类即可。
* 在web.xml文档中使用<listener.../>元素进行配置。

在web.xml中使用<listener.../>元素进行配置时只要配置如下子元素即可。
listener-class：指定Listener实现类。

使用ServletContextAttributeListener

ServletContextAttributeListener用于监听ServletContext（application）范围内属性的变化，实现该接口的监听器需要实现如下三个方法。

* attributeAdded(ServletContextAttributeEvent event)：当程序把一个属性存入application范围时触发该方法。
* attributeRemoved(ServletContextAttributeEvent event)：当程序把一个属性从application范围删除时触发该方法。
* attributeReplaced(ServletContextAttributeEvent event)：当程序替换application范围内的属性时将触发该方法。

### 使用ServletRequestListener和ServletRequestAttributeListener

ServletRequestListener用于监听用户请求的到达，实现该接口的监听器需要实现如下两个方法。

* requestInitialized(ServletRequestEvent sre)：用户请求到底、被初始化时触发该方法。
* requestDestroyed(ServletRequestEvent sre)：用户请求结束、被销毁时触发该方法。

ServletRequestAttributeListener则用于监听ServletRequest（request）范围内属性的变化，实现该接口的监听器需要实现attributeAdded、attributeRemoved、attributeReplaced三个方法。

### 使用HttpSessionListener和HttpSessionAttributeListener

HttpSessionListener用于监听用户session的创建和销毁，实现该接口的监听器需要实现如下两个方法。

* sessionCreated(HttpSessionEvent se)：用户与服务器的会话开始、创建时时触发该方法。
* sessionDestroyed(HttpSessionEvent se)：用户与服务器的会话断开、销毁时触发该方法。

HttpSessionAttributeListener则用于监听HttpSession（session）范围内属性的变化，实现该接口的监听器需要实现attributeAdded、attributeRemoved、attributeReplaced三个方法。

## JSP 2特性

相比JSP 1.2，JSP 2主要增加了如下新特性。

* 直接配置JSP属性。
* 表达式语言。
* 简化的自定义标签API。
* Tag文件语法。

如果需要使用JSP 2语法，其web.xml文件必须使用Servlet 2.4以上版本的配置文件。Servlet 2.4以上版本的配置文件的根元素写法如下：

```
<?xml version="1.0" encoding="GBK"?>
<!--  不再使用DTD，而是使用Schema描述，版本也升级为 2.4-->
<web-app xmlns="http://java.sun.com/xml/ns/j2ee" 
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://java.sun.com/xml/ns/j2ee http://java.sun.com/xml/ns/j2ee/web-app_2_4.xsd" version="2.4">
<!-- 此处是Web应用的其他配置 -->
...
</web-app> 
```
### 配置jsp属性

JSP属性定义使用元素配置，主要包括如下4个方面。

* 是否允许使用表达式语言：使用元素确定，默认值为false，即允许使用表达式语言。
* 是否允许使用JSP脚本：使用元素确定，默认值为false，即允许使用JSP脚本。
* 声明JSP页面的编码：使用元素确定，配置该元素后，可以代替每个页面里page指令contentType属性的charset部分。
* 使用隐式包含：使用和元素确定，可以代替在每个页面里使用include编译指令来包含其他页面。

此处隐式包含的作用与JSP提供的静态包含的作用相似。

```
<?xml version="1.0" encoding="GBK"?>
<web-app xmlns="http://java.sun.com/xml/ns/javaee"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://java.sun.com/xml/ns/javaee   http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd" version="3.0">
<jsp-config>
    <jsp-property-group>
        <url-pattern>/noscript/*</url-pattern>
        <el-ignored>true</el-ignored>
        <page-encoding>GBK</page-encoding>
        <scripting-invalid>true</scripting-invalid>
        <include-prelude>/inc/top.jspf</include-prelude>
        <include-coda>/inc/bottom.jspf</include-coda>
    </jsp-property-group>
    <jsp-property-group>
        <url-pattern>*.jsp</url-pattern>
        <el-ignored>false</el-ignored>
        <page-encoding>GBK</page-encoding>
        <scripting-invalid>false</scripting-invalid>
    </jsp-property-group>
    <jsp-property-group>
        <url-pattern>/inc/*</url-pattern>
        <el-ignored>false</el-ignored>
        <page-encoding>GBK</page-encoding>
        <scripting-invalid>true</scripting-invalid>
    </jsp-property-group>
</jsp-config>
</web-app> 
```

### 表达式语言

表达式语言（Expression Language）是一种简化的数据访问方式。使用表达式语言可以方便地访问JSP的隐含对象和JavaBeans组件，在JSP 2规范中，建议尽量使用表达式语言使JSP文件的格式一致，避免使用Java脚本。

表达式语言的语法格式是： `${expression}`
如果想输出`$`符号，则在`$`前加转义字符`\`

1. 表达式语言支持的算术运算符和逻辑运算符

    所有java语言里的算术运算符都支持，甚至java不支持的运算符也支持。
    div(除)、mod(取余)、lt(小于)、gt(大于)、ge(大于等于)、le(小于等于)、eq(等于)、ne(不等于)
    表达式语言不仅可在数字与数字之间比较，还可在字符与字符之间比较，字符串的比较是根据其对应UNICODE值来比较大小的。
    表达式语言把所有数值都当成浮点数处理，所以3/0的实质是3.0/0.0，得到结果应该是Infinity。

2. 表达式语言的内置对象
    
    表达式语言包含如下11个内置对象。
    * pageContext：代表该页面的pageContext对象，与JSP的pageContext内置对象相同。
    * pageScope：用于获取page范围的属性值。
    * requestScope：用于获取request范围的属性值。
    * sessionScope：用于获取session范围的属性值。
    * applicationScope：用于获取application范围的属性值。
    * param：用于获取请求的参数值。
    * paramValues：用于获取请求的参数值，与param的区别在于，该对象用于获取属性值为数组的属性值。
    * header：用于获取请求头的属性值。
    * headerValues：用于获取请求头的属性值，与header的区别在于，该对象用于获取属性值为数组的属性值。
    * initParam：用于获取请求Web应用的初始化参数。
    * cookie：用于获取指定的Cookie值。
    两种方法取得请求参数值：
    `${param.name}`、 `${param["name"]`
3. 表达式语言的自定义函数

    表达式语言除了可以使用基本的运算符外，还可以使用自定义函数。通过自定义函数，能够大大加强表达式语言的功能。自定义函数的开发步骤非常类似于标签的开发步骤，定义方式也几乎一样。区别在于自定义标签直接在页面上生成输出，而自定义函数则需要在表达式语言中使用。

    函数功能大大扩充了EL的功能，EL本身只是一种数据访问语言，因此它不支持调用方法。如果需要在EL中进行更复杂的处理，就可以通过函数来完成。函数的本质是：提供一种语法允许在EL中调用某个类的静态方法。

    使用标签库定义函数：定义函数的方法与定义标签的方法大致相似。在`<taglib.../>`元素下增加`<tag.../>`元素用于定义自定义标签；增加`<function.../>`元素则用于定义自定义函数。每个`<function.../>`元素只要三个子元素即可。

    * name：指定自定义函数的函数名。
    * function-class：指定自定义函数的处理类。
    * function-signature：指定自定义函数对应的方法。

    {% codeblock %}
    <?xml version="1.0" encoding="GBK"?>
    <taglib xmlns="http://java.sun.com/xml/ns/j2ee"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://java.sun.com/xml/ns/j2ee web-jsptaglibrary_2_0.xsd" version="2.0">
    <tlib-version>1.0</tlib-version>
    <short-name>crazyit</short-name>
    <!-- 定义该标签库的URI -->
    <uri>http://www.crazyit.org/tags</uri>
    <!-- 定义第一个函数 -->
    <function>
        <!-- 定义函数名:reverse -->
        <name>reverse</name>
        <!-- 定义函数的处理类 -->
        <function-class>lee.Functions</function-class>
        <!-- 定义函数的实现方法-->
        <function-signature>java.lang.String reverse(java.lang.String)</function-signature>
    </function>
        <!-- 定义第二个函数: countChar -->
        <function>
        <!-- 定义函数名:countChar -->
        <name>countChar</name>
        <!-- 定义函数的处理类 -->
        <function-class>lee.Functions</function-class>
        <!-- 定义函数的实现方法-->
        <function-signature>int countChar(java.lang.String)</function-signature>
    </function>
    </taglib> 
    {% endcodeblock %}

    上面的粗体字代码定义了两个函数，不难发现其实定义函数比定义自定义标签更简单，因为自定义函数只需配置三个子元素即可，变化更少。

    useFunctions.jsp：

    {% codeblock %}
    <%@ page contentType="text/html; charset=GBK" language="java" errorPage="" %>
    <%@ taglib prefix="crazyit" uri="http://www.crazyit.org/tags"%>
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">
    <head><title>new document</title></head>
    <body>
    <h2>表达式语言 - 自定义函数</h2><hr/>
    请输入一个字符串：
    <form action="useFunctions.jsp" method="post">
    字符串 = <input type="text" name="name" value="${param['name']}">
    <input type="submit"  value="提交">
    </form>
    <table border="1" bgcolor="aaaadd">
    <tr>
    <td><b>表达式语言</b></td>
    <td><b>计算结果</b></td>
    </tr>
    <tr>
    <td>\${param["name"]}</td>
    <td>${param["name"]}&nbsp;</td>
    </tr>
    <!--  使用reverse函数-->
    <tr>
    <td>\${crazyit:reverse(param["name"])}</td>
    <td>${crazyit:reverse(param["name"])}&nbsp;</td>
    </tr>
    <tr>
    <td>\${crazyit:reverse(crazyit:reverse(param["name"]))}</td>
    <td>${crazyit:reverse(crazyit:reverse(param["name"]))}&nbsp;</td>
    </tr>
    <!-- 使用countChar函数 -->
    <tr>
    <td>\${crazyit:countChar(param["name"])}</td>
    <td>${crazyit:countChar(param["name"])}&nbsp;</td>
    </tr>
    </table>
    </body> </html> 
    {% endcodeblock %}

    如上面程序中粗体字代码所示，导入标签库定义文件后（实质上也是函数库定义文件），就可以在表达式语言中使用函数定义库文件里定义的各函数了。

### Tag File 支持

建立Tag文件，在JSP所支持Tag File规范下，Tag File代理了标签处理类，它的格式类似于JSP文件。可以这样理解：如同JSP可以代替Servlet作为表现层一样，Tag File则可以代替标签处理类。

Tag File具有以下5个编译指令。

* taglib：作用与JSP文件中的taglib指令效果相同，用于导入其他标签库。
* include：作用与JSP文件中的include指令效果相同，用于导入其他JSP或静态页面。
* tag：作用类似于JSP文件中的page指令，有pageEncoding、body-content等属性，用于设置页面编码等属性。
* attribute：用于设置自定义标签的属性，类似于自定义标签处理类中的标签属性。
* variable：用于设置自定义标签的变量，这些变量将传给JSP页面使用。

下面是迭代器标签的Tag File，这个Tag File的语法与JSP语法非常相似。

iterator.tag
```
<%@ tag pageEncoding="GBK" import="java.util.List"%>
<!-- 定义了4个标签属性 -->
<%@ attribute name="bgColor" %>
<%@ attribute name="cellColor" %>
<%@ attribute name="title" %>
<%@ attribute name="bean" %>
<table border="1" bgcolor="${bgColor}">
<tr> <td><b>${title}</b></td> </tr>
<!-- 取出request范围的a集合 -->
<%
List<String> list = (List<String>) request.getAttribute("a");
//遍历输出list集合的元素
for (Object ele : list){
%> 
<tr> <td bgcolor="${cellColor}"><%=ele%> </td> </tr>
<%}%> 
```

将该文件存在Web应用的某个路径下，这个路径相当于标签库的URI名。如将其放在/WEB-INF/tags下

在页面中使用自定义标签时，需要先导入标签库，再使用标签。使用Tag File标签与普通自定义标签的用法完全相同，只是在导入标签库时存在一些差异。由于此时的标签库没有URI，只有标签库路径。因此导入标签时，使用如下语法格式：

```
<%@ taglib prefix="tagPrefix" tagdir="path" %> 
```
其中，prefix与之前的taglib指令的prefix属性完全相同，用于确定标签前缀；而tagdir标签库路径下存放很多Tag File，每个Tag File对应一个标签。

useTagFile.jsp

```
<%@ page contentType="text/html; charset=GBK" language="java" errorPage="" %>
<%@ page import="java.util.*" %>
<%@ taglib prefix="tags" tagdir="/WEB-INF/tags" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title>迭代器tag file</title></head>
<body>
<h2>迭代器tag file</h2>
<%
//创建集合对象，用于测试Tag File所定义的标签
List<String> a = new ArrayList<String>();
a.add("hello");
a.add("world");
a.add("java");
//将集合对象放入页面范围
request.setAttribute("a" , a);%>
//使用自定义标签
<tags:iterator bgColor="#99dd99" cellColor="#9999cc" title="迭代器标签" bean="a" />
</body> </html>
```

```
<tags:iterator bgColor="#99dd99" cellColor="#9999cc" title="迭代器标签" bean="a" /> 
```
tags表明该标签使用/WEB-INF/tags路径下的Tag File来处理标签；而iterator是标签名，即使用WEB-INF/tags路径下的iterator.tag文件负责处理该标签。

Tag File是自定义标签的简化。事实上，就如同JSP文件会编译成Servlet一样，Tag File也会编译成标签处理类，自定义标签的后台依然由标签处理类完成，而这个过程由容器完成。打开Tomcat的work\Catalina\localhost\jsp2\org\apache\jsp\tag\web路径，即可看到iterator_tag.java、iterator_tag.class两个文件，这两个文件就是Tag File所对应的标签处理类。

通过查看iterator_tag.java文件的内容不难发现，Tag File中只有如下几个内置对象。

* request：与JSP脚本中的request对象对应。
* response：与JSP脚本中的response对象对应。
* session：与JSP脚本中的session对象对应。
* application：与JSP脚本中的application对象对应。
* config：与JSP脚本中的config对象对应。
* out：与JSP脚本中的out对象对应。

## Servlet 3.0新特性

### Servlet 3.0的Annotation

Servlet 3.0规范在javax.servlet.annotation包下提供了如下Annotation。

* @WebServlet：用于修饰一个Servlet类，用于部署Servlet类。
* @WebInitParam：用于与@WebServlet或@WebFilter一起使用，为Servlet、Filter配置参数。
* @WebListener：用于修饰Listener类，用于部署Listener类。
* @WebFilter：用于修饰Filter类，用于部署Filter类。
* @MultipartConfig：用于修饰Servlet，指定该Servlet将会负责处理multipart/form-data类型的请求（主要用于文件上传）。
* @ServletSecurity：这是一个与JAAS有关的Annotation，修饰Servlet指定该Servlet的安全与授权控制。
* @HttpConstraint：用于与@ServletSecurity一起使用，用于指定该Servlet的安全与授权控制。
* @HttpMethodConstraint：用于与@ServletSecurity一起使用，用于指定该Servlet的安全与授权控制。

### Servlet 3.0的Web模块支持

Servlet 3.0规范不再要求所有Web组件（如Servlet、Listener、Filter等）都部署在web.xml文件中，而是允许采用"Web模块"来部署、管理它们。

一个Web模块通常对应于一个JAR包，这个JAR包有如下文件结构：

```
<webModule>.jar--这是Web模块的JAR包，可以改变
|－META-INF
|   |－web-fragment.xml
|－Web模块所用的类文件、资源文件等。
```

从上面的文件结构可以看出，Web模块与普通JAR的最大区别在于需要在META-INF目录下添加一个web-fragment.xml文件，这个文件也被称为Web模块部署描述符。

web-fragment.xml文件与web.xml文件的作用、文档结构都基本相似，因为它们都用于部署、管理各种Web组件。只是web-fragment.xml用于部署、管理Web模块而已，但web-fragment.xml文件可以多指定如下两个元素。

`<name.../>`：用于指定该Web模块的名称。
`<ordering.../>`：用于指定加载该Web模块的相对顺序。

web-fragment.xml:

```
<?xml version="1.0" encoding="GBK"?>
<web-fragment xmlns="http://java.sun.com/xml/ns/javaee"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-fragment_3_0.xsd" version="3.0">
<!-- 指定该Web模块的唯一标识 -->
<name>crazyit</name>
<listener>
<listener-class>lee.CrazyitListener</listener-class>
</listener>
<ordering>
<!-- 用于配置该Web模块必须位于哪些模块之前加载 -->
<before>
<!-- 用于指定位于其他所有模块之前加载 -->
<others/>
</before>
</ordering>
</web-fragment>
```
另一个web-fragment.xml:
```
<?xml version="1.0" encoding="GBK"?>
<web-fragment xmlns="http://java.sun.com/xml/ns/javaee"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-fragment_3_0.xsd" version="3.0">
<!-- 指定该Web模块的唯一标识 -->
<name>leegang</name>
<!-- 配置Listener -->
<listener>
<listener-class>lee.LeegangListener</listener-class>
</listener>
<ordering>
<!-- 用于配置该Web模块必须位于哪些模块之后加载 -->
<after>
<!-- 此处可用多个name元素列出该模块必须位于这些模块之后加载 -->
<name>crazyit</name>
</after>
</ordering>
</web-fragment>
```
先加载crazyit模块，再加载leegang模块。

Web应用除了可按web-fragment.xml文件中指定的加载顺序来加载Web模块之外，还可以通过web.xml文件指定各Web模块加载的绝对顺序。在web.xml文件中指定的加载顺序将会覆盖Web模块中web-fragment.xml文件所指定的加载顺序。

### Servlet 3.0提供的异步处理

在以前的Servlet规范中，如果Servlet作为控制器调用了一个耗时的业务方法，那么Servlet必须等到业务方法完全返回之后才会生成响应，这将使得Servlet对业务方法的调用变成一种阻塞式的调用，因此效率比较低。

Servlet 3.0规范引入了异步处理来解决这个问题，异步处理允许Servlet重新发起一条新线程去调用耗时的业务方法，这样就可避免等待。

Servlet 3.0的异步处理是通过AsyncContext类来处理的，Servlet可通过ServletRequest的如下两个方法开启异步调用、创建AsyncContext对象：

* AsyncContext startAsync()
* AsyncContext startAsync(ServletRequest, ServletResponse)

重复调用上面的方法将得到同一个AsyncContext对象。AsyncContext对象代表异步处理的上下文，它提供了一些工具方法，可完成设置异步调用的超时时长，dispatch用于请求、启动后台线程、获取request、response对象等功能。

AsyncServlet.java:

```
@WebServlet(urlPatterns="/async",asyncSupported=true)
public class AsyncServlet extends HttpServlet  {
@Override
public void doGet(HttpServletRequest request, HttpServletResponse response)
throws IOException,ServletException {
    response.setContentType("text/html;charset=GBK");
    PrintWriter out = response.getWriter();
    out.println("<title>异步调用示例</title>");
    out.println("进入Servlet的时间：" + new java.util.Date() + ".<br/>");
    out.flush();
    //创建AsyncContext，开始异步调用
    AsyncContext actx = request.startAsync();
    //设置异步调用的超时时长
    actx.setTimeout(30*1000);
    //启动异步调用的线程
    actx.start(new Executor(actx));
    out.println("结束Servlet的时间：" + new java.util.Date() + ".<br/>");
    out.flush();
    }
}
```

下面是线程执行体的代码。

Executor.java

```
public class Executor implements Runnable {
    private AsyncContext actx = null;
    public Executor(AsyncContext actx) {
        this.actx = actx;
    }
    public void run() {
        try {
            //等待5秒钟，以模拟业务方法的执行
            Thread.sleep(5 * 1000);
            ServletRequest request = actx.getRequest();
            List<String> books = new ArrayList<String>();
            books.add("疯狂Java讲义");
            books.add("经典Java EE企业应用实战");
            books.add("疯狂XML讲义");
            request.setAttribute("books" , books);
            actx.dispatch("/async.jsp");
        } catch(Exception e){
            e.printStackTrace();
        }
    }
} 
```
该线程执行体内让线程暂停5秒来模拟调用耗时的业务方法，最后调用AsyncContext的dispatch方法把请求dispatch到指定JSP页面。

被异步请求dispatch的目标页面需要指定session="false"，表明该页面不会重新创建session。

async.jsp:

```
<%@ page contentType="text/html; charset=GBK" language="java" session="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<ul> <c:forEach items="${books}" var="book">
<li>${book}</li> 
</c:forEach> 
</ul>
<%out.println("业务调用结束的时间：" + new java.util.Date());
//完成异步调用
request.getAsyncContext().complete();
%> 
```
为Servlet开启异步调用有两种方式：

* 为@WebServlet指定asyncSupported=true。
* 在web.xml文件的<servlet.../>元素中增加<async-supported.../>子元素。

当Servlet启用异步调用的线程之后，该线程的执行过程对开发者是透明的。但在有些情况下，开发者需要了解该异步线程的执行细节，并针对特定的执行结果进行针对性处理，这可借助于Servlet 3.0提供的异步监听器来实现。

异步监听器需要实现AsyncListener接口，实现该接口的监听器类需要实现如下4个方法。

* onStartAsync(AsyncEvent event)：当异步调用开始时触发该方法。
* onComplete(AsyncEvent event)：当异步调用完成时触发该方法。
* onError(AsyncEvent event)：当异步调用出错时触发该方法。
* onTimeout(AsyncEvent event)：当异步调用超时时触发该方法。

提供了异步监听器之后，还需要通过AsyncContext来注册监听器，调用该对象的addListener()方法即可注册监听器。例如在上面的Servlet中增加如下代码即可注册监听器：

```
AsyncContext actx = request.startAsync();
//为该异步调用注册监听器
actx.addListener(new MyAsyncListener());
```

虽然上面的MyAsyncListener监听器类可以监听异步调用开始、异步调用完成两个事件，但从实际运行的结果来看，它并不能监听到异步调用开始事件，这可能是因为注册该监听器时异步调用已经开始了的缘故。

在Filter中进行异步调用与在Servlet中进行异步调用的效果完全相似

### 改进的Servlet API

Servlet 3.0还有一个改变是改进了部分API，这种改进很好地简化了Java Web开发。其中两个较大的改进是：

HttpServletRequest增加了对文件上传的支持。

ServletContext允许通过编程的方式动态注册Servlet、Filter。

HttpServletRequest提供了如下两个方法来处理文件上传。

Part getPart(String name)：根据名称来获取文件上传域。

Collection<Part> getParts()：获取所有的文件上传域。

上面两个方法的返回值都涉及一个API：Part，每个Part对象对应于一个文件上传域，该对象提供了大量方法来访问上传文件的文件类型、大小、输入流等，并提供了一个write(String file)方法将上传文件写入服务器磁盘。

为了向服务器上传文件，需要在表单里使用`<input type="file" .../>`文件域，这个文件域会在HTML页面上产生一个单行文本框和一个"浏览"按钮，浏览者可通过该按钮选择需要上传的文件。除此之外，上传文件一定要为表单域设置enctype属性。

表单的enctype属性指定的是表单数据的编码方式，该属性有如下三个值。

* application/x-www-form-urlencoded：这是默认的编码方式，它只处理表单域里的value属性值，采用这种编码方式的表单会将表单域的值处理成URL编码方式。
* multipart/form-data：这种编码方式会以二进制流的方式来处理表单数据，这种编码方式会把文件域指定文件的内容也封装到请求参数里。
* text/plain：这种编码方式当表单的action属性为mailto:URL的形式时比较方便，这种方式主要适用于直接通过表单发送邮件的方式。

如果将enctype设置为application/x-www-form-urlencoded，或不设置enctype属性，提交表单时只会发送文件域的文本框里的字符串，也就是浏览者所选择文件的绝对路径，对服务器获取该文件在客户端上的绝对路径没有任何作用，因为服务器不可能访问客户机的文件系统。

UploadServlet.java:

```
@WebServlet(name="upload" , urlPatterns={"/upload"})
@MultipartConfig
public class UploadServlet extends HttpServlet {
    public void service(HttpServletRequest request , HttpServletResponse response) throws IOException , ServletException { 
        response.setContentType("text/html;charset=GBK");
        PrintWriter out = response.getWriter();
        //获取普通请求参数
        String fileName = request.getParameter("name");
        //获取文件上传域
        Part part = request.getPart("file");
        //获取上传文件的类型
        out.println("上传文件的类型为：" + part.getContentType() + "<br/>");
        //获取上传文件的大小
        out.println("上传文件的的大小为：" + part.getSize()  + "<br/>");
        //获取该文件上传域的Header Name
        Collection<String> headerNames = part.getHeaderNames();
        //遍历文件上传域的Header Name、Value
        for (String headerName : headerNames) {
            out.println(headerName + "--->" + part.getHeader(headerName) + "<br/>");
        }
        //将上传的文件写入服务器
        part.write(getServletContext().getRealPath("/uploadFiles") + "/" + fileName );
        //①
    }
} 
```

上面Servlet使用了@MultipartConfig修饰，处理文件上传的Servlet应该使用该Annotation修饰。接下来该Servlet中HttpServletRequest就可通过getPart(String name)方法来获取文件上传域--就像获取普通请求参数一样。

与Servlet 3.0所有Annotation相似的是，Servlet 3.0为@提供了相似的配置元素，我们同样可以通过在<servlet.../>元素中添加<multipart-config.../>子元素来达到相同的效果。

上面Servlet上传时保存的文件名直接使用了name请求参数，实际项目中一般不会这么做，因为可能多个用户会填写相同的name参数，这样将导致后面用户上传的文件覆盖前面用户上传的图片。实际项目中可借助于java.util.UUID工具类生成文件名。

ServletContext则提供了如下方法来动态地注册Servet、Filter，并允许动态设置Web应用的初始化参数。

* 多个重载的addServlet：动态地注册Servlet。
* 多个重载的addFilter：动态地注册Filter。
* 多个重载的addListener：动态地注册Listener。

setInitParameter(String name, String value)：为Web应用设置初始化参数。
