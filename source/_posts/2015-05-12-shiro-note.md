title: Shiro笔记
date: 2015-05-12 10:03:26
tags: Shiro
categories:
- Java
- Shiro
description: Shiro; Java安全框架; 认证、授权、加密和会话管理
---

## 简介

Apache Shiro是一个强大易用的Java安全框架，可以帮助我们完成：认证、授权、加密、会话管理、与Web集成、缓存等。

![Shiro基本功能](https://cdn.jsdelivr.net/gh/howiefh/assets/img/shiro-func.png)

* Authentication：身份认证/登录，验证用户是不是拥有相应的身份；
* Authorization：授权，即权限验证，验证某个已认证的用户是否拥有某个权限；即判断用户是否能做事情，常见的如：验证某个用户是否拥有某个角色。或者细粒度的验证某个用户对某个资源是否具有某个权限；
* Session Manager：会话管理，即用户登录后就是一次会话，在没有退出之前，它的所有信息都在会话中；会话可以是普通JavaSE环境的，也可以是如Web环境的；
* Cryptography：加密，保护数据的安全性，如密码加密存储到数据库，而不是明文存储；
* Web Support：Web支持，可以非常容易的集成到Web环境；
* Caching：缓存，比如用户登录后，其用户信息、拥有的角色/权限不必每次去查，这样可以提高效率；
* Concurrency：shiro支持多线程应用的并发验证，即如在一个线程中开启另一个线程，能把权限自动传播过去；
* Testing：提供测试支持；
* Run As：允许一个用户假装为另一个用户（如果他们允许）的身份进行访问；
* Remember Me：记住我，这个是非常常见的功能，即一次登录后，下次再来的话不用登录了。
 
<!-- more -->

**记住一点，Shiro不会去维护用户、维护权限；这些需要我们自己去设计/提供；然后通过相应的接口注入给Shiro即可。**

Shiro的三个核心组件：Subject, SecurityManager 和 Realms. 如下图： 

![Shiro框架图](https://cdn.jsdelivr.net/gh/howiefh/assets/img/shiro-core.png)
 
Subject：即“当前操作用户”。但是，在Shiro中，Subject这一概念并不仅仅指人，也可以是第三方进程、后台帐户（Daemon Account）或其他类似事物。它仅仅意味着“当前跟软件交互的东西”。但考虑到大多数目的和用途，你可以把它认为是Shiro的“用户”概念。Subject代表了当前用户的安全操作，SecurityManager则管理所有用户的安全操作。与Subject的所有交互都会委托给SecurityManager。 

SecurityManager：它是Shiro框架的核心，典型的Facade模式，Shiro通过SecurityManager来管理内部组件实例，并通过它来提供安全管理的各种服务。可以把它看成 DispatcherServlet 前端控制器 

Realm： Realm充当了Shiro与应用安全数据间的“桥梁”或者“连接器”。也就是说，当对用户执行认证（登录）和授权（访问控制）验证时，Shiro会从应用配置的Realm中查找用户及其权限信息。从这个意义上讲，Realm实质上是一个安全相关的DAO：它封装了数据源的连接细节，并在需要时将相关数据提供给Shiro。当配置Shiro时，你必须至少指定一个Realm，用于认证和（或）授权。配置多个Realm是可以的，但是至少需要一个。Shiro内置了可以连接大量安全数据源（又名目录）的Realm，如LDAP、关系数据库（JDBC）、类似INI的文本配置资源以及属性文件等。如果缺省的Realm不能满足需求，你还可以插入代表自定义数据源的自己的Realm实现。 

Shiro完整架构图： 

![Shiro框架图](https://cdn.jsdelivr.net/gh/howiefh/assets/img/shiro-frame.png)
 
* Subject (org.apache.shiro.subject.Subject)
    正在与软件交互的一个特定的实体“view”（用户、第三方服务、时钟守护任务等）。

* SecurityManager (org.apache.shiro.mgt.SecurityManager)
    如同上面提到的，SecurityManager 是 Shiro 的核心，它基本上就是一把“保护伞”用来协调它管理的组件使之平稳地一起工作，它也管理着 Shiro 中每一个程序用户的视图，所以它知道每个用户如何执行安全操作。

* Authenticator(org.apache.shiro.authc.Authenticator)
    Authenticator 是一个组件，负责执行和反馈用户的认证（登录），如果一个用户尝试登录，Authenticator 就开始执行。Authenticator 知道如何协调一个或多个保存有相关用户/帐号信息的 Realm，从这些 Realm中获取这些数据来验证用户的身份以确保用户确实是其表述的那个人。

* Authentication Strategy(org.apache.shiro.authc.pam.AuthenticationStrategy)
    如果配置了多个 Realm，AuthenticationStrategy 将会协调 Realm 确定在一个身份验证成功或失败的条件（例如，如果在一个方面验证成功了但其他失败了，这次尝试是成功的吗？是不是需要所有方面的验证都成功？还是只需要第一个？）

* Authorizer(org.apache.shiro.authz.Authorizer)
    Authorizer 是负责程序中用户访问控制的组件，它是最终判断一个用户是否允许做某件事的途径，像 Authenticator 一样，Authorizer 也知道如何通过协调多种后台数据源来访问角色和权限信息，Authorizer 利用这些信息来准确判断一个用户是否可以执行给定的动作。

* SessionManager(org.apache.shiro.session.mgt.SessionManager)
    SessionManager 知道如何创建并管理用户 Session 生命周期而在所有环境中为用户提供一个强有力的 Session 体验。这在安全框架领域是独一无二--Shiro 具备管理在任何环境下管理用户 Session 的能力，即使没有 Web/Servlet 或者 EJB 容器。默认情况下，Shiro 将使用现有的session（如Servlet Container），但如果环境中没有，比如在一个独立的程序或非 web 环境中，它将使用它自己建立的 session 提供相同的作用，sessionDAO 用来使用任何数据源使 session 持久化。

* SessionDAO(org.apache.shiro.session.mgt.eis.SessionDAO)
    SessionDAO 代表 SessionManager 执行 Session 持久（CRUD）动作，它允许任何存储的数据挂接到 session 管理基础上。

* CacheManager(org.apache.shiro.cache.CacheManager)
    CacheManager 为 Shiro 的其他组件提供创建缓存实例和管理缓存生命周期的功能。因为 Shiro 的认证、授权、会话管理支持多种数据源，所以访问数据源时，使用缓存来提高访问效率是上乘的选择。当下主流开源或企业级缓存框架都可以继承到 Shiro 中，来获取更快更高效的用户体验。

* Cryptography (`org.apache.shiro.crypto.*`)
    Cryptography 在安全框架中是一个自然的附加产物，Shiro 的 crypto 包包含了易用且易懂的加密方式，Hashes（即digests）和不同的编码实现。该包里所有的类都易于理解和使用，曾经用过 Java 自身的加密支持的人都知道那是一个具有挑战性的工作，而 Shiro 的加密 API 简化了 java 复杂的工作方式，将加密变得易用。

* Realms (org.apache.shiro.realm.Realm)
    如同上面提到的，Realm 是 shiro 和你的应用程序安全数据之间的“桥”或“连接”，当实际要与安全相关的数据进行交互如用户执行身份认证（登录）和授权验证（访问控制）时，shiro 从程序配置的一个或多个Realm 中查找这些数据，你需要配置多少个 Realm 便可配置多少个 Realm（通常一个数据源一个），shiro 将会在认证和授权中协调它们。

## 身份验证


认证就是验证用户身份的过程。在认证过程中，用户需要提交实体信息(Principals)和凭据信息(Credentials)以检验用户是否合法。最常见的“实体/凭证”组合便是“用户名/密码”组合。 

### Shiro认证过程 

```
//1、获取SecurityManager工厂，此处使用Ini配置文件初始化SecurityManager
Factory<SecurityManager> factory = new IniSecurityManagerFactory("classpath:shiro.ini");
//2、得到SecurityManager实例 并绑定给SecurityUtils
SecurityManager securityManager = factory.getInstance();
SecurityUtils.setSecurityManager(securityManager);
//3、获取当前执行用户:
Subject currentUser = SecurityUtils.getSubject();
//做点跟 Session 相关的事
Session session = currentUser.getSession();
session.setAttribute("someKey", "aValue");
String value = (String) session.getAttribute("someKey");
if (value.equals("aValue")) {
    log.info("Retrieved the correct value! [" + value + "]");
} 
if (!currentUser.isAuthenticated()) {
    //4、创建用户名/密码身份验证Token（即用户身份/凭证）
    UsernamePasswordToken token = new UsernamePasswordToken(
            "lonestarr", "vespa");
    token.setRememberMe(true);
    try {
        //5、登录、即身份验证
        currentUser.login(token);
    } catch (UnknownAccountException uae) {
        log.info("There is no user with username of " + token.getPrincipal());
    } catch (IncorrectCredentialsException ice) {
        log.info("Password for account " + token.getPrincipal() + " was incorrect!");
    } catch (LockedAccountException lae) {
        log.info("The account for username " + token.getPrincipal() + " is locked. " + "Please contact your administrator to unlock it.");
    }
    // ... 捕获更多异常
    catch (AuthenticationException ae) {
        // 无定义?错误?
    }
} 
// 打印主要识别信息 (本例是 username):
log.info("User [" + currentUser.getPrincipal() + "] logged in successfully.");
// 测试角色:
if (currentUser.hasRole("schwartz")) {
    log.info("May the Schwartz be with you!");
} else {
    log.info("Hello, mere mortal.");
} 
// 测试一个权限 (非（ instance-level） 实例级别)
if (currentUser.isPermitted("lightsaber:weild")) {
    log.info("You may use a lightsaber ring. Use it wisely.");
} else {
    log.info("Sorry, lightsaber rings are for schwartz masters only.");
} 
// 一个(非常强大)的实例级别的权限:
if (currentUser.isPermitted("winnebago:drive:eagle5")) {
    log.info("You are permitted to 'drive' the winnebago with license plate (id) 'eagle5'. "
            + "Here are the keys - have fun!");
} else {
    log.info("Sorry, you aren't allowed to drive the 'eagle5' winnebago!");
}
//6、完成 - 退出t!
currentUser.logout();
```
shiro.ini文件：
```
# Users and their (optional) assigned roles
# username = password, role1, role2, ..., roleN
[users]
root = secret, admin
guest = guest, guest
presidentskroob = 12345, president
darkhelmet = ludicrousspeed, darklord, schwartz
lonestarr = vespa, goodguy, schwartz
# Roles with assigned permissions
# roleName = perm1, perm2, ..., permN
[roles]
admin = *
schwartz = lightsaber:*
goodguy = winnebago:drive:eagle5
```

身份验证的主要流程就是：
1. 收集用户身份/凭证，即如用户名/密码；
2. 调用 Subject.login 进行登录，如果失败将得到相应的 AuthenticationException 异常，根
据异常提示用户错误信息；否则登录成功；
3. 最后调用 Subject.logout 进行退出操作。

**收集实体/凭据信息** 

UsernamePasswordToken支持最常见的用户名/密码的认证机制。同时，由于它实现了RememberMeAuthenticationToken接口，我们可以通过令牌设置“记住我”的功能。但是，“已记住”和“已认证”是有区别的：已记住的用户仅仅是非匿名用户，你可以通过subject.getPrincipals()获取用户信息。但是它并非是完全认证通过的用户，当你访问需要认证用户的功能时，你仍然需要重新提交认证信息。这一区别可以参考亚马逊网站，网站会默认记住登录的用户，再次访问网站时，对于非敏感的页面功能，页面上会显示记住的用户信息，但是当你访问网站账户信息时仍然需要再次进行登录认证。 subject.isAuthenticated()和subject.isRemembered()的值总是相反的。

**提交实体/凭据信息** 

收集了实体/凭据信息之后，我们可以通过SecurityUtils工具类，获取当前的用户，然后通过调用login方法提交认证。 

**认证处理** 

如果login方法执行完毕且没有抛出任何异常信息，那么便认为用户认证通过。之后在应用程序任意地方调用SecurityUtils.getSubject() 都可以获取到当前认证通过的用户实例，使用subject.isAuthenticated()判断用户是否已验证都将返回true. 相反，如果login方法执行过程中抛出异常，那么将认为认证失败。Shiro有着丰富的层次鲜明的异常类来描述认证失败的原因，如代码示例。 

**登出操作** 

登出操作可以通过调用subject.logout()来删除你的登录信息，当执行完登出操作后，Session信息将被清空，subject将被视作为匿名用户。 

以上，是Shiro认证在应用程序中的处理过程，下面将详细解说Shiro认证的内部处理机制。 
 
![身份认证流程](https://cdn.jsdelivr.net/gh/howiefh/assets/img/shiro-authentication.png)

如上图，我们通过Shiro架构图的认证部分，来说明Shiro认证内部的处理顺序： 
1. 应用程序构建了一个终端用户认证信息的AuthenticationToken 实例后，调用Subject.login方法。 
2. Subject的实例通常是DelegatingSubject类（或子类）的实例对象，在认证开始时，会委托应用程序设置的securityManager实例调用securityManager.login(token)方法。 
3. SecurityManager接受到token(令牌)信息后会委托内置的Authenticator的实例（通常都是ModularRealmAuthenticator类的实例）调用authenticator.authenticate(token). ModularRealmAuthenticator在认证过程中会对设置的一个或多个Realm实例进行适配，它实际上为Shiro提供了一个可拔插的认证机制。
4. 如果在应用程序中配置了多个Realm，ModularRealmAuthenticator会根据配置的AuthenticationStrategy(认证策略)来进行多Realm的认证过程。在Realm被调用后，AuthenticationStrategy将对每一个Realm的结果作出响应。注：如果应用程序中仅配置了一个Realm，Realm将被直接调用而无需再配置认证策略。
5. 判断每一个Realm是否支持提交的token，如果支持，Realm将调用getAuthenticationInfo(token); getAuthenticationInfo 方法就是实际认证处理，我们通过覆盖Realm的doGetAuthenticationInfo方法来编写我们自定义的认证处理。 

Realm接口中需要实现的方法。

String getName(); //返回一个唯一的 Realm 名字
boolean supports(AuthenticationToken token); //判断此 Realm 是否支持此 Token
AuthenticationInfo getAuthenticationInfo(AuthenticationToken token) throws AuthenticationException; //根据 Token 获取认证信息

![Realm](https://cdn.jsdelivr.net/gh/howiefh/assets/img/shiro-realm.png)

一般继承AuthorizingRealm即可，需要实现getAuthenticationInfo(AuthenticationToken token)和doGetAuthenticationInfo(PrincipalCollection principals)两个方法

其中主要默认实现如下：
org.apache.shiro.realm.text.IniRealm：[users]部分指定用户名/密码及其角色；[roles]部分指定角色即权限信息；
org.apache.shiro.realm.text.PropertiesRealm：user.username=password,role1,role2 指定用户名/密码及其角色；role.role1=permission1,permission2 指定角色及权限信息；
org.apache.shiro.realm.jdbc.JdbcRealm：
```
[main]
jdbcRealm=org.apache.shiro.realm.jdbc.JdbcRealm
dataSource=com.alibaba.druid.pool.DruidDataSource
dataSource.driverClassName=com.mysql.jdbc.Driver
dataSource.url=jdbc:mysql://localhost:3306/shiro
dataSource.username=root
#dataSource.password=
jdbcRealm.dataSource=$dataSource
securityManager.realms=$jdbcRealm
```

### 使用多个Realm的处理机制： 

有些网站既可以用用户名也可以用邮箱、手机登陆，通过多个Realm就可以实现。

#### Authenticator 

默认实现是ModularRealmAuthenticator,它既支持单一Realm也支持多个Realm。如果仅配置了一个Realm，ModularRealmAuthenticator 会直接调用该Realm处理认证信息，如果配置了多个Realm，它会根据认证策略来适配Realm，找到合适的Realm执行认证信息。 

```
[main]  
#指定 securityManager 的 authenticator 实现
authenticator=org.apache.shiro.authc.pam.ModularRealmAuthenticator
securityManager.authenticator=$authenticator
```
#### AuthenticationStrategy（认证策略） 

当应用程序配置了多个Realm时，ModularRealmAuthenticator将根据认证策略来判断认证成功或是失败。 
例如，如果只有一个Realm验证成功，而其他Realm验证失败，那么这次认证是否成功呢？如果大多数的Realm验证成功了，认证是否就认为成功呢？或者，一个Realm验证成功后，是否还需要判断其他Realm的结果？认证策略就是根据应用程序的需要对这些问题作出决断。 

认证策略是一个无状态的组件，在认证过程中会经过4次的调用： 

* 在所有Realm被调用之前
* 在调用Realm的getAuthenticationInfo 方法之前
* 在调用Realm的getAuthenticationInfo 方法之后
* 在所有Realm被调用之后

认证策略的另外一项工作就是聚合所有Realm的结果信息封装至一个AuthenticationInfo实例中，并将此信息返回，以此作为Subject的身份信息。 

Shiro有3中认证策略的具体实现： 
* AtLeastOneSuccessfulStrategy	只要有一个（或更多）的Realm验证成功，那么认证将被视为成功
* FirstSuccessfulStrategy	第一个Realm验证成功，整体认证将被视为成功，且后续Realm将被忽略
* AllSuccessfulStrategy	所有Realm成功，认证才视为成功

ModularRealmAuthenticator 内置的认证策略默认实现是AtLeastOneSuccessfulStrategy 方式，因为这种方式也是被广泛使用的一种认证策略。当然，你也可以通过配置文件定义你需要的策略，如： 
```
[main]  
authcStrategy = org.apache.shiro.authc.pam.FirstSuccessfulStrategy  
securityManager.authenticator.authenticationStrategy = $authcStrategy  
```

#### Realm的顺序 

由刚才提到的认证策略，可以看到Realm在ModularRealmAuthenticator 里面的顺序对认证是有影响的。 

ModularRealmAuthenticator 会读取配置在SecurityManager里的Realm。当执行认证是，它会遍历Realm集合，对所有支持提交的token的Realm调用getAuthenticationInfo 。 

因此，如果Realm的顺序对你使用的认证策略结果有影响，那么你应该在配置文件中明确定义Realm的顺序

## 授权

授权即访问控制，它将判断用户在应用程序中对资源是否拥有相应的访问权限。 
如，判断一个用户有查看页面的权限，编辑数据的权限，拥有某一按钮的权限，以及是否拥有打印的权限等等。 

### 授权的三要素 

授权有着三个核心元素：权限(permissions)、角色(roles)和用户(users)。 

权限 

权限是Apache Shiro安全机制最核心的元素。它在应用程序中明确声明了被允许的行为和表现。一个格式良好的权限声明可以清晰表达出用户对该资源拥有的权限。

大多数的资源会支持典型的CRUD操作（create,read,update,delete）,但是任何操作建立在特定的资源上才是有意义的。因此，权限声明的根本思想就是建立在资源以及操作上。 

而我们通过权限声明仅仅能了解这个权限可以在应用程序中做些什么，而不能确定谁拥有此权限。权限只描述行为。

于是，我们就需要在应用程序中对用户和权限建立关联。通常的做法就是将权限分配给某个角色，然后将这个角色关联一个或多个用户。 

**权限声明及粒度** 

Shiro权限声明通常是使用以冒号分隔的表达式。就像前文所讲，一个权限表达式可以清晰的指定资源类型，允许的操作，可访问的数据。同时，Shiro权限表达式支持简单的通配符，可以更加灵活的进行权限设置。 

字符串通配符权限
规则：“资源标识符：操作：对象实例 ID” 即对哪个资源的哪个实例可以进行什么操作。其默认支持通配符权限字符串，`:`表示资源/操作/实例的分割；`,`表示操作的分割；`*`表示任意资源/操作/实例。

下面以实例来说明权限表达式。 
可查询用户数据 `User:view`
可查询或编辑用户数据 `User:view,edit`
可对用户数据进行所有操作 `User:* 或 user`
可编辑id为123的用户数据 `User:edit:123`

注意：通过“system:user:update,delete”验证“system:user:update, system:user:delete”是没问题的，但是反过来是规则不成立。

### 角色 

Shiro支持两种角色模式： 
1. 传统角色：一个角色代表着一系列的操作，当需要对某一操作进行授权验证时，只需判断是否是该角色即可。这种角色权限相对简单、模糊，不利于扩展。 
2. 权限角色：一个角色拥有一个权限的集合。授权验证时，需要判断当前角色是否拥有该权限。这种角色权限可以对该角色进行详细的权限描述，适合更复杂的权限设计。 

[新的RBAC：基于资源的权限管理(Resource-Based Access Control)](www.waylau.com/new-rbac-resource-based-access-control/)

### 用户

一个用户本质上是程序中的“谁”，如同我们前面提到的，Subject 实际上是 shiro 的“用户”。

用户（Subjects）通过与角色或权限关联确定是否被允许执行程序内特定的动作，程序数据模型确切定义了 Subject 是否允许做什么事情。Shiro 依赖一个 Realm 实现将你的数据模型关联转换成 Shiro 可以理解的内容

### 授权实现 

Shiro支持三种方式实现授权过程： 
* 编码实现：if(subject.hasRole("admin")){//有权限}
* 注解实现：@RequiresRoles("admin")public void hello() {//有权限}
* JSP Taglig实现：`<shiro:hasRole name="admin"><!— 有权限 —></shiro:hasRole>`

#### 基于编码的授权实现 

**基于传统角色授权实现**

当需要验证用户是否拥有某个角色时，可以调用Subject 实例的`hasRole*`方法验证。 

```
Subject currentUser = SecurityUtils.getSubject();  
if (currentUser.hasRole("administrator")) {  
    //显示 admin 按钮
} else {  
    //不显示按钮?  灰色吗？ 
}  
```

相关验证方法如下： 

Subject方法                                 | 描述
---                                         | ---
`hasRole(String roleName)`                  | 当用户拥有指定角色时，返回true
`hasRoles(List<String> roleNames)`          | 按照列表顺序返回相应的一个boolean值数组
`hasAllRoles(Collection<String> roleNames)` | 如果用户拥有所有指定角色时，返回true

断言支持 

Shiro还支持以断言的方式进行授权验证。断言成功，不返回任何值，程序继续执行；断言失败时，将抛出异常信息。使用断言，可以使我们的代码更加简洁。 

```
Subject currentUser = SecurityUtils.getSubject();  
//保证当前用户是一个银行出纳员
//因此允许开立帐户：
currentUser.checkRole("bankTeller");  
openBankAccount();  
```

断言的相关方法： 

Subject方法                                | 描述
---                                        | ---
`checkRole(String roleName)`               | 断言用户是否拥有指定角色
`checkRoles(Collection<String> roleNames)` | 断言用户是否拥有所有指定角色
`checkRoles(String... roleNames)`          | 对上一方法的方法重载

**基于权限角色授权实现** 

相比传统角色模式，基于权限的角色模式耦合性要更低些，它不会因角色的改变而对源代码进行修改，因此，基于权限的角色模式是更好的访问控制方式。 

它的代码实现有以下几种实现方式： 

**基于权限对象的实现** 

创建org.apache.shiro.authz.Permission的实例，将该实例对象作为参数传递给Subject.isPermitted()进行验证。 

```
Permission printPermission = new PrinterPermission("laserjet4400n", "print");
Subject currentUser = SecurityUtils.getSubject();
if (currentUser.isPermitted(printPermission)) {
    //显示 打印 按钮
} else {
    //不显示按钮?  灰色吗？
}
```

相关方法如下： 

Subject方法                                    | 描述
---                                            | ---
`isPermitted(Permission p)`                    | Subject拥有制定权限时，返回treu
`isPermitted(List<Permission> perms)`          | 返回对应权限的boolean数组
`isPermittedAll(Collection<Permission> perms)` | Subject拥有所有制定权限时，返回true

**基于字符串的实现** 

相比笨重的基于对象的实现方式，基于字符串的实现便显得更加简洁。 

```
Subject currentUser = SecurityUtils.getSubject();
if (currentUser.isPermitted("printer:print:laserjet4400n")) {
    //显示 打印 按钮
} else {
    //不显示按钮?  灰色吗？
}
```

使用冒号分隔的权限表达式是org.apache.shiro.authz.permission.WildcardPermission 默认支持的实现方式。 

这里分别代表了 资源类型:操作:资源ID 

类似基于对象的实现相关方法

Subject 方法                    | 描述
---                             | ---
isPermitted(String perm)        | 如果Subject被允许执行字符串表达的动作或资源访问权限，返回真，否则返回假；
isPermitted(String... perms)    | 按照参数顺序返回isPermitted的结果数组，当许多字符串权限需要检查时非常有用（如定制一个复杂的视图时）；
isPermittedAll(String... perms) | 当Subject具备所有字符串定义的权限时返回真，否则返回假。

**基于权限对象的断言实现** 

```
Subject currentUser = SecurityUtils.getSubject();
//担保允许当前用户
//开一个银行帐户：
Permission p = new AccountPermission("open");
currentUser.checkPermission(p);
openBankAccount(); 
```

**基于字符串的断言实现** 

```
Subject currentUser = SecurityUtils.getSubject();
//担保允许当前用户
//开一个银行帐户：
currentUser.checkPermission("account:open");
openBankAccount();
```

**断言实现的相关方法** 

Subject方法                                      | 说明
---                                              | ---
`checkPermission(Permission p)`                  | 断言用户是否拥有制定权限
`checkPermission(String perm)`                   | 断言用户是否拥有制定权限
`checkPermissions(Collection<Permission> perms)` | 断言用户是否拥有所有指定权限
`checkPermissions(String... perms)`              | 断言用户是否拥有所有指定权限

#### 基于注解的授权实现 

Shiro注解支持AspectJ、Spring、Google-Guice等，可根据应用进行不同的配置。 

相关的注解： 
@RequiresAuthentication 
可以用户类/属性/方法，用于表明当前用户需是经过认证的用户。 

```
@RequiresAuthentication
public void updateAccount(Account userAccount) {
    //这个方法只会被调用在
    //Subject 保证被认证的情况下
    ...
}
```
相当于判断了SecurityUtils.getSubject().isAuthenticated()

@RequiresGuest 
表明该用户需为”guest”用户 

```
@RequiresGuest
public void signUp(User newUser) {
    //这个方法只会被调用在
    //Subject 未知/匿名的情况下
    ...
}
```
相当于判断了principals == null || principals.isEmpty()

@RequiresPermissions 
当前用户需拥指定权限 

```
@RequiresPermissions("account:create")
public void createAccount(Account account) {
    //这个方法只会被调用在
    //Subject 允许创建一个 account 的情况下
    ...
}
```
相当于判断了subject.isPermitted("account:create")

@RequiresRoles 
当前用户需拥有指定角色 
相当于判断了subject.hasRole("administrator")

@RequiresUser 
当前用户需为已认证用户或已记住用户 

#### 基于JSP TAG的授权实现 

Shiro提供了一套JSP标签库来实现页面级的授权控制。标签库描述文件 (TLD)被打包在 META-INF/shiro.tld 文件中的 shiro-web.jar 文件中。 

在使用Shiro标签库前，首先需要在JSP引入shiro标签： 

```
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>  
```

下面一一介绍Shiro的标签： 

guest标签:验证当前用户是否为“访客”，即未认证（包含未记住）的用户 
```
<shiro:guest>  
    Hi there!  Please <a href="login.jsp">Login</a> or <a href="signup.jsp">Signup</a> today!  
</shiro:guest>  
```

user标签:认证通过或已记住的用户 
```
<shiro:user>  
    Welcome back John!  Not John? Click <a href="login.jsp">here<a> to login.  
</shiro:user>  
```

authenticated标签:已认证通过的用户。不包含已记住的用户，这是与user标签的区别所在。 
```
<shiro:authenticated>  
    <a href="updateAccount.jsp">Update your contact information</a>.  
</shiro:authenticated>  
```

notAuthenticated标签:未认证通过用户，与authenticated标签相对应。与guest标签的区别是，该标签包含已记住用户。 
```
<shiro:notAuthenticated>  
    Please <a href="login.jsp">login</a> in order to update your credit card information.  
</shiro:notAuthenticated>  
```

principal 标签:输出当前用户信息，通常为登录帐号信息 
```
Hello, <shiro:principal/>, how are you today?  
```
principal property
```
Hello, <shiro:principal type="com.foo.User" property="firstName"/>, how are you today?
```
很大程度上等价于
```
Hello, <%= SecurityUtils.getSubject().getPrincipals().oneByType(com.foo.User.class).getFirstName().toString() %>, how are you today?
```

hasRole标签:验证当前用户是否属于该角色 
```
<shiro:hasRole name="administrator">  
    <a href="admin.jsp">Administer the system</a>  
</shiro:hasRole>  
```

lacksRole标签:与hasRole标签逻辑相反，当用户不属于该角色时验证通过 
```
<shiro:lacksRole name="administrator">  
    Sorry, you are not allowed to administer the system.  
</shiro:lacksRole>  
```

hasAnyRole标签:验证当前用户是否属于以下任意一个角色。 
```
<shiro:hasAnyRoles name="developer, project manager, administrator">  
    You are either a developer, project manager, or administrator.  
</shiro:lacksRole>  
```

hasPermission标签:验证当前用户是否拥有制定权限 
```
<shiro:hasPermission name="user:create">  
    <a href="createUser.jsp">Create a new User</a>  
</shiro:hasPermission>  
```

lacksPermission标签:与hasPermission标签逻辑相反，当前用户没有制定权限时，验证通过 
```
<shiro:hasPermission name="user:create">  
    <a href="createUser.jsp">Create a new User</a>  
</shiro:hasPermission>  
```

### 授权流程
 
![授权流程](https://cdn.jsdelivr.net/gh/howiefh/assets/img/Shiro-AuthorizationSequence.png)

1. 程序或框架代码调用一个 Subject 的`hasRole*`、`checkRole*`、`isPermitted*`或者`checkPermission*`方法，传递所需的权限或角色。
2. Subject实例，通常是一个 DelegatingSubject（或子类），通过调用securityManager 与各 `hasRole*`、`checkRole*`、`isPermitted*`或`checkPermission*` 基本一致的方法将权限或角色传递给程序的 SecurityManager(实现了 org.apache.shiro.authz.Authorizer 接口)。 
3. 接下来SecurityManager会委托内置的Authorizer的实例（默认是ModularRealmAuthorizer 类的实例，类似认证实例，它同样支持一个或多个Realm实例认证）调用相应的授权方法。 
4. 每一个Realm将检查是否实现了相同的 Authorizer 接口。然后，将调用Reaml自己的相应的授权验证方法。 

当使用多个Realm时，不同于认证策略处理方式，授权处理过程中： 
1. 当Realm实现了Authorizer接口
    1. 当调用Realm出现异常时，将立即抛出异常，结束授权验证。 
    2. 只要有一个Realm验证成功，那么将认为授权成功，立即返回，结束认证。 
2. 如果 Realm 没有实现 Authorizer 接口，将被忽略。

**授权顺序**

ModularRealmAuthorizer 拥有 SecurityManager 配置的 Realm 实例的入口，当执行一个授权操作时，它将在整个集合中进行迭代（iteration），对于每一个实现 Authorizer 接口的 Realm，调用Realm 各自的 Authorizer 方法（如 hasRole、 checkRole、 isPermitted或 checkPermission）。

**配置全局的 PermissionResolver**

当执行一个基于字符串的权限检查时，大部分 Shiro 默认的 Realm 将会在执行权限隐含逻辑之前首先把这个字符串转换成一个常用的权限实例。

为了这个转换目的，Shiro 支持 PermissionResolver，大部分 Shiro Realm 使用 PermissionResolver 来支持它们对Authorizer 接口中基于字符串权限方法的实现：当这些方法在Realm上被调用时，将使用PermissionResolver 将字符串转换为权限实例，并执行检查。默认使用内部的 WildcardPermissionResolver

## Realms

在认证、授权内部实现机制中都有提到，最终处理都将交给Realm进行处理。因为在Shiro中，最终是通过Realm来获取应用程序中的用户、角色及权限信息的。通常情况下，在Realm中会直接从我们的数据源中获取Shiro需要的验证信息。可以说，Realm是专用于安全框架的DAO. 

### 认证实现 

正如前文所提到的，Shiro的认证过程最终会交由Realm执行，这时会调用Realm的getAuthenticationInfo(token)方法。在一个 Realm 执行一个验证尝试之前，它的supports)方法被调用。只有在返回值为 true 的时候它的getAuthenticationInfo(token) 方法才会执行。因此想要禁用认证过程主要supports始终返回false即可。 

该方法主要执行以下操作: 
1. 检查提交的进行认证的令牌信息 
2. 根据令牌信息从数据源(通常为数据库)中获取用户信息 
3. 确定令牌支持的 credentials (凭证数据)和存储的数据相符。 
4. 验证通过将返回一个封装了用户信息的AuthenticationInfo实例。 
5. 验证失败则抛出AuthenticationException异常信息。 

而在我们的应用程序中要做的就是自定义一个Realm类，继承AuthorizingRealm抽象类，重载doGetAuthenticationInfo()，重写获取用户信息的方法。 

```
protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken authcToken) throws AuthenticationException {  
    String username = (String)token.getPrincipal();
    User user = userService.findByUsername(username);
    if(user == null) {
        throw new UnknownAccountException();//没找到帐号
    }
    if(Boolean.TRUE.equals(user.getLocked())) {
        throw new LockedAccountException(); //帐号锁定
    }
    //交给AuthenticatingRealm使用CredentialsMatcher进行密码匹配，如果觉得人家的不好可以自定义实现
    SimpleAuthenticationInfo authenticationInfo = new SimpleAuthenticationInfo(
            user.getUsername(), //用户名
            user.getPassword(), //密码
            ByteSource.Util.bytes(user.getCredentialsSalt()),//salt=username+salt
            getName()  //realm name
    );
    return authenticationInfo;
}  
```

**凭证匹配**

在上述 realm 认证工作流中，一个 Realm 必须较验 Subject 提交的凭证（如密码）是否与存储在数据中的凭证相匹配，如果匹配，验证成功，系统保留已认证的终端用户身份。

AuthenticatingRealm 以及它的子类支持用 CredentialsMatcher 来执行一个凭证对比。

在找到用户数据之后，它和提交的 AuthenticationToken 一起传递给一个 CredentialsMatcher ，后者用来检查提交的数据和存储的数据是否相匹配。Shiro某些 CredentialsMatcher 实现可以使你开箱即用，比如 SimpleCredentialsMatcher(直接比较明文) 和 HashedCredentialsMatcher(可以指定hash策略) 实现

```
Realm myRealm = new com.company.shiro.realm.MyRealm();
CredentialsMatcher customMatcher = new com.company.shiro.realm.CustomCredentialsMatcher();
myRealm.setCredentialsMatcher(customMatcher);
```

### 授权实现 

而授权实现则与认证实现非常相似，在我们自定义的Realm中，重载doGetAuthorizationInfo()方法，重写获取用户权限的方法即可。 

```
protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principals){  
    String username = (String)principals.getPrimaryPrincipal();

    SimpleAuthorizationInfo authorizationInfo = new SimpleAuthorizationInfo();
    authorizationInfo.setRoles(userService.findRoles(username));
    authorizationInfo.setStringPermissions(userService.findPermissions(username));
    return authorizationInfo;
}  
```

## 会话管理

Shiro 提供了完整的企业级会话管理功能，不依赖于底层容器（如 web 容器 tomcat），不管JavaSE 还是 JavaEE 环境都可以使用，提供了会话管理、会话事件监听、会话存储/持久化、容器无关的集群、失效/过期支持、对 Web 的透明支持、SSO 单点登录的支持等特性。

###　会话

登录成功后使用 Subject.getSession()即可获取会话；其等价于 Subject.getSession(true)，即如果当前没有创建 Session 对象会创建一个；另外 Subject.getSession(false)，如果当前没有创建 Session 则返回 null

* session.getId(); //获取会话唯一标识
* session.getHost(); //获取 Subject的主机地址,该地址是通过 HostAuthenticationToken.getHost()提供的
* session.getTimeout(); //获取过期时间
* session.setTimeout(毫秒); //设置会话过期时间
* session.getStartTimestamp(); //获取会话启动时间
* session.getLastAccessTime(); //获取最后访问时间
* session.touch(); //更新最后访问时间
* session.stop(); //销毁会话。
* session.setAttribute("key", "123"); //设置session属性
* session.getAttribute("key"));  //获取session属性
* session.removeAttribute("key");  //删除会话属性

### 会话管理器

SessionManager，名如其意，在应用程序中为所有的 subject 管理Session —— 创建，删除，失效及验证，等等。如同其他在Shiro 中的核心结构组件一样，SessionManager 也是一个由 SecurityManager 维护的顶级组件。

* Session start(SessionContext context); //启动会话
* Session getSession(SessionKey key) throws SessionException; //根据会话 Key 获取会话

Shiro 提供了三个默认实现：
* DefaultSessionManager：DefaultSecurityManager 使用的默认实现，用于 JavaSE 环境；
* ServletContainerSessionManager：DefaultWebSecurityManager 使用的默认实现，用于Web环境，其直接使用 Servlet 容器的会话；
* DefaultWebSessionManager：用于Web环境的实现，可以替代 ServletContainerSessionManager，自己维护着会话，直接废弃了 Servlet 容器的会话管理。

另外可以设置会话的全局过期时间（毫秒为单位），默认 30 分钟：sessionManager. globalSessionTimeout=1800000
另外如果使用 ServletContainerSessionManager 进行会话管理，Session 的超时依赖于底层 Servlet 容器的超时时间，可以在 web.xml 中配置其会话的超时时间（分钟为单位）：
```
<session-config>
<session-timeout>30</session-timeout>
</session-config>
```

在 Servlet 容器中，默认使用 JSESSIONID Cookie 维护会话，且会话默认是跟容器绑定的；在某些情况下可能需要使用自己的会话机制， 此时我们可以使用 DefaultWebSessionManager来维护会话：

```
sessionIdCookie=org.apache.shiro.web.servlet.SimpleCookie
sessionManager=org.apache.shiro.web.session.mgt.DefaultWebSessionManager
sessionIdCookie.name=sid
#sessionIdCookie.domain=sishuok.com
#sessionIdCookie.path=
sessionIdCookie.maxAge=1800
sessionIdCookie.httpOnly=true
sessionManager.sessionIdCookie=$sessionIdCookie
sessionManager.sessionIdCookieEnabled=true
securityManager.sessionManager=$sessionManager
```
* sessionIdCookie 是 sessionManager 创建会话 Cookie 的模板：
* sessionIdCookie.name：设置 Cookie 名字，默认为 JSESSIONID；
* sessionIdCookie.domain：设置 Cookie 的域名，默认空，即当前访问的域名；
* sessionIdCookie.path：设置 Cookie 的路径，默认空，即存储在域名根下；
* sessionIdCookie.maxAge：设置 Cookie 的过期时间，秒为单位，默认-1 表示关闭浏览器时过期 Cookie；
* sessionIdCookie.httpOnly：如果设置为 true，则客户端不会暴露给客户端脚本代码，使用HttpOnly cookie有助于减少某些类型的跨站点脚本攻击； 此特性需要实现了 Servlet 2.5 MR6及以上版本的规范的 Servlet 容器支持；
* sessionManager.sessionIdCookieEnabled：是否启用/禁用 Session Id Cookie，默认是启用的；如果禁用后将不会设置 Session Id Cookie，即默认使用了 Servlet 容器的 JSESSIONID，且通过 URL 重写（URL 中的“;JSESSIONID=id”部分）保存 Session Id。（这里设为false，url并没有重写，需要设置什么吗？)

### 会话监听器

会话监听器用于监听会话创建、过期及停止事件。可以实现SessionListener中的onStart、onExpiration、onStop方法

### 会话存储/持久化

Shiro 提供 SessionDAO 用于会话的 CRUD，即 DAO（Data Access Object）模式实现

```
-- SessionDAO
    -- AbstractSessionDAO 
        -- CachingSessionDAO
            -- EnterpriseCacheSessionDAO
        -- MemorySessionDAO
```
AbstractSessionDAO提供了SessionDAO的基础实现，如生成会话 ID等；CachingSessionDAO 提供了对开发者透明的会话缓存的功能，只需要设置相应的 CacheManager 即可；MemorySessionDAO 直接在内存中进行会话维护；而 EnterpriseCacheSessionDAO 提供了缓存功能的会话维护，默认情况下使用 MapCache 实现，内部使用 ConcurrentHashMap 保存缓存的会话。

Shiro 提供了使用 Ehcache 进行会话存储，Ehcache 可以配合 TerraCotta 实现容器无关的分布式集群。

```
sessionDAO=org.apache.shiro.session.mgt.eis.EnterpriseCacheSessionDAO
sessionDAO. activeSessionsCacheName=shiro-activeSessionCache
sessionManager.sessionDAO=$sessionDAO
cacheManager = org.apache.shiro.cache.ehcache.EhCacheManager
cacheManager.cacheManagerConfigFile=classpath:ehcache.xml
securityManager.cacheManager = $cacheManager
```
* sessionDAO. activeSessionsCacheName：设置Session 缓存名字，默认就是shiro-activeSessionCache；
* cacheManager：缓存管理器，用于管理缓存的，此处使用 Ehcache 实现；
* cacheManager.cacheManagerConfigFile：设置 ehcache 缓存的配置文件；
* securityManager.cacheManager：设置 SecurityManager 的 cacheManager，会自动设置实现了CacheManagerAware 接口的相应对象，如 SessionDAO 的 cacheManager；

ehcache.xml：
```
<cache name="shiro-activeSessionCache"
    maxEntriesLocalHeap="10000"
    overflowToDisk="false"
    eternal="false"
    diskPersistent="false"
    timeToLiveSeconds="0"
    timeToIdleSeconds="0"
    statistics="true"/>
```
Cache 的名字为 shiro-activeSessionCache，即设置的 sessionDAO 的 activeSessionsCacheName 属性值。

用于生成会话 ID，默认就是 JavaUuidSessionIdGenerator，使用 java.util.UUID 生成。
```
sessionIdGenerator=org.apache.shiro.session.mgt.eis.JavaUuidSessionIdGenerator
sessionDAO.sessionIdGenerator=$sessionIdGenerator
```
### 会话验证

Shiro 提供了会话验证调度器，用于定期的验证会话是否已过期，如果过期将停止会话；出于性能考虑，一般情况下都是获取会话时来验证会话是否过期并停止会话的；但是如在 web环境中，如果用户不主动退出是不知道会话是否过期的，因此需要定期的检测会话是否过期，Shiro 提供了会话验证调度器 SessionValidationScheduler 来做这件事情。

可以通过如下 ini 配置开启会话验证：
```
sessionValidationScheduler=org.apache.shiro.session.mgt.ExecutorServiceSessionValidationScheduler
sessionValidationScheduler.interval = 3600000
sessionValidationScheduler.sessionManager=$sessionManager
sessionManager.globalSessionTimeout=1800000
sessionManager.sessionValidationSchedulerEnabled=true
sessionManager.sessionValidationScheduler=$sessionValidationScheduler
```

* sessionValidationScheduler：会话验证调度器，sessionManager 默认就是使用 ExecutorServiceSessionValidationScheduler， 其使用 JDK 的 ScheduledExecutorService 进行定期调度并验证会话是否过期；
* sessionValidationScheduler.interval：设置调度时间间隔，单位毫秒，默认就是 1 小时；
* sessionValidationScheduler.sessionManager：设置会话验证调度器进行会话验证时的会话管理器；
* sessionManager.globalSessionTimeout：设置全局会话超时时间，默认 30 分钟，即如果 30 分钟内没有访问会话将过期；
* sessionManager.sessionValidationSchedulerEnabled：是否开启会话验证器，默认是开启的；
* sessionManager.sessionValidationScheduler：设置会话验证调度器，默认就是使用 ExecutorServiceSessionValidationScheduler。

Shiro 也提供了使用 Quartz 会话验证调度器,使用时需要导入 shiro-quartz 依赖：

如上会话验证调度器实现都是直接调用 AbstractValidatingSessionManager 的 validateSessions 方法进行验证，其直接调用 SessionDAO 的 getActiveSessions 方法获取所有会话进行验证，如果会话比较多，会影响性能；可以考虑如分页获取会话并进行验证

如果在会话过期时不想删除过期的会话，可以通过如下 ini 配置进行设置：
```
sessionManager.deleteInvalidSessions=false
```

会话工厂
```
sessionFactory=org.apache.shiro.session.mgt.OnlineSessionFactory
sessionManager.sessionFactory=$sessionFactory
```

## 编码/加密

### 编码/解码

Shiro 内部的一些数据的存储/表示都使用了 base64 和 16 进制字符串。

```
String str = "hello"; 
String base64Encoded = Base64.encodeToString(str.getBytes()); 
String str2 = Base64.decodeToString(base64Encoded); 
Assert.assertEquals(str, str2); 
```
还有一个可能经常用到的类 CodecSupport，提供了 toBytes(str,  "utf-8")  /  toString(bytes, "utf-8")用于在 byte 数组/String 之间转换。

### 散列算法

散列算法一般用于生成数据的摘要信息，是一种不可逆的算法，一般适合存储密码之类的 数据，常见的散列算法如 MD5、SHA 等。一般进行散列时最好提供一个 salt（盐），因为md5解密网站很容易通过散列值得到密码。

```
String str = "hello"; 
String salt = "123"; 
String md5 =new Md5Hash(str, salt, 2).toString();//还可以转换为  toBase64()/toHex()  做两次hash
```
除了Md5外还有Sha256/Sha1/Sha512

通用的散列支持
```
String str = "hello"; 
String salt = "123"; 
//内部使用Java的 MessageDigest 
String simpleHash =new SimpleHash("SHA-1", str, salt).toString(); 
```

为了方便使用，Shiro 提供了 HashService，默认提供了 DefaultHashService 实现

```
DefaultHashService hashService =new DefaultHashService(); //默认算法 SHA-512 
hashService.setHashAlgorithmName("SHA-512"); 
hashService.setPrivateSalt(newSimpleByteSource("123")); //私盐，默认无
hashService.setGeneratePublicSalt(true);//是否生成公盐，默认 false 
hashService.setRandomNumberGenerator(new  SecureRandomNumberGenerator());//用于生成公盐。默认就这个
hashService.setHashIterations(1); //生成 Hash 值的迭代次数
HashRequest request =new HashRequest.Builder() 
.setAlgorithmName("MD5").setSource(ByteSource.Util.bytes("hello")) 
.setSalt(ByteSource.Util.bytes("123")).setIterations(2).build(); 
String hex =hashService.computeHash(request).toHex(); 
```

### 加密/解密

Shiro 还提供对称式加密/解密算法的支持，如 AES、Blowfish 等；当前还没有提供对非对称加密/解密算法支持，未来版本可能提供。

AES算法
```
AesCipherService aesCipherService =new AesCipherService(); 
aesCipherService.setKeySize(128); //设置 key 长度
//生成 key 
Keykey = aesCipherService.generateNewKey(); 
String text = "hello"; 
//加密
String encrptText = aesCipherService.encrypt(text.getBytes(), key.getEncoded()).toHex(); 
//解密
String text2 = new String(aesCipherService.decrypt(Hex.decode(encrptText), key.getEncoded()).getBytes()); 
Assert.assertEquals(text, text2); 
```

### PasswordService/CredentialsMatcher

Shiro 提供了 PasswordService 及 CredentialsMatcher 用于提供加密密码及验证密码服务。

```
public interface PasswordService { 
//输入明文密码得到密文密码
String encryptPassword(ObjectplaintextPassword) throws IllegalArgumentException; 
}
public interface CredentialsMatcher { 
//匹配用户输入的 token 的凭证（未加密）与系统提供的凭证（已加密）
boolean doCredentialsMatch(AuthenticationToken token, AuthenticationInfo info); 
} 
```
Shiro 默认提供了 PasswordService 实现 DefaultPasswordService；CredentialsMatcher 实现PasswordMatcher及HashedCredentialsMatcher（更强大）。

```
[main] 
passwordService=org.apache.shiro.authc.credential.DefaultPasswordService 
hashService=org.apache.shiro.crypto.hash.DefaultHashService 
passwordService.hashService=$hashService 
hashFormat=org.apache.shiro.crypto.hash.format.Shiro1CryptFormat 
passwordService.hashFormat=$hashFormat 
hashFormatFactory=org.apache.shiro.crypto.hash.format.DefaultHashFormatFactory 
passwordService.hashFormatFactory=$hashFormatFactory 
passwordMatcher=org.apache.shiro.authc.credential.PasswordMatcher 
passwordMatcher.passwordService=$passwordService 
myRealm=com.github.zhangkaitao.shiro.chapter5.hash.realm.MyRealm 
myRealm.passwordService=$passwordService 
myRealm.credentialsMatcher=$passwordMatcher 
securityManager.realms=$myRealm 
```

1. passwordService 使用 DefaultPasswordService，如果有必要也可以自定义；
2. hashService 定义散列密码使用的 HashService，默认使用 DefaultHashService（默认SHA-256 算法）；
3. hashFormat 用于对散列出的值进行格式化，默认使用 Shiro1CryptFormat，另外提供了Base64Format 和 HexFormat，对于有 salt 的密码请自定义实现 ParsableHashFormat 然后把salt 格式化到散列值中；
4. hashFormatFactory 用于根据散列值得到散列的密码和 salt； 因为如果使用如 SHA 算法，那么会生成一个 salt，此 salt 需要保存到散列后的值中以便之后与传入的密码比较时使用；默认使用 DefaultHashFormatFactory；
5. passwordMatcher 使用 PasswordMatcher，其是一个 CredentialsMatcher 实现；
6. 将 credentialsMatcher 赋值给 myRealm， myRealm 间接继承了 AuthenticatingRealm， 其在调用getAuthenticationInfo 方法获取到AuthenticationInfo信息后，会使用 credentialsMatcher 来验证凭据是否匹配，如果不匹配将抛出 IncorrectCredentialsException 异常。

```
[main] 
credentialsMatcher=org.apache.shiro.authc.credential.HashedCredentialsMatcher 
credentialsMatcher.hashAlgorithmName=md5 
credentialsMatcher.hashIterations=2 
credentialsMatcher.storedCredentialsHexEncoded=true 
myRealm=com.github.zhangkaitao.shiro.chapter5.hash.realm.MyRealm2 
myRealm.credentialsMatcher=$credentialsMatcher 
securityManager.realms=$myRealm 
```
1. 通过 credentialsMatcher.hashAlgorithmName=md5 指定散列算法为 md5，需要和生成密码时的一样；
2. credentialsMatcher.hashIterations=2，散列迭代次数，需要和生成密码时的意义；
3. credentialsMatcher.storedCredentialsHexEncoded=true 表示是否存储散列后的密码为 16 进制，需要和生成密码时的一样，默认是 base64；

此处最需要注意的就是 HashedCredentialsMatcher 的算法需要和生成密码时的算法一样。 另外 HashedCredentialsMatcher 会自动根据AuthenticationInfo 的类型是否是 SaltedAuthenticationInfo 来获取 credentialsSalt 盐。

## 配置

Apache Shiro的配置主要分为四部分： 
1. 对象和属性的定义与配置
2. URL的过滤器配置
3. 静态用户配置
4. 静态角色配置

其中，由于用户、角色一般由后台进行操作的动态数据，因此Shiro配置一般仅包含前两项的配置。 

Apache Shiro的大多数组件是基于POJO的，因此我们可以使用POJO兼容的任何配置机制进行配置，例如：Java代码、Sping XML、YAML、JSON、ini文件等等。

Shiro 是从根对象 SecurityManager 进行身份验证和授权的；也就是所有操作都是自它开始的，这个对象是线程安全且整个应用只需要一个即可

**INI配置**

1. 对象名=全限定类名 相当于调用 public 无参构造器创建对象
2. 对象名.属性名=值 相当于调用 setter 方法设置常量值
3. 对象名.属性名=$对象引用 相当于调用 setter 方法设置对象引用

```
[main]
#提供了对根对象 securityManager 及其依赖的配置
securityManager=org.apache.shiro.mgt.DefaultSecurityManager
…………
dataSource.driverClassName=com.mysql.jdbc.Driver
#常量值注入
jdbcRealm.permissionsLookupEnabled=true
…………
#对象引用值注入
securityManager.realms=$jdbcRealm
…………
#嵌套属性注入
securityManager.authenticator.authenticationStrategy=$authenticationStrategy
#byte数组注入
#base64 byte[]
authenticator.bytes=aGVsbG8=
#hex byte[]
authenticator.bytes=0x68656c6c6f
#Array/Set/List注入
authenticator.array=1,2,3
authenticator.set=$jdbcRealm,$jdbcRealm
#Map注入
authenticator.map=$jdbcRealm:$jdbcRealm,1:1,key:abc
[users]
#提供了对用户/密码及其角色的配置，用户名=密码，角色 1，角色 2
username=password,role1,role2
[roles]
#提供了角色及权限之间关系的配置，角色=权限 1，权限 2
role1=permission1,permission2
[urls]
#用于 web，提供了对 web url 拦截相关的配置，url=拦截器[参数]，拦截器
/index.html = anon
/admin/** = authc, roles[admin], perms["permission1"]
```

XML配置： 

主要是对Shiro各个组件的实现进行定义配置，主要组件在前文已做过简单介绍，这里不再一一说明。 

```
<bean id="securityManager" class="org.apache.shiro.mgt.DefaultSecurityManager">  
        <property name="cacheManager" ref="cacheManager"/>  
        <property name="sessionMode" value="native"/>  
        <!-- Single realm app.  If you have multiple realms, use the 'realms' property instead. -->
        <property name="realm" ref="myRealm"/>  
        <property name="sessionManager" ref="sessionManager"/>   
</bean>  
```

Shiro过滤器的配置 

Shiro主要是通过URL过滤来进行安全管理，这里的配置便是指定具体授权规则定义。 

```
<bean id="shiroFilter" class="org.apache.shiro.spring.web.ShiroFilterFactoryBean">  
    <property name="securityManager" ref="securityManager"/>  
    <property name="loginUrl" value="/login.jsp"/>  
    <property name="successUrl" value="/home.jsp"/>  
    <property name="unauthorizedUrl" value="/unauthorized.jsp"/> -->  
    <property name="filterChainDefinitions">  
        <value>  
            # some example chain definitions:  
            /admin/** = authc, roles[admin]  
            /docs/** = authc, perms[document:read]  
            /** = authc  
            # more URL-to-FilterChain definitions here  
        </value>  
    </property>  
</bean>  
```

URL过滤器配置说明： 

Shiro可以通过配置文件实现基于URL的授权验证。FilterChain定义格式： `URL_Ant_Path_Expression = Path_Specific_Filter_Chain` 

每个URL配置，表示匹配该URL的应用程序请求将由对应的过滤器进行验证。 

例如： 
```
[urls] 
/index.html = anon 
/user/create = anon 
/user/** = authc 
/admin/** = authc, roles[administrator] 
/rest/** = authc, rest 
/remoting/rpc/** = authc, perms["remote:invoke"] 
```

URL表达式说明 

1. URL目录是基于HttpServletRequest.getContextPath()此目录设置 
2. URL可使用通配符，**代表任意子目录 
3. Shiro验证URL时，URL匹配成功便不再继续匹配查找。所以要注意配置文件中的URL顺序，尤其在使用通配符时。 

URL 路径表达式按事先定义好的顺序判断传入的请求，并遵循 FIRST MATCH WINS 这一原则。例如
```
/account/** = ssl, authc
/account/signup = anon
```
如果传入的请求旨在访问 `/account/signup/index.html`（所有 'anon'ymous 用户都能访问），那么它将永不会被处理！原因是因为`/account/*`  的模式第一个匹配了传入的请求，“短路”了其余的定义。 

Filter Chain定义说明 

1. 一个URL可以配置多个Filter，使用逗号分隔 
2. 当设置多个过滤器时，全部验证通过，才视为通过 
3. 部分过滤器可指定参数，如perms，roles 

Shiro内置的FilterChain 

Filter Name       | Class
---               | ---
anon              | org.apache.shiro.web.filter.authc.AnonymousFilter
authc             | org.apache.shiro.web.filter.authc.FormAuthenticationFilter
authcBasic        | org.apache.shiro.web.filter.authc.BasicHttpAuthenticationFilter
logout            | org.apache.shiro.web.filter.authc.LogoutFilter
noSessionCreation | org.apache.shiro.web.filter.session.NoSessionCreationFilter
perms             | org.apache.shiro.web.filter.authz.PermissionsAuthorizationFilter
port              | org.apache.shiro.web.filter.authz.PortFilter
rest              | org.apache.shiro.web.filter.authz.HttpMethodPermissionFilter
roles             | org.apache.shiro.web.filter.authz.RolesAuthorizationFilter
ssl               | org.apache.shiro.web.filter.authz.SslFilter
user              | org.apache.shiro.web.filter.authc.UserFilter

OncePerRequestFilter（及其所有子类）支持 Enabling/Disabling 所有请求及 per-request 基础。 一般为所有的请求启用或禁用一个过滤器是通过设置其 enabled 属性为true 或 false。

```
[main]
ssl.enabled=false
```

## 缓存

* CacheManager - 负责所有缓存的主要管理组件，它返回 Cache 实例。
* Cache - 维护key/value 对。
* CacheManagerAware - 通过想要接收和使用 CacheManager 实例的组件来实现。

CacheManager 返回Cache 实例，各种不同的Shiro 组件使用这些Cache 实例来缓存必要的数据。任何实现了 CacheManagerAware 的 Shiro 组件将会自动地接收一个配置好的 CacheManager，该 CacheManager 能够用来获取 Cache 实例。

### Realm缓存

Shiro 的 SecurityManager 实现及所有 AuthorizingRealm 实现都实现了 CacheManagerAware 。如果你在 SecurityManager 上设置了 CacheManger，它反过来也会将它设置到实现了CacheManagerAware 的各种不同的 Realm 上（OO delegation）

```
userRealm=com.github.zhangkaitao.shiro.chapter11.realm.UserRealm
userRealm.credentialsMatcher=$credentialsMatcher
userRealm.cachingEnabled=true
userRealm.authenticationCachingEnabled=true
userRealm.authenticationCacheName=authenticationCache
userRealm.authorizationCachingEnabled=true
userRealm.authorizationCacheName=authorizationCache
securityManager.realms=$userRealm
cacheManager=org.apache.shiro.cache.ehcache.EhCacheManager
cacheManager.cacheManagerConfigFile=classpath:shiro-ehcache.xml
securityManager.cacheManager=$cacheManager
```

* userRealm.cachingEnabled：启用缓存，默认 false；
* userRealm.authenticationCachingEnabled：启用身份验证缓存，即缓存 AuthenticationInfo 信息，默认 false；
* userRealm.authenticationCacheName：缓存 AuthenticationInfo 信息的缓存名称；
* userRealm. authorizationCachingEnabled：启用授权缓存，即缓存 AuthorizationInfo 信息，默认 false；
* userRealm. authorizationCacheName：缓存 AuthorizationInfo 信息的缓存名称；
* cacheManager：缓存管理器，此处使用 EhCacheManager，即 Ehcache 实现，需要导入相应的 Ehcache 依赖，请参考 pom.xml；

如果凭证数据或授权数据发生改变，需要调用Realm的clearCachedAuthenticationInfo 和 clearCachedAuthorizationInfo方法

### Session缓存

如 securityManager 实现了 SessionsSecurityManager，其会自动判断 SessionManager 是否实现了 CacheManagerAware 接口，如果实现了会把 CacheManager 设置给它。然后sessionManager 会判断相应的 sessionDAO（如继承自 CachingSessionDAO）是否实现了CacheManagerAware， 如果实现了会把 CacheManager 设置给它

```
sessionDAO=com.github.zhangkaitao.shiro.chapter11.session.dao.MySessionDAO
sessionDAO.activeSessionsCacheName=shiro-activeSessionCache
```
activeSessionsCacheName 默认就是 shiro-activeSessionCache。

## 与Spring的集成

### JavaSE

spring-shiro.xml 
```
<!-- 缓存管理器 使用 Ehcache 实现 -->
<bean id="cacheManager" class="org.apache.shiro.cache.ehcache.EhCacheManager">
    <property name="cacheManagerConfigFile" value="classpath:ehcache.xml"/>
</bean>
<!-- 凭证匹配器 -->
<bean id="credentialsMatcher" class="com.github.zhangkaitao.shiro.chapter12.credentials.RetryLimitHashedCredentialsMatcher">
    <constructor-arg ref="cacheManager"/>
    <property name="hashAlgorithmName" value="md5"/>
    <property name="hashIterations" value="2"/>
    <property name="storedCredentialsHexEncoded" value="true"/>
</bean>
<!-- Realm 实现 -->
<bean id="userRealm" class="com.github.zhangkaitao.shiro.chapter12.realm.UserRealm">
    <property name="userService" ref="userService"/>
    <property name="credentialsMatcher" ref="credentialsMatcher"/>
    <property name="cachingEnabled" value="true"/>
    <property name="authenticationCachingEnabled" value="true"/>
    <property name="authenticationCacheName" value="authenticationCache"/>
    <property name="authorizationCachingEnabled" value="true"/>
    <property name="authorizationCacheName" value="authorizationCache"/>
</bean>
<!-- 会话 ID 生成器 -->
<bean id="sessionIdGenerator" class="org.apache.shiro.session.mgt.eis.JavaUuidSessionIdGenerator"/>
<!-- 会话 DAO -->
<bean id="sessionDAO" class="org.apache.shiro.session.mgt.eis.EnterpriseCacheSessionDAO">
    <property name="activeSessionsCacheName" value="shiro-activeSessionCache"/>
    <property name="sessionIdGenerator" ref="sessionIdGenerator"/>
</bean>
<!-- 会话验证调度器 -->
<bean id="sessionValidationScheduler" class="org.apache.shiro.session.mgt.quartz.QuartzSessionValidationScheduler">
    <property name="sessionValidationInterval" value="1800000"/>
    <property name="sessionManager" ref="sessionManager"/>
</bean>
<!-- 会话管理器 -->
<bean id="sessionManager" class="org.apache.shiro.session.mgt.DefaultSessionManager">
    <property name="globalSessionTimeout" value="1800000"/>
    <property name="deleteInvalidSessions" value="true"/>
    <property name="sessionValidationSchedulerEnabled" value="true"/>
    <property name="sessionValidationScheduler" ref="sessionValidationScheduler"/>
    <property name="sessionDAO" ref="sessionDAO"/>
</bean>
<!-- 安全管理器 -->
<bean id="securityManager" class="org.apache.shiro.mgt.DefaultSecurityManager">
    <property name="realms">
    <list><ref bean="userRealm"/></list>
    </property>
    <property name="sessionManager" ref="sessionManager"/>
    <property name="cacheManager" ref="cacheManager"/>
</bean>
<!-- 相当于调用 SecurityUtils.setSecurityManager(securityManager) -->
<bean class="org.springframework.beans.factory.config.MethodInvokingFactoryBean">
    <property name="staticMethod" value="org.apache.shiro.SecurityUtils.setSecurityManager"/>
    <property name="arguments" ref="securityManager"/>
</bean>
<!-- Shiro 生命周期处理器-->
<bean id="lifecycleBeanPostProcessor" class="org.apache.shiro.spring.LifecycleBeanPostProcessor"/>
```
LifecycleBeanPostProcessor 用于在实现了 Initializable 接口的 Shiro bean 初始化时调用 Initializable 接口回调，在实现了 Destroyable 接口的 Shiro bean 销毁时调用 Destroyable 接口回调。 如 UserRealm 就实现了 Initializable， 而 DefaultSecurityManager 实现了 Destroyable。具体可以查看它们的继承关系。 

### Web应用

spring-shiro-web.xml，只列出了和JavaSE不同的项，其中会话管理器和安全管理器和JavaSE稍有不同，其他几个是新加的
```
<!-- 会话 Cookie 模板 -->
<bean id="sessionIdCookie" class="org.apache.shiro.web.servlet.SimpleCookie">
    <constructor-arg value="sid"/>
    <property name="httpOnly" value="true"/>
    <property name="maxAge" value="180000"/>
</bean>
<!-- 会话管理器 -->
<bean id="sessionManager" class="org.apache.shiro.web.session.mgt.DefaultWebSessionManager">
    <property name="globalSessionTimeout" value="1800000"/>
    <property name="deleteInvalidSessions" value="true"/>
    <property name="sessionValidationSchedulerEnabled" value="true"/>
    <property name="sessionValidationScheduler" ref="sessionValidationScheduler"/>
    <property name="sessionDAO" ref="sessionDAO"/>
    <property name="sessionIdCookieEnabled" value="true"/>
    <property name="sessionIdCookie" ref="sessionIdCookie"/>
</bean>
<!-- 安全管理器 -->
<bean id="securityManager" class="org.apache.shiro.web.mgt.DefaultWebSecurityManager">
    <property name="realm" ref="userRealm"/>
    <property name="sessionManager" ref="sessionManager"/>
    <property name="cacheManager" ref="cacheManager"/>
</bean>
<!-- 基于 Form 表单的身份验证过滤器 -->
<bean id="formAuthenticationFilter" class="org.apache.shiro.web.filter.authc.FormAuthenticationFilter">
    <property name="usernameParam" value="username"/>
    <property name="passwordParam" value="password"/>
    <property name="loginUrl" value="/login.jsp"/>
</bean>
<!-- Shiro 的 Web 过滤器 -->
<bean id="shiroFilter" class="org.apache.shiro.spring.web.ShiroFilterFactoryBean">
    <property name="securityManager" ref="securityManager"/>
    <property name="loginUrl" value="/login.jsp"/>
    <property name="unauthorizedUrl" value="/unauthorized.jsp"/>
    <property name="filters"> <!-- 对应ini文件[filters] -->
        <util:map>
            <entry key="authc" value-ref="formAuthenticationFilter"/>
        </util:map>
    </property>
    <property name="filterChainDefinitions">
        <value>
        /index.jsp = anon
        /unauthorized.jsp = anon
        /login.jsp = authc
        /logout = logout
        /** = user
        </value>
    </property>
</bean>
```

还要在web.xml中添加shiro过滤器

```
<!-- Shiro filter-->  
<filter>  
    <filter-name>shiroFilter</filter-name>  
    <filter-class>  
        org.springframework.web.filter.DelegatingFilterProxy  
    </filter-class>  
</filter>  
<filter-mapping>  
    <filter-name>shiroFilter</filter-name>  
    <url-pattern>/*</url-pattern>  
</filter-mapping>  
```
下面是上述配置所做的事情：

1. EnvironmentLoaderListener 初始化一个Shiro WebEnvironment 实例（其中包含 Shiro 需要的一切操作，包括 SecurityManager ），使得它在 ServletContext 中能够被访问。如果你需要在任何时候获得WebEnvironment 实例，你可以调用WebUtils.getRequiredWebEnvironment（ServletContext）。
2. ShiroFilter 将使用此 WebEnvironment 对任何过滤的请求执行所有必要的安全操作。
3. 最后，filter-mapping 的定义确保了所有的请求被 ShiroFilter 过滤，建议大多数 Web 应用程序使用以确保任何请求是安全的。

通常为了shiro能够很好的工作，这个配置应该在其他过滤器之前

### Shiro 权限注解

Shiro 提供了相应的注解用于权限控制，如果使用这些注解就需要使用 AOP 的功能来进行判断，如 Spring AOP；Shiro 提供了 Spring AOP 集成用于权限注解的解析和验证。为了测试，此处使用了 Spring MVC 来测试 Shiro 注解，当然 Shiro 注解不仅仅可以在 web 环境使用，在独立的 JavaSE 中也是可以用的

在spring-mvc.xml中添加权限注解的支持
```
<aop:config proxy-target-class="true"></aop:config>
<bean class="org.apache.shiro.spring.security.interceptor.AuthorizationAttributeSourceAdvisor">
    <property name="securityManager" ref="securityManager"/>
</bean>
```

### RememberMe

spring-shiro-web.xml 配置：
```
<bean id="rememberMeCookie" class="org.apache.shiro.web.servlet.SimpleCookie">
    <constructor-arg value="rememberMe"/>
    <property name="httpOnly" value="true"/>
    <property name="maxAge" value="2592000"/><!-- 30 天 -->
</bean>
<!-- rememberMe 管理器 -->
<bean id="rememberMeManager" class="org.apache.shiro.web.mgt.CookieRememberMeManager">
    <property name="cipherKey" value="#{T(org.apache.shiro.codec.Base64).decode('4AvVhmFLUs0KTA3Kprsdag==')}"/>
    <property name="cookie" ref="rememberMeCookie"/>
</bean>
<!-- 安全管理器 -->
<bean id="securityManager" class="org.apache.shiro.web.mgt.DefaultWebSecurityManager">
    ……
    <property name="rememberMeManager" ref="rememberMeManager"/>
</bean>
<bean id="formAuthenticationFilter" class="org.apache.shiro.web.filter.authc.FormAuthenticationFilter">
    ……
    <property name="rememberMeParam" value="rememberMe"/>
</bean>
```
rememberMe 管理器，cipherKey 是加密 rememberMe Cookie 的密钥；默认 AES 算法；设置 securityManager 安全管理器的 rememberMeManager；rememberMeParam，即 rememberMe 请求参数名，请求参数是 boolean 类型，true 表示 rememberMe。

`/authenticated.jsp = authc` 表示访问该地址用户必须身份验证通过（ Subject.isAuthenticated()==true）；而`/** = user`表示访问该地址的用户是身份验证通过或 RememberMe 登录的都可以。
