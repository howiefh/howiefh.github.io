title: Spring笔记一
date: 2015-03-06 16:09:20
tags: Spring
categories: 
- JavaEE
- Spring
description: Spring
---


使用Spring框架，必须使用Spring Core Container，主要由`org.springframework.core`、`org.springframework.beans`和`org.springframework.context`、`org.springframework.expression`四个包及其子包组成，主要提供Spring IoC容器支持。

<!-- more -->

![Spring组成结构](http://fh-1.qiniudn.com/spring3-modules.png "Spring组成结构")

## Spring核心机制：依赖注入

Java应用（从applets的小范围到全套n层服务端企业应用）是一种典型的依赖型应用，它就是由一些互相适当地协作的对象构成的。因此，我们说这些对象间存在依赖关系。加入A组件调用了B组件的方法，我们就可以称A组件依赖于B组件。我们通过使用依赖注入，Java EE应用中的各种组件不需要以硬编码方式耦合在一起，甚至无需使用工厂模式。当某个Java 实例需要其他Java 实例时，系统自动提供所需要的实例，无需程序显示获取，这种自动提供java实例我们谓之为依赖注入，也可以称之为控制反转（Inversion of Control IoC）。

依赖注入通常有如下两种：
1. 设置注入：IoC容器使用属性的setter方法来注入被依赖的实例。
2. 构造注入：IoC容器使用构造器来注入被依赖的实例。

### 设值注入

设值注入是指IoC容器使用属性的setter方法来注入被依赖的实例。这种注入方式比较简单、直观。
下面是Person接口，该接口定义了一个Person规范。

```
public interface Person {  
    //定义使用斧子的方法  
    public void useAxe();  
}  
```

Axe接口：

```
public interface Axe {  
    //Axe接口里面有个砍的方法  
    public String chop();  
}  
```

Person的实现类。

```
public class Chinese implements Person {  
    private Axe axe;  
    private String name;  

    // 设值注入所需的setter方法  
    public void setAxe(Axe axe) {  
        this.axe = axe;  
    }  

    public void setName(String name) {  
        this.name = name;  
    }  

    // 实现Person接口的userAxe方法  
    public void useAxe() {  
        // 调用axe的chop方法，表明Person对象依赖于Axe对象  
        System.out.println("我是"+name+"用"+axe.chop());  
    }  

}  
```

上面的代码实现了Person接口的userAxe()方法，实现该方法时调用了axe的的chop()方法，这就是典型的依赖关系。

在这里Spring容器的作用就是已松耦合的方式来管理这种调用关系。在上面的Chinese类中，Chinese类并不知道它要调用的axe实例在哪里，也不知道axe实例是如何实现的，它只是需要调用一个axe实例，这个Axe实例将由Spring容器负责注入。
Axe的实现类：StoneAxe类

```
public class StoneAxe implements Axe{  
    public String chop() {  
        return "石斧砍柴好慢啊!!!";  
    }  
}  
```

直到这里，程序依然不知道Chinese类和Axe实例耦合，Spring也不知道！实际上，Spring需要使用XML配置文件来指定实例之间的依赖关系。
Spring采用了XML文件作为配置文件。
对于本应用的XML配置文件如下：

```
<?xml version="1.0" encoding="UTF-8"?>  
<beans xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
xmlns="http://www.springframework.org/schema/beans"  
xsi:schemaLocation="http://www.springframework.org/schema/beans  
http://www.springframework.org/schema/beans/spring-beans-3.0.xsd">  
    <!-- 配置Chinese实例，其实现类是Chinese -->  
    <bean id="chinese" class="com.spring.service.impl.Chinese">  
        <!-- 将StoneAxe注入给axe属性 -->  
        <property name="axe" ref="stoneAxe" />  
        <property name="name" value="孙悟空"/>  
    </bean>  
    <!-- 配置stoneAxe实例 -->  
    <bean id="stoneAxe" class="com.spring.service.impl.StoneAxe" />  
</beans>  
```

在配置文件中，Spring配置Bean实例通常会指定两个属性：

* id：指定该Bean的唯一标识，程序会通过id属性值来访问该Bean实例。
* class：指定该Bean的实现类，此处不可再用接口，必须是实现类，Spring容器会使用XML解析器读取该属性值，并利用反射来创建该实现类的实例。

从上面可以看出Bean于Bean之间的依赖关系放在配置文件里组织，而不是写在代码里。通过配置文件的指定，Spring能够精确地为每个Bean注入属性。因此，配置文件里的`<bean…/>`元素的class属性值不能是接口，而必须是真正的实现类。

Spring会自动接管每个`<bean…/>`定义里的`<property …/>`元素定义，Spring会在调用无参数的构造器、创建默认的Bean实例后，调用相应的setter方法为程序注入属性值。`<property…/>`定义的属性值将不再有该Bean来主动设置、管理，而是接受Spring的注入。

每个Bean的id属性是该Bean的唯一标识，程序通过id属性访问Bean，Bean与Bean的依赖关系也是通过id属性关联。
测试程序：

```
public class BeanTest {  
    public static void main(String[] args) {  
        //创建Spring容器  
        ApplicationContext ctx = new ClassPathXmlApplicationContext("bean.xml");  
        //获取Chinese实例  
        Person person = ctx.getBean("chinese",Person.class);  
        person.useAxe();  
    }  
}  
```

Bean与Bean之间的依赖关系有Spring管理，Spring采用setter方法为目标Be阿玛尼注入所依赖的Bean，这种方式被称之为设值注入。

从上面的实例我们可以看出，依赖注入以配置文件管理Bean实例之间的耦合，让Bean实例之间的耦合从代码层次分离出来。

Spring IoC容器有如下3个基本要点：

1. 应用程序的各个组件面向接口编程。面向接口编程可以将各个组件的耦合提升到接口层次，从而有利于项目后期的扩展。
2. 应用程序的各组件不再由程序主动产生，而是由Spring容器来负责产生，并初始化。
3. Spring采用配置文件、或者Annotation来管理Bean的实现类、依赖关系，Spring容器则根据配置文件，利用反射机制来创建时间，并为之注入依赖关系。

### 构造注入

构造注入就是利用构造器来设置依赖关系的方式。
Japanese类：

```
public class Chinese implements Person{  
    private Axe axe;  
    //默认构造器  
    public Chinese(){  

    }  
    //构造注入所需的带参数构造器  
    public Chinese(Axe axe){  
    this.axe = axe;  
    }  
    public void useAxe() {  
        System.out.println(axe.chop());  
    }  
}
```

上面的Chinese类并没有setter方法，仅仅只是提供了一个带Axe属性的构造器，Spring将通过该构造器为Chinese注入所依赖的Bean实例。

构造注入的配置文件需要做一些修改。为了使用构造注入，使用`<constructor-arg…/>`元素来指定构造器的参数。如下

```
<?xml version="1.0" encoding="UTF-8"?>  
<beans xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
xmlns="http://www.springframework.org/schema/beans"  
xsi:schemaLocation="http://www.springframework.org/schema/beans  
http://www.springframework.org/schema/beans/spring-beans-3.0.xsd">  
    <!-- 配置Chinese实例 -->  
    <bean id="chinese" class="com.spring.service.impl.Chinese">  
        <!-- 使用构造注入，为Japanese实例注入SteelAxe实例-->  
        <constructor-arg ref="stoneAxe"/>  
    </bean>  
    <!-- 配置stoneAxe实例 -->  
    <bean id="stoneAxe" class="com.spring.service.impl.StoneAxe" />  
</beans>  
```

上面的配置文件使用`<contructor-arg…/>`元素指定了一个构造器参数，该参数类型是Axe，这指定Spring调用Chinese类里带一个Axe参数的构造器来创建chinese实例，因为使用了有参数的构造器创建实例，所以当Bean实例被创建完成后，该Bean的依赖关系也就已经设置完成。

### 两种注入方式的对比

Spring支持两种依赖注入方式，这两种依赖注入方式并没有好坏之分，只是适合的场景有所不同。
设值注入有如下优点：
1. 与传统的JavaBean的写法更相似，程序开发人员更加容易理解，接受。通过setter方法设定依赖关系显得更加直观、自然。
2. 对于复杂的依赖关系，如果采用构造注入，会导致构造器过于臃肿，难以阅读。Spring在创建Bean实例时，需要同时实例化其依赖的全部实例，因此导致性能下降。而设值注入，则可以避免这些问题。
3. 尤其是在某些属性可选的情况下，多参数的构造器更加笨重。
但是构造器也有如下优势：
1. 构造注入可以再构造器中决定依赖关系的注入顺序，优先依赖的优先注入。
2. 对于依赖关系无须变化的Bean，构造注入更有用处。因为没有setter方法，所有的依赖关系全部在构造器中设定，因此，无须担心后续的代码对依赖关系产生破坏。
3. 依赖关系只能在构造器中设定，则只有组件的创建者才能改变组件的依赖关系。对组件的调用者而言，组件内部的依赖关系完全透明，更加符合高内聚的原则。

通过上面的对比。所以建议用以设值注入为主，构造注入为辅的注入策略。对于依赖关系无须变化的注入，尽量采用构造注入；而其他的依赖关系，则考虑设值注入。

Spring有两个核心接口：BeanFactory和ApplicationContext，其中ApplicationContext是BeanFactory的子接口。他们都可代表Spring容器，Spring容器是生成Bean实例的工厂，并且管理容器中的Bean。Bean是Spring管理的基本单位，在基于Spring的Java EE应用中，所有的组件都被当成Bean处理，包括数据源、Hibernate的SessionFactory、事务管理器等。

而且应用中的所有组件，都处于Spring的管理下，都被Spring以Bean的方式管理，Spring负责创建Bean实例，并管理他们的生命周期。Bean在Spring容器中运行，无须感受Spring容器的存在，一样可以接受Spring的依赖注入，包括Bean属性的注入，协作者的注入、依赖关系的注入等。

Spring容器负责创建Bean实例，所以需要知道每个Bean的实现类，Java程序面向接口编程，无须关心Bean实例的实现类；但是Spring容器必须能够精确知道每个Bean实例的实现类，因此Spring配置文件必须精确配置Bean实例的实现类。

## Spring容器

Spring容器最基本的接口就是BeanFactor。BeanFactory负责配置、创建、管理Bean，他有一个子接口：ApplicationContext，因此也称之为Spring上下文。Spring容器负责管理Bean与Bean之间的依赖关系。

BeanFactory接口包含以下几个基本方法：
* `Boolean containBean(String name)`:判断Spring容器是否包含id为name的Bean实例。
* `<T> getBean(Class<T> requiredTypr)`:获取Spring容器中属于requiredType类型的唯一的Bean实例。
* `Object getBean(String name)`：返回Sprin容器中id为name的Bean实例。
* `<T> T getBean(String name,Class requiredType)`：返回容器中id为name,并且类型为requiredType的Bean
* `Class <?> getType(String name)`：返回容器中指定Bean实例的类型。

在使用BeanFactory接口时，我们一般都是使用这个实现类：org.springframework.beans.factory.xml.XmlBeanFactory。然而ApplicationContext作为BeanFactory的子接口，使用它作为Spring容器会更加方便。它的实现类有：FileSystemXmlApplicationContext、ClassPathXmlApplicationContext、AnnotationConfigApplicationContext。

创建Spring容器实例时，必须提供Spring容器管理的Bean的详细配置信息。Spring的配置信息通常采用xml配置文件来设置，因此，创建BeanFactory实例时，应该提供XML配置文件作为参数。

XML配置文件通常使用Resource对象传入。Resource接口是Spring提供的资源访问接口，通过使用该接口，Spring能够以简单、透明的方式访问磁盘、类路径以及网络上的资源。

对于Java EE应用而言，可在启动Web应用时自动加载ApplicationContext实例，接受Spring管理的Bean无须知道ApplicationContext的存在。一般使用如下方式实例化BeanFactory

```
//搜索当前文件路径下的bean.xml文件创建Resource对象  
InputStreamSource isr = new FileSystemResource("bean.xml");  
//以Resource对象作为参数创建BeanFactory实例  
XmlBeanFactory factory = new XmlBeanFactory((Resource) isr);
```
//搜索当前文件路径下的bean.xml文件创建Resource对象  

或
```
ClassPathResource res = new ClassPathResource("bean.xml");  
//以Resource对象作为参数创建BeanFactory实例  
XmlBeanFactory factory = new XmlBeanFactory(res);
```
但是如果应用里面有多个属性配置文件，则应该采用BeanFactory的子接口ApplicationContext来创建BeanFactory的实例。ApplicationContext通常使用如下两个实现类：

* FileSystemXmlApplicationContext：以基于文件系统的XML配置文件创建ApplicationContext实例。
* ClassPathXmlApplicationContext：以类加载路径下的XML配置文件创建的ApplicationContext实例。
如果需要同时加载多个XML配置文件，采用如下方式：

```
//搜索CLASSPATH路径，以classpath路径下的bean.xml、service.xml文件创建applicationContext  
ApplicationContext ctx = new ClassPathXmlApplicationContext(new String[]{"bean.xml","service.xml"});  

//以指定路径下的bean.xml、service.xml文件创建applicationContext  
ApplicationContext ctx1 = new FileSystemXmlApplicationContext(new String[]{"bean.xml","service.xml"});
```

### 使用ApplicationContext

ApplicationContext允许以声明式方式操作容器，无须手动创建它。在Web应用启动时自动创建ApplicationContext。当然，也可以采用编程方式创建ApplicationContext。

除了提供BeanFactory所支持的全部功能外，ApplicationContext还有如下功能：

1. ApplicationContext继承MessageSource接口，因此提供国际化支持。
2. 资源访问。
3. 事件机制。
4. 载入多个配置文件。
5. 以声明式的方式启动，并创建Spring容器。

当系统创建ApplicationContext容器时，默认会预初始化所有的singleton Bean。也就是说，当ApplicationContext容器初始化完成后，容器中所有singleton Bean也实例化完成，这就意味着：系统前期创建ApplicationContext时将有较大的系统开销，但一旦ApplicationContext初始化完成，程序后面获取singleton Bean实例时将拥有较好的性能。

### ApplicationContext的国际化支持

ApplicationContext接口继承MessageSource接口，因此具备国际化功能。MessageSource接口中定义了三个方法用于国际化功能。

* `String getMessage(Stringcode,Object[] args,Locale loc);`
* `StringgetMessage(String code,Object[] args,String default,Locale loc);`
* `StringgetMessage(MessageSourceResolvable resolvable,Local loc);`

ApplicationContext正是通过这三个方法来实现国际化的。当程序创建ApplicationContext容器时，Spring会自动查找在配置文件中名为messageSource的bean实例，一旦找到这个Bean实例，上述三个方法的调用被委托给该MessageSource Bean。如果没有该Bean，ApplicationContext会查找其父定义中的messagesource Bean，如果找到，它会作为messageSource Bean使用。但是如果无法找到messageSource，系统将会创建一个空的staticMessageSource Bean，该Bean的能接受上述三个方法的调用。

在Spring中配置messagesourceBean时通常使用ResourceBundleMessageSource.如下：
```
<?xml version="1.0" encoding="UTF-8"?>  
<beans xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
xmlns="http://www.springframework.org/schema/beans"  
xsi:schemaLocation="http://www.springframework.org/schema/beans  
http://www.springframework.org/schema/beans/spring-beans-3.0.xsd">  
<bean id="messsageSource" class="org.springframework.context.support.ResourceBundleMessageSource">  
<property name="basenames">  
<list>  
    <value>messagevalue>  
    <!--如果有多个资源文件，全部列在此处-->
</list>  
</property>  
</bean>  
</beans>  
```

message.properties:
```
hello=欢迎你:{0}
now=现在时间是:{0}
```

配置文件中包含非西欧文字需要使用native2ascii工具
```
native2ascii message.properties message_zh_CN.properties
```

使用
```
ApplicationContext ctx = new ClassPathXmlApplicationContext("bean.xml");
String[] a ={"howie"};
String hello = ctx.getMessage("hello",a, Locale.getDefault());
Object[] b = {new Date()};
String now = ctx.getMessage("now",b,Locale.getDefault());
```

### ApplicationContext的事件机制

ApplicationContext的事件机制是观察者设计模式的实现，通过ApplicationEvent类和ApplicationListener接口，可以实现ApplicationContext的事件处理。

Spring的事件框架有如下两个重要成员：

1. ApplicationEvent：容器事件，必须由ApplicationContext发布。
2. ApplicationListener：监听器，可由容器中的任何监听器Bean担任。

Spring的事件机制需要事件源、事件和事件监听器组成。只是此处的事件是ApplicationContext，且事件必须由java程序显示触发。下图简单示范了ApplicationContext的事件流程。
                                    
下面实例展示了Spring容器的事件机制。
1. 定义一个ApplicationEvent类，其对象就是Spring容器事件。
        
    {% codeblock %}
    public class EmailEvent extends ApplicationEvent {  
        private static final long serialVersionUID = 1L;  
        private String address;  
        private String text;  
        // 定义一个带参的构造函数  
        public EmailEvent(Object source) {  
            super(source);  
        }  
        public EmailEvent(Object source, String address, String text) {  
            super(source);  
            this.address = address;  
            this.text = text;  
        }  
        //address、text的setter和getter方法
    }
    {% endcodeblock %}

    容器事件的监听器类必须实现ApplicationListener接口，它的实现方法如下：
    onAPplicationEvent(ApplicationEventevent):每当容器内发生任何事件时，此方法都会被触发。

2. 编写该容器的监听器类。

    {% codeblock %}
    public class EmailNotifier implements ApplicationListener{  
        //该方法会在容器发生事件时触发  
        public void onApplicationEvent(ApplicationEvent event) {  
            if(event instanceof EmailEvent){  
                //只处理EmailEvent，发送email通知  
                EmailEvent emailEvent = (EmailEvent) event;  
                System.out.println("需要发送邮件的接收地址为:"+emailEvent.getAddress());  
                    
                System.out.println("需要发送邮件的邮件正文是:"+emailEvent.getText());  
            } else {
                //容器内置事件不作任何处理  
                System.out.println("容器本身的事件:"+event);  
            }  
        }  
    }  
    {% endcodeblock %}

3. 将监听器类配置在容器中。

    在为Spring容器注册监听器时，我们只需在Spring配置文件中配置一个实现了ApplicationListener的Bean即可，Spring容器会把这个Bean当做容器事件的监听器。 
    {% codeblock %}
    <?xml version="1.0" encoding="UTF-8"?>  
    <beans xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
    xmlns="http://www.springframework.org/schema/beans"  
    xsi:schemaLocation="http://www.springframework.org/schema/beans  
    http://www.springframework.org/schema/beans/spring-beans-3.0.xsd">  
    <!-- 配置监听器 -->  
    <bean class="com.app.listener.EmailNotifier"/>  
    </beans>  
    {% endcodeblock %}

通过上面的3个步骤就可以实现Spring容器的事件了。当系统创建Spring容器，加载Spring容器时会自动触发容器事件，容器事件监听器可以监听到这些事件。同时我们也可以调用ApplicationContext的pulishEvent()方法来主动触发容器事件。

```
public class SpringTest {  
    public static void main(String[] args) {  
        ApplicationContext ctx = new ClassPathXmlApplicationContext("bean.xml");  
        //创建一个ApplicationEvent对象  
        EmailEvent emailEvent = new EmailEvent("hello","spring_test@163.com","this is a test");  
        //主动触发容器事件  
        ctx.publishEvent(emailEvent);  
    }  
}  
```

如果Bean想发布事件，则Bean必须获得其容器的引用。如果程序中没有直接获取容器的引用，则应该让Bean实现ApplicationContextAware或BeanFactoryAware接口，从而获得容器的引用。

除了我们可以自己实现Spring容器的事件外，Spring也提供了几个内置事件：
1. ContextRefreshedEvent：ApplicationContext容器初始化或者刷新时触发该事件。
2. ContextStartedEvent：当使用ConfigurableApplicationContext接口的start()方法启动ApplicationContext容器时触发该事件。
3. ContextClosedEvent：当使用ConfigurableApplicationContext接口的close()方法关闭ApplicationContext容器时触发该事件。
4. ContextStopedEvent: 当使用ConfigurableApplicationContext接口的stop()方法停止ApplicationContext容器时触发该事件。

### 让Bean获取Spring容器

在Spring中我们可以使用Spring容器中getBean()方法来获取Spring容器中的Bean实例。在这样的访问模式下，程序中总是持有Spring容器的引用。但是在实际的应用中，Spring容器通常是采用声明式方式配置产生：即开发者只要在web.xml文件中配置一个Listener，该Listener将会负责初始化Spring容器。在这种情况下，容器中Bean处于容器管理下，无须主动访问容器，只需要接受容器的注入管理即可。同时Bean实例的依赖关系通常也是由容器动态注入，无须Bean实例主动请求。

在这种情况下，Sprig容器中Bean通常不会需要访问容器中其他的Bean—采用依赖注入，让Spring把被依赖的Bean注入到依赖的Bean中即可。

实现BeanFactoryAware接口的Bean，拥有访问的BeanFactory容器的能力，实现BeanFactoryAware接口的Bean实例将会拥有对容器的访问能力。BeanFactoryAware接口仅有如下一个方法：

SetBeanFactory(BeanFactory beanFactory)：该方法有一个参数beanFactory，该参数指向创建它的BeanFactory。

该方法将由Spring调动，当Spring调用该方法时会将Spring容器作为参数传入该方法。

```
public class Chinese implements ApplicationContextAware{  
    //将BeanFactory容器以成员变量保存  
    private ApplicationContext ctx;  
    /** 
    * 实现ApplicationContextAware接口实现的方法 
    */  
    public void setApplicationContext(ApplicationContext cyx)  throws BeansException {  
        this.ctx = ctx;
    }  
    //获取ApplicationContext的测试方法  
    public ApplicationContext getContext(){  
        return ctx;  
    }  
}  
```

上面的Chinese类实现了ApplicationContext接口，并实现了该接口提供的setApplicationContextAware()方法，这就使得该Bean实例可以直接访问到创建她的Spring容器。
将该Bean部署在Spring容器中。
测试类：
该程序先通过实例化的方法来获取ApplicationContext，然后通过chinese Bean来获得BeanFactory，并将两者进行比较。

```
public class ChineseTest {  
    public static void main(String[] args) {  
        ApplicationContext ctx = new ClassPathXmlApplicationContext("bean.xml");
        Chinese c = ctx.getBean("chinese",Chinese.class);  
        System.out.println(c.getContext());  
        System.out.println(c.getContext()==ctx);  

    }  
}  
//结果如下：
true
```
上面的代码虽然实现了ApplicationContextAware接口让Bean拥有了访问容器的能力，但是污染了代码，导致代码与Spring接口耦合在一起。所以，如果不是特别需要，一般不建议直接访问容器。

## Spring容器中的Bean

从前面我们知道Spring其实就是一个大型的工厂，而Spring容器中的Bean就是该工厂的产品.对于Spring容器能够生产那些产品，则取决于配置文件中配置。

对于我们而言，我们使用Spring框架所做的就是两件事：开发Bean、配置Bean。对于Spring框架来说，它要做的就是根据配置文件来创建Bean实例，并调用Bean实例的方法完成“依赖注入”。

### Bean的基本定义

beans元素可以有以下属性，bean元素可以有没有default-前缀的属性，beans属性是全局的。
* default-lazy-init ：延迟初始化
* default-merge：merge行为
* default-autowire：自动装配行为
* default-autowire-candidates：自动装配候选bean
* default-init-method：初始化方法
* default-destroy-method：回收方法

`<beans…/>`元素是Spring配置文件的根元素，`<bean…/>`元素师`<beans../>`元素的子元素，`<beans…/>`元素可以包含多个`<bean…/>`子元素，每个`<bean…/>`元素可以定义一个Bean实例，每一个Bean对应Spring容器里的一个Java实例定义Bean时通常需要指定两个属性。

* id：确定该Bean的唯一标识符，容器对Bean管理、访问、以及该Bean的依赖关系，都通过该属性完成。Bean的id属性在Spring容器中是唯一的。    
* class：指定该Bean的具体实现类。注意这里不能是接口。通常情况下，Spring会直接使用new关键字创建该Bean的实例，因此，这里必须提供Bean实现类的类名。

下面是定义一个Bean的简单配置
```
<!-- 定义第一个Bean实例：bean1 -->  
<bean id="bean1" class="com.Bean1" />  
<!-- 定义第二个Bean实例：bean2 -->  
<bean id="bean2" class="com.Bean2" />  
```

当我们在配置文件中通过`<bean id=”xxx” class=”x.xxxClass”/>`方法配置一个Bean时，这样就需要该Bean实现类中必须有一个无参构造器。故Spring底层相当于调用了如下代码：
```
xxx = new x.xxxClass()  
```

如果在配置文件中通过构造注入来创建Bean：
```
<bean id="bean1" class="com.Bean1">  
    <constructor-arg value="chenssy"/>  
    <constructor-arg value="35-354"/>  
</bean>  
```

则Spring相当于调用如下代码：
```
Bean bean = new com.Test("chenssy","35-354");  
```
除了可以为`<bean…/>`元素指定一个id属性外，还可以为`<bean…/>`元素指定name属性，用于为Bean实例指定别名。如果需要为Bean实例指定多个别名，可以在name属性中使用逗号、冒号或者空格来分隔多个别名，后面通过任一别名即可访问该Bean实例。但是在一些特殊的情况下，程序无法在定义Bean时就指定所有的别名，而是在其他地方为一个已经存在的Bean实例指定别名，则可以使用`<alias…/>`元素来完成，该元素有如下两个属性：
* name：该属性指定一个Bean实例的标识名，表示将会为该Bean指定别名。
* alias：指定一个别名.
如：

```
<alias name=”bean1” alias=”name1”/>  
<alias name=”bean2” alias=”name2”/>  
```
在默认情况下，当Spring创建ApplicationContext容器时，Spring会自动预初始化容器中所有的singleton实例，如果我们想让Spring容器预初始化某个singleton Bean，则可以为该`<bean…/>`元素增加lazy-init属性，该属性用于指定该Bean实例的预初始化，如果设置为true，则Spring不会预初始化该Bean实例。

```
<bean id=”person” class=”com.Person” lazy-init=”true”/>  
```

### 容器中Bean的作用域

当通过Spring容器创建一个Bean实例时，不仅可以完成Bean实例的实例化，还可以为Bean指定特定的作用域。Spring支持5种作用域：

* singleton：单例模式。在整个Spring IoC容器中，使用singleton定义的Bean将只有一个实例。
* prototype：原型模式。每次通过容器的getBean方法获取prototype定义的Bean时，都将产生一个新的Bean实例。
* request：对于每次HTTP请求，使用request定义的Bean都将产生一个新的实例，即每次HTTP请求都会产生不同的Bean实例。当然只有在WEB应用中使用Spring时，该作用域才真正有效。
* session：对于每次HTTPSession，使用session定义的Bean都将产生一个新的实例时，即每次HTTP Session都将产生不同的Bean实例。同HTTP一样，只有在WEB应用才会有效。
* global session：每个全局的HTTPSession对应一个Bean实例。仅在portlet Context的时候才有效。

比较常用的singleton和prototype。如果一个Bean实例被设置为singleton，那么每次请求该Bean时都会获得相同的实例。容器负责跟踪Bean实例的状态，负责维护Bean实例的生命周期行为。如果一个Bean实例被设置为prototype，那么每次请求该id的Bean，Spring都会创建一个新的Bean实例返回给程序，在这种情况下，Spring容器仅仅使用new关键字创建Bean实例，一旦创建成功，容器将不会再跟踪实例，也不会维护Bean实例的状态。Spring默认使用singleton作用域。prototype作用域Bean的创建、销毁代价会比较大。除非必要，否则尽量避免将Bean的作用域设置为prototype。

设置Bean的作用域是通过scope属性来指定。可以接受Singleton、prototype、request、session、global session 5个值。
```
<!-- 配置一个singleton Bean实例：默认 -->  
<bean id="bean1" class="com.Bean1" />  
<!-- 配置一个prototype Bean实例 -->  
<bean id="bean2" class="com.Bean2" scope="prototype"/>  
```

测试代码：
```
public class SpringTest {  

    public static void main(String[] args) {  
        ApplicationContext ctx = new ClassPathXmlApplicationContext("bean.xml");
        //判断两次请求singleton作用域的Bean实例是否相等  
        System.out.println(ctx.getBean("bean1")==ctx.getBean("bean1"));  
        //判断两次请求prototype作用域的Bean实例是否相等  
        System.out.println(ctx.getBean("bean2")==ctx.getBean("bean2"));  
    }  
}  
//程序运行结果如下
true
false
```
request和session作用域只在web应用中才会有效，并且必须在Web应用中增加额外配置才会生效。为了能够让request和session两个作用域生效，必须将HTTP请求对象绑定到位该请求提供的服务线程上，这使得具有request和session作用的Bean实例能够在后面的调用链中被访问到。

因此我们可以采用两种配置方式：采用Listener配置或者采用Filter配置，在web.xml中。
Listener配置：
```
<listener>  
<listener-class>  
org.springframework.web.context.request.RequestContextListener  
</listener-class>  
</listener>  
```
Filter配置
```
<filter>  
<filter-name>requestContextFilter</filter-name>  
<filter-class>org.springframework.web.filter.RequestContextFilter</filter-class>  
</filter>  
<filter-mapping>  
<filter-name>requestContextFilter</filter-name>  
<url-pattern>/*</url-pattern>  
</filter-mapping>  
```

一旦在web.xml中增加上面两种配置中的一种，程序就可以在Spring配置文件中使用request或者session作用域了。如下：
```
<!-- 指定使用request作用域 -->  
<bean id="p" class="com.app.Person" scope="request"/>  
```

上面的配置文件配置了一个实现类Person的Bean，指定它的作用域为request。这样Spring容器会为每次的HttP请求生成一个Person的实例，当该请求响应结束时，该实例也会被注销。

### 配置依赖

在一般情况下，我是不应该在配置文件中管理普通属性的引用，通常只是用配置文件管理容器中的Bean实例的依赖关系。

Spring在实例化容器时，会校验BeanFactory中每一个Bean的配置。这些校验包括：

* Bean引用的依赖Bean是否指向一个合法的Bean。
* Bean的普通属性值是否获得一个有效值。

对于singleton作用域的Bean，如果没有强行取消其预初始化的行为，系统会在创建Spring容器时预初始化所用singleton Bean，与此同时，该Bean所依赖的Bean也被一起实例化。

BeanFactory与ApplicationContext实例化容器中的Bean的时机也是不同的：BeanFactory等到程序需要Bean实例时才创建Bean，而ApplicationContext是在创建ApplicationContext实例时，会预初始化容器中的全部Bean。

ApplicationContext实例化过程比BeanFactory实例化过程的时间和内存开销大，但是一旦创建成功，应用后面的响应速度会非常快，同时可以检验出配置错误，故一般都是推荐使用ApplicationContext作为Spring容器。

其实我们可以指定lazy-int=”true”来强制取消singleton作用域的Bean的预初始。这样该Bean就不会随着ApplicationContext启动而预实例化了。

Spring可以为任何java对象注入任何类型的属性，只要改java对象为该属性提供了对应的setter方法即可。

```
<bean id="person" class="lee.Person">  
<!-- Property配置需要依赖注入的属性 -->  
<property name="name" value="chenming" />  
<property name="age" value="22" />  
</bean>  
```

Spring会为`<bean…/>`元素创建一个java对象，一个这样的java对象对应一个Bean实例，对于如上代码，Spring会采用如下形式来创建Java实例。

```
//获取lee.Person类的Class对象  
Class  personClass = Class.forName("lee.Person");  
//创建lee.Person类的默认实例  
Object personBean = personBean.newInStance();  
```

创建该实例后，Spring就会遍历该`<bean../>`元素的所有`<property…/>`子元素。`<bean…/>`元素每包含一个`<property…/>`子元素，Spring就会为该Bean实例调用一次setter方法。类似于下面程序：

```
//获取name属性的setter方法  
String setName = "set"+"Name";  
//获取lee.Person类里面的Set()Name方法  
java.lang.reflect.Method setMethod = personClass.getMethod(setName, aVal.getClass());  
//调用Bean实例的SetName()方法  
setMethod.invoke(personBean, aVal);  
```

对于使用`<constructor-arg…/>`元素来指定构造器注入，Spring不会采用默认的构造器来创建Bean实例，而是使用特定的构造器来创建该Bean实例。
```
<bean id="person" class="lee.Person">  
<constructor-arg index="0" value="aVal" />  
<constructor-arg index="1" value="bVal" />  
</bean>  
```

针对上面的代码，Spring会采用类似如下的代码来创建Bean实例：
```
//获取lee.Person类的class对象  
Class  personClass = Class.forName("lee.Person");  
//获取第一个参数是aVal类型，第二个参数是bVal类型的构造器  
Constructor personCtr = personClass.getConstructor(aVal.getClass(),bVal.getClass());  
//以指定构造器创建Bean实例  
Object bean = personCtr.newInstance(aVal,bVal);  
```

上面的程序只是一个实例，实际上Spring还需要根据`<property…/>`元素、`<contructor-arg../>`元素所使用value属性，ref属性等来判断需要注入的到底是什么数据类型，并要对这些值进行合适的类型转换，所以Spring的实际处理过程会更加复杂。

Java实例的属性值可以有很多种数据类型、基本类型值、字符串类型、java实例甚至其他的Bean实例、java集合、数组等。所以Spring允许通过如下几个元素为Bean实例的属性指定值：
* value
* ref
* bean
* list、set、map、props

### 设置普通属性值

value属性用于指定字符串类型、基本类型的属性值。Spring使用XML解析器来解析出这些数据，然后利用java.beans.PropertyEdior完成类型转换：从java.lang.String类型转换为所需的参数值类型。如果目标类型是基本数据类型，通常都是可以正确转换。
```
public class ValueTest {  
//定义一个String型属性  
private String name;  
//定义一个int型属性  
private int age;  
// name 、age的getter和setter方法
}  
```
上面实例只是演示了注入普通属性值。在Spring配置文件中使用value属性来为这两个属性指定属性值。

```
<bean id="text" class="com.spring.service.impl.ValueTest">  
<property name="age" value="1" />  
<property name="name" value="chenssy" />  
</bean>  
```

### 配置合作者

如果我们需要为Bean设置属性值是另一个Bean实例时，这个时候需要使用ref属性。

```
<bean id="steelAxe" class="com.spring.service.impl.SteelAce"></bean>  
<bean id="chinese" class="com.spring.service.impl.Chinese" >  
<property name="axe" ref="steelAxe" />  
</bean>  
```

早期Spring版本使用ref元素，ref元素可以指定如下两个属性。
bean:引用不在同一份XML配置文件中的其他Bean实例的id属性值。
local：引用同一份XML配置文件中的其他Bean实例的id属性值。
```
<bean id="steelAxe" class="com.spring.service.impl.SteelAce"></bean>  
<bean id="chinese" class="com.spring.service.impl.Chinese" >  
<property name="axe">  
<ref local="steelAxe"/>  
</property>  
</bean>  
```

### 使用自动装配注入合作者bean

Spring支持自动装配Bean与Bean之间的依赖关系，也就是说我们无需显示的指定依赖Bean。由BeanFactory检查XML配置文件内容，根据某种规则，为主调Bean注入依赖关系。

Spring的自动装配机制可以通过`<bean.../>`元素的default-autowire属性指定，也可以通过`<bean.../>`元素的autowire属性指定。

自动装配可以减少配置文件的工作量，但是它降低了依赖关系的透明性和清晰性，所以一般来说在较大部署环境中不推荐使用，显示配置合作者能够得到更加清晰的依赖关系。Spring提供了如下几种规则来实现自动装配。

* no:不适用自动装配。Bean依赖必须通过ref元素定义。
* byName：根据属性名自动装配。BeanFactory查找容器中的全部Bean，找出其中id属性与属性同名的Bean来完成注入。如果没有找到匹配的Bean实例，则Spring不会进行任何注入。
* byType：根据属性类型自动装配。BeanFactory查找容器中的全部Bean，如果正好有一个与依赖属性类型相同的Bean，就自动注入这个属性；但是如果有多个这样的Bean，就会抛出一个异常。如果没有匹配的Bean，则什么都不会发生，属性就不会被设置。如果需要无法自动装配时抛出异常，则设置dependency-check=”objects”。
* constructor:与不Type类似，区别是用于构造注入的参数。
* autodetect:BeanFactory根据Bean内部结构，决定使用constructor或者byType。如果找到一个默认的构造函数，则使用byType。

#### byName规则

byName规则是指通过名字注入依赖关系，假如Bean A的实现类里面包含setB()方法，而Spring的配置文件恰好包含一个id为b的Bean，则Spring容器就会将b实例注入Bean A中。如果容器中没有名字匹配的Bean，Spring则不会做任何事情。

```
<bean id="chinese" class="com.spring.service.impl.Chinese" autowire="byName" />  
<bean id="gundog" class="com.spring.service.impl.Gundog">  
<property name="name" value="wangwang" />  
</bean>  
```
上面的配置文件指定了byName规则。则com.app.service.impl.Chinese类中提供如下的依赖注入方法：
```
/** 
* 依赖关系必须的setter方法，因为需要通过名字自动装配 
* 所以setter方法必须提供set+Bean名，Bean名的首字母大写 
* @param dog 设置的dog值 
*/  
public void setGundog(Dog dog){  
    this.dog = dog;  
}  
```

#### byType规则

byType规则是根据类型匹配注入依赖关系。假如A实例有setB(B b)方法，而Spring配置文件中恰好有一个类型B的Bean实例，容器为A注入类型匹配的Bean实例。如果容器中存在多个B的实例，则会抛出异常，如果没有B实例，则不会发生任何事情。
```
<bean id="chinese" class="com.spring.service.impl.Chinese" autowire="byType" />  
<bean id="gundog" class="com.spring.service.impl.Gundog">  
<property name="name" value="wangwang" />  
</bean>  
```

针对上面的配置文件Chinese类有如下方法。
```
/**  
* 依赖关系必须的setter方法  
* 因为使用按类型自动装配，setter方法的参数类型与容器的Bean的类型相同  
* 程序中的Gundog实现了Dog接口  
* @param dog传入的dog对象  
*/  
public void setDog(Dog dog){  
    this.dog = dog;  
}  
```

当一个Bean即使用自动装配依赖，又使用ref显示依赖时，则显示指定的依赖就会覆盖自动装配。

在默认的情况下，Spring会自动搜索容器中的全部Bean，并对这些Bean进行判断，判断他们是否满足自动装配的条件，如果满足就会将该Bean注入目标Bean实例中。如果我们不想让Spring搜索容器中的全部Bean，也就是说，我们需要Spring来判断哪些Bean需要搜索，哪些Bean不需要搜索，这个时候就需要用到autowire-candidate属性。通过为`<bean.../>`元素设置autowire-candidate=”false”，即可将该Bean限制在自动装配范围之外，容器在查找自动装配对象时将不考虑该Bean。

### 注入嵌套Bean

如果某个Bean所依赖的Bean不想被Spring容器直接访问，则可以使用嵌套Bean。`<bean.../>`元素用来定义嵌套Bean，嵌套Bean只对嵌套它的外部Bean有效，Spring容器无法直接访问嵌套Bean，因此在定义嵌套Bean时是无需指定id属性的。

```
<bean id="chinese" class="com.spring.service.impl.Chinese" autowire="byName">
<property name="axe">  
<!--   
属性值为嵌套Bean，嵌套Bean不能由Spring容器直接访问，  
所以嵌套Bean是不需要id属性  
-->  
<bean class="com.spring.service.impl.SteelAce" />  
</property>  
</bean>  
```

采用上面的配置可以保证嵌套Bean不能被容器访问，因此不用担心其他程序修改嵌套bean。但是嵌套Bean限制了Bean的访问，提高了程序的内聚性。

### list、set、map、props

`<list.../>`、`<set.../>`、`<map.../>`和`<props.../>`元素分别用来设置类型list、set、map和Properties的集合属性值。
先看下面java类：
```
public class Chinese implements Person{  

//下面是一系列的集合属性  
private List<String> schools;  
private Map scores;  
private Map<String, Axe> phaseAxes;  
private Properties health;  
private Set axe;  
private String[] books;  
//setter 和getter方法
}
```
上面的java代码中有数组、list、set、，map、Properties。下面是针对上面的配置文件。
```
<?xml version="1.0" encoding="UTF-8"?>  
<beans xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
xmlns="http://www.springframework.org/schema/beans"  
xsi:schemaLocation="http://www.springframework.org/schema/beans  
http://www.springframework.org/schema/beans/spring-beans-3.0.xsd">  
<!-- 定义一个普通的Axe Bean -->  
<bean id="steelAxe" class="com.spring.service.impl.SteelAxe" />  
<bean id="stoneAxe" class="com.spring.service.impl.StoneAxe" />  

<!--定义Chinese Bean -->  
<bean id="chinese" class="com.spring.service.impl.Chinese">  
<property name="schools">  
<list>  
    <value>小学</value>  
    <value>中学</value>  
    <value>大学</value>  
</list>  
</property>  

<property name="scores">  
<map>  
    <entry key="语文" value="88" />  
    <entry key="数学" value="87" />  
    <entry key="外语" value="88" />  
</map>  
</property>  

<property name="phaseAxes">  
<map>  
    <entry key="原始社会" value-ref="stoneAxe" />  
    <entry key="农业社会" value-ref="steelAxe" />  
</map>  
</property>  

<property name="health">  
<props>  
    <prop key="血压">正常</prop>  
    <prop key="身高">175</prop>  
</props>  
</property>  

<property name="axe">  
<set>  
    <value>普通字符串</value>  
    <bean class="com.spring.service.impl.SteelAxe"></bean>  
    <ref local="stoneAxe"/>  
</set>  
</property>  

<property name="books">  
<list>  
    <value>java 编程思想</value>  
    <value>思考致富</value>  
    <value>将才</value>  
</list>  
</property>  
</bean>  
</beans>  
```

从上面的配置文件中可以看出，Spring对list属性和数组属性的处理是一样的。

当我们使用`<list.../>`、`<set.../>`、`<map.../>`等元素配置集合属性时，我们还需要手动配置集合元素。由于集合元素又可以是基本类型值、引用容器中的其他Bean、嵌套Bean和集合属性等。所以这些元素又可以接受如下子元素：

* value:指定集合元素是基本数据类型或者字符类型值。
* ref:指定集合元素师容器中另一个Bean实例。
* bean:指定集合元素是一个嵌套Bean。
* list、set、map、props:指定集合元素值又是集合。

`<props.../>`元素用于配置Properties类型的属性，Properties类型是一种特殊的类型，其key和value都只能是字符串。

使用`<map.../>`元素配置Map属性时比较复杂，因为Map集合的每个元素由key、value两个部分组成，所以配置文件中每个`<entry.../>`配置一个Map元素，其中entry支持如下4个属性：
* key：Map的key是基本类型或字符串。
* key-ref：Map的key是容器中另一个Bean实例。
* value：Map的value是基本类型或字符串。
* value-ref：Map的value是容器中另一个Bean实例。

### 组合属性名称

当在配置文件中为Bean属性指定值时，还可以使用组合属性名的方式。例如我们使用如foo.bar.name的属性名，这表明为Bean实例的foo属性的bar属性的name属性指定值。

```
public class Person {  
    private String name;  
    //getter .. setter
}  
public class ExampleBean {  
    private Person person=new Person();  
    public Person getPerson() {  
        return person;  
    }  
}  
```
bean.xml核心配置：
```
<bean id="exampleBean" class="com.bean.ExampleBean">  
        <property name="person.name" value="孙悟空"/>  
</bean>  
```
除了最后一个属性外，其他属性不能为null，否则引发异常

上面配置片段相当Spring执行：
```
exampleBean.getPerson().setName("孙悟空");
```

### Spring的Bean和JavaBean

Spring容器对Bean没有特殊要求，甚至不要求该Bean像标准的JavaBean那样必须为每个属性提供对应的getter和setter方法。Spring中的Bean是Java实例、Java组件；而传统的Java应用中的JavaBean通常作为DTO(数据传输对象)，用来封装值对象，在各层之间传递数据。

虽然Spring对Bean没有特殊要求，但还是建议Spring中的Bean应该尽量满足如下几个原则：

* 尽量为每个Bean实现类提供无参数的构造器。
* 接受构造注入的Bean，应该提供对应的构造函数。
* 接受设值注入的Bean，应该提供对应的setter方法，并不强制要求提供对应的getter方法。

传统的JavaBean和Spring中的Bean存在如下区别：
* 用处不同：传统的JavaBean更多作为值对象传递参数；Spring中的Bean用处几乎无所不包，任何应用组件都被称为Bean。
* 写法不同：传统的JavaBean作为值对象，要求每个属性都提供getter和setter方法；但Spring的Bean只需为接受设值注入的属性提供setter方法。
* 生命周期不同：传统的JavaBean作为值对象传递，不接受任何容器管理其生命周期；但Spring中的Bean由Spring管理其生命周期行为。

## Spring 3.0提供的Java配置管理 

Spring允许开发者使用Java类进行配置管理。
 
假如有如下Person实现类：
```
public class Chinese implements Person {
       private Axe axe;
       private String name;
       //设值注入所需的setter方法
       public void setAxe(Axe axe) {
           this.axe = axe;
       }
       //设值注入所需的setter方法
       public void setName(String name) {
           this.name = name;
       }
       //实现Person接口的useAxe方法
       public void useAxe() {
           //调用axe的chop()方法，
           //表明Person对象依赖于axe对象
           System.out.println("我是：" + name + axe.chop());
       }
}
```

上面Chinese类需要注入两个属性：name和Axe，本示例当然也为Axe提供了两个实现类：StoneAxe和SteelAxe。如果我们采用XML配置，相应的配置文件如下：
```
<?xml version="1.0" encoding="GBK"?>
<!-- Spring配置文件的根元素，使用spring-beans-3.0.xsd语义约束 -->
<beans xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns="http://www.springframework.org/schema/beans"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
       http://www.springframework.org/schema/beans/spring-beans-3.0.xsd">
       <!-- 配置chinese实例，其实现类是Chinese -->
       <bean id="chinese" class="org.crazyit.app.service.impl.Chinese">
                       <!-- 将stoneAxe注入给axe属性 -->
                       <property name="axe" ref="stoneAxe"/>
                       <property name="name" value="孙悟空"/>
       </bean>
       <!-- 配置stoneAxe实例，其实现类是StoneAxe -->
       <bean id="stoneAxe" class="org.crazyit.app.service.impl.StoneAxe"/>
       <!-- 配置steelAxe实例，其实现类是SteelAxe -->
       <bean id="steelAxe" class="org.crazyit.app.service.impl.SteelAxe"/>
</beans>
```

如果开发者不喜欢使用XML配置文件，Spring 3.0允许开发者使用Java类进行配置。
上面XML配置文件可以替换为如下Java配置类：

```
@Configuration
public class AppConfig {
       //定义需要依赖注入的属性值
       @Value("孙悟空") String personName;
       //配置一个Bean：chinese
       @Bean(name="chinese")
       public Person person() {
           Chinese p = new Chinese();
           p.setAxe(stoneAxe());
           p.setName(personName);
           return p;
       }
       //配置Bean：stoneAxe
       @Bean(name="stoneAxe")
       public Axe stoneAxe() {
           return new StoneAxe();
       }
       //配置Bean：steelAxe
       @Bean(name="steelAxe")
       public Axe steelAxe() {
           return new SteelAxe();
       }
}
```

上面配置文件中使用了Java配置类的3个常用Annotation：

* @Configuration：用于修饰一个Java配置类。
* @Bean：用于修饰一个方法，将该方法的返回值定义成容器中的一个Bean。
* @Value：用于修饰一个Field，用于为配置一个值。

一旦使用了Java配置类来管理Spring容器中Bean、及其依赖关系，此时需要使用如下方式来创建Spring容器：
```
//创建Spring容器
ApplicationContext ctx = new
       AnnotationConfigApplicationContext(AppConfig.class);
```
上面AnnotationConfigApplicationContext类会根据Java配置类来创建Spring容器。不仅如此，该类还提供了一个register(Class)方法用于添加Java配置类。

获得Spring容器之后，接下来利用Spring容器获取Bean实例、调用Bean方法就没有任何特别之处了。

使用Java配置类时，还有如下常用的Annotation：
* @Import：修饰一个Java配置类，用于向当前Java配置类中导入其他Java配置类。
* @Scope：用于修饰一个方法，指定该方法对应的Bean的生命域。
* @Lazy：用于修饰一个方法，指定该方法对应的Bean的是否需要延迟初始化。
* @DependOn：用于修饰一个方法，指定在初始化该方法对应的Bean之前初始化指定Bean。
 
1. 如果以XML配置为主，就需要让XML配置能加载Java类配置。这并不难，只要在XML配置中增加如下代码即可：
    {% codeblock %}
    <?xml version="1.0" encoding="GBK"?>
    <beans xmlns="http://www.springframework.org/schema/beans"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:context="http://www.springframework.org/schema/context"
        xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans-3.0.xsd
        http://www.springframework.org/schema/context
        http://www.springframework.org/schema/context/spring-context-3.0.xsd">
        <context:annotation-config/>
        <!—加载Java配置类 -->
        <bean class="org.crazyit.app.config.AppConfig”/>
    </beans>
    {% endcodeblock %}
    由于应用以XML配置为主，因此应用创建Spring容器时，还是以这份XML文件为参数来创建ApplicationContext对象。那么Spring会先加载这份XML配置文件，再根据这份XML配置文件的指示，去加载指定的Java配置类。

2. 如果以Java类配置为主，就需要让Java配置类能加载XML配置。这就需要借助于@ImportResource Annotation，这个Annotation可修饰Java配置类，用于导入指定的XML配置文件。也就是在Java配置类上增加如下Annotation即可：
    {% codeblock %}
    @Configuration
    //导入XML配置
    @ImportResource("classpath:/bean.xml")
    public class MyConfig {
        ……
    }
    {% endcodeblock %}
    由于应用以Java类配置为主，因此应用创建Spring容器时，应以Java配置类为参数，创建AnnotationConfigApplicationContext对象来作为Spring容器。那么Spring会先加载这个Java配置类，再根据这个Java配置类的指示，去加载指定的XML配置文件。

## Bean实例的创建方式及依赖配置

创建Bean通常有如下方法：调用构造器，调用静态工厂方法，调用实例工厂方法。

### 使用构造器创建Bean实例

使用构造器来创建Bean实例是最常见的情况，如果采用设置注入的方式，要求该类提供无参数构造器。class属性是必需的（除非采用继承）

BeanFactory将使用无参数构造器来创建Bean实例，该实例是个默认实例，Spring对Bean实例的所有属性执行默认初始化，即所有基本类型的值初始化为0或false，所有引用类型的值初始化为null。

接下来，BeanFactory会根据配置文件决定依赖关系，先实例化被依赖的Bean实例，然后为Bean注入依赖关系。最后将一个完整的Bean实例返回给程序，该Bean实例的所有属性，已经由Spring容器完成了初始化。

Axe.java :
```
public interface Axe {  
    public String chop();  
}  
```
Person.java :
```
public interface Person {  
    public void useAxe();  
}  
```
SteelAxe.java :
```
public class SteelAxe implements Axe {  
    @Override  
    public String chop() {  
        return "钢斧砍柴真快";  
    }  
    public SteelAxe() {  
        System.out.println("Spring实例化依赖Bean:SteelAxe实例...");  
    }  
}  
```
Chinese.java :
```
public class Chinese implements Person{  
    @Override  
    public void useAxe() {  
        System.out.println(axe.chop());  
    }  
    private Axe axe;  
    public void setAxe(Axe axe) {  
        System.out.println("Spring执行依赖关系注入");  
        this.axe = axe;  
    }  
    public Chinese() {  
        System.out.println("Spring实例化主调Bean:Chinese实例...");  
    }  
}  
```
bean.xml核心配置 :
```
<bean id="chinese" class="com.bean.Chinese">  
    <property name="axe" ref="steelAxe"/>  
</bean>  
    
<bean id="steelAxe" class="com.bean.SteelAxe"/>  
```
Test.java :
```
public class Test {  
    public static void main(String[] args) {  
        ApplicationContext ctx=new ClassPathXmlApplicationContext("bean.xml");  
        Person person=(Person) ctx.getBean("chinese");  
        person.useAxe();  
    }  
}  
//控制台输出：
Spring实例化主调Bean:Chinese实例...
Spring实例化依赖Bean:SteelAxe实例...
Spring执行依赖关系注入
钢斧砍柴真快
```

执行结果清楚地反映了执行过程：
1. 程序创建ApplicationContext实例。
2. 调用Chinese类的默认构造器创建默认实例。
3. 根据配置文件注入依赖关系：先实例化依赖Bean，然后将依赖Bean注入。
4. 返回一个完整的Chinese实例。

### 使用静态工厂方法创建Bean

Being.java :
```
public interface Being {  
    public void testBeing();  
}  
```
Dog.java :
```
public class Dog implements Being {  
    private String msg;  
    public void setMsg(String msg) {  
        this.msg = msg;  
    }  
    @Override  
    public void testBeing() {  
        System.out.println(msg+",狗爱啃骨头");  
    }  
}  
```
Cat.java :
```
public class Cat implements Being {  
    private String msg;  
    public void setMsg(String msg) {  
        this.msg = msg;  
    }  
    @Override  
    public void testBeing() {  
        System.out.println(msg+",猫爱吃老鼠");  
    }  
}  
```
BeingFactory.java :
  
```
public class BeingFactory {  
    public static Being getBeing(String arg){  
        if(arg.equalsIgnoreCase("dog")){  
            return new Dog();  
        }else{  
            return new Cat();  
        }  
    }  
}  
```
bean.xml核心配置：
```
<bean id="dog" class="com.bean.BeingFactory" factory-method="getBeing">  
    <constructor-arg value="dog"/>  
    <property name="msg" value="我是狗"/>  
</bean>  
    
<bean id="cat" class="com.bean.BeingFactory" factory-method="getBeing">  
    <constructor-arg value="cat"/>  
    <property name="msg" value="我是猫"/>  
</bean>  
```
从上面的核心配置可以看出，cat和dog两个Bean配置的class属性和factory-method属性完全相同，这是因为这两个实例都是由同一个工厂类的同一个静态方法生产得到的。配置这两个Bean实例指定了工厂的静态方法的实参值不同，配置静态方法的实参值使用`<constructor-arg.../>`元素。
Test.java :
```
public class Test {  
    public static void main(String[] args) {  
        ApplicationContext ctx=new ClassPathXmlApplicationContext("bean.xml");  
        Being b1=(Being) ctx.getBean("dog");  
        b1.testBeing();  
        Being b2=(Being) ctx.getBean("cat");  
        b2.testBeing();  
    }  
}  
```

使用静态工厂方法创建Bean实例时，class属性也必须指定，但此时class属性并不是Bean实例的实现类，而是静态工厂类。除此之外，还需要使用factory-method属性来指定工厂的静态方法名。

### 调用实例工厂方法创建Bean

Person.java :
```
public interface Person {  
    public String sayHello(String name);  
    public String sayGoodBye(String name);  
}  
```
Chinese.java :
```
public class Chinese implements Person {  
    @Override  
    public String sayGoodBye(String name) {  
        return name+",再见！";  
    }  
    @Override  
    public String sayHello(String name) {  
        return name+",你好";  
    }  
}  
```
American.java :
```
public class American implements Person {  
    @Override  
    public String sayGoodBye(String name) {  
        return name+",Good Bye !";  
    }  
  
    @Override  
    public String sayHello(String name) {  
        return name+",Hello !";  
    }  
}  
```
PersonFactory.java :
```
public class PersonFactory {  
    public Person getPerson(String ethnic){  
        if(ethnic.equalsIgnoreCase("chin")){  
            return new Chinese();  
        }else{  
            return new American();  
        }  
    }  
}  
```
bean.xml核心配置 :
```
<bean id="personFactory" class="com.bean.PersonFactory"/>  
<bean id="chinese" factory-bean="personFactory" factory-method="getPerson"> 
    <constructor-arg value="chin"/>  
</bean>  
   
<bean id="american" factory-bean="personFactory" factory-method="getPerson">
    <constructor-arg value="ame"/>  
</bean>  
```
Test.java :
```
public class Test {  
    public static void main(String[] args) {  
        ApplicationContext ctx=new ClassPathXmlApplicationContext("bean.xml");  
        Person p1=(Person) ctx.getBean("chinese");  
        System.out.println(p1.sayGoodBye("tom")+p1.sayHello("tom"));  
        Person p2=(Person) ctx.getBean("american");  
        System.out.println(p2.sayGoodBye("tom")+p2.sayHello("tom"));  
    }  
}  
```
实例工厂方法与静态工厂方法的区别。

调用实例工厂方法创建Bean，必须将实例工厂配置成Bean实例。而静态工厂方法创建Bean，则无需配置工厂Bean。
调用实例工厂方法创建Bean，必须使用factory-bean属性确定工厂Bean。而静态工厂方法创建Bean，则使用class元素确定静态工厂类。

## 深入理解容器中的Bean

### 使用抽象Bean

抽象Bean，都是指定abstract属性为true的Bean，抽象Bean不能被实例化，Spring容器不会创建抽象Bean的实例。抽象Bean的价值在于被继承，抽象Bean通常作为父Bean被继承。
当某个Bean将作为其他Bean的模板使用时，该Bean通常不需要实例化，而ApplicationContext默认预初始化所有的singleton Bean。为了阻止Bean模板被预初始化，可以指定abstract=“true”将该模板Bean设置为抽象Bean，Spring容器会忽略所有的抽象Bean定义，预初始化时不初始化抽象Bean。

```
<bean id="chineseTemplate" class="com.bean.Chinese" abstract="true">  
   <property name="axe" ref="steelAxe"/>  
</bean>  
<bean id="steelAxe" class="com.bean.SteelAxe"/>  
```
这样配置以后，当程序采用ApplicationContext作为Spring容器时，程序实例化ApplicationContext容器时会默认实例化所有的singleton Bean，但不会初始化abstract  Bean。
抽象Bean是一个模板，容器会忽略抽象Bean的定义，不会实例化抽象Bean。抽象Bean因为无须实例化，因此可以没有class属性。
```
<bean id="chineseTemplate" abstract="true">  
   <property name="axe" ref="steelAxe"/>  
</bean>  
<bean id="steelAxe" class="com.bean.SteelAxe"/>  
```
抽象Bean不能实例化，因此既不能通过getBean显式地获得抽象Bean实例，也不能将抽象Bean注入成其他Bean的依赖属性。无论何时，只要企图实例化抽象Bean，都将导致错误。

### 使用子Bean

现象：有一批Bean配置的大量配置信息完全相同，只有少量配置不同。那么我们是否有办法来简化配置呢？Spring提供了 Bean继承来应对这个问题。Spring可以先为这批Bean配置一个Bean模板，将这批Bean中相同的配置信息配置成Bean模板，因为Spring容器无须创建Bean模板的实例，所以通常将这个Bean模板配成抽象Bean。

将大部分相同信息配置成Bean模板后，将实际的Bean实例配置成Bean模板的子Bean即可。子Bean定义可以从父Bean继承实现类、构造器参数、属性值等配置信息，除此之外，子Bean配置可以增加新的配置信息，并可指定新的配置信息覆盖父Bean的定义。

子Bean无法从父Bean继承如下属性：depends-on、autowire、singleton、scope、lazy-init，这些属性将总是从子Bean定义中获得，或采取默认值。

通过为一个`<bean.../>`元素指定 parent属性 即可指定该Bean是一个子Bean，parent属性指定该Bean所继承的父Bean的id。

Axe.java :
```
public interface Axe {  
    public String chop();  
}  
```
SteelAxe.java :
```
public class SteelAxe implements Axe {  
    @Override  
    public String chop() {  
        return "钢斧砍柴真快";  
    }  
    public SteelAxe() {  
        System.out.println("Spring实例化依赖bean:SteelAxe实例...");  
    }  
}  
```
StoneAxe.java :
```
public class StoneAxe implements Axe {  
    @Override  
    public String chop() {  
        return "石斧砍柴真慢";  
    }  
    public StoneAxe() {  
        System.out.println("Spring实例化依赖bean:StoneAxe实例...");  
    }  
}  
```
Person.java :
```
public interface Person {  
    public void useAxe();  
}  
```
Chinese.java :
```
public class Chinese implements Person{  
    private Axe axe;  
    public void setAxe(Axe axe) {  
        System.out.println("Spring执行依赖关系注入...");  
        this.axe = axe;  
    }  
    public Chinese() {  
        System.out.println("Spring实例化主调bean:Chinese实例...");  
    }  
    @Override  
    public void useAxe() {  
        System.out.println(axe.chop());  
    }  
}  
```
bean.xml核心配置：
```
<bean id="steelAxe" class="com.bean.SteelAxe"/>  
<bean id="stoneAxe" class="com.bean.StoneAxe"/>  
  
<bean id="chineseTemplate" class="com.bean.Chinese" abstract="true">  
   <property name="axe" ref="steelAxe"/>  
</bean>  
<bean id="chinese" parent="chineseTemplate"/>  
```
Test.java :
```
public class Test {  
    public static void main(String[] args) {  
        ApplicationContext ctx=new ClassPathXmlApplicationContext("bean.xml");  
        Person p=(Person) ctx.getBean("chinese");  
        p.useAxe();  
    }  
}  
//控制台输出：
Spring实例化依赖bean：SteelAxe实例...
Spring实例化依赖bean：StoneAxe实例...
Spring实例化主调bean：Chinese实例...
Spring执行依赖关系注入...
钢斧砍柴真快
```

子Bean从父Bean继承了实现类，依赖关系等配置信息。实际上，子Bean也可以覆盖父Bean的配置信息：
```
<bean id="steelAxe" class="com.bean.SteelAxe"/>  
<bean id="stoneAxe" class="com.bean.StoneAxe"/>  
  
<bean id="chineseTemplate" class="com.bean.Chinese" abstract="true">  
   <property name="axe" ref="steelAxe"/>  
</bean>  
<bean id="chinese" parent="chineseTemplate">  
   <property name="axe" ref="stoneAxe"/>  
</bean>  
```
控制台输出：
```
Spring实例化依赖bean：SteelAxe实例...
Spring实例化依赖bean：StoneAxe实例...
Spring实例化主调bean：Chinese实例...
Spring执行依赖关系注入...
石斧砍柴真慢
```

### Bean继承与Java继承的区别

Spring中的Bean继承与Java中的继承截然不同。前者是实例与实例之间的参数的延续，后者则是一般到特殊的细化；前者是对象与对象之间的关系，后者是类与类之间的关系。Spring中的Bean继承与Java中的继承有如下区别：
1. Spring中子Bean和父Bean可以是不同类型，但Java中的继承则可保证子类是一种特殊的父类。
2. Spring中的Bean继承是实例之间的关系，因此主要表现为参数值的延续；而Java中的继承是类之间的关系，主要表现为方法、属性的延续。
3. Spring中子Bean不可作为父Bean使用，不具备多态性；Java中的子类实例完全可以当成父类实例使用。

### 容器中的 工厂Bean

此处的工厂Bean，与前面介绍的实例工厂方法创建Bean，或者静态工厂方法创建Bean的工厂有所区别：前面那些工厂是标准的工厂模式，Spring只是负责调用工厂方法来创建Bean实例；此处的工厂Bean是Spring的一种特殊Bean，这种工厂Bean必须实现FactoryBean接口。

FactoryBean接口是工厂Bean的标准接口，实现该接口的Bean通常只能作为工厂Bean使用，当我们将工厂Bean部署在容器中，并通过getBean( )方法来获取工厂Bean时，容器不会返回FactoryBean实例，而是返回FactoryBean的产品。

FactoryBean接口提供如下三个方法：
* Object getObject( )	实现该方法负责返回该工厂Bean生成的Java实例。
* Class getObjectType( )	实现该方法返回该工厂Bean生成的Java实例的实现类。
* boolean isSingleton( )	实现该方法表示该工厂Bean生成的Java实例是否为单例模式。 实现FactoryBean接口的Bean无法作为正常Bean使用，配置FactoryBean与配置普通Bean没有区别，但当客户端对该Bean id请求时，容器返回该FactoryBean的产品，而不是返回该FactoryBean本身。

Person.java :
```
public interface Person {  
    public String sayHello(String name);  
    public String sayGoodBye(String name);  
}  
```
Chinese.java :
```
public class Chinese implements Person{  
    @Override  
    public String sayGoodBye(String name) {  
        return "再见,"+name;  
    }  
    @Override  
    public String sayHello(String name) {  
        return "你好,"+name;  
    }  
}  
```
PersonFactory.java :
```
public class PersonFactory implements FactoryBean {  
    private Person p;  
    //返回工厂Bean所生产的产品  
    public Person getObject(){  
        if(p==null){  
            p=new Chinese();  
        }  
        return p;  
    }  
    //获取工厂Bean所生产的产品的类型  
    public Class<?> getObjectType() {  
        return Chinese.class;  
    }  
    //返回该工厂Bean所生产的产品是否为单例  
    public boolean isSingleton() {  
        return true;  
    }  
}  
```
bean.xml核心配置：
```
<bean id="chinese" class="com.bean.PersonFactory"/>  
```
Test.java :
```
public class Test {  
    public static void main(String[] args) {  
        ApplicationContext ctx=new ClassPathXmlApplicationContext("bean.xml");  
        //直接请求FactoryBean时，系统将返回该FactoryBean的产品  
        Person p1=(Person) ctx.getBean("chinese");//1  
        System.out.println(p1.sayHello("汤姆"));  
        System.out.println(p1.sayGoodBye("汤姆"));  
        //再次获取该FactoryBean的产品  
        Person p2=(Person) ctx.getBean("chinese");//2  
        System.out.println(p1==p2);  
        System.out.println(ctx.getBean("&chinese"));//3  
    }  
}  
///控制台输出：
你好，汤姆
再见，汤姆
true
com.bean.PersonFactory@5e5a50
```

上面的PersonFactory是一个标准的工厂Bean，该PersonFactory的getObject( )方法保证每次产生的Person对象是单例的，故该工厂类的isSingleton( )方法返回true。

Test.java中1和2直接请求容器中的FactoryBean，Spring将不会返回该FactoryBean实例，而是返回该FactoryBean的产品；程序3在Bean id前增加&符号，这将会让Spring返回FactoryBean本身。

因为FactoryBean以单例方式管理产品Bean，因此两次请求的产品，是同一个共享实例。

当程序需要获取FactoryBean本身时，并不直接请求Bean id，而是在Bean id前增加&符号。

对于初学者而言，可能无法体会到工厂Bean的作用。实际上，FactoryBean是Spring中非常有用的一个接口，Spring内置提供了很多实用的工厂Bean，例如TransactionProxyFactoryBean等，这个工厂Bean专门用于为目标Bean创建事务代理。

Spring提供的工厂Bean，大多以FactoryBean后缀结尾，Spring提供的工厂Bean，大多用于生产一批具有某种特征的Bean实例，工厂Bean是Spring的一个重要工具类。

### 获得Bean部署时的id

在某些极端情况下，程序开发Bean类时需要获得在容器中部署该Bean时指定的id属性，此时可借助于Spring提供的 BeanNameAware 接口，通过该接口允许Bean类获取部署该Bean时指定的id属性。

BeanNameAware接口提供的一个方法：setBeanName(String name)，该方法的name参数就是Bean的id，实现该方法的Bean类就可通过该方法来获得部署该Bean的id了。

Chinese.java :
```
public class Chinese implements BeanNameAware{  
    private String beanName;  
    @Override  
    public void setBeanName(String name) {  
        this.beanName=name;  
    }  
    public void getBeanId(){  
        System.out.println("Chinese实现类，部署该Bean时指定的id为："+beanName);  
    }  
}  
```
bean.xml 核心配置：
```
<bean id="chinese" class="com.bean.Chinese"/>  
```
Test.java :
```
public class Test {  
    public static void main(String[] args) {  
        ApplicationContext ctx=new ClassPathXmlApplicationContext("bean.xml");  
        Chinese c=(Chinese) ctx.getBean("chinese");  
        c.getBeanId();  
    }  
}  
///控制台输出：
Chinese实现类，部署该Bean时指定的id为:chinese
```

Spring容器何时回调Bean实例的setBeanName(String name)方法呢？Spring容器会在Bean初始化完成后回调该方法--这里的初始化指的是Bean的初始化行为：包括回调实现InitializingBean接口所实现的afterPropertiesSet方法，回调Bean配置中init-method属性指定的方法。当Spring容器完成了Bean的初始化动作之后，接下来将会回调实现BeanNameAware接口里的setBeanName(String name)方法。

### 强制初始化Bean

Spring默认有个规则：总是先初始化主调Bean，然后再初始化依赖Bean。

大多数情况下，Bean之间的依赖关系非常直接，Spring容器在返回Bean实例之前，完成Bean依赖关系的注入。假如Bean A依赖于Bean B，程序请求Bean A时，Spring容器会自动先初始化Bean B，再将Bean B注入Bean A，最后将具备完整依赖的Bean A返回给程序。

在极端的情况下，Bean之间的依赖不够直接。比如某个类的初始化块中使用其他Bean，Spring总是先初始化主调Bean，执行初始化块时还没有实例化主调Bean，被依赖的Bean还没实例化，此时将引发异常。

为了让指定Bean在目标Bean之前初始化，可以使用 depends-on 属性，该属性可以在初始化主调Bean之前，强制初始化一个或多个Bean。

```
<bean id="beanOne" class="ExampleBean" depends-on="manager">  
    <property name="manager" ref="manager"/>  
</bean>  
<bean id="manager" class="ManagerBean"/>  
```

## 容器中Bean的生命周期

对于singleton作用域的Bean，Spring容器知道Bean何时实例化结束、何时销毁，Spring可以管理实例化结束之后和销毁之前的行为。管理Bean的生命周期行为主要有如下两个时机：
1. 注入依赖关系之后。
2. 即将销毁Bean之前。

### 依赖关系注入之后的行为

依赖关系注入之后的行为：
Spring提供两种方式在Bean全部属性设置成功后执行特定行为：
1. 使用 init-method 属性
    使用init-method属性指定某个方法应在Bean全部依赖关系设置结束后自动执行，使用这种方法不需将代码与Spring的接口耦合在一起，代码污染小。
2. 实现 InitializingBean 接口
    该接口提供一个方法，void afterPropertiesSet( )throws Exception。Spring容器会在为该Bean注入依赖关系之后，接下来会调用该Bean所实现的afetrPropertiesSet( )方法。

Axe.java :
```
public interface Axe {  
    public String chop();  
}  
```
Person.java :
```
public interface Person {  
    public void useAxe();  
}  
```
SteelAxe.java :
```
public class SteelAxe implements Axe {  
    @Override  
    public String chop() {  
        return "钢斧砍柴真快";  
    }  
    public SteelAxe() {  
        System.out.println("Spring实例化依赖bean:SteelAxe实例...");  
    }  
}  
```
Chinese.java :
```
public class Chinese implements Person,InitializingBean {  
    private Axe axe;  
    public Chinese() {  
        System.out.println("Spring实例化主调Bean:Chinese实例...");  
    }  
    public void setAxe(Axe axe) {  
        System.out.println("Spring执行依赖关系注入...");  
        this.axe = axe;  
    }  
    @Override  
    public void useAxe() {  
        System.out.println(axe.chop());  
    }  
    public void init(){  
        System.out.println("正在执行初始化方法init...");  
    }  
    @Override  
    public void afterPropertiesSet() throws Exception {  
        System.out.println("正在执行初始化方法afterPropertiesSet...");  
    }  
}  
```
bean.xml 核心配置：
```
<bean id="chinese" class="com.bean.Chinese" init-method="init">  
    <property name="axe" ref="steelAxe"></property>  
</bean>  
    
<bean id="steelAxe" class="com.bean.SteelAxe"/>  
```
Test.java :
```
public class Test {  
    public static void main(String[] args) {  
        ApplicationContext ctx=new ClassPathXmlApplicationContext("bean.xml");  
        Person p=(Person) ctx.getBean("chinese");  
        p.useAxe();  
    }  
}  
```

从运行结果可以看出：依赖注入完成之后，程序先调用afterPropertiesSet方法，再调用init-method属性所指定的方法进行初始化。

### Bean 销毁之前的行为

与定制初始化行为相似，Spring也提供两种方法定制Bean实例销毁之前的行为：
1. 使用destroy-method属性：
    destroy-method属性指定某个方法在Bean销毁之前被自动执行。使用这种方式，不需要将代码与Spring的接口耦合，代码污染小。
2. 实现DisposableBean接口：
    该接口提供了一个方法，void destroy( ) throws Exception，该方法就是Bean实例被销毁之前应该执行的方法。

Axe.java :
```
public interface Axe {  
    public String chop();  
}  
```
Person.java :
```
public interface Person {  
    public void useAxe();  
}  
```
SteelAxe.java :
```
public class SteelAxe implements Axe {  
    @Override  
    public String chop() {  
        return "钢斧砍柴真快";  
    }  
    public SteelAxe() {  
        System.out.println("Spring实例化依赖Bean:SteelAxe实例...");  
    }  
}  
```
Chinese.java :
```
public class Chinese implements Person,DisposableBean {  
    private Axe axe;  
    public Chinese() {  
        System.out.println("Spring实例化主调Bean:Chinese实例...");  
    }  
    public void setAxe(Axe axe) {  
        System.out.println("Spring执行依赖关系注入...");  
        this.axe = axe;  
    }  
    @Override  
    public void useAxe() {  
        System.out.println(axe.chop());  
    }  
    public void close(){  
        System.out.println("正在执行销毁之前的方法close...");  
    }  
    @Override  
    public void destroy() throws Exception {  
        System.out.println("正在执行销毁之前的方法destroy...");  
    }  
}  
```
bean.xml核心配置：
```
<bean id="chinese" class="com.bean.Chinese" destroy-method="close">  
   <property name="axe" ref="steelAxe"></property>  
</bean>  
   
<bean id="steelAxe" class="com.bean.SteelAxe"/>  
```
Test.java :
```
public class Test {  
    public static void main(String[] args) {  
        AbstractApplicationContext ctx=new ClassPathXmlApplicationContext("bean.xml");  
        Person p=(Person) ctx.getBean("chinese");  
        p.useAxe();  
        ctx.registerShutdownHook();  
    }  
}  
```

singleton 作用域的Bean通常会随容器的关闭而销毁，但问题是：ApplicationContext容器在什么时候关闭呢？在基于web的ApplicationContext实现中，系统已经提供了相应的代码保证关闭web应用时恰当地关闭Spring容器。

如果处于一个非web应用的环境下，为了让Spring容器优雅地关闭，并调用singleton Bean上的相应析构回调方法，则需要在JVM虚拟机里注册一个关闭钩子，这样就可保证Spring容器被恰当关闭，且自动执行singleton Bean实例的析构回调方法。

为了注册关闭钩子，只需要调用在AbstractApplicationContext中提供的registerShutdownHook( )方法即可。

从程序的输出可以看出：Spring容器注入之后，关闭之前，程序先调用destroy方法进行回收资源，再调用close方法进行回收资源。

如果某个Bean类实现了DisposableBean接口，在Bean被销毁之前，Spring容器会自动调用该Bean实例的destroy方法，其结果与采用destroy-method属性指定生命周期方法几乎一样。但实现DisposableBean接口污染了代码，是侵入式设计，因此不推荐使用。

除此之外，如果容器中很多Bean都需要指定特定的生命周期行为，则可以利用 `<beans.../>` 元素的 default-init-method属性和 default-destroy-method 属性，这两个属性的作用类似于 `<bean.../>`元素的 init-method 属性和destroy-method 属性，区别是default-init-method和default-destroy-method是针对容器中所有Bean生效。

### 协调作用域不同步的Bean

当两个singleton作用域Bean存在依赖关系时，或prototype作用域Bean依赖singleton作用域Bean时，不会有任何问题。

但当singleton作用域Bean依赖prototype作用域Bean时，singleton作用域Bean只有一次初始化的机会，它的依赖关系也只在初始化阶段被设置，它所依赖的prototype作用域Bean则需要每次都得到一个全新的Bean实例，这将会导致singleton作用域的Bean的依赖得不到即时更新。

由于singleton Bean具有单例行为，当客户端多次请求singleton Bean时，Spring返回给客户端的将是同一个singleton Bean实例，这不存在任何问题。问题是：如果客户端多次请求singleton Bean、并调用singleton Bean去调用prototype Bean的方法时，始终都是调用同一个prototype Bean实例，这就违背了设置prototype Bean的初衷：本来希望它具有prototype行为，但实际上它却表现出singleton行为。

这就是问题的所在：当singleton作用域的Bean依赖于prototype作用域的Bean时，会产生不同步的现象。

解决该问题有如下两种思路：
1. 部分放弃依赖注入：singleton作用域Bean每次需要prototype作用域Bean时，主动向容器请求新的Bean实例，即可保证每次注入的prototype Bean实例都是最新的实例。
2. 利用方法注入。
第一种方式显然不是一个好的做法，代码主动请求新的Bean实例，必然导致代码与Spring API耦合，造成代码严重污染。
通常情况下，我们采用第二种做法，使用方法注入。方法注入通常使用lookup方法注入，利用lookup方法注入可以让Spring容器重写容器中Bean的抽象或具体方法，返回查找容器中其他Bean的结果，被查找的Bean通常是一个non-singleton Bean。Spring通过使用CGLIB库修改客户端的二进制码，从而实现上述的要求。

Axe.java :
```
public interface Axe {  
    public String chop();  
}  
```
SteelAxe.java :
```
public class SteelAxe implements Axe {  
    @Override  
    public String chop() {  
        return "钢斧砍柴真快";  
    }  
    public SteelAxe() {  
        System.out.println("Spring实例化依赖Bean:SteelAxe实例...");  
    }  
}  
```
Person.java :
```
public interface Person {  
    public void useAxe();  
}  
```
Chinese.java :
```
public abstract class Chinese implements Person{  
    public Chinese() {  
        System.out.println("Spring实例化主调Bean:Chinese实例...");  
    }  
    //singleton Bean里增加一个抽象方法  
    //方法的返回值类型是被依赖的Bean  
    public abstract Axe getAxe();  
    @Override  
    public void useAxe() {  
        System.out.println("正在使用"+getAxe()+"砍柴!");  
        System.out.println(getAxe().chop());  
    }  
}  
```
bean.xml核心配置：
```
<bean id="chinese" class="com.bean.Chinese">  
   <lookup-method name="getAxe" bean="steelAxe"/>  
</bean>  
<bean id="steelAxe" class="com.bean.SteelAxe" scope="prototype"/>  
```
Test.java :
```
public class Test {  
    public static void main(String[] args) {  
        ApplicationContext ctx=new ClassPathXmlApplicationContext("bean.xml");  
        Person p=(Person) ctx.getBean("chinese");  
        p.useAxe();  
        p.useAxe();  
    }  
}  
```

我们在singleton Bean里新增一个抽象方法，该方法的返回值类型是被依赖的Bean，该方法是一个抽象方法，其实现由Spring完成。问题是：Spring怎么知道如何实现该方法呢？为了让Spring知道如何实现该方法，我们需要在配置文件中使用`<lookup-method.../>`元素来配置这个方法。
使用`<lookup-method.../>`元素需要指定如下两个属性：
1. name：指定需要让Spring实现的方法。
2. bean：指定Spring实现该方法后的返回值。

程序的执行结果表明：使用lookup方法注入后，系统每次调用getAxe( )方法都将生成一个新的SteelAxe实例，这就可以保证当singleton作用域的Bean需要全新的Bean实例时，直接调用getAxe()方法即可，从而可以避免一直使用最早注入的Bean实例。

## 深入理解依赖关系配置

组件与组件之间的耦合，采用依赖注入管理，但是普通的javabean属性值，应直接在代码里设置。

在spring配置文件中使用xml元素进行配置,实际上是让spring执行相应的java代码  
例如:  

1. 使用<bean>元素,就是让spring执行无参数构造函数  
2. 使用<property> 就是让spring执行setter方法  

但是java程序还有可能还有其他语句,调用getting,调用普通方法,访问类或者对象的file,spring也为这种语句提供利配置的语法  
  
1. 调用getter方法:使用 PropertyPathFactoryBean  
2. 访问类或对象的Field值,使用FieldRetrievingFactoryBean  
3. 调用普通方法:使用MethodInvokingFactoryBean  
由此可见,spring可以然我们不写java代码就可以实现java编程,只要使用合适XML 语法进行配置,spring就可通过反射执行任意的底层java代码.  

### 注入其他Bean的属性值

属性值的注入，是通过PropertyPathFactoryBean完成的，PropertyPathFactoryBean用来获取目标bean的属性，获得的值可以注入到其他bean,也可以定义成新的bean

```
<bean id="person" class="com.bean.Person">
    <property name="age" value="30"/>
    <property name="son">
        <bean class="com.bean.Son">
            <property name="age" value="11"/>
        </bean>
    </property>
</bean>

<!--如下将会将person的属性son的属性age传入son1实例的age属性-->
<bean id="son1" class="com.bean.Son">
    <property name="age">
        <!--以下是访问bean属性的简单方式,这样可以将person这个bean的age属性赋值给son1这个bean的age属性-->           
        <bean id="person.son.age" class="org.springframework.beans.factory.config.PropertyPathFactoryBean"/>
    </property>
</bean>
    
<!-- 以下将会获得结果son,它将是person bean的son的数值-->
<bean id="son2" class="org.springframework.beans.factory.config.PropertyPathFactoryBean">
    <property name="targetBeanName" value="person"/>
    <property name="propertyPath" value="son"/>
</bean>
    
<!-- 以下将会获得结果16,它将是person bean的son的age属性-->
<bean id="theAge1" class="org.springframework.beans.factory.config.PropertyPathFactoryBean">
    <property name="targetBeanName" value="person"/>
    <property name="propertyPath" value="son.age"/>
</bean>

<!-- 以下会获得结果为30 ,它将是获得该bean的内部bean的age属性-->
<bean id="theAge2" class="org.springframework.beans.factory.config.PropertyPathFactoryBean">
    <property name="targetObject">
        <bean class="com.bean.Person">
            <property name="age" value="30"/>
        </bean>
    </property>
    <property name="propertyPath" value="age"/>
</bean>
```

测试代码：

```
public static void main(String[] args) throws Exception {
        String path=new Test().getClass().getResource("/").getPath();
        String realpath=path.substring(1, path.length());
        ApplicationContext context=new FileSystemXmlApplicationContext(realpath+"/superIOCparam.xml");
        Son son1=(Son)context.getBean("son1");
        Son son2=(Son)context.getBean("son2");

        System.out.println("person age is:"+son1.getAge());
        System.out.println("person age is:"+son2.getAge());
        System.out.println(context.getBean("theAge1"));
        System.out.println(context.getBean("theAge2"));
}
```
1. 可以将Bean实例的属性值注入另一个Bean，此时bean的id是指定属性表达式，不是唯一标识。
2. 可以将Bean实例的属性值直接定义成Bean实例，此时的id就是它的唯一标识。且必须指定两个属性：targetBeanName用于指定目标Bean，确定获取哪个Bean的属性值，或targetObject用于指定嵌套Bean实例；propertyPath，用于指定属性，确定获取目标Bean的哪个属性值，此处的属性可直接使用复合属性的形式。

### 注入其他Bean的Field值

FieldRetrievingFactoryBean获得目标Bean的Field值后，得到的值可注入给其他Bean，也可直接定义成新的Bean。

```
<!-- 将指定的类的静态Field设置成bean的属性值 -->  
<bean id="son" class="com.bean.Son">  
    <property name="age">  
    <!-- id指定了哪个Field的值 将会被设置给id="son"的bean -->  
    <bean id="java.sql.Connection.TRANSACTION_SERIALIZABLE"   
            class="org.springframework.beans.factory.config.FieldRetrievingFactoryBean">  
    </property>  
</bean>  
    
<!-- 将其他bean的Field定义成一个bean -->  
<bean id="theAge1" class="org.springframework.beans.factory.config.FieldRetrievingFactoryBean">    
    <!-- targetClass 设置Field所在的类,targetObject,当目标对象时使用(代替targetClass) -->  
    <property name="targetClass" value="java.sql.Connection" />  
    <!-- targetField指定目标类的目标Field -->  
    <property name="targetField" value="TRANSACTION_SERIALIZABLE" />  
</bean>  
    
<!-- 将静态Field定义成一个bean的简单写法 -->  
<bean id="theAge2" class="org.springframework.beans.factory.config.FieldRetrievingFactoryBean">    
    <property name="staticField" value="java.sql.Connection.TRANSACTION_SERIALIZABLE" />  
</bean>  
```

测试代码：

```
public static void main(String[] args) throws Exception {
        String path=new Test().getClass().getResource("/").getPath();
        String realpath=path.substring(1, path.length());
        ApplicationContext context=new FileSystemXmlApplicationContext(realpath+"/superIOCparam.xml");
        Son son=(Son)context.getBean("son",Son.class);

        System.out.println("son age is:"+son.getAge());
        System.out.println(context.getBean("theAge1"));
        System.out.println(context.getBean("theAge2"));
}
```
使用FieldRetrievingFactoryBean获取Field值时，必须指定两个属性值
* targetClass或targetObject：分别用于指定Field值所在的目标类或目标对象，如果需要获得Field是静态Field，则使用targetClass指定目标类，否则使用targetObject指定目标对象。
* targetField：用于指定目标Field的Field名。如果是静态Field可以通过staticField直接指定域。

### 注入其他Bean的方法返回值

通过MethodInvokingFactoryBean工厂Bean，可获得指定方法的返回值并将其注入到指定Bean实例的指定属性，也可以直接定义成Bean实例。

```
<!-- 提供方法的bean -->  
<bean id="valueGenerator" class="com.util.valueGenerator" />  
<!-- 将一个bean的方法 返回值 注入 新bean的 age属性 -->  
<bean id="son1" class="com.bean.Son">  
    <property name="age">  
    <bean class="org.springframework.beans.factory.config.MethodInvokingFactoryBean">  
        <property name="targetObject" ref="valueGenerator" />  
        <property name="targetMethod" value="getValue" />  
    </bean>  
    </property>    
</bean>  
<!-- 上面 是调用非静态类对象的getValue()这种无参方法 -->  
    
<!-- 调用静态类的静态方法,静态方法的返回值直接 定义成bean -->  
<bean id="sysProps" class="org.springframework.beans.factory.config.MethodInvokingFactoryBean">  
    <property name="targetClass" value="java.lang.System" />  
    <property name="targetMethod" value="getProperties" />  
</bean>  
<!-- 调用无参 静态类的静态方法 创建bean name="staticMethod",value=静态类.静态方法-->  
<bean id="myBean" class="org.springframework.beans.factory.config.MethodInvokingFactoryBean">  
    <property name="staticMethod" value="xxx.MyStaticClass.myStaticMethod" />
</bean>  
    
<!-- 有参数的方法调用,返回值 配置成一个bean -->  
<bean id="javaVersion" class="org.springframework.beans.factory.config.MethodInvokingFactoryBean">  
    <!-- 目标bean,确定调用哪个bean的方法 -->  
    <property name="targetObject" ref="sysProps" />  
    <!-- 确定目标方法,确定调用bean的哪个方法 -->  
    <property name="targetMethod" value="getProperty" />  
    <!-- 确定调用目标方法的参数 相当于调用getProperty方法,传递参数"java.version" -->  
    <property name="arguments">  
    <list>  
        <value>java.version</value>  
    </list>  
    </property>     
</bean> 
```
ValueGenrator类
```
public class ValueGenerator{
    public int getValue(){
        return 2;
    }
    public static int getStaticValue(){
        return 8;
    }
}
```
测试类
```
public static void main(String[] args) throws Exception {
        String path=new Test().getClass().getResource("/").getPath();
        String realpath=path.substring(1, path.length());
        ApplicationContext context=new FileSystemXmlApplicationContext(realpath+"/superIOCparam.xml");
        Son son1=(Son)context.getBean("son1",Son.class);
        Son son2=(Son)context.getBean("son2",Son.class);

        System.out.println("son age is:"+son1.getAge());
        System.out.println("son age is:"+son2.getAge());
}
```

* targetClass或targetObject：分别用于指定目标类或目标对象。
* targetMethod：用于指定目标方法的方法名。如果是静态方法可以通过staticMethod直接指定方法。

## 基于xml schema 的简化配置方式

### 使用p名称空间配置属性 

使用p命名空间可以简化原来property 的配置

```
<?xml version="1.0" encoding="UTF-8"?>  
<beans xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
xmlns="http://www.springframework.org/schema/beans"  
xmlns:p="http://www.springframework.org/schema/p"  
xsi:schemaLocation="http://www.springframework.org/schema/beans  
http://www.springframework.org/schema/beans/spring-beans-3.0.xsd">  
    <!-- 配置Chinese实例 -->  
    <bean id="chinese" class="com.spring.service.impl.Chinese" p:age="29" p:age-ref="stoneAxe"/>  
    <!-- 配置stoneAxe实例 -->  
    <bean id="stoneAxe" class="com.spring.service.impl.StoneAxe" />  
</beans>  
```
首先，需要导入p名字空间，通过在axe后添加"-ref"指定该值不是一个具体的值，而是对另外一个Bean的引用。

### 使用util Schema 

```
<?xml version="1.0" encoding="UTF-8"?>  
<beans xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
xmlns="http://www.springframework.org/schema/beans"  
xmlns:p="http://www.springframework.org/schema/p"  
xmlns:util="http://www.springframework.org/schema/util"  
xsi:schemaLocation="http://www.springframework.org/schema/beans  
http://www.springframework.org/schema/util
http://www.springframework.org/schema/util/spring-util-3.0.xsd
http://www.springframework.org/schema/beans/spring-beans-3.0.xsd">  
    <!-- 配置Chinese实例 -->  
    <bean id="chinese" class="com.spring.service.impl.Chinese"
    p:age-ref="chin.age"
    p:age-ref="stoneAxe"
    p:schools-ref="chin.schools"
    p:axes-ref="chin.axes"
    p:scores-ref="chin.scores" />  
    <!-- 配置stoneAxe实例 -->  
    <bean id="stoneAxe" class="com.spring.service.impl.StoneAxe" />  
    <bean id="steelAxe" class="com.spring.service.impl.SteelAxe" />  

    <!-- 将指定类的静态Field暴露出来 -->  
    <util:constant id="chin.age" static-field="java.sql.Connection.TRANSACTION_SERIALIZABLE"/>  
    
    <!-- 将指定bean的属性 暴露出来 -->  
    <util:property-path id="test" path="chinese.age"/>  
    
    <!-- 加载指定资源文件 -->  
    <util:properties id="confTest" location="classpath:message_zh_CN.properties"/>  
    
    <!-- 定义一个list -->  
    <util:list id="chin.schools" list-class="java.util.LinkedList">  
            <value>小学</value>  
            <value>中学</value>  
            <value>大学</value>  
    </util:list>  
    
    <!-- 定义一个set对象 -->  
    <util:set id="chin.axes" set-class="java.util.HashSet">  
            <value>字符串斧子</value>  
            <bean class="com.spring.service.impl.SteelAxe"/>  
            <ref local="stoneAxe"/>  
    </util:set>  
    
    <!-- 定一个 map对象 -->  
    <util:map id="chin.scores" map-class="java.util.TreeMap" key-type="java.lang.String" value-type="java.lang.Double">  
            <entry key="数学" value="89"/>  
            <entry key="英语" value="89"/>  
            <entry key="语文" value="89"/>  
    </util:map>  
</beans>
```

util Schema元素

* constant：该标签用于将指定类的静态Field暴露成一个Bean实例。使用该标签时可制定如下两个属性。
    * id：该属性指定将静态Field定义成名为id的Bean实例
    * static-field：该属性指定将哪个类、哪个静态Field暴露出来。
* property-path：该标签用于将指定Bean实例的指定属性暴露成一个Bean实例，使用该标签时可指定如下两个属性  
    * id：该属性指定将属性定义成名为id的Bean实例
    * path：该属性指定将哪个Bean实例、哪个属性（支持复合属性）暴露出来。
* list 该标签用于定义一个List Bean，支持使用value、ref、bean等标签来定义List集合元素，使用该标签支持如下三个属性，  
    * id：该属性指定定义一个名为id的List实例
    * list-class：该属性指定Spring使用哪个List实现类来创建Bean实例
    * scope：指定该List实例的作用域
* set：该标签用于定义一个Set Bean，支持使用value、ref、bean等标签来定义Set集合元素，使用该标签支持如下三个属性。
    * id：该属性指定定义一个名为id的Set Bean实例
    * set-class：该属性指定Set Bean使用哪个Set实现类来创建Bean实例
    * scope：指定该Set Bean实例的作用域
* map 该标签用于定义一个Map Bean，支持使用entry来定义Map的key-value对．使用该标签支持如下三个属性
    * id：该属性指定定义一个名为id的Map Bean实例
    * map-class：该属性指定Spring使用哪个Map实现类来创建Bean实例
    * scope：指定该Map Bean实例的作用域
* properties：该标签用于加载一份资源文件并根据加载的资源文件创建个Properties Bean实例，使用该标签可指定如下几个属性
    * id：该属性指定定义一个名为id的Properties Bean实例
    * location：指定资源文件的位置。
    * scope：指定该Properties Bean实例的作用域

## Spring3.0提供的表达式语言(SpEl)

Spring的表达式语言与Java注解结合，以便开发人员可以撰写和指向他们的配置，而不需要单独的XML文件写入，使得Spring开发者在不需要XML的情况下对应用进行配置。

### 使用Expression接口进行表达式求值
 

```
public class SpELTest {
    @Test
       @Test  
    public void test2() {  
        ExpressionParser parser=new SpelExpressionParser();  
        Expression exp=parser.parseExpression("'Hello World'");  
        System.out.println("Hello World的结果"+exp.getValue());  
          
        exp=parser.parseExpression("'Hello World'.concat('!')");  
        System.out.println("concat后的结果"+exp.getValue());  
          
        exp=parser.parseExpression("'Hello World'.bytes");  
        System.out.println("调用getBytes方法后的结果"+exp.getValue());  
          
        exp=parser.parseExpression("'Hello World'.bytes.length");  
        System.out.println("方法返回值后的属性的结果"+exp.getValue());  
          
        exp=parser.parseExpression("new String('Hello World').toUpperCase()");  
        exp=parser.parseExpression("age");  
        Chinese c=act.getBean("chinese",Chinese.class);  
        System.out.println("以Chinese为root,age的表达式的值是:"+exp.getValue(c, Integer.class));  
        exp=parser.parseExpression("age==15");  
        StandardEvaluationContext ctx=new StandardEvaluationContext();  
        ctx.setRootObject(c);  
        System.out.println(exp.getValue(ctx, Boolean.class));  
          
        List<Boolean> list=new ArrayList<Boolean>();  
        list.add(true);  
        EvaluationContext ctx2=new StandardEvaluationContext();  
        ctx2.setVariable("list",list);  
          
        parser.parseExpression("#list[0]").setValue(ctx2, "false");  
        System.out.println("List集合中的第一个元素:"+list.get(0)); 
    }
}
```

1. 创建解析器：SpEL使用ExpressionParser接口表示解析器，提供SpelExpressionParser默认实现；
2. 解析表达式：使用ExpressionParser的parseExpression来解析相应的表达式为Expression对象。
3. 构造上下文：准备比如变量定义等等表达式需要的上下文数据。
4. 求值：通过Expression接口的getValue方法根据上下文获得表达式值。


接下来让我们看下SpEL的主要接口吧：

1. ExpressionParser接口：表示解析器，默认实现是org.springframework.expression.spel.standard包中的SpelExpressionParser类，使用parseExpression方法将字符串表达式转换为Expression对象，对于ParserContext接口用于定义字符串表达式是不是模板，及模板开始与结束字符
2. EvaluationContext接口：表示上下文环境，默认实现是org.springframework.expression.spel.support包中的StandardEvaluationContext类，使用setRootObject方法来设置根对象，使用setVariable方法来注册自定义变量，使用registerFunction来注册自定义函数等等。
3. Expression接口：表示表达式对象，默认实现是org.springframework.expression.spel.standard包中的SpelExpression，提供getValue方法用于获取表达式值，提供setValue方法用于设置对象值。

### Bean定义中的表达式语言支持

xml配置文件和Annotation中使用SpEL时，都需要在表达式外面增加#{}包围。

### SpEL语法详述

#### 基本表达式

* 字面量表达式
* 算术运算表达式
* 比较运算表达式
* 逻辑运算表达式
* 字符串连接与截取表达式
* 三目运算及Elivis运算表达式
* 正则表达式

字面量表达式
字符串、数字类型（int、long、float、double）、布尔类型、null。
字符串 'Hello World!'、"Hello World!"
数值类型 1、-1L、1.1、1.1E+2、0xa、0xaL
布尔类型 true、false
null null

算术运算表达式
加(+)、减(-)、乘(`*`)、除(/或DIV)、求余（%或MOD）、幂（^）。
加减乘除 `1+2-3*4/2`、`1+2-3*4DIV2`
求余 `4%3`、`4MOD 3`
幂运算 `2^3`

比较运算表达式

不等于 !=或ne 1!= 1或 1ne 1
等于 ==或eq 1== 1或 1eq 1
大于等于 >=或ge 1>= 1或 1ge 1
小于等于 <=或le 1<= 1或 1le 1
大于 >或gt 1> 1或 1gt 1
小于 <或lt 1< 1或 1lt 1
区间 between 1 between {1, 2}

逻辑运算表达式
与 AND true AND true
或 OR true OR true
非 NOT NOT true

字符串连接及截取表达式
连接 + 'Hello' + 'World !'
截取一个字符 string[index] 'Hello World'[0]

三目运算及Elivis运算表达式
三目运算符 表达式1?表达式2:表达式3 2>1?true:false
Elivis运算 表达式1?:表达式2 null? :false或true?:false

正则表达式
正则表达式 matches '123' matches '\\d{3}'

#### 类相关表达式

* 类类型表达式
* 类实例化表达式
* instanceof表达式
* 变量定义及引用
* 自定义函数
* 赋值表达式
* 对象属性存取及安全导航表达式
    * 访问root对象属性
    * 安全访问
    * 给root对象属性赋值
对象方法调用
Bean引用

类类型表达式
使用"T(Type)"来表示java.lang.Class实例，"Type"必须是类全限定名（java.lang包除外）。使用类类型表达式还可以进行访问类静态方法及类静态字段。
实例 示例
java.lang包类访问 T(String)
其他包的类访问 T(foo.bar.spel.SpELTest)
类静态字段访问 T(Integer).MAX_VALUE
类静态方法调用 T(Integer).parseInt('1')

类实例化表达式
实例 示例
java.lang包类的实例化 new String('hello')
其他包的类实例化 new java.util.Date()

instanceof
实例 示例
Java内使用同义 'hello' instanceof T(String)

变量定义与引用
变量定义通过EvaluationContext接口的setVariable(variableName, value)方法定义；在表达式中使用“#variableName”引用；除了引用自定义变量，SpEL还允许引用根对象及当前上下文对象，使用 “#root”引用根对象，使用“#this”引用当前上下文对象。“#this”引用当前上下文对象，此处“#this”即根对象。
```
@Test
publicvoid testVariableExpression() { 
   ExpressionParser parser =new SpelExpressionParser(); 
   EvaluationContext context =new StandardEvaluationContext(); 
   context.setVariable("variable","hello"); 
   context.setVariable("variable","world");
   
   String result1 = parser.parseExpression("#variable").getValue(context, String.class); 
   Assert.assertEquals("world", result1); 
  
   context =new StandardEvaluationContext("hello"); 
   String result2 = parser.parseExpression("#root").getValue(context, String.class); 
   Assert.assertEquals("hello", result2);
   
   String result3 = parser.parseExpression("#this").getValue(context, String.class); 
   Assert.assertEquals("hello", result3); 
}
```

自定义函数
目前只支持类静态方法注册为自定义函数；SpEL使用StandardEvaluationContext的registerFunction方法进行注册自定义函数，其实完全可以使用setVariable代替，两者其实本质是一样的。
```
@Test
publicvoid testFunctionExpression()throws SecurityException, NoSuchMethodException {
    ExpressionParser parser = new SpelExpressionParser();
    StandardEvaluationContext context = new StandardEvaluationContext();
    Method parseInt = Integer.class.getDeclaredMethod("parseInt", String.class);
    context.registerFunction("parseInt", parseInt);
    context.setVariable("parseInt2", parseInt);
    String expression1 = "#parseInt('3') == #parseInt2('3')";
    boolean result1 = parser.parseExpression(expression1).getValue(context,boolean.class);
    Assert.assertEquals(true, result1);
}
```

赋值表达式
SpEL即允许给自定义变量赋值，也允许给跟对象赋值，直接使用“#variableName=value”即可赋值：
```
@Test
publicvoid testAssignExpression() {
    ExpressionParser parser = new SpelExpressionParser();
    // 1.给root对象赋值
    EvaluationContext context = new StandardEvaluationContext("aaaa");
    String result1 = parser.parseExpression("#root='aaaaa'").getValue(context, String.class);
    Assert.assertEquals("aaaaa", result1);
    String result2 = parser.parseExpression("#this='aaaa'").getValue(context, String.class);
    Assert.assertEquals("aaaa", result2);
    
    // 2.给自定义变量赋值
    context.setVariable("#variable","variable");
    String result3 = parser.parseExpression("#variable=#root").getValue(context, String.class);
    Assert.assertEquals("aaaa", result3);
}
```

对象属性存取及安全导航表达式
对象属性获取非常简单，即使用如“a.property.property”这种点缀式获取，SpEL对于属性名首字母是不区分大小写的。

给对象属性赋值可以采用赋值表达式或Expression接口的setValue方法赋值，而且也可以采用点缀方式赋值。

SpEL还引入了Groovy语言中的安全导航运算符“(对象|属性)?.属性”，用来避免当“?.”前边的表达式为null时抛出空指针异常，而是返回null。
```
ExpressionParser parser =new SpelExpressionParser();
// ===============访问root对象属性 ===============
Date date =new Date();
StandardEvaluationContext context =new StandardEvaluationContext(date);
int result1 = parser.parseExpression("Year").getValue(context,int.class);
Assert.assertEquals(date.getYear(), result1);
int result2 = parser.parseExpression("year").getValue(context,int.class);
Assert.assertEquals(date.getYear(), result2);
// ===============安全访问 ===============
context.setRootObject(null); 
Object result3 = parser.parseExpression("#root?.year").getValue(context, Object.class); 
Assert.assertEquals(null, result3);
// ===============给root对象属性赋值 ===============
context.setRootObject(date);
int result4 = parser.parseExpression("Year = 4").getValue(context,int.class);
Assert.assertEquals(4, result4);
parser.parseExpression("Year").setValue(context, 5);
int result5 = parser.parseExpression("Year").getValue(context,int.class);
Assert.assertEquals(5, result5);
```

对象方法调用
对象方法调用更简单，跟Java语法一样；如“'helo'.substring(2,4)”将返回“lo”。对于根对象可以直接调用方法。

```
ExpressionParser parser =new SpelExpressionParser();
// ===============直接调用对象方法 ===============
String result1 = parser.parseExpression("'hello'.substring(3)").getValue(String.class);
Assert.assertEquals("lo", result1);
// ===============调用上下文root对象方法 ===============
Date date =new Date();
StandardEvaluationContext context =new StandardEvaluationContext(date); 
int result2 = parser.parseExpression("getYear()").getValue(context,int.class); 
Assert.assertEquals(date.getYear(), result2);
```

Bean引用
SpEL支持使用“@”符号来引用Bean，在引用Bean时需要使用BeanResolver接口实现来查找Bean，Spring提供BeanFactoryResolver实现。

在示例中首先初始化了一个IoC容器，ClassPathXmlApplicationContext 实现默认会把“System.getProperties()”注册为“systemProperties”Bean，因此使用 “@systemProperties”来引用该Bean。

```
@Test 
publicvoid testBeanExpression() { 
   ClassPathXmlApplicationContext ctx =new ClassPathXmlApplicationContext(); 
    ctx.refresh(); 
   ExpressionParser parser =new SpelExpressionParser(); 
   StandardEvaluationContext context =new StandardEvaluationContext(); 
   context.setBeanResolver(new BeanFactoryResolver(ctx)); 
   Properties result1 = parser.parseExpression("@systemProperties").getValue(context, Properties.class); 
    Assert.assertEquals(System.getProperties(), result1); 
}
```
 
#### 集合相关表达式

* 内联List
* 内联Array
* Collection，Map元素访问
* Collection、Map、Array元素修改
* 集合投影
* 集合选择

内联List
从Spring3.0.4开始支持内联List，使用{表达式，……}定义内联List。如“{1,2,3}”将返回一个整型的ArrayList，而“{}”将返回空的List，对于字面量表达式列表，SpEL会使用java.util.Collections.unmodifiableList方法将列表设置为不可修改。

```
//将返回不可修改的空List 
List<Integer> result2 = parser.parseExpression("{}").getValue(List.class);
//对于列表中只要有一个不是字面量表达式，将只返回原始List，不会进行不可修改处理
String expression3 = "{ {1 + 2,2 + 4}, {3, 4 + 4} }";
List<List<Integer>> result3 = parser.parseExpression(expression3).getValue(List.class);
result3.get(0).set(0, 1);
Assert.assertEquals(2, result3.size());
```

内联Array

```
//声明一维数组并初始化值 
int[] result2 = parser.parseExpression("new int[]{1,2}").getValue(int[].class);
Assert.assertEquals(result2[0], 1);
//定义多维数组但不初始化（定义多维数组不能初始化）
int[][][] result3 = parser.parseExpression("new int[2][2][2]").getValue(int[][][].class);
```

集合，字典元素访问
SpEL目前支持所有集合类型和字典类型的元素访问，使用“集合[索引]”访问集合元素，使用“map[key]”访问字典元素。
集合元素访问是通过Iterator遍历来定位元素位置的。
```
// SpEL内联List访问
int result1 = parser.parseExpression("{1,2,3}[0]").getValue(int.class);
//即list.get(0)
Assert.assertEquals(1, result1);
// SpEL目前支持所有集合类型的访问
Collection<Integer> collection =new HashSet<Integer>();
collection.add(1);
collection.add(2);
EvaluationContext context2 =new StandardEvaluationContext();
context2.setVariable("collection", collection);
int result2 = parser.parseExpression("#collection[1]").getValue(context2,int.class);
//对于任何集合类型通过Iterator来定位元素
Assert.assertEquals(2, result2);
// SpEL对Map字典元素访问的支持
Map<String, Integer> map =new HashMap<String, Integer>();
map.put("a", 1);
EvaluationContext context3 =new StandardEvaluationContext();
context3.setVariable("map", map);
int result3 = parser.parseExpression("#map['a']").getValue(context3,int.class);
Assert.assertEquals(1, result3);
```

列表，字典，数组元素修改
可以使用赋值表达式或Expression接口的setValue方法修改。对数组修改直接对“#array[index]”赋值即可修改元素值，同理适用于集合和字典类型。
```
// ===============修改数组元素值 ===============
int[] array =newint[] { 1, 2 };
EvaluationContext context1 =new StandardEvaluationContext();
context1.setVariable("array", array);
int result1 = parser.parseExpression("#array[1] = 3").getValue(context1,int.class);
Assert.assertEquals(3, result1);
// ===============修改集合值 ===============
Collection<Integer> collection =new ArrayList<Integer>();
collection.add(1);
collection.add(2);
EvaluationContext context2 =new StandardEvaluationContext();
context2.setVariable("collection", collection);
int result2 = parser.parseExpression("#collection[1] = 3").getValue(context2,int.class);
Assert.assertEquals(3, result2);
parser.parseExpression("#collection[1]").setValue(context2, 4);
result2 = parser.parseExpression("#collection[1]").getValue(context2,int.class);
Assert.assertEquals(4, result2);
// ===============修改map元素值 ===============
Map<String, Integer> map =new HashMap<String, Integer>();
map.put("a", 1);
EvaluationContext context3 =new StandardEvaluationContext();
context3.setVariable("map", map);
int result3 = parser.parseExpression("#map['a'] = 2").getValue(context3,int.class);
Assert.assertEquals(2, result3);
```

集合投影
在SQL中投影指从表中选择出列，而在SpEL指根据集合中的元素中通过选择来构造另一个集合，该集合和原集合具有相同数量的元素；SpEL使用“（list|map）.![投影表达式]”来进行投影运算：
```
Collection<Integer> collection =new ArrayList<Integer>();
collection.add(4);
collection.add(5);
// =============== 测试集合或数组 ===============
EvaluationContext context1 =new StandardEvaluationContext();
context1.setVariable("collection", collection);
Collection<Integer> result1 = parser.parseExpression("#collection.![#this+1]").getValue(context1, Collection.class);
Assert.assertEquals(2, result1.size());
Assert.assertEquals(new Integer(5), result1.iterator().next());
对于集合或数组使用如上表达式进行投影运算，其中投影表达式中“#this”代表每个集合或数组元素，可以使用比如“#this.property”来获取集合元素的属性，其中“#this”可以省略。
Map<String, Integer> map =new HashMap<String, Integer>();
map.put("a", 1);
map.put("b", 2);
// ===============测试Map =============== 
EvaluationContext context2 =new StandardEvaluationContext(); 
context2.setVariable("map", map); 
List<Integer> result2 = 
parser.parseExpression("#map.![value+1]").getValue(context2, List.class); 
Assert.assertEquals(2, result2.size()); 
```
SpEL投影运算还支持Map投影，但Map投影最终只能得到List结果，如上所示，对于投影表达式中的“#this”将是Map.Entry，所以可以使用“value”来获取值，使用“key”来获取键。

集合选择
在SQL中指使用select进行选择行数据，而在SpEL指根据原集合通过条件表达式选择出满足条件的元素并构造为新的集合，SpEL使用“(list|map).?[选择表达式]”，其中选择表达式结果必须是boolean类型，如果true则选择的元素将添加到新集合中，false将不添加到新集合中。
```
Collection<Integer> collection =new ArrayList<Integer>();
collection.add(4);
collection.add(5);
// ===============集合或数组测试 ==============
EvaluationContext context1 =new StandardEvaluationContext();
context1.setVariable("collection", collection);
Collection<Integer> result1 = parser.parseExpression("#collection.?[#this>4]").getValue(context1, Collection.class);
Assert.assertEquals(1, result1.size());
Assert.assertEquals(new Integer(5), result1.iterator().next());
Map<String, Integer> map =new HashMap<String, Integer>();
map.put("a", 1);
map.put("b", 2);
// =============== Map测试 ==============
EvaluationContext context2 =new StandardEvaluationContext();
context2.setVariable("map", map);
Map<String, Integer> result2 = parser.parseExpression("#map.?[#this.key != 'a']").getValue(context2, Map.class);
Assert.assertEquals(1, result2.size());
 
List<Integer> result3 = parser.parseExpression("#map.?[key != 'a'].![value+1]").getValue(context2, List.class);
Assert.assertEquals(new Integer(3), result3.iterator().next());
```
对于Map选择，如“#map.?[#this.key != 'a']”将选择键值不等于”a”的，其中选择表达式中“#this”是Map.Entry类型，而最终结果还是Map，这点和投影不同；集合选择和投影可以一起使用，如“#map.?[key != 'a'].![value+1]”将首先选择键值不等于”a”的，然后在选出的Map中再进行“value+1”的投影。
 
#### 表达式模板

模板表达式就是由字面量与一个或多个表达式块组成。每个表达式块由“前缀+表达式+后缀”形式组成，如“${1+2}”即表达式块。在前边我们已经介绍了使用ParserContext接口实现来定义表达式是否是模板及前缀和后缀定义。在此就不多介绍了，如“Error ${#v0} ${#v1}”表达式表示由字面量“Error ”、模板表达式“#v0”、模板表达式“#v1”组成，其中v0和v1表示自定义变量，需要在上下文定义。
