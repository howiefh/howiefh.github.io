title: Shiro & CAS 实现单点登录
date: 2015-05-19 00:11:12
tags: [Shiro, CAS, SSO]
categories:
- Java
- Shiro
description: Shiro; CAS; SSO; Shrio 单点登录；单点登出；单点登录 验证码；单点登录 记住密码；单点登陆 查询数据库; 单点登录 自定义
---

## 概览

单点登录主要用于多系统集成，即在多个系统中，用户只需要到一个中央服务器登录一次即可访问这些系统中的任何一个，无须多次登录。

本文使用开源框架[Jasig CAS]来完成单点登录。下载地址：<https://www.apereo.org/cas/download>。在写本文时，使用的cas server版本为4.0.1

<!-- more -->

## 部署服务器

本文服务器使用Tomcat7，下载了[cas-server-4.0.0-release.zip](http://downloads.jasig.org/cas/cas-server-4.0.0-release.zip)，将其解压，找到modules目录下面的cas-server-webapp-4.0.0.war直接复制到webapps文件夹下即可。启动Tomcat，访问http://localhost:8080/cas-server-webapp-4.0.0，使用casuser/Mellon登录，即可登录成功。

Tomcat默认没有开启HTTPS协议，所以这里直接用了HTTP协议访问。为了能使客户端在HTTP协议下单点登录成功，需要修改一下配置：

* WEB-INF\spring-configuration\ticketGrantingTicketCookieGenerator.xml和WEB-INF\spring-configuration\warnCookieGenerator.xml：将`p:cookieSecure="true"`改为`p:cookieSecure="false"`

* WEB-INF\deployerConfigContext.xml：`<bean class="org.jasig.cas.authentication.handler.support.HttpBasedServiceCredentialsAuthenticationHandler" p:httpClient-ref="httpClient" />`添加` p:requireSecure="false"`

至此，一个简单的单点登录服务器就基本部署好了。

## 部署客户端

客户端需要添加对[shiro-cas]和cas-client-core这两个包的依赖。这里主要讲跟CAS相关的配置。

之后配置web.xml

```
<!-- 用于单点退出，该过滤器用于实现单点登出功能，可选配置。-->
<listener>
    <listener-class>org.jasig.cas.client.session.SingleSignOutHttpSessionListener</listener-class>
</listener>
<!-- 该过滤器用于实现单点登出功能，可选配置。 -->
<filter>
    <filter-name>CAS Single Sign Out Filter</filter-name>
    <filter-class>org.jasig.cas.client.session.SingleSignOutFilter</filter-class>
</filter>
<filter-mapping>
    <filter-name>CAS Single Sign Out Filter</filter-name>
    <url-pattern>/*</url-pattern>
</filter-mapping>
```

自定义Realm：

```
public class MyCasRealm extends CasRealm {

    private UserService userService;

    public void setUserService(UserService userService) {
        this.userService = userService;
    }

    @Override
    protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principals) {
        String username = (String)principals.getPrimaryPrincipal();
        SimpleAuthorizationInfo authorizationInfo = new SimpleAuthorizationInfo();
        authorizationInfo.setRoles(userService.findRoles(username));
        authorizationInfo.setStringPermissions(userService.findPermissions(username));
        return authorizationInfo;
    }
}
```

配置

```
<bean id="casRealm" class="package.for.your.MyCasRealm">
    <property name="userService" ref="userService"/>
    <property name="cachingEnabled" value="true"/>
    <property name="authenticationCachingEnabled" value="true"/>
    <property name="authenticationCacheName" value="authenticationCache"/>
    <property name="authorizationCachingEnabled" value="true"/>
    <property name="authorizationCacheName" value="authorizationCache"/>
    <!--该地址为cas server地址 -->
    <property name="casServerUrlPrefix" value="${shiro.casServer.url}"/>
    <!-- 该地址为是当前应用 CAS 服务 URL，即用于接收并处理登录成功后的 Ticket 的，
    必须和loginUrl中的service参数保持一致，否则服务器会判断service不匹配-->
    <property name="casService" value="${shiro.client.cas}"/>
</bean>
```

配置CAS过滤器

```
<bean id="casFilter" class="org.apache.shiro.cas.CasFilter">
    <property name="failureUrl" value="/casFailure.jsp"/>
</bean>
<bean id="shiroFilter" class="org.apache.shiro.spring.web.ShiroFilterFactoryBean">
    <property name="securityManager" ref="securityManager"/>
    <property name="loginUrl" value="${shiro.login.url}"/>
    <property name="successUrl" value="${shiro.login.success.url}"/>
    <property name="filters">
        <util:map>
            <entry key="cas" value-ref="casFilter"/>
            <entry key="logout" value-ref="logoutFilter" />
        </util:map>
    </property>
    <property name="filterChainDefinitions">
        <value>
            /casFailure.jsp = anon
            /cas = cas
            /logout = logout
            /** = user
        </value>
    </property>
</bean>
```

上面登录url我的配置的是`http://localhost:8080/cas-server/login?service=http://localhost:8080/cas-client/cas`，service参数是之后服务将会跳转的地址。

`/cas=cas`：即/cas 地址是服务器端回调地址，使用 CasFilter 获取 Ticket 进行登录。

之后通过eclipse部署，访问http://localhost:8080/cas-client 即可测试。为了看到单点登录的效果，可以直接复制一份webapps中的client为client2，只需要修改上述配置中的地址即可。如果用户已经登录，那么访问http://localhost:8080/cas-client2发现不会再跳转到登录页面了，用户已经是登录状态了。

还需要注意一个问题，就是cas server默认是开启单点登出的但是这里却没有这样的效果，APP1登出了，但是APP2仍能访问，如果查看浏览器的cookie的话，会发现有两个sessionid，一个是JSESSIONID，容器原生的，另一个是shiro中配置的:

```
<!-- 会话Cookie模板 -->
<bean id="sessionIdCookie" class="org.apache.shiro.web.servlet.SimpleCookie">
SingleSignOutFilter发现是logoutRequest请求后，原来SingleSignOutHandler中创建的原生的session已经被销毁了，因为从a登出的，a的shiro session也会销毁，
    但是b的shiro的session还没有被销毁，于是再访问b还是能访问，单点登出就有问题了-->
    <constructor-arg value="JSESSIONID"/>
    <property name="httpOnly" value="true"/>
    <property name="maxAge" value="-1"/>
```

如果我们把sid改为JSESSIONID会怎么样，答案是如果改为JSESSIONID会导致重定向循环，原因是当登录时，shiro发现浏览器发出的请求中的JSESSIONID没有或已经过期，于是生成一个JSESSIONID给浏览器，同时链接被重定向到服务器进行认证，认证成功后返回到客户端服务器的cas service url，并且带有一个ticket参数。因为有SingleSignOutFilter，当发现这是一个tocken请求时，SingleSignOutHandler会调用request.getSession()获取的是原生Session，如果没有原生session的话，又会创建并将JSESSIONID保存到浏览器cookie中，当客户端服务器向cas服务器验证ticket之后，客户端服务器重定向到之前的页面，这时shiro发现JSESSIONID是SingleSignOutHandler中生成的，在自己维护的session中查不到，又会重新生成新的session，然后login，然后又会重定向到cas服务器认证，然后再重定向到客户端服务器的cas service url，不同的是SingleSignOutHandler中这次调用session.getSession(true)不会新创建一个了，之后就如此循环。如果使用sid又会导致当单点登出时候，如果有a、b两个客户端服务器，从a登出，会跳转到cas服务器登出，cas服务器会对所有通过它认证的service调用销毁session的方法，但是b的shiro的session还没有被销毁，于是再访问b还是能访问，单点登出就有问题了

之所以这样是因为我设置shiro的session管理器为DefaultWebSessionManager，这个管理器直接抛弃了容器的session管理器，自己来维护session，所以就会出现上述描述的问题了。如果我们不做设置，那么shiro将使用默认的session管理器ServletContainerSessionManager：Web 环境，其直接使用 Servlet 容器的会话。这样单点登出就可以正常使用了。

此外如果我们非要使用DefaultWebSessionManager的话，我们就要重写一个SingleSignOutFilter、SingleSignOutHandler和SessionMappingStorage了。

如果没有使用Spring框架，则可以参考如下配置web.xml

```
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns="http://java.sun.com/xml/ns/javaee" xmlns:web="http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd"
	xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd"
	id="WebApp_ID" version="2.5">
	<display-name>YPshop Authority Manage</display-name>
	<context-param>
		<param-name>webAppRootKey</param-name>
		<param-value>authority.root</param-value>
	</context-param>

	<!-- ======================== 单点登录开始 ======================== -->
	<!-- 说明：这种客户端的配置方式是不需要Spring支持的 -->
	<!-- 参考资料：http://blog.csdn.net/yaoweijq/article/details/6003187 -->
	<listener>
      <listener-class>org.jasig.cas.client.session.SingleSignOutHttpSessionListener</listener-class>
	</listener>
	<filter>
	<filter-name>CAS Single Sign Out Filter</filter-name>
	    <filter-class>org.jasig.cas.client.session.SingleSignOutFilter</filter-class>
	</filter>
	<filter-mapping>
	    <filter-name>CAS Single Sign Out Filter</filter-name>
	    <url-pattern>/*</url-pattern>
	</filter-mapping>
	<filter>
	    <filter-name>CAS Authentication Filter</filter-name>
	    <filter-class>org.jasig.cas.client.authentication.AuthenticationFilter</filter-class>
	    <init-param>
	        <param-name>casServerLoginUrl</param-name>
	        <param-value>https://localhost:8443/cas-server/login</param-value>
	    </init-param>
	    <init-param>
	        <param-name>serverName</param-name>
	        <param-value>https://localhost:8443</param-value>
	    </init-param>
	</filter>
	<filter-mapping>
	    <filter-name>CAS Authentication Filter</filter-name>
	    <url-pattern>/*</url-pattern>
	</filter-mapping>
	<filter>
	    <filter-name>CAS Validation Filter</filter-name>
	    <filter-class>org.jasig.cas.client.validation.Cas20ProxyReceivingTicketValidationFilter</filter-class>
	    <init-param>
	        <param-name>casServerUrlPrefix</param-name>
	        <param-value>https://localhost:8443/cas-server</param-value>
	    </init-param>
	    <init-param>
	        <param-name>serverName</param-name>
	        <param-value>https://localhost:8443</param-value>
	    </init-param>
	</filter>
	<filter-mapping>
	    <filter-name>CAS Validation Filter</filter-name>
	    <url-pattern>/*</url-pattern>
	</filter-mapping>
		<!-- 该过滤器使得开发者可以通过org.jasig.cas.client.util.AssertionHolder来获取用户的登录名。 比如AssertionHolder.getAssertion().getPrincipal().getName()。 -->
 	<filter>
		<filter-name>CAS Assertion Thread Local Filter</filter-name>
		<filter-class>org.jasig.cas.client.util.AssertionThreadLocalFilter</filter-class>
	</filter>
	<filter-mapping>
	    <filter-name>CAS Assertion Thread Local Filter</filter-name>
	    <url-pattern>/*</url-pattern>
	</filter-mapping>
	<!-- ======================== 单点登录结束 ======================== -->

	<welcome-file-list>
		<welcome-file>index.html</welcome-file>
		<welcome-file>index.jsp</welcome-file>
	</welcome-file-list>
	<distributable />
</web-app>
```

## 进阶

### 使用HTTPS协议

首先我们需要生成数字证书
```
keytool -genkey -keystore "D:\localhost.keystore" -alias localhost -keyalg RSA
输入密钥库口令:
再次输入新口令:
您的名字与姓氏是什么?
[Unknown]: localhost
您的组织单位名称是什么?
[Unknown]: xa
您的组织名称是什么?
[Unknown]: xa
您所在的城市或区域名称是什么?
[Unknown]: xi'an
您所在的省/市/自治区名称是什么?
[Unknown]: xi'an
该单位的双字母国家/地区代码是什么?
[Unknown]: cn
CN=localhost, OU=xa, O=xa, L=xi'an, ST=xi'an, C=cn 是否正确
?
[否]: y
输入 <localhost> 的密钥口令
(如果和密钥库口令相同, 按回车):
```

需要注意的是 "您的名字与姓氏是什么?"这个地方不能随便填的，如果运行过程中提示“Caused by: java.security.cert.CertificateException: No name matching localhost found”那么就是因为这里设置错了，当然除了localhost也可以写其他的，如helloworld.com，但是需要能解析出来，可以直接在hosts中加`127.0.0.1 helloworld.com`

然后，由于Tomcat默认没有开HTTPS，所以我们需要在server.xml文件中找到8443出现的地方。然后修改如下

```
<Connector port="8443" protocol="HTTP/1.1" SSLEnabled="true"
    maxThreads="150" scheme="https" secure="true"
    clientAuth="false" sslProtocol="TLS"
    keystoreFile="D:\localhost.keystore" keystorePass="123456"/>
```

keystorePass 就是生成 keystore 时设置的密码。

如果出现下面的问题，修改server.xml中的protocol为`org.apache.coyote.http11.Http11Protocol`

Failed to initialize end point associated with ProtocolHandler [“http-apr-8443”]
java.lang.Exception: Connector attribute SSLCertificateFile must be defined when using SSL with APR

因为 CAS client 需要使用该证书进行验证，所以我们要使用 localhost.keystore 导出数字证书（公钥）到 D:\localhost.cer。再将将证书导入到 JDK 中。

```
keytool -export -alias localhost -file D:\localhost.cer -keystore D:\localhost.keystore
cd D:\jdk1.7.0_21\jre\lib\security
keytool -import -alias localhost -file D:\localhost.cer -noprompt -trustcacerts -storetype jks -keystore cacerts -storepass 123456
```

如果导入失败，可以先把 security 目录下的 cacerts 删掉

搞定证书之后，我们需要将之前client中配置的地址修改一下。然后还可以添加ssl过滤器。

如果遇到以下异常，一般是证书导入错误造成的，请尝试重新导入，如果还是不行，有可能是运行应用的 JDK 和安装数字证书的 JDK 不是同一个造成的：

Caused by: sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target

### 单点登出重定向

客户端中配置logout过滤器

```
<bean id="logoutFilter" class="org.apache.shiro.web.filter.authc.LogoutFilter">
    <property name="redirectUrl" value="${shiro.logout.url}"/>
</bean>
```

WEB-INF/cas-servlet.xml中将 `cas.logout.followServiceRedirects`修改为true即可在登出后重定向到service参数提供的地址

### 单点登出

单点登出重定向是很好解决了，但是在客户端与shiro集成过程中，如客户端部署部分所述，如果shiro没有使用 ServletContainerSessionManager 管理session，单点登出就会有问题了。最简单奏效的办法就是改用 ServletContainerSessionManager 了，但是我们偏要用 DefaultWebSessionManager 呢，那就应该要参考org.jasig.cas.client.session这个包中的几个类，重新实现单点登出了。我的思路是，添加一个shiro过滤器，继承自AdviceFilter在preHandle方法中实现逻辑：如果请求中包含了ticket参数，记录ticket和sessionID的映射；如果请求中包含logoutRequest参数，标记session为无效；如果session不为空，且被标记为无效，则登出。如果请求中包含了logoutRequest参数，那么这个请求是从cas服务器发出的，所以这里不能直接用subject.logout()，因为subject跟线程绑定，客户端对cas服务器端的请求会创建一个新的subject。

那么CAS单点登出是怎么实现的呢，下面是我对CAS单点登出的简单理解：

在TicketGrantingTicketImpl有一个HashMap<String, Service> services字段，以id和通过认证的客户端service为键值对。当我们要登出时LogoutManagerImpl通过for (final String ticketId : services.keySet())向每个service发送一个POST请求，请求中包含一个logoutRequest参数，参数的值由SamlCompliantLogoutMessageCreator创建。客户端的 SingleSignOutFilter会判断请求中是否包含了logoutRequest参数，如果包含，那么销毁session。SingleSignOutHttpSessionListener实现了javax.servlet.http.HttpSessionListener接口，用于监听session销毁事件。

我在配置的过程中发现单点登出有问题，首先在服务端打开 debug log，cas 服务器默认是打开单点登出功能的，所以正常的话日志中会记录`<Sending logout request for: [https://localhost:8443/cas-client1/cas]>`之类的内容，有日志记录发送了请求，一般服务器应该不会有什么问题了。那么有可能会是客户端的问题，我重新配置了一个客户端，这个客户端没有使用spring也没有使用shiro，只用了在部署客户端中提到的无spring的web.xml文件，发现从其他客户端登出，这个客户端也是登出的，所以这个配置是没有什么问题。后来在浏览器打开控制台才发现有两个SESSIONID一个是sid是在shiro中配置的，另一个是JSESSIONID，应该是容器原生的。再然后就下了3.2.2版本的cas-client-core，通过maven构建，导入eclipse中，开始调试。我们的cas-client要依赖这个cas-client-core工程，怎么设置可以参考[eclipse小技巧](http://howiefh.github.io/2014/02/08/eclipse-tips/)。然后调试，一定要保证在cas-client的propertie 设置中的Deployment Assembly中已经没有之前的版本的cas-client-core的jar包了。调试的过程中才发现，SingleSignOutFilter销毁的是容器原生的session，但是shiro的session还在，所以如果是从其他客户端登出的，那这个客户端还是能够登录。

### 通过数据库中的用户密码认证

服务器端需要添加cas-server-support-jdbc和mysql-connector-java依赖。

cas-server-support-jdbc提供了org.jasig.cas.adaptors.jdbc.QueryDatabaseAuthenticationHandler、org.jasig.cas.adaptors.jdbc.SearchModeSearchDatabaseAuthenticationHandler 和org.jasig.cas.adaptors.jdbc.QueryAndEncodeDatabaseAuthenticationHandler。他们都继承自AbstractJdbcUsernamePasswordAuthenticationHandler 能够通过配置sql语句验证用户凭证，后者更复杂些，能够配置盐，散列函数迭代次数。

下面说一下配置QueryDatabaseAuthenticationHandler，配置/src/main/webapp/WEB-INF/deployerConfigContext.xml，先注释掉原先的primaryAuthenticationHandler然后添加下面配置

```
<!-- 自定义数据库鉴权 -->
<bean id="primaryAuthenticationHandler" class="org.jasig.cas.adaptors.jdbc.QueryDatabaseAuthenticationHandler">
    <property name="dataSource" ref="dataSource"/>
    <property name="sql"  value="${auth.sql}"/>
    <property name="passwordEncoder" ref="MD5PasswordEncoder"/>
</bean>

<!-- 数据源 -->
<bean id="dataSource" class="org.springframework.jdbc.datasource.DriverManagerDataSource">
     <property name="driverClassName" value="${dataSource.driver}"></property>
     <property name="url" value="${dataSource.url}"/>
     <property name="username" value="${dataSource.username}"/>
     <property name="password" value="${dataSource.password}"/>
 </bean>
 <!-- MD5加密 -->
<bean id="MD5PasswordEncoder" class="org.jasig.cas.authentication.handler.DefaultPasswordEncoder">
    <constructor-arg value="MD5"/>
</bean>
```

加密算法可以自定义。

### 添加验证码

验证码的实现使用了kaptcha，所以需要添加其依赖。

web.xml添加如下配置

```
<servlet>
    <servlet-name>Kaptcha</servlet-name>
    <servlet-class>com.google.code.kaptcha.servlet.KaptchaServlet</servlet-class>
    <!-- 设定宽度 -->
    <init-param>
        <param-name>kaptcha.image.width</param-name>
        <param-value>100</param-value>
    </init-param>
    <!-- 设定高度 -->
    <init-param>
        <param-name>kaptcha.image.height</param-name>
        <param-value>50</param-value>
    </init-param>
    <!-- 如果需要全部是数字 -->
    <init-param>
        <param-name>kaptcha.textproducer.char.string</param-name>
        <param-value>0123456789</param-value>
    </init-param>
    <!-- 去掉干扰线 -->
    <init-param>
        <param-name>kaptcha.noise.impl</param-name>
        <param-value>com.google.code.kaptcha.impl.NoNoise </param-value>
    </init-param>
</servlet>
<servlet-mapping>
    <servlet-name>Kaptcha</servlet-name>
    <url-pattern>/captcha.jpg</url-pattern>
</servlet-mapping>
```

在login-webflow.xml中找到viewLoginForm，在binder节点下面添加`<binding property="captcha" />`，对应我们页面提交的验证码参数

然后我们还要实现一个UsernamePasswordCaptchaCredential 类，继承UsernamePasswordCredential 在其中添加了captcha字段和相应setter和getter方法。

```
public class UsernamePasswordCaptchaCredential extends UsernamePasswordCredential {
	private static final long serialVersionUID = -2988130322912201986L;
    @NotNull
    @Size(min=1,message = "required.captcha")
    private String captcha;

    //set、get方法
}
```

接着回到 login-webflow.xml ，找到credential的声明处，将org.jasig.cas.authentication.UsernamePasswordCredential修改为刚刚实现的类全路径名。viewLoginForm 也需要修改

```
<transition on="submit" bind="true" validate="true" to="validatorCaptcha">
    <evaluate expression="authenticationViaFormAction.doBind(flowRequestContext, flowScope.credential)" />
</transition>
```

再添加如下配置

```
<!-- 添加一个 validatorCaptcha 校验验证码的操作 -->
<action-state id="validatorCaptcha">
    <evaluate expression="authenticationViaFormAction.validatorCaptcha(flowRequestContext, flowScope.credential, messageContext)"></evaluate>
    <transition on="error" to="generateLoginTicket" />
    <transition on="success" to="realSubmit" />
</action-state>
```

我们在配置中添加了一个 validatorCaptcha 的操作，同时可以看到 expression 是 authenticationViaFormAction.validatorCaptcha(...)，所以我们需要在  authenticationViaFormAction 中添加一个校验验证码的方法 validatorCaptcha()。authenticationViaFormAction 这个bean是配置在 cas-servlet.xml 中的：

```
<bean id="authenticationViaFormAction" class="org.jasig.cas.web.flow.AuthenticationViaFormAction"
    p:centralAuthenticationService-ref="centralAuthenticationService"
    p:warnCookieGenerator-ref="warnCookieGenerator"
    p:ticketRegistry-ref="ticketRegistry"/>
```

我们可以看看 org.jasig.cas.web.flow.AuthenticationViaFormAction 的源代码，里面有一个 submit 方法，这个就是我们提交表单时的方法了。继承AuthenticationViaFormAction实现一个新类

```
public class MyAuthenticationViaFormAction extends AuthenticationViaFormAction{

    public final String validatorCaptcha(final RequestContext context, final Credential credential,
            final MessageContext messageContext){

            final HttpServletRequest request = WebUtils.getHttpServletRequest(context);
            HttpSession session = request.getSession();
            String captcha = (String)session.getAttribute(com.google.code.kaptcha.Constants.KAPTCHA_SESSION_KEY);
            session.removeAttribute(com.google.code.kaptcha.Constants.KAPTCHA_SESSION_KEY);

            UsernamePasswordCaptchaCredential upc = (UsernamePasswordCaptchaCredential)credential;
            String submitAuthcodeCaptcha =upc.getCaptcha();


            if(!StringUtils.hasText(submitAuthcodeCaptcha) || !StringUtils.hasText(submitAuthcodeCaptcha)){
                messageContext.addMessage(new MessageBuilder().code("required.captcha").build());
                return "error";
            }
            if(submitAuthcodeCaptcha.equals(captcha)){
                return "success";
            }
            messageContext.addMessage(new MessageBuilder().code("error.authentication.captcha.bad").build());
            return "error";
    }
}
```

这边有抛出两个异常，这两个异常信息 required.captcha、error.authentication.captcha.bad 需要在 messages_zh_CN.properties 文件下添加

```
required.captcha=必须输入验证码。
error.authentication.captcha.bad=您输入的验证码有误。
```

然后把 authenticationViaFormAction 这个Bean路径修改为我们新添加的类的全路径名。

当然最后，我们的页面也需要修改，找到casLoginView.jsp添加

```
<section class="row">
        <spring:message code="screen.welcome.label.captcha.accesskey" var="captchaAccessKey" />
        <spring:message code="screen.welcome.label.captcha" var="captchaHolder" />
        <form:input cssClass="required" cssErrorClass="error" id="captcha" size="10" tabindex="3"  path="captcha" placeholder="${captchaHolder }" accesskey="${captchaAccessKey}" autocomplete="off" htmlEscape="true" />
        <img alt="${captchaHolder }" src="captcha.jpg" onclick="this.src='captcha.jpg?'+Math.random();">
</section>
```

以上添加验证码参考<http://www.cnblogs.com/vhua/p/cas_3.html>

### 添加记住密码

可以参考<http://jasig.github.io/cas/development/installation/Configuring-LongTerm-Authentication.html>

在cas.properties中添加如下配置

```
# Long term authentication session length in seconds
rememberMeDuration=1209600
```

spring-configuration文件夹下找到 ticketExpirationPolicies.xml 和 ticketGrantingTicketCookieGenerator.xml 需要在这两个配置文件中定义长期有效的session

在 ticketExpirationPolicies.xml文件中更新如下配置

```
<bean id="standardSessionTGTExpirationPolicy"
      class="org.jasig.cas.ticket.support.TicketGrantingTicketExpirationPolicy"
      p:maxTimeToLiveInSeconds="${tgt.maxTimeToLiveInSeconds:28800}"
      p:timeToKillInSeconds="${tgt.timeToKillInSeconds:7200}"/>

<!--
   | The following policy applies to long term CAS SSO sessions.
   | Default duration is two weeks (1209600s).
   -->
<bean id="longTermSessionTGTExpirationPolicy"
      class="org.jasig.cas.ticket.support.TimeoutExpirationPolicy"
      c:timeToKillInMilliSeconds="#{ ${rememberMeDuration:1209600} * 1000 }" />

<bean id="grantingTicketExpirationPolicy"
      class="org.jasig.cas.ticket.support.RememberMeDelegatingExpirationPolicy"
      p:sessionExpirationPolicy-ref="standardSessionTGTExpirationPolicy"
      p:rememberMeExpirationPolicy-ref="longTermSessionTGTExpirationPolicy" />
```

更新ticketGrantingTicketCookieGenerator.xml

```
<bean id="ticketGrantingTicketCookieGenerator" class="org.jasig.cas.web.support.CookieRetrievingCookieGenerator"
      p:cookieSecure="true"
      p:cookieMaxAge="-1"
      p:rememberMeMaxAge="${rememberMeDuration:1209600}"
      p:cookieName="CASTGC"
      p:cookiePath="/cas" />
```

在 deployerConfigContext.xml 中找到 PolicyBasedAuthenticationManager 使其包含RememberMeAuthenticationMetaDataPopulator组件

```
<property name="authenticationMetaDataPopulators">
	<list>
		<bean
			class="org.jasig.cas.authentication.SuccessfulHandlerMetaDataPopulator" />
		<bean
			class="org.jasig.cas.authentication.principal.RememberMeAuthenticationMetaDataPopulator" />
	</list>
</property>
```

和添加验证码类似的，我们还需要修改login-webflow.xml

找到credential 的声明修改如下

```
<var name="credential" class="org.jasig.cas.authentication.RememberMeUsernamePasswordCredential" />
```

由于之前已经实现了验证码，所以这里不需要修改了，只需让 UsernamePasswordCaptchaCredential继承RememberMeUsernamePasswordCredential即可

找到viewLoginForm 在binder节点下添加`<binding property="rememberMe" />`

更新 casLoginView.jsp

```
<section class="row check">
    <input id="rememberMe" name="rememberMe" value="false" tabindex="4" accesskey="<spring:message code="screen.welcome.label.rememberMe.accesskey" />" type="checkbox" />
    <label for="rememberMe"><spring:message code="screen.welcome.label.rememberMe" /></label>
</section>
```

### 自定义primaryAuthenticationHandler

虽然已经有QueryDatabaseAuthenticationHandler和QueryAndEncodeDatabaseAuthenticationHandler两个类，能够通过配置sql语句验证用户凭证，后者还能配置盐，散列函数迭代次数。但是我们可能还需要判断用户是否被锁定或被禁用了，我们可以参考QueryAndEncodeDatabaseAuthenticationHandler自定义一个AuthenticationHandler，继承AbstractJdbcUsernamePasswordAuthenticationHandler。添加两个字段名lockedFieldName和disabledFieldName通过这两个字段判断用户是否被锁定或被禁用，关键代码如下

```
public class ValidUserQueryDBAuthenticationHandler extends AbstractJdbcUsernamePasswordAuthenticationHandler{
    ......
    private static final String DEFAULT_LOCKED_FIELD = "locked";
    private static final String DEFAULT_DISABLED_FIELD = "disabled";
    ......
    @NotNull
    protected String disabledFieldName = DEFAULT_DISABLED_FIELD;
    @NotNull
    protected String lockedFieldName = DEFAULT_LOCKED_FIELD;
    ......
    public ValidUserQueryDBAuthenticationHandler(final DataSource datasource, final String sql, final String algorithmName) {
        super();
        setDataSource(datasource);
        this.sql = sql;
        this.algorithmName = algorithmName;
    }

    @Override
    protected final HandlerResult authenticateUsernamePasswordInternal(final UsernamePasswordCredential transformedCredential)
            throws GeneralSecurityException, PreventedException {
        final String username = getPrincipalNameTransformer().transform(transformedCredential.getUsername());

        try {
            final Map<String, Object> values = getJdbcTemplate().queryForMap(this.sql, username);

            if (Boolean.TRUE.equals(values.get(this.disabledFieldName))) {
                throw new AccountDisabledException(username + "  has been disabled.");
            }
            if (Boolean.TRUE.equals(values.get(this.lockedFieldName))) {
                throw new AccountLockedException(username + "  has been locked.");
            }

            final String digestedPassword = digestEncodedPassword(transformedCredential.getPassword(), values);
            if (!values.get(this.passwordFieldName).equals(digestedPassword)) {
                throw new FailedLoginException("Password does not match value on record.");
            }
            return createHandlerResult(transformedCredential,
                    new SimplePrincipal(username), null);

        } catch (final IncorrectResultSizeDataAccessException e) {
            if (e.getActualSize() == 0) {
                throw new AccountNotFoundException(username + " not found with SQL query");
            } else {
                throw new FailedLoginException("Multiple records found for " + username);
            }
        } catch (final DataAccessException e) {
            throw new PreventedException("SQL exception while executing query for " + username, e);
        }

    }

    protected String digestEncodedPassword(final String encodedPassword, final Map<String, Object> values) {
        final ConfigurableHashService hashService = new DefaultHashService();

        if (StringUtils.isNotBlank(this.staticSalt)) {
            hashService.setPrivateSalt(ByteSource.Util.bytes(this.staticSalt));
        }
        hashService.setHashAlgorithmName(this.algorithmName);

        Long numOfIterations = this.numberOfIterations;
        if (values.containsKey(this.numberOfIterationsFieldName)) {
            final String longAsStr = values.get(this.numberOfIterationsFieldName).toString();
            numOfIterations = Long.valueOf(longAsStr);
        }

        hashService.setHashIterations(numOfIterations.intValue());
        if (!values.containsKey(this.saltFieldName)) {
            throw new RuntimeException("Specified field name for salt does not exist in the results");
        }

        final String dynaSalt = values.get(this.saltFieldName)==null?"":values.get(this.saltFieldName).toString();
        final HashRequest request = new HashRequest.Builder()
                                    .setSalt(dynaSalt)
                                    .setSource(encodedPassword)
                                    .build();
        return hashService.computeHash(request).toHex();
    }

    public final void setDisabledFieldName(final String disabledFieldName) { this.disabledFieldName = disabledFieldName; }
    public final void setLockedFieldName(final String lockedFieldName) { this.lockedFieldName = lockedFieldName; }
}
```

然后更新配置deployerConfigContext.xml

```
<bean id="primaryAuthenticationHandler" class="io.github.howiefh.cas.authentication.ValidUserQueryDBAuthenticationHandler">
    <constructor-arg ref="dataSource" index="0"></constructor-arg>
    <constructor-arg value="${auth.sql}" index="1"></constructor-arg>
    <constructor-arg value="MD5" index="2"></constructor-arg>
</bean>
```

### 自定义登录页面

1. 在cas.properties 修改 cas.viewResolver.basename  值为 custom_view ，那样系统就会自动会查找 custom_view.properties 这个配置文件
2. 直接复制原来的 default_views.properties 就行了，重命名为custom_view.properties
3. 把 custom_view.properties 中的WEB-INF\view\jsp\default全部替换把这地址替换成 WEB-INF\view\jsp\custom
4. 接下来把 cas\WEB-INF\view\jsp\default 下面的所有文件复制，然后重命名为我们需要的名称，cas\WEB-INF\view\jsp\custom

主要修改casLoginView.jsp和cas.css即可

布局时遇到一个问题，就是将页脚固定在页面底部。可以参看[如何将页脚固定在页面底部](http://www.w3cplus.com/css/css-sticky-foot-at-bottom-of-the-page)

### 其它

[【SSO单点系列】（4）：CAS4.0 SERVER登录后用户信息的返回](http://www.cnblogs.com/vhua/p/cas_4.html)
[在多点环境下使用cas实现单点登陆及登出](http://www.cnblogs.com/huangbin/p/3282643.html)
[关于单点登录中的用户信息存储问题的探讨](http://blog.csdn.net/tch918/article/details/22316175)

## 原理

从结构来看，CAS主要分为Server和Client。Server主要负责对用户的认证工作；Client负责处理客户端受保护资源的访问请求，登录时，重定向到Server进行认证。

基础模式的SSO访问流程步骤：

1. 访问服务：客户端发送请求访问应用系统提供的服务资源。
2. 定向认证：客户端重定向用户请求到中心认证服务器。
3. 用户认证：用户进行身份认证
4. 发放票据：服务器会产生一个随机的 Service Ticket 。
5. 验证票据： SSO 服务器验证票据 Service Ticket 的合法性，验证通过后，允许客户端访问服务。
6. 传输用户信息： SSO 服务器验证票据通过后，传输用户认证结果信息给客户端。

CAS最基本的协议过程：

![CAS 最基本的协议过程](http://fh-1.qiniudn.com/cas-clip.jpg)

如上图： CAS Client 与受保护的客户端应用部署在一起，以 Filter 方式保护 Web 应用的受保护资源，过滤从客户端过来的每一个 Web 请求，同时， CAS Client 会分析 HTTP 请求中是否包含请求 Service Ticket( ST 上图中的 Ticket) ，如果没有，则说明该用户是没有经过认证的；于是 CAS Client 会重定向用户请求到 CAS Server （ Step 2 ），并传递 Service （要访问的目的资源地址）。 Step 3 是用户认证过程，如果用户提供了正确的 Credentials ， CAS Server 随机产生一个相当长度、唯一、不可伪造的 Service Ticket ，并缓存以待将来验证，并且重定向用户到 Service 所在地址（附带刚才产生的 Service Ticket ） , 并为客户端浏览器设置一个 Ticket Granted Cookie （ TGC ） ； CAS Client 在拿到 Service 和新产生的 Ticket 过后，在 Step 5 和 Step6 中与 CAS Server 进行身份核实，以确保 Service Ticket 的合法性。

在该协议中，所有与 CAS Server 的交互均采用 SSL 协议，以确保 ST 和 TGC 的安全性。协议工作过程中会有两次重定向的过程。但是 CAS Client 与 CAS Server 之间进行 Ticket 验证的过程对于用户是透明的（使用 HttpsURLConnection ）。

### 相关概念

TGT、ST、PGT、PGTIOU、PT，其中TGT、ST是CAS1.0协议中就有的票据，PGT、PGTIOU、PT是CAS2.0协议中有的票据。

CAS为用户签发登录票据，CAS认证成功后，将TGT对象放入自己的缓存，CAS生成cookie即TGC，自后登录时如果有TGC的话，则说明用户之前登录过，如果没有，则用户需要重新登录。

* TGC （Ticket-granting cookie）：存放用户身份认证凭证的cookie，在浏览器和CAS Server用来明确用户身份的凭证。
* ST（Service Ticket）：CAS服务器通过浏览器分发给客户端服务器的票据。一个特定服务只能有一个唯一的ST。
* PGT（Proxy Granting Ticket）：由 CAS Server 颁发给拥有 ST 凭证的服务， PGT 绑定一个用户的特定服务，使其拥有向 CAS Server 申请，获得 PT 的能力。
* PGTIOU（全称 Proxy Granting Ticket I Owe You）：作用是将通过凭证校验时的应答信息由 CAS Server 返回给 CAS Client ，同时，与该 PGTIOU 对应的 PGT 将通过回调链接传给 Web 应用。 Web 应用负责维护 PGTIOU 与 PGT 之间映射关系的内容表。PGTIOU是CAS的serviceValidate接口验证ST成功后，CAS会生成验证ST成功的xml消息，返回给Proxy Service，xml消息中含有PGTIOU，proxy service收到Xml消息后，会从中解析出PGTIOU的值，然后以其为key，在map中找出PGT的值，赋值给代表用户信息的Assertion对象的pgtId，同时在map中将其删除。
* PT（Proxy Ticket）：是应用程序代理用户身份对目标程序进行访问的凭证；

CAS 基本流程图（没有使用PROXY代理）

![CAS 基本流程图（没有使用PROXY代理）](http://fh-1.qiniudn.com/cas-noproxy.png)

对于客户端来说会通过客户端session判断用户是否已认证，没有的话跳转到服务器认证，对于服务器，通过SSO session判断用户是否认证，没有的话跳到登录页面。

CAS 基本流程图（使用PROXY代理）

![CAS 基本流程图（使用PROXY代理）](http://fh-1.qiniudn.com/cas-proxy.png)

这一节参考：

[【SSO单点系列】（6）：CAS4.0 单点流程序列图（中文版）以及相关术语解释（TGT、ST、PGT、PT、PGTIOU）](http://www.cnblogs.com/vhua/p/cas_6.html)
[CAS实现SSO单点登录原理](http://www.coin163.com/java/cas/cas.html)

代码:[github](https://github.com/howiefh/framework/tree/shiro-cas-sso)

[Jasig CAS]:https://github.com/Jasig/cas/releases
[shiro-cas]:http://shiro.apache.org/cas.html
