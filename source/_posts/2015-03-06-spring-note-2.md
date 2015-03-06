title: Spring笔记二 
date: 2015-03-06 16:09:20
tags: Spring
categories: Spring
description: Spring
---

## 两种后处理器

Spring框架提供了很好的扩展性，除了可以与各种第三方框架良好整合外，其IoC容器也允许开发者进行扩展，这种扩展甚至无须实现BeanFactory或ApplicationContext接口，而是允许通过两个后处理器对IOC容器进行扩展。Spring提供了两种常用的后处理器：
1. Bean后处理器：这种后处理器会对容器中的Bean进行后处理，对Bean功能进行额外加强。
2. 容器后处理器：这种后处理器对IoC容器进行后处理，用于增强容器功能。

<!-- more -->

### Bean后处理器

Bean后处理器是一种特殊的Bean，这种特殊Bean并不对外提供服务，它甚至可以无须id属性，它主要负责对容器中的其他Bean执行后处理，例如为容器中的目标Bean生成代理等。

Bean后处理器会在Bean实例创建成功之后，对Bean实例进行进一步的增强处理。

Bean后处理器必须实现 BeanPostProcessor 接口，它包含两个方法：

1. Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException：第一个参数是系统即将进行后处理的Bean实例，第二个参数是该Bean实例的名字。
2. Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException：第一个参数是系统即将进行后处理的Bean实例，第二个参数是该Bean实例的名字。

实现该接口的Bean后处理器必须实现这两个方法，这两个方法会对容器中的Bean进行后处理，会在目标Bean初始化之前、初始化之后分别被回调，这两个方法用于对容器中的Bean实例进行增强处理。

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
public class Chinese implements Person,InitializingBean{  
    private Axe axe;  
    private String name;  
    public void setAxe(Axe axe) {  
        System.out.println("Spring执行依赖关系注入,setAxe...");  
        this.axe = axe;  
    }  
    public void setName(String name) {  
        System.out.println("Spring执行依赖关系注入,setName...");  
        this.name = name;  
    }  
    public Chinese() {  
        System.out.println("Spring实例化主调Bean:Chinese实例...");  
    }  
    @Override  
    public void useAxe() {  
        System.out.println(name+axe.chop());  
    }  
    @Override  
    public void afterPropertiesSet() throws Exception {  
        System.out.println("正在执行初始化方法afterPropertiesSet...");  
    }  
    public void init(){  
        System.out.println("正在执行初始化方法init...");  
    }  
}  
```
FirstBeanPostProcessor.java :
```
public class FirstBeanPostProcessor implements BeanPostProcessor {  
    @Override  
    public Object postProcessBeforeInitialization(Object bean, String beanName)  
            throws BeansException {  
        System.out.println("Bean后处理器在初始化之前对"+beanName+"进行增强处理...");  
        return bean;  
    }  
    @Override  
    public Object postProcessAfterInitialization(Object bean, String beanName)  
            throws BeansException {  
        System.out.println("Bean后处理器在初始化之后对"+beanName+"进行增强处理...");  
        if(bean instanceof Chinese){  
            Chinese c=(Chinese)bean;  
            c.setName("中国人");  
        }  
        return bean;  
    }  
}  
```
bean.xml核心配置：
```
<bean id="chinese" class="com.bean.Chinese" init-method="init">  
   <property name="axe" ref="steelAxe"/>  
   <property name="name" value="依赖注入的值"/>  
</bean>  
   
<bean id="steelAxe" class="com.bean.SteelAxe"/>  
<bean id="beanPostProcessor" class="com.bean.FirstBeanPostProcessor"/>  
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

容器中一旦注册了Bean后处理器，Bean后处理器就会自动启动，在容器中每个Bean创建时自动工作。从上面程序的运行结果可以看出，Bean后处理器两个方法的回调时机如下所示：

![Bean后处理器两个方法的毁掉时机](http://fh-1.qiniudn.com/Bean后处理器两个方法的毁掉时机.png)

采用ApplicationContext作为Spring容器时，无须手动注册BeanPostProcessor。但是如果采用BeanFactory作为Spring容器时，就必须手动注册BeanPostProcess，如下：
```
public class Test {  
    public static void main(String[] args) {  
        ClassPathResource resource=new ClassPathResource("bean.xml");  
        XmlBeanFactory factory=new XmlBeanFactory(resource);  
        BeanPostProcessor bpp=(FirstBeanPostProcessor) factory.getBean("beanPostProcessor");  
        factory.addBeanPostProcessor(bpp);  //注册BeanPostProcessor实例  
        System.out.println("程序已经实例化BeanFactory...");  
        Person p=(Person) factory.getBean("chinese");  
        System.out.println("程序中已经完成了chinese bean的实例化...");  
        p.useAxe();  
    }  
}  
```

下面是Spring提供的两个常用的后处理器：
1. BeanNameAutoProxyCreator：根据Bean实例的name属性，创建Bean实例的代理。
2. DefaultAdvisorAutoProxyCreator：根据提供的advisor，对容器中所有的Bean实例创建代理。
上面提供的两个Bean后处理器，都用于根据容器中配置的拦截器，创建代理Bean，代理Bean就是对目标Bean进行增强、在目标Bean的基础上进行修改得到新的Bean。

### 容器后处理器

Spring还提供了一种容器后处理器。Bean后处理器负责处理容器中的所有Bean实例，而容器后处理器则负责处理容器本身。

容器后处理器必须实现 BeanFactoryPostProcessor 接口，该接口中有一个方法：

void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException

实现该方法的方法体就是对Spring容器进行的处理，这种处理可以对Spring容器进行自定义扩展，当然也可以对Spring容器不进行任何处理。

FirstBeanFactoryPostProcessor.java :
```
public class FirstBeanFactoryPostProcessor implements BeanFactoryPostProcessor {  
    @Override  
    public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory)  
            throws BeansException {  
        System.out.println("程序对Spring所做的BeanFactory的初始化没有改变...");  
        System.out.println("Spring容器是:"+beanFactory);  
    }  
}  
```
bean.xml核心配置：
```
<bean id="chinese" class="com.bean.Chinese">  
   <property name="axe" ref="steelAxe"/>  
</bean>  
   
<bean id="steelAxe" class="com.bean.SteelAxe"/>  
<bean id="beanFactoryPostProcessor" class="com.bean.FirstBeanFactoryPostProcessor"/>  
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

程序会自动搜索容器中实现了BeanFactoryPostProcessor接口的类，并将它注册成容器后处理器。

Spring已经提供了如下几个常用的容器后处理器：
1. PropertyPlaceholderConfigurer：属性占位符配置器。
2. PropertyOverrideConfigurer：重写占位符配置器。
3. CustomAutowireConfigurer：自定义自动装配的配置器。
4. CustomScopeConfigurer：自定义作用域的配置器。

从上面的介绍可以看出，容器后处理器通常用于对Spring容器进行处理，并且总是在容器实例化任何其他的Bean之前，读取配置文件的元数据，并有可能修改这些元数据。

如果有需要，程序可以配置多个容器后处理器，多个容器后处理器可设置order属性来控制容器后处理器的执行次序。

### 属性占位符配置器

Spring提供了PropertyPlaceholderConfigurer，它是一个容器后处理器，负责读取Properties属性文件里的属性值，并将这些属性值设置成Spring配置文件的元数据。

```
<?xml version="1.0" encoding="UTF-8"?>  
<beans xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
xmlns="http://www.springframework.org/schema/beans"  
xsi:schemaLocation="http://www.springframework.org/schema/beans  
http://www.springframework.org/schema/beans/spring-beans-3.0.xsd">  
    <!--如果采用基于XML Schema的配置文件则可以简化下面配置-->
    <bean class="com.springframework.beans.factory.config.PropertyPlaceholderConfigurer">  
        <property name="locations">  
            <list>
                <value>dbconn.properties</value>
                <!-- 如果有多个属性文件，依次在下面列出来 -->
            </list>
        </property>
    </bean>  
    <bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource" destroy-method="close" >  
        <property name="driverClass" value="${jdbc.driverClassName}" />
        <property name="jdbcUrl" value="${jdbc.url}" />
        <property name="user" value="${jdbc.username}" />
        <property name="password" value="${jdbc.password}" />
    </bean>
</beans>  
```

dbconn.properties:
```
jdbc.driverClassName=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/javaee
jdbc.username=root
jdbc.password=123456
```

通过这种方法，可从主XML配置文件中分离出部分配置信息。如果仅需要修改数据库连接属性，则无须修改主XML配置文件。

简化的配置属性占位符
```
<context:property-placeholder location="classpath:dbconn.properties"/>
```

### 重写占位符配置器

Spring提供了PropertyOverrideConfigurer，负责读取Properties属性文件里的属性值，并将这些属性值直接覆盖Spring配置文件的元数据。即允许XML配置文件中有默认的配置信息。可以认为Spring配置文件是XML配置文件和属性文件的总和。

```
<?xml version="1.0" encoding="UTF-8"?>  
<beans xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
xmlns="http://www.springframework.org/schema/beans"  
xsi:schemaLocation="http://www.springframework.org/schema/beans  
http://www.springframework.org/schema/beans/spring-beans-3.0.xsd">  
    <!--如果采用基于XML Schema的配置文件则可以简化下面配置-->
    <bean class="com.springframework.beans.factory.config.PropertyOverrideConfigurer">  
        <property name="locations">  
            <list>
                <value>dbconn.properties</value>
                <!-- 如果有多个属性文件，依次在下面列出来 -->
            </list>
        </property>
    </bean>  
    <bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource" destroy-method="close" />  
</beans>  
```

dbconn.properties:
```
jdbc.driverClassName=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/javaee
jdbc.username=root
jdbc.password=123456
```

通过这种方法，可从主XML配置文件中分离出部分配置信息。如果仅需要修改数据库连接属性，则无须修改主XML配置文件。

简化的配置属性占位符
```
<context:property-override location="classpath:dbconn.properties"/>
```

## Spring的“零配置”支持

Spring提供了如下几个Annotation来标注Spring Bean。

Annotation名称 | 说明
---            | ---
@Component     | 标注一个普通的Spring Bean类。
@Controller    | 标注一个控制器组件类。
@Service       | 标注一个业务逻辑组件类。
@Repository    | 标注一个DAO组件类。

如果我们需要定义一个普通的Spring Bean，则直接使用@Component标注即可。但如果用@Repository、@Service或@Controller来标注这些Bean类，这些Bean类将被作为特殊的JavaEE组件对待，也许能更好地被工具处理，或与切面进行关联。

在Spring的未来版本中，@Controller、@Service和@Repository也许还能携带更多语义，因此如果需要在JavaEE应用中使用这些标注时，尽量考虑使用@Controller、@Service和@Repository来代替通用的@Component标注。

指定了某些类可作为Spring Bean类使用后，最后还需要让Spring搜索指定路径，此时需要在Spring配置文件中导入context Scheme，并指定一个简单的搜索路径。

SteelAxe.java :
```
@Component  
public class SteelAxe implements Axe {  
    @Override  
    public String chop() {  
        return "钢斧砍柴真快";  
    }  
}  
```
StoneAxe.java :
```
@Component  
public class StoneAxe implements Axe {  
    @Override  
    public String chop() {  
        return "石斧砍柴真慢";  
    }  
}  
```
Chinese.java :
```
@Component  
public class Chinese implements Person {  
    private Axe axe;  
    public void setAxe(Axe axe) {  
        this.axe = axe;  
    }  
    @Override  
    public void useAxe() {  
        System.out.println(axe.chop());  
    }  
}  
```
bean.xml :
```
<?xml version="1.0" encoding="UTF-8"?>  
<beans xmlns="http://www.springframework.org/schema/beans"  
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
        xmlns:context="http://www.springframework.org/schema/context"  
        xmlns:tx="http://www.springframework.org/schema/tx"  
        xsi:schemaLocation="http://www.springframework.org/schema/beans   
        http://www.springframework.org/schema/beans/spring-beans-2.5.xsd  
                http://www.springframework.org/schema/context   
                http://www.springframework.org/schema/context/spring-context-2.5.xsd  
                http://www.springframework.org/schema/tx   
                http://www.springframework.org/schema/tx/spring-tx-2.5.xsd">  
  <context:component-scan base-package="com.bean"/>  
</beans>  
```
Test.java :
```
public class Test {  
    public static void main(String[] args) {  
        ApplicationContext ctx=new ClassPathXmlApplicationContext("bean.xml");  
        System.out.println(Arrays.toString(ctx.getBeanDefinitionNames()));  
    }  
}  
```
运行Test.java，控制台输出：
```
[ steelAxe, stoneAxe, chinese, 
org.springframework.context.annotation.internalCommonAnnotationProcessor, 
org.springframework.context.annotation.internalAutowiredAnnotationProcessor,
org.springframework.context.annotation.internalRequiredAnnotationProcessor ]
```
从上面程序的运行结果来看，Spring容器中三个Bean实例的名称分别为chinese、steelAxe和stoneAxe，之所以叫这些名称，是因为在这种基于Annotation的方式下，Spring采用约定的方式来为这些Bean实例指定名称，这些Bean实例的名称默认是Bean类的首字母小写，其他部分不变。

当然，Spring也允许在使用@Component标注时指定Bean实例的名称：
```
@Component("axe")  
public class SteelAxe implements Axe{  
   //codes here  
}  
```
在默认情况下，Spring会自动搜索所有以@Component、@Controller、@Service和@Repository标注的Java类，并将它们当成Spring Bean来处理。

除此之外，我们还可通过为`<component-scan.../>`元素添加`<include-filter.../>`或`<exclude-filter.../>`子元素来指定Spring Bean类，只要位于指定路径下的Java类满足这种规则，即使这些java类没有使用任何Annotation标注，Spring一样会将它们当成Bean类来处理。

`<include-filter.../>`元素用于指定满足该规则的Java类会被当成Bean类处理。`<exclude-filter.../>`元素用于指定满足该规则的Java类不会被当成Bean类处理。使用这两个元素时都要求指定如下两个属性：
1. type：指定过滤器类型。
2. expression：指定过滤器所需要的表达式。
Spring内建支持如下4种过滤器：
1. annotation：Annotation过滤器，该过滤器需要指定一个Annotation名，如lee.AnnotationTest
2. assignable：类名过滤器，该过滤器直接指定一个Java类。
3. regex：正则表达式过滤器，该过滤器指定一个正则表达式，匹配该正则表达式的Java类将满足该过滤规则，如`org\.example\.Default.*`。
4. aspectj：AspectJ过滤器，如`org.example..*Service+`。

例如下面的配置文件指定所有以Chinese结尾的类，以Axe结尾的类都将被当成Spring Bean处理。
```
<context:component-scan base-package="org.crazyit.app.service">  
  <context:include-filter type="regex" expression=".*Chinese"/>  
  <context:include-filter type="regex" expression=".*Axe"/>  
</context:component-scan>  
```
### 指定Bean的作用域

当使用XML配置方式来配置Bean实例时，可以通过scope来指定Bean实例的作用域，没有指定scope属性的Bean实例的作用域默认是singleton。

当我们采用零配置方式来管理Bean实例时，可以使用@Scope Annotation，只要在该Annotation中提供作用域的名称即可。例如：

```
@Scope("prototype")  
@Component("axe")  
public class SteelAxe implements Axe{  
   //codes here  
}  
```

### 使用@Resource配置依赖

@Resource位于java.annotation包下，是来自JavaEE规范的一个Annotation，Spring直接借鉴了该Annotation，通过使用该Annotation为目标Bean指定协作者Bean。

@Resource有一个name属性，默认情况下，Spring将这个值解释为需要被注入的Bean实例的名字。换句话说，使用@Resource与`<property.../>`元素的ref属性有相同的效果。
```
@Component  
public class Chinese implements Person {  
    private Axe axe;  
    @Resource(name="stoneAxe")  
    public void setAxe(Axe axe) {  
        this.axe = axe;  
    }  
    @Override  
    public void useAxe() {  
        System.out.println(axe.chop());  
    }  
}  
```
上面的@Resource Annotation指定将stoneAxe注入该setAxe( )方法，也就是将容器中的stoneAxe Bean作为setAxe方法的参数传入。

@Resource不仅可以修饰setter方法，也可以直接修饰Field，使用@Resource时还可以省略name属性。使用@Resource修饰Field时连setter方法都可以不要：

```
@Component  
public class Chinese implements Person {  
    @Resource(name="stoneAxe")  
    private Axe axe;  
    @Override  
    public void useAxe() {  
        System.out.println(axe.chop());  
    }  
}  
```

1. 当使用@Resource修饰setter方法时，如果省略name属性，例如@Resource标注setName( )方法，则Spring默认注入容器中名为name的组件。
2. 当使用@Resource修饰Field时，如果省略name属性，例如@Resource标注name Field，则Spring默认会注入容器中名为name的组件。

### 使用@PostConstruct和@PreDestroy定制生命周期行为

@PostConstruct和@PreDestroy同样位于java.annotation包下，也是来自JavaEE规范的两个Annotation，Spring直接借鉴了它们，用于定制Spring容器中Bean的生命周期行为。

@PostConstruct和@PreDestroy大致相当于`<bean.../>`元素的 init-method 属性和 destroy-method 属性指定的方法：
```
@Component  
public class Chinese implements Person {  
    @Resource(name="steelAxe")  
    private Axe axe;  
    @Override  
    public void useAxe() {  
        System.out.println(axe.chop());  
    }  
    @PostConstruct  
    public void init(){  
        System.out.println("正在执行初始化的init方法...");  
    }  
    @PreDestroy  
    public void close(){  
        System.out.println("正在执行销毁之前的close方法...");  
    }  
}
```

### Spring3.0新增的@DependsOn和@Lazy

@DependsOn用于强制初始化其他Bean。可以修饰Bean类或方法，使用该Annotation时可以指定一个字符串数组作为参数，每个数组元素对应于一个强制初始化的Bean。

```
@DependsOn({"steelAxe","abc"})  
@Component  
public class Chinese implements Person{  
   //codes here  
}  
```
@Lazy用于指定该Bean是否取消预初始化。主要用于修饰Spring Bean类，用于指定该Bean的预初始化行为，使用该Annotation时可以指定一个boolean型的value属性，该属性决定是否要预初始化该Bean。
```
@Lazy(true)  
@Component  
public class Chinese implements Person{  
   //codes here  
}  
```

### 自动装配和精确装配

spring提供了@Autowired Annotation来指定自动装配，使用@Autowired可以标注setter方法、普通方法、Field、函数形参和构造器等。

例如下代码：

```
@Component
public class Chinese implements Person {
    private Axe axe;
    @Autowired
    public void setAxe(Axe axe){
        this.axe = axe;
    }
    public Axe getAxe(){
        return axe;
    }
    @Override
    public void useAxe() {
        System.out.println(axe.chop());
    }
}
```

上面的代码使用@Autowired 指定setAxe()方法进行自动装配，spring将会自动搜索容器中类型为Axe的Bean实例，并将该Bean实例作为setAxe()方法的参数传入，此时spring默认的装配策略为byType。同样的@Autowired可以修饰普通的方法，Field和构造器等，且其默认的装配策略均为byType类型的装配。

为了实现精确的自动装配，spring提供了@Qualifier Annotation，通过使用@Qualifier，允许根据Bean的标识来指定自动装配，如下代码所示：

```
@Component
public class Chinese implements Person {
    @Autowired
    @Qualifier("steelAxe")
    private Axe axe;
    public void setAxe(Axe axe){
        this.axe = axe;
    }
    public Axe getAxe(){
        return axe;
    }
    @Override
    public void useAxe() {
        System.out.println(axe.chop());
    }
}
```

## 资源访问

Resource接口的主要方法有:

* InputStream getInputStream() throws IOException:返回资源对应的输入流.
* boolean exists():资源是否存在.
* boolean isOpen():资源是否打开.
* URL getURL() throws IOException:如果底层资源可以表示成URL,该方法返回对应的URL对象.
* File getFile() throws IOException:如果底层资源对应一个文件,该方法返回对应的File对象.
* String getDescription():返回资源的描述信息，用于资源处理出错时输出该信息，通常是全限定文件名或实际URL.
* String getFilename():返回资源文件名，通常是路径中的最后一部分，比如"file.txt".

### Resource实现类

Spring在设计上使用了策略模式，针对不同的资源访问，提供了不同的实现类，常用的实现类有：

* UrlResource：封装了java.net.URL,用户能够访问任何可以通过URL表示的资源,如文件的系统资源,HTTP资源和FTP资源等.
* ClassPathResource：访问类加载路径里的资源的实现类.
* FileSystemResource：访问文件系统资源的实现类
* ServletContextResource：访问相对于ServletContext路径里的资源的实现类
* InputStreamResource：访问输入流资源的实现类
* ByteArrayResource：访问字节数组资源的实现类

* 访问网络资源

URL资源通常应该提供标准的协议前缀。file:用于访问文件系统；http:用于通过HTTP协议访问资源；ftp:用于通过FTP协议访问资源等。

```
public class UrlResourceTest {
    public static void main(String[] args) {
        //创建一个Resource对象，指定从文件系统里读取资源
        //1.只需要将此出替换即可使用其他策略
        Resource res = new UrlResource("file:book.xml");
        //获取该资源的简单信息
        System.out.println(res.getFilename());
        System.out.println(res.getDescription());
        //创建Dom4j的解析器
        SAXReader reader = new SAXReader();
        Document doc = reader.read(res.getFile());
        //获取根元素
        Element el = doc.getRootElement();
        List list = el.elements();
        //遍历根元素的全部子元素
        for (Iterator it = list.iterator();it.hasNext();) {
            Element book = (Element)it.next();
            List ll = book.elements();
            for(Iterator it2 = ll.iterator();it2.hasNext();) {
                Element eee = (Element)it2.next();
                System.out.println(eee.getText());
            }
        }
    }
}
```

* 加载类加载路径下的资源

```
Resource res = new ClassPathResource("book.xml");
```

* 访问文件系统资源

```
Resource res = new FileSystemResource("book.xml");
```

* 访问应用相关资源

```
Resource res = new ServletContextResource("book.xml");
```

用于访问Web Context下相对路径下的资源。默认情况下，JSP不能直接访问WEB-INF路径下的任何资源，所以应用中的JSP页面需要使用ServletContextResource来访问资源。

* 访问字节数组资源

Spring 提供了InputStreamResource来访问二进制输入流资源，InputStreamResource是针对输入流的Resource实现，只有当没有合适的Resource实现时，才考虑使用该InputStreamResource。通常情况下，优先考虑使用ByteArrayResource或者基于文件的Resource实现。

InputStreamResource是一个总是被打开的Resource，所以isOpen方法总是返回true。因此需要多次读取某个流，就不要使用InputStreamResource，创建InputStreamResource实例时应提供一个InputStreamResource参数。

在某些情况下，如读取数据库得到的Blob对象，可以通过Blob的getBinaryStream方法获取二进制输入流。

ByteArrayResource在Socket，线程之间的信息交换方面是很有用的。

```
String file = "<?xml version='1.0' encoding='UTF-8'"
            + "<计算机书籍列表><书><书名>疯狂JAVA讲义"
            + "</书名><作者>李刚</作者></书><书><书名>"
            + "轻量级java ee企业应用实战</书名><作者>李刚"
            + "</作者></书></计算机书籍列表>"
byte[] fileBytes = file.getBytes();
Resource res = new ByteArrayResource(fileBytes);
```

### ResourceLoader接口和ResourceLoaderAware接口

ResourceLoader 接口由能返回(或者载入)Resource 实例的对象来实现。

所有的ApplicationContext都实现了 ResourceLoader 接口， 因此它们可以用来获取Resource 实例。

当你调用特定ApplicationContext的 getResource() 方法， 而且资源路径并没有特定的前缀时，你将获得与该ApplicationContext相应的 Resource 类型。例如：假定下面的代码片断是基于ClassPathXmlApplicationContext 实例上执行的：

```
Resource template = ctx.getResource("some/resource/path/myTemplate.txt");
```

这将返回ClassPathResource；如果是基于FileSystemXmlApplicationContext 实例上执行的，那你将获得FileSystemResource。而对于 WebApplicationContext 你将获得ServletContextResource，依此类推。

另一方面，无论什么类型的ApplicationContext，你可以通过使用特定的前缀 classpath: 强制使用ClassPathResource。

```
Resource template = ctx.getResource("classpath:some/resource/path/myTemplate.txt");
```
同样的，你可以用任何标准的 java.net.URL 前缀，强制使用 UrlResource ：
```
Resource template = ctx.getResource("file:/some/resource/path/myTemplate.txt");
Resource template = ctx.getResource("http://myhost.com/resource/path/myTemplate.txt");
```
下面的表格概述了 String 到 Resource 的转换规则：

前缀       | 例子                           | 说明
---        | ---                            | ---
classpath: | classpath:com/myapp/config.xml | 从classpath中加载。
file:      | file:/data/config.xml          | 作为 URL 从文件系统中加载。
http:      | http://myserver/logo.png       | 作为 URL 加载。
(none)     | /data/config.xml               | 根据 ApplicationContext 进行判断。

ResourceLoaderAware是特殊的标记接口，它希望拥有一个ResourceLoader 引用的对象。
当实现了 ResourceLoaderAware接口的类部署到ApplicationContext(比如受Spring管理的bean)中时，它会被ApplicationContext识别为 ResourceLoaderAware。 接着ApplicationContext会调用setResourceLoader(ResourceLoader)方法，并把自身作为参数传入该方法(记住，所有Spring里的ApplicationContext都实现了ResourceLoader接口)。

既然 ApplicationContext 就是ResourceLoader，那么该bean就可以实现 ApplicationContextAware接口并直接使用所提供的ApplicationContext来载入资源，但是通常更适合使用特定的满足所有需要的 ResourceLoader实现。 这样一来，代码只需要依赖于可以看作辅助接口的资源载入接口，而不用依赖于整个Spring ApplicationContext 接口。

TestBean.java:
```
public class TestBean implements ResourceLoaderAware {
    ResourceLoader rd;
    public void setResourceLoader(ResourceLoader resourceloader){
        this.rd = resourceloader;
    }
    public ResourceLoader getResourceLoader() {
        return rd;
    }
}
```
SpringTest.java:
```
public class SpringTest{
    public static void main(String[] args){
        ApplicationContext ctx = new ClassPathXmlApplicationContext("bean.xml");
        TestBean tb = (TestBean)ctx.getBean("test");
        ResourceLoader rl = tb.getResourceLoader();
        System.out.println(rl == ctx);
    }
}
```

### 使用Resource作为属性

前面都是通过编码的方式获取资源的，资源所在的物理位置就耦合到代码中了，如果资源位置变化，则必须改写程序。因此，可以通过依赖注入资源

```
public class TestBean{
    private Resource res;

    public void setResource(Resource res) {
        this.res = res;
    }
}
```
bean.xml:
```
<bean id="testBean" class="com.bean.TestBean">
  <property name="res" value="classpath:book.xml"/>
</bean>
```
如果不采用任何前缀，则Spring将采用与该ApplicationContext相同的资源访问策略来访问资源。

### 在ApplicationContext中使用资源

ApplicationContext确定资源访问策略通常有两个方法：

* ApplicationContext实现类指定访问策略
* 前缀指定访问策略

#### ApplicationContext实现类指定访问策略

ClassPathXmlApplicationContext：返回ClassPathResource
FileSystemXmlApplicationContext： 获得FileSystemResource
XmlWebApplicationContext： 获得ServletContextResource

#### 前缀指定访问策略

```
ApplicationContext ctx = new FileSystemXmlApplicationContext("classpath:bean.xml");
Resource r = ctx.getResource("book.xml");
System.out.println(r.getDescription());
```
通过classpath:前缀指定资源访问策略仅仅对当次访问有效，程序后面进行资源访问时，还是会根据ApplicationContext的实现类来选择对应的资源访问策略。建议尽量显示指定资源，而不是通过前缀。

#### classpath*:前缀的用法

classpath*:前缀提供了装载多个XML配置文件的能力，当使用classpath*:前缀来指定XML配置文件时，系统搜索类加载路径，找出所有与文件名匹配的文件，分辨装载文件中的配置定义，最后合并成一个ApplicationContext。classpath*:前缀仅对ApplicationContext有效，用于加载配置文件。其他情况，使用classpath*:前缀加载多个资源是不行的。

还有一种可以一次加载多个配置文件的方式：指定配置文件时使用通配符。

这两种方式也可以混合使用

```
ApplicationContext ctx = new FileSystemXmlApplicationContext("classpath*:bean*.xml");
```

这将会加载类加载路径下所有以bean开头的配置文件。

#### file:前缀的用法

FileSystemApplicationContext 会简单地让所有绑定的 FileSystemResource 实例把绝对路径都当成相对路径，而不管它们是否以反斜杠开头。也就是说，下面的含义是相同的：

```
ApplicationContext ctx = new FileSystemXmlApplicationContext("conf/context.xml");
ApplicationContext ctx = new FileSystemXmlApplicationContext("/conf/context.xml");
```
上面的两行代码是没有区别的。

实际上如果的确需要使用绝对路径，那你最好就不要使用 FileSystemResource 或 FileSystemXmlApplicationContext来确定绝对路径。我们可以通过使用 file: URL前缀来强制使用UrlResource。

```
ApplicationContext ctx = new FileSystemXmlApplicationContext("file:/conf/context.xml");
```

## Spring的AOP

### 使用AspectJ实现AOP

AOP 专门用于处理系统中分布于各个模块（不同方法）中的交叉关注点问题，在JavaEE应用中，常常通过AOP来处理一些具有横切性质的系统级服务，如事务管理、安全检查、缓存、对象池管理等，AOP已经成为一种非常常用的解决方案。

AspectJ是一个基于Java语言的AOP框架，提供了强大的AOP功能，其他很多AOP框架都借鉴或采纳了它的一些思想。由于Spring3.0的AOP与AspectJ进行了很好的集成，因此掌握AspectJ是学习Spring AOP的基础。

AspectJ是Java语言的一个AOP实现，其主要包括两个部分：第一个部分定义了如何表达、定义AOP编程中的语法规范，通过这套语法规范，我们可以方便地用AOP来解决Java语言中存在的交叉关注点问题；第二个部分是工具部分，包括编译器、调试工具等。

AspectJ是最早、功能比较强大的AOP实现之一，对整套AOP机制都有较好的实现，很多其他语言的AOP实现，也借鉴或采纳了AspectJ中的很多设计。而在Java领域，AspectJ中的很多语法结构基本上已经成为AOP领域的标准。

从Spring2.0开始，Spring AOP已经引入了对AspectJ的支持，并且允许直接使用AspectJ进行AOP编程，而Spring自身的AOP API也努力与AspectJ保持一致。因此学习Spring AOP就必然需要从AspectJ开始，因为它是Java领域最流行的AOP解决方案。即使不用Spring框架，我们甚至也可以直接使用AspectJ进行AOP编程。

下载、安装AspectJ和配置环境变量：
登陆点击打开链接站点[AspectJ](http://www.eclipse.org/aspectj/downloads.php#stable_release)，下载AspectJ的一个稳定版本。下载完成后得到一个aspectj-[version].jar文件。我这里将它放在D盘的lib文件夹下的aspectj文件夹下。启动命令行窗口：

```
java -jar aspectj-[version].jar
```

安装好了以后记得配置环境变量：将 E:\Java\AOP\aspectj\bin添加到path环境变量中，将 E:\Java\AOP\aspectj\lib\aspectjrt.jar添加到CLASSPATH，注意这还不够，前面得有点号和分号。

#### AspectJ使用入门

我们在D盘下写一个Hello.java :
```
public class Hello{  
    public static void main(String[] args){  
        Hello h=new Hello();  
        h.sayHello();  
    }  
  
    public void sayHello(){  
        System.out.println("Hello AspectJ !");  
    }  
}  
```
编译运行：
```
javac -d . Hello.java
java Hello
```

假设现在客户需要在执行sayHello()方法之前启动事务，方法结束之后关闭事务，在传统的编程模式下，我们必须手动修改sayHello()方法。但是如果采用面向切面编程的思想，则可以无须修改sayHello( )方法，也可以达到同样的效果。这里我们使用AspectJ框架帮我们做到这一点。我们在D盘下写一个TransactionAspect.java：
  
```
public aspect TransactionAspect{  
    //指定执行Hello.sayHello()方法时执行下面的代码块  
    void around():call(void Hello.sayHello()){  
        System.out.println("开启事务");  
        proceed();//回调原来的sayHello()方法  
        System.out.println("结束事务");  
    }  
}  
```

上面的java文件不是使用class、interface或enum，而是使用 aspect，aspect是AspectJ才能识别的关键字。
```
ajc -d . Hello.java TransactionAspect.java
java Hello
```

我们可以把 ajc 命令理解成javac命令，它们都用于编译Java程序，区别是ajc命令可以识别AspectJ的语法，从这个意义上看，我们可以将ajc当成一个增强版的javac命令。

运行Hello类没有任何改变，但是程序的输出已经让我们足够惊喜了，对，就是我们想要的结果！

有了AOP，我们完全可以不对Hello.java类进行任何修改，同时又可以满足客户的需求。上面的程序只是在控制台打印输出语句模拟事务的开启和关闭，在实际工作中可以用实际的操作代码来代替打印语句，这就可以满足客户的要求了。
如果客户再次提出新需求，需要在sayHello( )方法后增加记录日志的功能，那也很简单，我们再写一个 LogAspect.java :
  
```
public aspect LogAspect{  
    pointcut logPointcut()  
        :execution(void Hello.sayHello());  
    after():logPointcut(){  
        System.out.println("记录日志功能...");  
    }  
}  
```

```
ajc -d . *.java
java Hello
```

实际上，AspectJ允许同时为多个方法添加新功能，只要我们定义Pointcut时指定匹配更多的方法即可。如如下片段：

```
pointcut xxxPointcut()  
   :execution(void H*.say*());  
```
上面程序中的xxxPointcut将可以匹配所有以H开头的类中、所有以say开头的方法，但该方法返回的必须是void。如果想匹配任意的返回值类型：

```
pointcut xxxPointcut  
   :execution(* H*.say*());  
```

修改：

Hello.java :
  
```
public class Hello{  
    public static void main(String[] args){  
        Hello h=new Hello();  
        h.sayHello();  
        h.sayGoodbye();  
    }  
    public void sayHello(){  
        System.out.println("Hello AspectJ !");  
    }  
    public void sayGoodbye(){  
        System.out.println("Goodbye Java !");  
    }  
}  
```
LogAspect.java :
  
```
public aspect LogAspect{  
    pointcut logPointcut()  
        :execution(void Hello.say*());  
    after():logPointcut(){  
        System.out.println("记录日志功能...");  
    }  
}  
```
TransactionAspect.java :
  
```
public aspect TransactionAspect{  
    //指定执行Hello.sayHello()方法时执行下面的代码块  
    void around():call(void Hello.say*()){  
        System.out.println("开启事务");  
        proceed();//回调原来的sayHello()方法  
        System.out.println("结束事务");  
    }  
}  
```

### AOP 的基本概念

如果安装了Java的反编译工具，可以反编译上篇文章中的Hello.class文件，我们将会发现该Hello.class文件不是由Hello.java文件编译得到的，该Hello.class里新增了很多内容。这表明AspectJ在编译时已增强了Hello.class类的功能，因此 AspectJ 通常被称为编译时增强的AOP框架。

与AspectJ相对的还有另外一种AOP框架，它们不需要在编译时对目标类进行增强，而是运行时生成目标类的代理类，该代理类要么与目标类实现相同的接口，要么是目标类的子类。总之，代理类都对目标类进行了增强处理，前者是JDK动态代理的处理策略，后者是CGLIB代理的处理策略。

Spring AOP以创建动态代理的方式来生成代理类，底层既可使用JDK动态代理，也可采用CGLIB代理。

一般来说，编译时增强的AOP框架在性能上更有优势--因为运行时动态增强的AOP框架需要每次运行时都进行动态增强。

AOP从程序运行角度考虑程序的流程，提取业务处理过程的切面。AOP面向的是程序运行中各个步骤，希望以更好的方式来组合业务处理的各个步骤。

AOP框架并不与特定的代码耦合，AOP框架能处理程序执行中特定切入点（Pointcut），而不与某个具体类耦合。AOP框架具有如下两个特征：

1. 各步骤之间的良好隔离性。
2. 源代码无关性。

下面是关于面向切面编程的一些术语：

1. 切面（Aspect）：业务流程运行的某个特定步骤，也就是应用运行过程的关注点，关注点可能横切多个对象，所以常常也称为横切关注点。
2. 连接点（Joinpoint）：程序执行过程中明确的点，如方法的调用或者异常的抛出。Spring AOP中，连接点总是方法的调用。
3. 增强处理（Advice）：AOP框架在特定的切入点执行的增强处理。处理有around，before，after等类型。
4. 切入点（Pointcut）：可以插入增强处理的连接点。简而言之，当某个连接点满足指定要求时，该连接点将被添加增强处理，该连接点也就变成了切入点。例如如下代码：
```
pointcut xxxPointcut()  
   :execution(void H*.say*())  
```

每个方法被调用都只是连接点，但如果该方法属于H开头的类，且方法名义say开头，那么该方法的调用执行将变成切入点。如何使用表达式来定义切入点是AOP的核心，Spring默认使用AspectJ切入点语法：

1. 引入：将方法或字段添加到被处理的类中。Spring允许引入新的接口到任何被处理的对象。例如你可以使用一个引入，使任何对象实现isModified接口，以此来简化缓存。
2. 目标对象：被AOP框架进行增强处理的对象，也被称为被增强的对象。如果AOP框架是通过运行时代理来实现的，那么这个对象将是一个被代理的对象。
3. AOP代理：AOP框架创建的对象，简单地说，代理就是对目标对象的加强。Spring中的AOP代理可以是JDK动态代理，也可以是CGLIB代理。前者为实现接口的目标对象的代理，后者为不实现接口的目标对象的代理。
4. 织入（Weaving）：将增强处理添加到目标对象中，并创建一个被增强的对象（AOP代理）的过程就是织入。织入有两种实现方式：编译时增强（例如AspectJ）和运行时增强（例如CGLIB）。Spring和其他纯Java AOP框架一样，在运行时完成织入。

由前面的介绍知道：AOP代理其实是由AOP框架动态生成的一个对象，该对象可作为目标对象使用。AOP代理包含了目标对象的全部方法，但AOP代理中的方法与目标对象的方法存在差异：AOP方法在特定切入点添加了增强处理，并且回调了目标对象的方法。
AOP代理所包含的方法与目标对象的方法示意图如下：

![AOP代理的方法和目标对象代理的方法](http://fh-1.qiniudn.com/AOP代理的方法和目标对象代理的方法.jpg)

### Spring 的AOP支持

Spring中AOP代理由Spring的IOC容器负责生成、管理，其依赖关系也由IOC容器负责管理。因此，AOP代理可以直接使用容器中的其他Bean实例作为目标，这种关系可由IOC容器的依赖注入提供。Spring默认使用Java动态代理来创建AOP代理，这样就可以为任何接口实例创建代理了。

Spring也可以使用CGLIB代理，在需要代理类而不是代理接口的时候，Spring会自动切换为使用CGLIB代理。但Spring推荐使用面向接口编程，因此业务对象通常都会实现一个或多个接口，此时默认将使用JDK动态代理，但也可强制使用CGLIB。

Spring AOP使用纯Java实现，它不需要专门的编译过程。Spring AOP不需要控制类装载器层次，因此它可以在所有JavaWeb容器或应用服务器中运行良好。

Spring目前仅支持将方法调用作为连接点，如果需要把对field的访问和更新也作为增强处理的连接点，则可以考虑使用AspectJ。

Spring实现AOP的方法跟其他的框架不同，Spring并不是要提供最完整的AOP实现，Spring侧重于AOP实现和Spring IOC容器之间的整合，用于帮助解决在企业级开发中的常见问题。

因此Spring的AOP通常和Spring IOC容器一起使用，Spring AOP从来没有打算通过提供一种全面的AOP解决方案来与AspectJ竞争。Spring AOP采用基于代理的AOP实现方案，而AspectJ则采用编译时增强的解决方案。

一旦我们掌握了上面AOP的相关概念，就不难发现进行AOP编程其实是很简单的事情。纵观AOP编程，其中需要程序员参与的只有三个部分：

1. 定义普通业务组件。
2. 定义切入点，一个切入点可能横切多个业务组件。
3. 定义增强处理，增强处理就是在AOP框架为普通业务组件织入的处理动作。

上面三个部分的第一个部分是最平常不过的事情，那么进行AOP编程的关键就是定义切入点和定义增强处理。一旦定义了合适的切入点和增强处理，AOP框架将会自动生成AOP代理，而AOP代理的方法大致有如下公式：

代理对象的方法 = 增强处理 + 被代理对象的方法

我们使用AspectJ方式来定义切入点和增强处理，在这种方式下，Spring有两种选择来定义切入点和增强处理。

1. 基于 Annotation 的零配置方式：使用@Aspect、@Pointcut等Annotation来标注切入点和增强处理。
2. 基于XML配置文件的管理方式：使用Spring配置文件来定义切入点和增强处理。

### 基于Annotation的“零配置”方式

AspectJ 允许使用Annotation定义切面、切入点和增强处理，而 Spring框架则可识别并根据这些Annotation来生成AOP代理。Spring只是使用了和AspectJ一样的注解，并没有使用AspectJ的编译器和织入器，底层依然使用的是 Spring AOP，依然是在运行时动态生成AOP代理，并不依赖于AspectJ的编译器或者织入器。

为了启用Spring对@AspectJ切面配置的支持，并保证Spring容器中的目标Bean被一个或多个切面自动增强，必须在配置文件中加如下代码：

```
<aop:aspectj-autoproxy/>  
```
如果不打算使用Spring的XML Schema配置方式，则应该在Spring配置文件中增加如下片段来启用@AspectJ支持

```
<bean class="org.springframework.aop.aspectj.annotation.AnnotationAwareAspectJAutoProxyCreator" />
```

为了在Spring应用中启动@AspectJ支持，还需要添加 aspectjrt.jar 和aspectjweaver.jar到工程lib目录下。

#### 定义切面Bean

使用@Aspect标注一个Java类，该Java类将会作为切面Bean

```
@Aspect
public class LogAspect {
}
```
开发时无须担心使用@Aspect 定义的切面类被增强处理，当Spring容器检测到某个Bean类使用了@Aspect标注之后，Spring容器不会对该Bean类进行增强。

#### 定义Before增强处理

Person.java:
```
public interface Person {  
    public String sayHello(String name);  
    public void eat(String food);  
}  
```
Chinese.java:
```
@Component  
public class Chinese implements Person {  
    @Override  
    public void eat(String food) {  
        System.out.println("我正在吃:"+food);  
    }  
    @Override  
    public String sayHello(String name) {  
        return name+"Hello,Spring AOP";  
    }  
}  
```
BeforeAdviceTest.java :
```
@Aspect  
public class BeforeAdviceTest {  
    @Before("execution(* com.bean.*.*(..))")  
    public void authority(){  
        System.out.println("模拟执行权限检查");  
    }  
}  
```
bean.xml :
```
<?xml version="1.0" encoding="UTF-8"?>  
<beans xmlns="http://www.springframework.org/schema/beans"  
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
        xmlns:context="http://www.springframework.org/schema/context"  
        xmlns:aop="http://www.springframework.org/schema/aop"  
        xmlns:tx="http://www.springframework.org/schema/tx"  
        xsi:schemaLocation="http://www.springframework.org/schema/beans   
                http://www.springframework.org/schema/beans/spring-beans-2.5.xsd  
                http://www.springframework.org/schema/context   
                http://www.springframework.org/schema/context/spring-context-3.0.xsd  
                http://www.springframework.org/schema/aop  
                http://www.springframework.org/schema/aop/spring-aop-3.0.xsd">  
    <context:component-scan base-package="com.bean">  
        <context:include-filter type="annotation"   
                 expression="org.aspectj.lang.annotation.Aspect"/>  
    </context:component-scan>  
    <aop:aspectj-autoproxy/>  
</beans>  
```
Test.java :
```
public class Test {  
    public static void main(String[] args) {  
        ApplicationContext ctx=new ClassPathXmlApplicationContext("bean.xml");  
        Person p=(Person) ctx.getBean("chinese");  
        System.out.println(p.sayHello("张三"));  
        p.eat("西瓜");  
    }  
}  
```

#### 定义AfterReturning增强处理

AfterReturning 增强处理将在目标方法正常完成后被织入。
使用@AfterReturning可指定如下两个属性：
1. pointcut / value : 两者都用于指定该切入点对应的切入表达式
2. returning : 指定一个返回值形参名，增强处理定义的方法可通过该行参名来访问目标方法的返回值。

AfterReturningAdviceTest.java :

```
@Aspect  
public class AfterReturningAdviceTest {  
    @AfterReturning(returning="rvt",pointcut="execution(* com.bean.*.*(..))")  
    public void log(Object rvt){  
        System.out.println("获取目标方法返回值："+rvt);  
        System.out.println("模拟记录日志的功能...");  
    }  
}  
```
Test.java :
```
public class Test {  
    public static void main(String[] args) {  
        ApplicationContext ctx=new ClassPathXmlApplicationContext("bean.xml");  
        Person p=(Person) ctx.getBean("chinese");  
        System.out.println(p.sayHello("张三"));  
        p.eat("西瓜");  
    }  
}  
```

#### 定义AfterThrowing增强处理

@AfterThrowing 主要用于处理程序中未处理的异常。
使用@AfterThrowing 时可指定如下两个属性：
1. pointcut / value : 用于指定该切入点对应的切入表达式。
2. throwing : 指定一个返回值形参名，增强处理定义的方法可通过该形参名来访问目标方法中所抛出的异常对象。

Chinese.java :
```
@Component  
public class Chinese implements Person {  
    @Override  
    public void divide() {  
        int a=5/0;  
        System.out.println("divide执行完成！");  
    }  
    @Override  
    public String sayHello(String name) {  
        try {  
            System.out.println("sayHello方法开始被执行...");  
            new FileInputStream("a.txt");  
        } catch (FileNotFoundException e) {  
            System.out.println("目标类的异常处理"+e.getMessage());  
        }  
        return name+" Hello,Spring AOP";  
    }  
}  
```
AfterThrowingAdviceTest.java :
```
@Aspect  
public class AfterThrowingAdviceTest {  
    @AfterThrowing(throwing="ex",pointcut="execution(* com.bean.*.*(..))")  
    public void doRecoveryActions(Throwable ex){  
        System.out.println("目标方法中抛出的异常:"+ex);  
        System.out.println("模拟抛出异常后的增强处理...");  
    }  
}  
```
Test.java :
```
public class Test {  
    public static void main(String[] args) {  
        ApplicationContext ctx=new ClassPathXmlApplicationContext("bean.xml");  
        Person p=(Person) ctx.getBean("chinese");  
        System.out.println(p.sayHello("张三"));  
        p.divide();  
    }  
}  
```

上面程序中的sayHello方法和divide两个方法都会抛出异常，但sayHello方法中的异常将由该方法显式捕捉，所以Spring AOP不会处理该异常；而divide方法将抛出ArithmeticException异常，且该异常没有被任何程序所处理，故Spring AOP会对该异常进行处理。

catch捕捉 意味着完全处理该异常，如果catch块中没有重新抛出新异常，则该方法可以正常结束；而 AfterThrowing 虽然处理了该异常，但他不能完全处理该异常，该异常依然会传播到上一级调用者，本例中传播到JVM，导致程序终止。

如果上面的doRecoveryActions方法定义了ex形参的类型是NullPointerException，则该切入点只匹配抛出NullPointerException异常的情况。

#### After增强处理

@After与@AfterReturning有点相似，但是也有区别：
1. AfterReturning 增强处理只在目标方法成功完成后才会被织入。
2. After 增强处理不管目标方法如何结束，包括成功完成和遇到异常终止两种情况，它都会被织入。
因为不论一个方法是如何结束的，After增强处理都会被织入，因此After增强处理必须准备处理正常返回和异常返回两种情况，这种增强处理通常用于释放资源。

Chinese.java :
```
@Component  
public class Chinese implements Person {  
    @Override  
    public void divide() {  
        int a=5/0;  
        System.out.println("divide执行完成！");  
    }  
    @Override  
    public String sayHello(String name) {  
        try {  
            System.out.println("sayHello方法开始被执行...");  
            new FileInputStream("a.txt");  
        } catch (FileNotFoundException e) {  
            System.out.println("目标类的异常处理"+e.getMessage());  
        }  
        return name+" Hello,Spring AOP";  
    }  
}  
```
AfterAdviceTest.java :
```
@Aspect  
public class AfterAdviceTest {  
    @After("execution(* com.bean.*.*(..))")  
    public void realease(){  
        System.out.println("模拟方法结束后的释放资源...");  
    }  
}  
```
Test.java :
```
public class Test {  
    public static void main(String[] args) {  
        ApplicationContext ctx=new ClassPathXmlApplicationContext("bean.xml");  
        Person p=(Person) ctx.getBean("chinese");  
        System.out.println(p.sayHello("张三"));  
        p.divide();  
    }  
}
```

虽然divide方法因为ArithemeticException异常结束，但After增强处理依然被正常织入。由此After的作用有点类似finally块。

#### Around增强处理

@Around 增强处理是功能比较强大的增强处理，它近似等于Before 和 AfterReturning的总和。@Around既可在执行目标方法之前织入增强动作，也可在执行目标方法之后织入增强动作。@Around甚至可以决定目标方法在什么时候执行，如何执行，更甚者可以完全阻止目标方法的执行。

@Around可以改变执行目标方法的参数值，也可以改变执行目标方法之后的返回值。

@Around功能虽然强大，但通常需要在线程安全的环境下使用。因此，如果使用普通的Before、AfterReturning就能解决的问题，就没有必要使用Around了。如果需要目标方法执行之前和之后共享某种状态数据，则应该考虑使用Around。尤其是需要使用增强处理阻止目标的执行，或需要改变目标方法的返回值时，则只能使用Around增强处理了。

当定义一个Around增强处理方法时，该方法的第一个形参必须是 ProceedingJoinPoint 类型，在增强处理方法体内，调用ProceedingJoinPoint的proceed方法才会执行目标方法--这就是@Around增强处理可以完全控制目标方法执行时机、如何执行的关键；如果程序没有调用ProceedingJoinPoint的proceed方法，则目标方法不会执行。

调用ProceedingJoinPoint的proceed方法时，还可以传入一个Object[]对象，该数组中的值将被传入目标方法作为实参。如果传入的Object[]数组长度与目标方法所需要的参数个数不相等，或者Object[]数组元素与目标方法所需参数的类型不匹配，程序就会出现异常。

Chinese.java :
```
@Component  
public class Chinese implements Person {  
    @Override  
    public void divide() {  
        int a=5/0;  
        System.out.println("divide执行完成！");  
    }  
    @Override  
    public String sayHello(String name) {  
        System.out.println("sayHello方法被调用...");  
        return name+" Hello,Spring AOP";  
    }  
    @Override  
    public void eat(String food) {  
        System.out.println("我正在吃:"+food);  
    }  
}  
```
AroundAdviceTest.java :
```
@Aspect  
public class AroundAdviceTest {  
    @Around("execution(* com.bean.*.*(..))")  
    public Object processTx(ProceedingJoinPoint jp) throws Throwable{  
        System.out.println("执行目标方法之前，模拟开始事务...");  
        Object rvt=jp.proceed(new String[]{"被改变的参数"});  
        System.out.println("执行目标方法之后，模拟结束事务...");  
        return rvt+"新增的内容";  
    }  
}  
```
Test.java :
```
public class Test {  
    public static void main(String[] args) {  
        ApplicationContext ctx=new ClassPathXmlApplicationContext("bean.xml");  
        Person p=(Person) ctx.getBean("chinese");  
        System.out.println(p.sayHello("张三"));  
        p.eat("西瓜");  
        p.divide();  
    }  
}  
```

如果proceed方法参数数组的维度大于需要增强处理的方法，程序会抛出异常。

#### 访问目标方法 

最简单的做法就是定义增强处理方法时将第一个参数定义为JoinPoint 类型，当该增强处理方法被调用时，该JoinPoint参数就代表了织入增强处理的连接点。JoinPoint里包含了如下几个常用的方法：

* Object[ ] getArgs( )	返回执行目标方法时的参数
* Signature getSignature( )	返回被增强的方法的相关信息
* Object getTarget( )	返回被织入增强处理的目标对象
* Object getThis( )	返回AOP框架为目标对象生成的代理对象

Chinese.java :
```
@Component  
public class Chinese implements Person {  
    @Override  
    public String sayHello(String name) {  
        System.out.println("sayHello方法被调用...");  
        return name+" Hello,Spring AOP";  
    }  
    @Override  
    public void eat(String food) {  
        System.out.println("我正在吃:"+food);  
    }  
}  
```
FourAdviceTest.java :
```
@Aspect  
public class FourAdviceTest {  
    @Around("execution(* com.bean.*.*(..))")  
    public Object processTx(ProceedingJoinPoint jp) throws Throwable{  
        System.out.println("Around增强:执行目标方法之前，模拟开始事务...");
        Object[] args=jp.getArgs();  
        if(args!=null && args.length>0 && args[0].getClass()==String.class){
            args[0]="被改变的参数";  
        }  
        Object rvt=jp.proceed(args);  
        System.out.println("Around增强:执行目标方法之后，模拟结束事务...");
        return rvt+" 新增的内容";  
    }  
    @Before("execution(* com.bean.*.*(..))")  
    public void authority(JoinPoint jp){  
        System.out.println("Before增强:模拟执行权限检查...");  
        System.out.println("Before增强:被织入增强处理的目标方法为："+ jp.getSignature().getName());  
        System.out.println("Before增强：目标方法的参数为："+Arrays.toString(jp.getArgs()));  
        System.out.println("Before增强:被织入增强处理的目标对象为："+jp.getTarget());  
    }  
      
    @AfterReturning(returning="rvt",pointcut="execution(* com.bean.*.*(..))")  
    public void log(JoinPoint jp,Object rvt){  
        System.out.println("AfterReturning增强：获取目标方法返回值："+rvt);
        System.out.println("AfterReturning增强：模拟记录日志功能...");  
        System.out.println("AfterReturning增强：被织入增强处理的目标方法为:"+ jp.getSignature().getName());  
        System.out.println("AfterReturning增强：目标方法的参数为："+ Arrays.toString(jp.getArgs()));  
        System.out.println("AfterReturning增强:被织入增强处理的目标对象为："+ jp.getTarget());  
    }  
      
    @After("execution(* com.bean.*.*(..))")  
    public void release(JoinPoint jp){  
        System.out.println("After增强：模拟方法结束后的释放资源...");  
        System.out.println("After增强：被织入增强处理的目标方法为："+ jp.getSignature().getName());  
        System.out.println("After增强：目标方法的参数为："+ Arrays.toString(jp.getArgs()));  
        System.out.println("After增强: 被织入增强处理的目标对象为："+ jp.getTarget());  
    }  
}  
```
Test.java :
```
public class Test {  
    public static void main(String[] args) {  
        ApplicationContext ctx=new ClassPathXmlApplicationContext("bean.xml");  
        Person p=(Person) ctx.getBean("chinese");  
        System.out.println(p.sayHello("张三"));  
        p.eat("西瓜");  
    }  
}  
```
Before、Around、AfterReturning、After增强处理的优先级从低到高的顺序：Before、Around、AfterReturning、After

#### 织入增强处理的顺序

Spring AOP 采用和 AspectJ 一样的优先顺序来织入增强处理：在进入连接点时，高优先级的增强处理将先被织入；在退出连接点时，高优先级的增强处理会后被织入。

当不同的切面里的两个增强处理需要在同一个连接点被织入时，Spring AOP将以随机的顺序来织入这两个增强处理。如果应用需要指定不同切面类里增强处理的优先级，Spring提供了如下两种解决方案：

1. 让切面类实现org.springframework.core.Ordered接口，实现该接口只需实现一个int getOrder()方法，该方法返回值越小，则优先级越高。
2. 直接使用@Order注解来修饰一个切面类，使用 @Order 时可指定一个int型的value属性，该属性值越小，则优先级越高。

Chinese.java :
```
@Component  
public class Chinese implements Person {  
    @Override  
    public void eat(String food) {  
        System.out.println("我正在吃:"+food);  
    }  
}  
```
AspectFirst.java :
```
@Aspect  
@Order(5)  
public class AspectFirst {  
    @Before("execution(* com.bean.*.*(..))")  
    public void aspectFirstStart(){  
        System.out.println("@Before增强处理：我是AspectFirst切面，我的优先级为5");  
    }  
    @After("execution(* com.bean.*.*(..))")  
    public void aspectFirstEnd(){  
        System.out.println("@After增强处理：我是AspectFirst切面，我的优先级为5");  
    }  
}  
```
AspectSecond.java :
```
@Aspect  
@Order(1)  
public class AspectSecond {  
    @Before("execution(* com.bean.*.*(..))")  
    public void aspectSecondStart(){  
        System.out.println("@Before增强处理：我是AspectSecond切面，我的优先级为1");  
    }  
    @After("execution(* com.bean.*.*(..))")  
    public void aspectSecondEnd(){  
        System.out.println("@After增强处理：我是AspectSecond切面，我的优先级为1");  
    }  
}  
```
Test.java :
```
public class Test {  
    public static void main(String[] args) {  
        ApplicationContext ctx=new ClassPathXmlApplicationContext("bean.xml");  
        Person p=(Person) ctx.getBean("chinese");  
        p.eat("西瓜");  
    }  
}  
```

同一个切面类里的两个相同类型的增强处理在同一个连接点被织入时，Spring AOP将以随机顺序来织入这两个增强处理，没有办法指定它们的织入顺序。如果确实需要保证它们以固有的顺序被织入，则可考虑将多个增强处理压缩成一个，或者将不同增强处理重构到不同切面类中，通过在切面类级别上进行排序。

#### 定义切入点

我们在前面的文章中，在一个切面类中定义了4个增强处理，定义4个增强处理时分别指定了相同的切入点表达式，这种做法显然不太符合软件设计的原则：我们居然将那个切入点表达式重复了4次，如果有一天需要修改这个切入点表达式，那就要修改4个地方。如果重复了更多次呢？岁，我们就得修改更多次。

为了解决这个问题，AspectJ和Spring都允许定义切入点。所谓 定义切入点，其实质就是为一个切入点表达式起一个名称，从而允许在多个增强处理中重用该名称。

Spring AOP 只支持以Spring Bean的方法执行组作为连接点，所以可以把 切入点 看成所有能和切入表达式匹配的Bean方法。

切入点定义包括两个部分：
1. 一个切入点表达式：用于指定该切入点和哪些方法进行匹配。
2. 一个包含名字和任意参数的方法签名：作为该切入点的名称。

在@AspectJ风格的AOP中，切入点签名 采用一个普通的方法定义(方法体通常为空)，且方法的返回值必须为void；切入点表达式需要使用@Pointcut注解来标注。

下面的代码片段定义了一个切入点，anyOldTransfer，这个切入点将匹配任何名为transfer的方法的执行：
```
//使用@Pointcut注解时指定切入点表达式  
@Pointcut("execution(* transfer(..))")  
//使用一个返回值为void，方法体为空的方法来命名切入点  
private void anyOldTransfer(){}  
```

切入点表达式，也就是组成@Pointcut注解的值，是正规的AspectJ5切入点表达式。如果想要更多了解AspectJ的切入点语法，参见AspectJ编程指南。

一旦采用上面的代码片段定义了名为anyOldTransfer的切入点之后，程序就可以多次重复使用该切入点了，甚至可以在其他切面类、其他包的切面类里使用该切入点，至于是否可以在其他切面类、其他包的切面类里访问该切入点，则取决于该方法签名前的访问控制符--例如，本示例中anyOldTransfer方法使用的是private修饰符，则意味着仅能在当前切面类中使用该切入点。

如果需要使用本切面类中的切入点，则可在使用@Pointcut时，指定value属性值为已有的切入点，如下所示：
```
@AfterReturning(pointcut="myPointcut()",returning="retVal")  
public void writeLog(String msg,Object retVal){  
   ...  
}  
```
可以看出，指定切入点时非常像调用Java方法的语法------只是该方法代表一个切入点，其实质是为该增强处理定义一个切入点表达式。

如果需要使用其他切面类中的切入点，则其他切面类中的切入点不能使用private修饰。如下程序的切面类中仅定义了一个切入点：

```
@Aspect  
public class SystemArchitecture{  
   @Pointcut("execution(* org.crazyit.app.service.impl.Chin*.say*(..))")  
   public void myPointcut(){  
   }  
}  
```
下面的切面类中将直接使用上面定义的myPointcut切入点：
```
@Aspect  
public class LogAspect {  
    @AfterReturning(pointcut="SystemArchitecture.myPointcut()&& args(msg)",returning="retVal")  
    public void writeLog(String msg,Object retVal){  
        System.out.println(msg);  
        System.out.println(retVal);  
        System.out.println("模拟记录日志...");  
    }  
}  
```

#### 切入点指示符

前面定义切点表达式时使用了大量的execution表达式，其中execution就是一个切入点指示符。Spring AOP仅支持部分AspectJ的切入点指示符，但Spring AOP还额外支持一个bean切入点指示符。不仅如此，因为Spring AOP只支持使用方法调用作为连接点，所以Spring AOP的切入点指示符仅匹配方法执行的连接点。

完整的AspectJ切入点语言支持大量切入点指示符，但是Spring并不支持它们。它们是：call，get，preinitialization，staticinitialization，initialization，handler，adviceexecution，withincode，cflow，cflowbelow，if，@this和@withincode。一旦在Spring AOP中使用这些切点指示符，就会抛出IllegalArgumentException。

Spring AOP支持的切入点指示符有如下几个：

* execution：用于匹配执行方法的连接点，这是Spring AOP中国最主要的切入点指示符。该切入点的用法也相对复杂，execution表达式的格式如下：

    execution(modifier-pattern? ret-type-pattern declaring-type-pattern? name-pattern(param-pattern) throws-pattern?)

    上面的格式中，execution是不变的，用于作为execution表达式的开头，整个表达式中几个参数的详细解释如下：

    * modifier-pattern：指定方法的修饰符，支持通配符，该部分可以省略
    * ret-type-pattern：指定返回值类型，支持通配符，可以使用“*”来通配所有的返回值类型
    * declaring-type-pattern：指定方法所属的类，支持通配符，该部分可以省略
    * name-pattern：指定匹配的方法名，支持通配符，可以使用“*”来通配所有的方法名
    * param-pattern：指定方法的形参列表，支持两个通配符，“*”和“..”，其中“*”代表一个任意类型的参数，而“..”代表0个或多个任意类型的参数。
    * throw-pattern：指定方法声明抛出的异常，支持通配符，该部分可以省略

如下是几个execution表达式：

```
execution(public * * (..))//匹配所有public方法
execution(* set*(..))//匹配以set开始的方法
execution(* com.abc.service.AdviceManager.* (..))//匹配AdviceManager中任意方法
execution(* com.abc.service.*.* (..))//匹配com.abc.servcie包中任意类的任意方法
```

* within：限定匹配特定类型的连接点，当使用Spring AOP的时候，只能匹配方法执行的连接点。下面是几个例子：

    {% codeblock %}
    within(com.abc.service.*)//匹配com.abc.service包中的任意连接点
    within(com.abc.service..*)//匹配com.abc.service包或子包中任意的连接点
    {% endcodeblock %}

* this：用于指定AOP代理必须是指定类型的实例，用于匹配该对象的所有连接点。当使用Spring AOP的时候，只能匹配方法执行的连接点。下面是个例子：

    {% codeblock %}
    this(com.abc.service.AdviceManager)//匹配实现了AdviceManager接口的代理对象的所有连接点，在Spring中只是方法执行的连接点
    {% endcodeblock %}

* target：用于限定目标对象必须是指定类型的实例，用于匹配该对象的所有连接点。当使用Spring AOP的时候，只能匹配方法执行的连接点。下面是个例子：

    {% codeblock %}
    target(com.abc.servcie.AdviceManager)//匹配实现了AdviceManager接口的目标对象的所有连接点，在Spring中只是方法执行的连接点
    {% endcodeblock %}

* args：用于对连接点的参数类型进行限制，要求参数的类型时指定类型的实例。同样，当使用Spring AOP的时候，只能匹配方法执行的连接点。下面是个例子：

    {% codeblock %}
    args(java.io.Serializable)//匹配只接受一个参数，且参数类型是Serializable的所有连接点，在Spring中只是方法执行的连接点
    {% endcodeblock %}

    注意，这个例子与使用execution(* *(java.io.Serializable))定义的切点不同，args版本只匹配运行时动态传入参数值是Serializable类型的情形，而execution版本则匹配方法签名只包含一个Serializable类型的形参的方法。

    另外，Spring AOP还提供了一个名为bean的切入点提示符，它是Spring AOP额外支持的，并不是AspectJ所支持的切入点指示符。这个指示符对Spring框架来说非常有用：它将指定为Spring中的哪个Bean织入增强处理。当然，Spring AOP中只能使用方法执行作为连接点。

* bean：用于指定只匹配该Bean实例内的连接点，实际上只能使用方法执行作为连接点。定义bean表达式时需要传入Bean的id或name，支持使用"*"通配符。下面是几个例子：

    {% codeblock %}
    bean(adviceManager)//匹配adviceManager实例内方法执行的连接点
    bean(*Manager)//匹配以Manager结尾的实例内方法执行的连接点
    {% endcodeblock %}

#### 使用组合切点表达式

Spring支持使用如下三个逻辑运算符来组合切入点表达式：

* &&：要求连接点同时匹配两个切点表达式
* ||：要求连接点匹配至少一个切入点表达式
* !：要求连接点不匹配指定的切入点表达式

其实在之前介绍args的时候，已经用到了“&&”运算符：

```
pointcut("execution(* com.abc.service.*.*(..) && args(name))")
```
上面的pointcut由两个表达式组成，而且使用&&来组合这两个表达式，因此连接点需要同时满足这两个表达式才能被织入增强处理。

### 基于XML配置文件的管理方式

在Spring的配置文件中，所有的切面、切点和增强处理都必须定义在`<aop:config../>`元素内部。`<beans../>`元素可以包含多个`<aop:config../>`元素，一个`<aop:config../>`可以包含pointcut、advisor和aspect元素，且这三个元素需要按照此顺序来定义。

注意：当我们使用`<aop:config../>`方式进行配置时，可能与Spring的自动代理方式相互冲突，因此，建议要么全部使用`<aop:config../>`配置方式，要么全部使用自动代理方式，不要把两者混合使用。

#### 配置切面

配置`<aop:config../>`元素时，实质是将已有的Spring Bean转换成切面Bean，所以需要先定义一个普通的Spring Bean。因为切面Bean可以当成一个普通的Spring Bean来配置，所以我们完全可以为该切面Bean配置依赖注入。当切面Bean的定义完成后，通过`<aop:congig../>`元素中使用ref属性来引用该Bean，就可以将该Bean转换成切面Bean了。配置`<aop:config../>`元素时可以指定如下三个属性：

* id：该切面Bean的标识名
* ref：指定将要被转换成切面Bean的的普通Bean的id
* order：指定该切面Bean的优先级，值越小，优先级越高

如下配置片段定义了一个切面：

```
<!-- 定义普通的Bean实例 -->
<bean id="afterAdviceBean" class="com.bean.AfterAdviceBean" />
<aop:config>
    <!-- 将容器中的afterAdviceBean转换成切面Bean -->
    <aop:aspect id="afterAdviceAspect" ref="afterAdviceBean">
        ...
    </aop:aspect>
</aop:config>
```

上面的配置中，将一个AfterAdviceBean类型普通的Bean对象afterAdviceBean转换成了切面Bean对象afterAdviceAspect。

#### 配置增强处理

与使用@AspectJ完全一样，使用XML一样可以配置Before、After、AfterReturning、AfterThrowing和Around 5种增强处理，而且完全支持和@Aspect完全一样的语义。使用XML配置增强处理分别依赖于如下几个元素：

* `<aop:before../>`：配置Before增强处理
* `<aop:after../>`：配置After增强处理
* `<aop:after-returning../>`：配置AfterReturning增强处理
* `<aop:after-throwing../>`：配置AfterThrowing增强处理
* `<aop:around../>`：配置Around增强处理

这些元素都不支持使用子元素，但通常可以指定如下属性：

* pointcut：指定一个切入点表达式，Spring将在匹配该表达式的连接点织入增强处理
* pointcut-ref：指定一个已经存在的切入点名称，通常pointcut和pointcut-ref只需使用其中之一
* method：指定一个方法名，指定切面Bean的该方法作为增强处理
* throwing：只对`<aop:after-throwing../>`元素有效，用于指定一个形参名，AfterThrowing增强处理方法，可通过该形参访问目标方法所抛出的异常
* returning：只对`<aop:after-returning../>`元素有效，用于指定一个形参名，AfterThrowing增强处理方法，可通过该形参访问目标方法的返回值

定义切点时，XML配置方式和@AspectJ注解方式支持完全相同的切点指示符，一样可以支持execution、within、args、this、target和bean等切点提示符。另外，XML配置文件方式也和@AspectJ方式一样支持组合切入点表达式，但XML配置方式不再使用简单的&&、|| 和 ! 作为组合运算符（因为直接在XML文件中需要使用实体引用来表示他们），而是使用如下三个组合运算符：and（相当于&&）、or（相当于||）和not（相当于！）。 下面是一个使用`<aop:congig../>`的例子，这是把前面的例子中关于切面切点和增强处理的注解去掉后，使用XML配置文件来重新实现这些切面切点的功能：

```
<bean id="adviceTest" class="com.bean.AdviceTest" />
<aop:config>
    <!-- 注意这里可以使用order属性为Aspect指定优先级 -->
    <aop:aspect id="firstAspect" ref="adviceTest" order="2">
        <!-- @Before切点 -->
        <aop:before pointcut="execution(* com.abc.service.*.*(..))" 
                method="permissionCheck"/>
        <!-- @After切点 -->
        <aop:after pointcut="execution(* com.abc.service.*.*(..))" 
                method="releaseResource"/>
        <!-- @AfterReturning切点 -->
        <aop:after-returning pointcut="execution(* com.abc.service.*.*(..))" 
                method="log"/>
        <!-- @AfterThrowing切点 -->
        <aop:after-throwing pointcut="execution(* com.abc.service.*.*(..))" 
                method="handleException"/>
        <!-- @Around切点（多个切点提示符使用and、or或者not连接） -->
        <aop:around pointcut="execution(* com.abc.service.*.*(..)) and args(name,time,..)" 
                method="process"/>
    </aop:aspect>
</aop:config>
```
上面的定义中，特意为firstAspec指定了order=2，表明firstAspect的优先级为2，如果这个XML文件中还有order=1的Aspect，那么这个Aspect将被Spring AOP优先织入。其执行结果，和前面几篇文章中介绍的相同，这里不再给出。

#### 配置切点

在Spring中通过`<aop:pointcut../>`元素来定义切点。当把`<aop:pointcut../>`元素作为`<aop:config../>`的子元素时，表明该切点可以被多个切面共享；当把`<aop:pointcut../>`元素作为`<aop:aspect../>`的子元素时，表明该切点只能在这个切面内使用。配置`<aop:pointcut../>`时，通常需要配置如下两个属性：

* id：指定该切点的标识名
* expression：指定该切点关联的切点表达式

如下的配置定义了一个简单的切点：

```
<aop:pointcut id="point1" expression="execution(* com.bean.service.*.*(..))" />
```
另外，如果程序中已经使用注解的方式定义了切点，在`<aop:pointcut../>`元素中指定切入点表达式时还有另一种用法，看例子：

```
<aop:pointcut id="point2" expression="com.bean.AdviceTest.myPointcut()" />
```
下面的程序中定义了一个AfterThrowing增强处理，包含该增强处理的切面类如下：

```
public class AfterThrowingAdviceTest {
    //定义一个普通方法作为增强处理方法，这个方法名将在XML配置文件中指定
    public void doRecoveryAction(Throwable th) {
        System.out.println("目标方法抛出异常：" + th);
        System.out.println("模拟数据库事务恢复");
    }
}
```
与前面的切面类完全类似，该Java类就是一个普通的Java类。下面的配置文件将负责配置该Bean实例，并将该Bean转换成切面Bean：

```
<bean id="afterThrowingAdviceTest" 
    class="com.abc.advice.AfterThrowingAdviceTest" />
<aop:config>
    <!-- 这个切点将可以被多个<aop:aspect../>使用 -->
    <aop:pointcut id="myPointcut" 
        expression="execution(* com.abc.service.*.*(..))" />
    <!-- 这个aspect由上面的Bean afterThrowingAdviceTest转化而来 -->
    <aop:aspect id="aspect1" ref="afterThrowingAdviceTest">
        <!-- 定义一个AfterThrowing增强处理，指定切入点以切面Bean中
            的doRecoverryAction作为增强处理方法 -->
        <aop:after-throwing pointcut-ref="myPointcut" 
            method="doRecoveryAction" throwing="th" />
    </aop:aspect>
</aop:config>
```

上面的`<aop:pointcut../>`元素定义了一个全局的切点myPointcut，这样其他切面Bean就可以多次复用这个切点了。`<aop:after-throwing../>`元素中，使用pointcut-ref属性指定了一个已经存在的切点。

## Spring 的事务

### Spring支持的事务策略

JavaEE应用的传统事务有两种策略：全局事务和局部事务。

* 全局事务由应用服务器管理，需要底层服务器的JTA支持。
* 局部事务和底层所采用的持久化技术有关，当采用JDBC持久化技术时，需要使用Connection对象来操作事务；而采用Hibernate持久化技术时，需要使用Session对象来操作事务。

当采用传统的事务编程策略时，程序代码必然和具体的事务操作代码耦合，这样造成的后果是：当应用需要在不同的事务策略之间切换时，开发者必须手动修改程序代码。当使用Spring事务策略后，就可以改变这种状况。

Spring事务策略是通过PlatformTransactionManager接口实现的，该接口是Spring事务策略的核心。该接口的源代码如下：

```
public interface PlatformTransactionManager {  
   //平台无关的获得事务的方法  
   TransactionStatus getTransaction(TransactionDefinition definition) throws TransactionException;  
   //平台无关的事务提交方法  
   void commit(TransactionStatus status) throws TransactionException;  
   //平台无关的事务回滚方法  
   void rollback(TransactionStatus status) throws TransactionException;  
}  
```
PlatformTransactionManager是一个与任何事务策略分离的接口，随着底层不同事务策略的切换，应用必须采用不同的实现类。PlatformTransactionManager接口没有与任何事务资源捆绑在一起，它可以适应于任何的事务策略，结合Spring的IoC容器，可以向PlatformTransactionManager注入相关的平台特性。

PlatformTransactionManager接口有许多不同的实现类，应用程序面向于平台无关的接口编程，当底层采用不同的持久层技术时，系统只需使用不同的 PlatformTransactionManager 实现类即可。而这种切换通常由Spring容器负责管理，应用程序既无须与具体的事务API耦合，也无须与特定实现类耦合，从而将应用和持久化技术、事务API彻底分离开来。

TransactionStatus对象表示一个事务。getTransaction(TransactionDefinition definition)返回的TransactionStatus对象，可能是一个新的事务，也可能是一个已经存在的事务对象；否则，系统将新建一个事务对象后返回。

TransactionDefinition接口定义了一个事务规则，该接口必须指定如下几个属性：

* 事务隔离	当前事务和其他事务的隔离程度。例如这个事务能否看到其他事务未提交的数据等。
* 事务传播	通常，在事务中执行的代码都会在当前事务中运行。但是如果一个事务上下文已经存在，有几个选项可指定该事务性方法的执行行为。例如，大多数情况下，简单地在现有的事务上下文中运行；或者挂起现有事务，创建一个新的事务。Spring提供EJB CMT中所有的事务传播选项。
* 事务超时	事务在超时前能运行多久，也就是事务的最长持续时间。如果事务一直没有被提交或回滚，将在超出该时间后，系统自动回滚事务。
* 只读状态	只读事务不修改任何数据。在某些情况下，例如使用Hibernate时，只读事务是非常有用的优化。TransactionStatus代表事务本身，它提供了简单的控制事务执行和查询事务状态的方法，这些方法在所有的事务API中都是相同的：

```
public interface TransactionStatus extends SavepointManager {  
    boolean isNewTransaction();  
    boolean hasSavepoint();  
    void setRollbackOnly();  
    boolean isRollbackOnly();  
    boolean isCompleted();  
}  
public interface SavepointManager {  
    Object createSavepoint() throws TransactionException;  
    void rollbackToSavepoint(Object savepoint) throws TransactionException;  
    void releaseSavepoint(Object savepoint) throws TransactionException;  
}  
```
Spring具体的事务管理由PlatformTransactionManager的不同实现类来完成。在Spring容器中配置PlatformTransactionManager Bean时，必须针对不同环境提供不同的实现类。
譬如针对 JDBC数据源 的局部事务策略的配置文件如下：
```
<?xml version="1.0" encoding="UTF-8"?>  
<beans xmlns="http://www.springframework.org/schema/beans"  
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
        xmlns:context="http://www.springframework.org/schema/context"  
        xmlns:tx="http://www.springframework.org/schema/tx"  
        xsi:schemaLocation="http://www.springframework.org/schema/beans   
        http://www.springframework.org/schema/beans/spring-beans-2.5.xsd  
                http://www.springframework.org/schema/context   
                http://www.springframework.org/schema/context/spring-context-2.5.xsd  
                http://www.springframework.org/schema/tx   
                http://www.springframework.org/schema/tx/spring-tx-2.5.xsd">
    <!-- 定义数据源Bean，使用C3P0数据源实现 -->  
    <bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource">
        <property name="driverClass" value="oracle.jdbc.driver.OracleDriver"/> 
        <property name="jdbcUrl" value="jdbc:oracle:thin:@localhost:1521:orcl"/>  
        <property name="user" value="scott"/>  
        <property name="password" value="tiger"/>  
        <property name="maxPoolSize" value="40"/>  
        <property name="minPoolSize" value="1"/>  
        <property name="initialPoolSize" value="1"/>  
        <property name="maxIdleTime" value="20"/>  
    </bean>  
    <!-- 配置JDBC数据源的局部事务管理器，使用DataSourceTransactionManager类 -->
    <!-- 该类实现PlatformTransactionManager接口，是针对采用数据源连接的特定实现 -->  
    <bean id="transactionManager"   
          class="org.springframework.jdbc.datasource.DataSourceTransactionManager">  
        <property name="dataSource" ref="dataSource"/>  
    </bean>  
</beans>  
```
针对 Hibernate 的局部事务策略的配置文件如下：
```
<!-- 定义Hibernate的SessionFactory -->  
<bean id="sessionFactory" class="org.springframework.orm.hibernate3.LocalSessionFactoryBean">  
    <property name="dataSource" ref="dataSource"/>  
    <property name="mappingResources">  
        <list>  
            <value>xxx/Xxx.hbm.xml</value>  
        </list>  
    </property>  
    <property name="hibernateProperties">  
        <props>  
            <prop key="hibernate.dialect">org.hibernate.dialect.MySQLInnoDBDialect</prop>  
            <prop key="hibernate.hbm2ddl.auto">update</prop>  
        </props>  
    </property>  
</bean>  
<!-- 配置Hibernate的局部事务管理器，使用HibernateTransactionManager类 -->  
<!-- 该类实现PlatformTransactionManager接口，是针对采用Hibernate的特定实现 -->  
<bean id="transactionManager"   
        class="org.springframework.orm.hibernate3.HibernateTransactionManager">  
    <property name="sessionFactory" ref="sessionFactory"/>  
</bean>  
```      

从上面的配置文件可以看出，当采用Spring事务管理策略时，应用程序无须与具体的事务策略耦合。Spring提供了两种事务管理方式：
1. 编程式事务管理：即使利用Spring编程式事务时，程序也可直接获取容器中的transactionManager Bean，该Bean总是PlatformTransactionManager的实例，所以可以通过该接口提供的3个方法来开始、提交事务和回滚事务。
2. 声明式事务管理：无须在Java程序中书写任何的事务操作代码，而是通过在XML文件中为业务组件配置事务代理，AOP为事务代理所织入的增强处理也由Spring提供：在目标方法执行之前，织入开始事务；在目标方法执行之后，织入结束事务。

不论采用何种持久化策略，Spring都提供了一致的事务抽象，因此，应用开发者能在任何环境下，使用一致的编程模型。无须更改代码，应用就可在不同的事务管理策略中切换。

### 使用TransactionProxyFactoryBean创建事务代理

Spring同时支持编程式事务策略和声明式事务策略，在实际开发中，几乎都采用声明式事务策略。使用声明式事务策略的优势 十分明显：

1. 声明式事务能大大降低开发者的代码书写量，而且声明式事务几乎不影响应用的代码。因此，无论底层事务策略如何变化，应用程序都无须任何改变。
2. 应用程序代码无须任何事务处理代码，可以更关注于业务逻辑的实现。
3. Spring可对任何POJO的方法提供事务管理，而且Spring的声明式事务管理无须容器的支持，可在任何环境下使用。
4. EJB的CMT无法提供声明式回滚规则；而通过配置文件，Spring可指定事务在遇到特定异常时自动回滚。Spring不仅可在代码中使用setRollbackOnly回滚事务，也可在配置文件中配置回滚规则。
5. 由于Spring采用AOP方式管理事务，因此可以在事务回滚动作中插入用户自己的动作，而不仅仅是执行系统默认的回滚。

在Spring1.x中，声明式事务使用 TransactionProxyFactoryBean 来配置事务代理Bean。每个TransactionProxyFactoryBean为一个目标Bean生成一个事务代理Bean，事务代理的方法改写了目标Bean的方法，就是在目标Bean的方法执行之前加入开始事务，在目标Bean的方法正常结束之后提交事务，如果遇到特定异常则回滚事务。

TransactionProxyFactoryBean创建事务代理时，需要了解当前事务所处的环境，该环境属性通过PlatformTransactionManager实例传入，而相关事务规则则在该Bean定义中给出。

NewsDao.java :
```
public interface NewsDao {  
    public void insert(Integer id,String title,String content);  
}  
```
NewsDaoImpl.java :
```
public class NewsDaoImpl implements NewsDao{  
    private DataSource ds;  
    public void setDs(DataSource ds) {  
        this.ds = ds;  
    }  
    @Override  
    public void insert(Integer id, String title, String content) {  
        JdbcTemplate jt=new JdbcTemplate(ds);  
        jt.update("insert into news values(?,?,?)",new Object[]{id,title,content});  
        jt.update("insert into news values(?,?,?)",new Object[]{id,title,content});  
    }  
}  
```
bean.xml :
```
<?xml version="1.0" encoding="UTF-8"?>  
<beans xmlns="http://www.springframework.org/schema/beans"  
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
        xmlns:context="http://www.springframework.org/schema/context"  
        xmlns:tx="http://www.springframework.org/schema/tx"  
        xsi:schemaLocation="http://www.springframework.org/schema/beans   
        http://www.springframework.org/schema/beans/spring-beans-2.5.xsd  
                http://www.springframework.org/schema/context   
                http://www.springframework.org/schema/context/spring-context-2.5.xsd  
                http://www.springframework.org/schema/tx   
                http://www.springframework.org/schema/tx/spring-tx-2.5.xsd">
    <!-- 定义数据源Bean -->  
    <bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource">
        <property name="driverClass" value="oracle.jdbc.driver.OracleDriver"/>
        <property name="jdbcUrl" value="jdbc:oracle:thin:@localhost:1521:orcl"/>  
        <property name="user" value="scott"/>  
        <property name="password" value="tiger"/>  
        <property name="maxPoolSize" value="40"/>  
        <property name="minPoolSize" value="1"/>  
        <property name="initialPoolSize" value="1"/>  
        <property name="maxIdleTime" value="20"/>  
    </bean>  
    <!-- 配置一个业务逻辑Bean -->  
    <bean id="newsDao" class="com.bean.NewsDaoImpl">  
        <property name="ds" ref="dataSource"/>  
    </bean>  
    <!-- 配置JDBC数据源的局部事务管理器 -->  
    <bean id="transactionManager"   
          class="org.springframework.jdbc.datasource.DataSourceTransactionManager">  
        <property name="dataSource" ref="dataSource"/>  
    </bean>  
    <!-- 为业务逻辑Bean配置事务代理 -->  
    <bean id="newsDaoTrans"   
          class="org.springframework.transaction.interceptor.TransactionProxyFactoryBean">  
          <property name="transactionManager" ref="transactionManager"/>  
          <property name="target" ref="newsDao"/>  
          <property name="transactionAttributes">  
            <props>  
                <prop key="*">PROPAGATION_REQUIRED</prop>  
            </props>  
          </property>  
    </bean>  
</beans>  
```
Test.java :
```
public class Test {  
    public static void main(String[] args) {  
        ApplicationContext ctx=new ClassPathXmlApplicationContext("bean.xml");  
        NewsDao dao=(NewsDao) ctx.getBean("newsDaoTrans");  
        dao.insert(1,"夺冠","绿衫军夺冠");  
    }  
}  
```

可以知道，插入数据失败。上面程序中违反主键约束，该行代码将引发异常。

如果在没有事务控制的环境下，前一条代码将会向数据表中插入一条记录，第二条插入失败。但是现在一条记录都没有插入，这说明事务起作用了，这两条语句是一个整体，因为第二条插入失败，导致第一条插入的数据也被回滚。

配置事务代理 时需要传入一个事务管理器，一个目标Bean，并指定该事物代理的事务属性，事务属性由transactionAttributes属性指定。上面事务属性只有一条事务传播规则，该规则指定对于所有方法都使用PROPAGATION_REQUIRED的传播规则。Spring支持的事务传播规则如下：

* PROPAGATION_MANDATORY	要求调用该方法的线程必须处于事务环境中，否则抛出异常。
* PROPAGATION_NESTED	如果执行该方法的线程已经处于事务环境下，依然启动新的事务，方法在嵌套的事务里执行。如果执行该方法的线程并未处于事务中，也启动新的事务，然后执行该方法，次时与PROPAGATION_REQUIRED相同。
* PROPAGATION_NEVER	不允许调用该方法的线程处于事务环境下，如果调用该方法的线程处于事务环境下，则抛出异常。
* PROPAGATION_NOT_SUPPORTED	如果调用该方法的线程处在事务中，则先暂停当前事务，然后执行该方法。
* PROPAGATION_REQUIRED	要求在事务环境中执行该方法，如果当前执行线程已经处于事务中，则直接调用；如果当前执行线程不处于事务中，则启动新的事务后执行该方法。
* PROPAGATION_REQUIRES_NEW	该方法要求在新的事务环境中执行，如果当前执行线程已经处于事务中，则先暂停当前事务，启动新事务后执行该方法；如果当前调用线程不处于事务中，则启动新的事务后执行方法。
* PROPAGATION_SUPPORTS	如果当前执行线程处于事务中，则使用当前事务，否则不使用事务。

### Spring2.x的事务配置策略

Spring1.x 的声明式事务使用TransactionProxyFactoryBean配置策略简单易懂，但是配置起来极为繁琐：每个目标Bean都需要额外配置一个TransactionProxyFactoryBean代理，这种方式将导致配置文件急剧增加。

Spring 2.x 的XML Schema方式提供了更简洁的事务配置策略，Spring2.x提供了tx命名空间来配置事务管理，tx命名空间下提供了`<tx:advice.../>` 元素来配置事务增强处理，一旦使用该元素配置了事务增强处理，就可直接使用`<aop:advisor.../>` 元素启用自动代理了。

bean.xml :
```
<?xml version="1.0" encoding="UTF-8"?>  
<beans xmlns="http://www.springframework.org/schema/beans"  
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
        xmlns:context="http://www.springframework.org/schema/context"  
        xmlns:aop="http://www.springframework.org/schema/aop"  
        xmlns:tx="http://www.springframework.org/schema/tx"  
        xsi:schemaLocation="http://www.springframework.org/schema/beans   
        http://www.springframework.org/schema/beans/spring-beans-2.5.xsd  
                http://www.springframework.org/schema/context   
                http://www.springframework.org/schema/context/spring-context-2.5.xsd  
                http://www.springframework.org/schema/tx   
                http://www.springframework.org/schema/tx/spring-tx-2.5.xsd  
                http://www.springframework.org/schema/aop   
                http://www.springframework.org/schema/aop/spring-aop-2.5.xsd">  
    <!-- 定义数据源Bean -->  
    <bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource">
        <property name="driverClass" value="oracle.jdbc.driver.OracleDriver"/>  
        <property name="jdbcUrl" value="jdbc:oracle:thin:@localhost:1521:orcl"/>  
        <property name="user" value="scott"/>  
        <property name="password" value="tiger"/>  
        <property name="maxPoolSize" value="40"/>  
        <property name="minPoolSize" value="1"/>  
        <property name="initialPoolSize" value="1"/>  
        <property name="maxIdleTime" value="20"/>  
    </bean>  
    <!-- 配置一个业务逻辑Bean -->  
    <bean id="newsDao" class="com.bean.NewsDaoImpl">  
        <property name="ds" ref="dataSource"/>  
    </bean>  
    <!-- 配置JDBC数据源的局部事务管理器 -->  
    <bean id="transactionManager"   
          class="org.springframework.jdbc.datasource.DataSourceTransactionManager">  
        <property name="dataSource" ref="dataSource"/>  
    </bean>  
    <!-- 配置事务增强处理Bean，指定事务管理器 -->  
    <tx:advice id="txAdvice" transaction-manager="transactionManager">  
        <tx:attributes>  
            <!-- 所有以'get'开头的方法是只读的 -->  
            <tx:method name="get*" read-only="true"/>  
            <!-- 其他方法使用默认的事务处理 -->  
            <tx:method name="*"/>  
        </tx:attributes>  
    </tx:advice>  
    <!-- AOP配置的元素 -->  
    <aop:config>  
        <aop:pointcut id="myPointcut" expression="execution(* com.bean.*.*(..))"/>  
        <aop:advisor advice-ref="txAdvice" pointcut-ref="myPointcut"/>  
    </aop:config>  
</beans>  
```
Test.java :
```
public class Test {  
    public static void main(String[] args) {  
        ApplicationContext ctx=new ClassPathXmlApplicationContext("bean.xml");  
        NewsDao dao=(NewsDao) ctx.getBean("newsDao");  
        dao.insert(1,"夺冠","绿衫军夺冠");  
    }  
}  
```

可见，事务已经自动启动了。两条记录是一个事务，第二条记录插入失败，导致第一条记录也被回滚。

配置 `<tx:advice.../>` 元素时只需指定一个transaction-manager属性，该属性的默认值是“transactionManager”。除了transaction-manager属性之外，还需要配置一个attributes子元素，该子元素里又可包含多个method子元素，每个`<method.../>`子元素为一批方法指定所需的事务语义，包括事务传播属性、事务隔离属性、事务超时属性、只读事务、对指定异常回滚，对指定异常不回滚等。

配置method子元素时可以指定如下几个属性：

* name	必选属性，与该事务语义关联的方法名。该属性支持使用通配符，例如get*，handle*等。
* propagation	指定事务传播行为，该属性值可为Propagation枚举类的任一枚举值，默认为Propagation_REQUIRED。
* isolation	指定事务隔离级别。该属性值可为Isolation枚举类的任一枚举值，默认为Isolation_DEFAULT。
* timeout	指定事务超时的时间(以秒为单位)。指定-1意味着不超时，默认值为-1。
* read-only	指定事务是否只读。默认为false。
* rollback-for	指定触发事务回滚的异常类，可指定多个异常类，以英文逗号隔开。
* no-rollback-for	指定不触发事务回滚的异常类，可指定多个异常类，以英文逗号隔开。

### 使用@Transactional

Spring 还允许将事务配置放在Java类中定义，这需要借助于@Transactional注解，该注解既可用于修饰Spring Bean类，也可用于修饰Bean类中的某个方法。

使用@Transactional修饰Bean类，表明这些事务设置对整个Bean类起作用；
使用@Transactional修饰Bean类中的某个方法，表明这些事务设置只对该方法有效。
使用@Transactional 时可指定如下属性：
* isolation	用于指定事务的隔离级别，默认为底层事务的隔离级别。
* noRollbackFor	指定遇到指定异常时强制不回滚事务。
* noRollbackForClassName	指定遇到指定多个异常时强制不回滚事务，该属性值可以指定多个异常类名。
* propagation	指定事务传播属性。
* readOnly	指定事务是否只读。
* rollbackFor	指定遇到特定异常时强制回滚事务。
* rollbackForClassName	指定遇到指定多个异常时强制回滚事务，该属性值可以指定多个异常类名。
* timeout	指定事务的超时时长。 例如：

```
public class NewsDaoImpl implements NewsDao{  
    private DataSource ds;  
    public void setDs(DataSource ds) {  
        this.ds = ds;  
    }  
    @Transactional(propagation=Propagation.REQUIRED)//这里  
public void insert(Integer id, String title, String content) {  
        JdbcTemplate jt=new JdbcTemplate(ds);  
        jt.update("insert into news values(?,?,?)",new Object[]{id,title,content});  
        jt.update("insert into news values(?,?,?)",new Object[]{id,title,content});  
    }  
}  
```
仅仅使用这个Annotation修饰还不够，还需要让Spring根据Annotation来配置事务代理，所以还需要在Spring配置文件中增加如下配置片段：
```
<bean id="transactionManager"   
          class="org.springframework.jdbc.datasource.DataSourceTransactionManager">  
        <property name="dataSource" ref="dataSource"/>  
    </bean>  
<tx:annotation-driven transaction-manager="transactionManager"/>  
```

## Spring整合Struts2

### 启动Spring容器

实际开发中，项目多数会选择使用Spring整合Struts2框架。对于使用Spring框架的Web应用，我们不能手动创建Spring容器，而是通过配置文件，声明式地创建Spring容器。为了让Spring容器随着Web应用的启动而自动地创建起来，可以借助于ServletContextListener监听器完成，该监听器可以在Web应用启动时回调自定义方法从而创建Spring容器。

Spring提供了一个ContextLoaderListener，该监听器类实现了ServletContextListener接口，可以作为监听器使用。那么该监听器类的回调方法根据什么东西创建Spring容器呢？答案当然是Spring的配置文件。如果有多个配置文件需要载入，考虑使用`<context-param.../>`元素来确定配置文件。ContextLoaderListener加载时，会查找名为contextConfigLocation的初始化参数，因此配置`<context-param.../>`时应指定参数名为contextConfigLocation。参数值为Spring的多个配置文件，文件之间以逗号隔开。

Spring根据指定配置文件创建WebApplicationContext对象，并将其保存在Web应用的ServletContext中。如果要获得Spring容器对象，可以通过如下代码：

```
WebApplicationContext ctx=  WebApplicationContextUtils.getWebApplicationContext(servletContext);  
```

web.xml :
```
<?xml version="1.0" encoding="UTF-8"?>  
<web-app version="2.4"   
    xmlns="http://java.sun.com/xml/ns/j2ee"   
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"   
    xsi:schemaLocation="http://java.sun.com/xml/ns/j2ee   
    http://java.sun.com/xml/ns/j2ee/web-app_2_4.xsd">  
  <context-param>  
    <param-name>contextConfigLocation</param-name>  
    <param-value>classpath:beans.xml</param-value>  
  </context-param>  
  <listener>  
    <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>  
  </listener>  
  <filter>  
    <filter-name>struts2</filter-name>  
    <filter-class>org.apache.struts2.dispatcher.ng.filter.StrutsPrepareAndExecuteFilter</filter-class>  
  </filter>  
  <filter-mapping>  
    <filter-name>struts2</filter-name>  
    <url-pattern>/*</url-pattern>  
  </filter-mapping>  
</web-app>  
```
index.jsp :
```
<body>  
<a href="test">点击我</a>  
</body>  
```
ok.jsp :
```
<body>  
操作成功，已获得Spring容器实例,控制台已经输出了容器对象...  
</body>  
```
struts.xml :
```
<?xml version="1.0" encoding="UTF-8" ?>  
<!DOCTYPE struts PUBLIC  
    "-//Apache Software Foundation//DTD Struts Configuration 2.1.7//EN"  
    "http://struts.apache.org/dtds/struts-2.1.7.dtd">  
<struts>  
    <package name="demo" extends="struts-default">  
        <action name="test" class="com.action.TestAction">  
            <result>/ok.jsp</result>  
        </action>  
    </package>  
</struts>  
```
TestAction.java :
```
public class TestAction extends ActionSupport {  
    @Override  
    public String execute() throws Exception {  
        ServletContext servletContext=ServletActionContext.getServletContext();  
        WebApplicationContext ctx=  
            WebApplicationContextUtils.getWebApplicationContext(servletContext);  
        System.out.println(ctx);  
        return "success";  
    }  
}  
```

如果将Spring的配置文件放在WEB-INF目录下：

则修改web.xml的<param-value>的值为：
```
<context-param>  
  <param-name>contextConfigLocation</param-name>  
  <param-value>/WEB-INF/beans.xml</param-value>  
</context-param>  
```

### MVC框架与Spring整合的思考

对于一个基于B/S架构的JavaEE应用而言，用户请求总是向MVC框架的控制器请求，而当控制器拦截到用户请求后，必须调用业务逻辑组件来处理用户请求。此时有一个问题：控制器应该如何获得业务逻辑组件？

最容易想到的策略是，直接通过 new 关键字创建业务逻辑组件，然后调用业务逻辑组件的方法，根据业务逻辑方法的返回值确定结果。

在实际开发中，很少采用上面的策略，因为这是一种非常差的策略。原因有三：
1. 控制器直接创建业务逻辑组件，导致控制器和业务逻辑组件的耦合降低到代码层次，不利于高层次解耦。
2. 控制器不应该负责业务逻辑组件的创建，控制器只是业务逻辑组件的使用者，无须关心业务逻辑组件的实现。
3. 每次创建新的业务逻辑组件导致性能下降。

对于轻量级的JavaEE应用，工厂模式 则是更实际的策略。因为在轻量级JavaEE应用中，业务逻辑组件不是EJB，通常就是一个POJO，业务逻辑组件的生成通常应由工厂负责，而且工厂可以保证该组件的实例只有一个，这样就可以避免重复实例化造成的系统开销。

采用工厂模式，将控制器和业务逻辑组件的实现分离，从而提供更好的解耦。在采用工厂模式的访问策略中，所有的业务逻辑组件的创建由工厂负责，业务逻辑组件的运行也由工厂负责。控制器只需定位工厂实例即可。

如果系统采用 Spring框架，则Spring成为最大的工厂。Spring负责业务逻辑组件的创建和生成，并可管理业务逻辑组件的生命周期。可以如此理解：Spring是个性能非常优秀的工厂，可以生产出所有的实例，从业务逻辑组件，到持久层组件，甚至控制器组件。

现在的问题是：控制器如何访问到Spring容器中的业务逻辑组件呢？有两种策略：
1. Spring容器负责管理控制器Action，并利用依赖注入为控制器注入业务逻辑组件。
2. 利用Spring的自动装配，Action将会自动从Spring容器中获取所需的业务逻辑组件。

### 让Spring容器管理控制器

web.xml如前所示。 
index.jsp :
```
<body>  
<form action="add" method="post">  
部门名称:<input type="text" name="dname"><br>  
部门地址:<input type="text" name="loc"><br>  
<input type="submit" value="提交">  
</form>  
</body>  
```
ok.jsp :
```
<body>  
部门信息添加成功...  
</body>  
```
Dept.java :
```
public class Dept {  
    private String dname;  
    private String loc;  
    //setter .. getter
}  
```
DeptDAO.java :
```
public interface DeptDAO {  
    public void save(Dept dept);  
}  
```
DeptDAOImpl.java :
```
public class DeptDAOImpl implements DeptDAO {  
    @Override  
    public void save(Dept dept) {  
        System.out.println("将Dept对象保存进数据库");  
    }  
}  
```
AddDeptAction.java :
```
public class AddDeptAction extends ActionSupport {  
    private String dname;  
    private String loc;  
    private DeptDAO deptDao;  
    public String execute(){  
        Dept dept=new Dept();  
        dept.setDname(dname);  
        dept.setLoc(loc);  
        deptDao.save(dept);  
        return "success";  
    }  
    //setter ... getter
}  
```
struts.xml :
```
<?xml version="1.0" encoding="UTF-8" ?>  
<!DOCTYPE struts PUBLIC  
    "-//Apache Software Foundation//DTD Struts Configuration 2.1.7//EN"  
    "http://struts.apache.org/dtds/struts-2.1.7.dtd">  
<struts>  
    <package name="demo" extends="struts-default">  
        <action name="add" class="addDeptAction">  
            <result>/ok.jsp</result>  
        </action>  
    </package>  
</struts>  
```
beans.xml :
```
<?xml version="1.0" encoding="UTF-8"?>  
<beans xmlns="http://www.springframework.org/schema/beans"  
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
        xmlns:context="http://www.springframework.org/schema/context"  
        xmlns:aop="http://www.springframework.org/schema/aop"  
        xmlns:tx="http://www.springframework.org/schema/tx"  
        xsi:schemaLocation="http://www.springframework.org/schema/beans   
                http://www.springframework.org/schema/beans/spring-beans-2.5.xsd  
                http://www.springframework.org/schema/context   
                http://www.springframework.org/schema/context/spring-context-2.5.xsd  
                http://www.springframework.org/schema/tx  
                http://www.springframework.org/schema/tx/spring-tx-2.5.xsd  
                http://www.springframework.org/schema/aop  
                http://www.springframework.org/schema/aop/spring-aop-2.5.xsd">  
    <bean id="addDeptAction" class="com.action.AddDeptAction" scope="prototype">  
        <property name="deptDao" ref="dao"/>  
    </bean>  
    <bean id="dao" class="com.dao.DeptDAOImpl"/>  
</beans>  
```

## Spring整合Hibernate

### Spring提供的DAO支持

DAO模式 是一种标准的Java EE设计模式，DAO模式的核心思想是：所有的数据库访问，都通过DAO组件完成，DAO组件封装了数据库的增删改等原子操作。业务逻辑组件依赖于DAO组件提供的数据库原子操作，完成系统业务逻辑的实现。

DAO组件是整个Java EE应用的持久层访问的重要组件，每个JavaEE应用的底层实现都难以离开DAO组件的支持。Spring对实现DAO组件提供了许多工具类，系统的DAO组件可通过继承这些工具类完成，从而可以更加简便地实现DAO组件。

Spring提供了一系列的抽象类，这些抽象类将被作为应用中DAO实现类的父类。通过继承这些抽象类，Spring简化了DAO的开发步骤，能以一致的方式使用数据库访问技术。不管底层采用JDBC还是Hibernate，应用中都可采用一致的编程模型。

除外之外，Spring通过了一致的异常抽象，将原有的checked异常转换包装成Runtime异常，因而，编码时无须捕获各种技术中特定的异常。Spring DAO体系中的异常，都继承DataAccessException，而DataAccessException异常是Runtime的，无须显式捕捉。通过DataAccessException的子类包装原始异常信息，从而保证应用程序依然可以捕捉到原始异常信息。

### 管理Hibernate的SessionFactory

在实际开发中，我们直接以配置文件来管理SessionFactory实例。

```
<!-- 定义Hibernate的SessionFactory -->  
<bean id="sessionFactory" class="org.springframework.orm.hibernate3.LocalSessionFactoryBean">  
    <property name="dataSource" ref="dataSource"/>  
    <property name="mappingResources">  
        <list>  
            <value>xxx/Xxx.hbm.xml</value>  
        </list>  
    </property>  
    <property name="hibernateProperties">  
        <props>  
            <prop key="hibernate.dialect">org.hibernate.dialect.MySQLInnoDBDialect</prop>  
            <prop key="hibernate.hbm2ddl.auto">update</prop>  
        </props>  
    </property>  
</bean>  
```

### 使用HibernateTemplate

HibernateTemplate文档中的一句话：

NOTE: As of Hibernate 3.0.1, transactional Hibernate access code can also be coded in plain Hibernate style. Hence, for newly started projects,consider adopting the standard Hibernate3 style of coding data access objects instead, based on SessionFactory.getCurrentSession().(Spring's LocalSessionFactoryBean automatically supports Spring transaction management for the Hibernate3 getCurrentSession() method.)作者说：在新开始的工程，可以考虑用标准的Hibernate3的编码方式作为HibernateTemplate的替代。因为Hibernate3提供的SessionFactory.getCurrentSession()已经取代了以往那种每次操作都open一个新Session的方式，同时Spring的LocalSessionFactoryBean自动支持Hibernate3的getCurrentSession()的事务管理。也就是说，如果不用HibernateTemplate这咱Spring的专有API，而只用Hibernate3,我们一样可以受用Spring的事务管理。

```
puclic class PersonDaoImpl implements PersonDao {
    private HibernateTemplate ht = null;
    @Resource(name="sessionFactory")
    private SessionFactory sessionFactory;

    private HibernateTemplate getHibernateTemplate(){
        if(ht==null){
            ht = new HibernateTemplate(sessionFactory);
        }
        return ht;
    }
    public Person get(Integer id){
        return getHibernateTemplate().get(Person.class,id);
    }
    //....
}
```

常用方法
delete(Object entity)：删除指定持久化实例
deleteAll(Collection entities)：删除集合内全部持久化类实例
find(String queryString)：根据HQL查询字符串来返回实例集合  //from Person,返回Person的全部实例 ；select p.name,p.password from Person 则返回Object对象， select后要new select new Person（p.name,p.password）from Pserson p
findByNamedQuery(String queryName)：根据命名查询返回实例集合
get(Class entityClass, Serializable id)：根据主键加载特定持久化类的实例
save(Object entity)：保存新的实例
saveOrUpdate(Object entity)：根据实例状态，选择保存或者更新
update(Object entity)：更新实例的状态，要求entity是持久状态
setMaxResults(int maxResults)：设置分页的大小

### 使用HibernateCallback

弥补HibernateTemplate灵活性不足。HibernateTemplate还提供一种更加灵活的方式来操作数据库，通过这种方式可以完全使用Hibernate的操作方式。这种灵活方式主要是通过如下两个方法完成的：

```
Object execute(HibernateCallback action)  
List executeFind(HibernateCallback action)  
```

HibernateCallback是个接口，该接口包含一个方法doInHibernate(org.hibernate.Session session)，该方法只有一个参数Session。 

在doInHibernate方法内可访问Session，该Session对象是绑定到该线程的Session实例。在该方法内的持久层操作，与不使用Spring时的持久化操作完全相同。这保证了对于复杂的持久化层访问，依然可以使用Hibernate的访问方式。 

```
/**        
使用hql进行分页查询        
@param hql 需要查询的hql语句        
@param offset 第一条记录索引        
@param pageSize 当前需要显示的记录数        
@return 当前页的所有记录   */            
public List findByPage(final String hql, final int offset, final int pageSize){   
        //通过一个HibernateCallback对象来执行查询           
        List list = getHibernateTemplate().executeFind(   
                new HibernateCallback(){//实现HibernateCallback接口必须实现的方法   
                    public Object doInHibernate(Session session)throws HibernateException, SQLException{//执行Hibernate分页查询   
                        List result = session.createQuery(hql)   
                        .setFirstResult(offset)   
                        .setMaxResults(pageSize)   
                        .list();   
                        return result;   
                        }   
                    });   
        return list;          
}          
```
注意：Spring提供的XxxTemplate和XxxCallBack互为补充，XxxTemplate对通用操作进行封装，而XxxCallBack解决了封装后灵活性不足的缺陷。

### 实现DAO组件

为了实现DAO组件，Spring提供了大量的XxxDaoSupport类，这些DAO支持类对于实现DAO组件有很大的帮助，因为这些DAO支持类完成了大量基础性工作。 

Spring为Hibernate的DAO提供工具类：HibernateDaoSupport。该类主要提供如下两个方法来简化DAO的实现： 

* public final HibernateTemplate getHibernateTemplate() 
* public final void setSessionFactory(SessionFactory sessionFactory) 

在继承HibernateDaoSupport的DAO实现里，程序无须理会Hibernate的Session管理，Spring会根据实际的操作，采用“每次事务打开一次session”的策略，自动提高数据库访问的性能。 

```
public class MyHibernateDaoSupport extends HibernateDaoSupport implements IMyHibernateDaoSupport {  
      
    public void testDao(){  
        List list = getHibernateTemplate().find("from NewsInf");  
        System.out.println("list.size()="+list.size());  
    }  
}  
```

```
<bean id="myHibernateDaoSupport" class="com.dao.impl.MyHibernateDaoSupport">
        <property name="hibernateTemplate" ref="hibernateTemplate"></property>
</bean>  
```
### 使用IoC容器组装各种组件

至此为止，J2EE应用所需要的各种组件都已经出现了，从MVC层的控制器组件，到业务逻辑组件，以及持久层的DAO组件，已经全部成功实现。应用程序代码并未将这些组件耦合在一起，代码中都是面向接口编程，因此必须利用Spring的IoC容器将他们组合在一起。

从用户角度来看，用户发出HTTP请求，当MVC框架的控制器组件拦截到用户请求时，将调用系统的业务逻辑组件，而业务逻辑组件则调用系统的DAO组件，而DAO组件则依赖于SessionFactory和DataSource等底层组件实现数据库访问。

从系统实现角度来看，IoC容器先创建SessionFactory和DataSource等底层组件，然后将这些底层组件注入给DAO组件，提供一个完整的DAO组件，并将此DAO组件注入给业务逻辑组件，从而提供一个完整的业务逻辑组件，而业务逻辑组件又被注入给控制器组件，控制器组件负责拦截用户请求，并将处理结果呈现给用户——这一系列的衔接都由Spring的IoC容器提供实现。

下面给出关于如何在容器中配置J2EE组件的大致模板，其模板代码如下：
```
<?xml version="1.0" encoding="GBK"?>
<!-- beans是Spring配置文件的根元素，并且指定了Schema信息 -->
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">
    <!-- 定义数据源Bean，使用C3P0数据源实现 -->
    <bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource"
    destroy-method="close">
        <!-- 指定连接数据库的驱动 -->
        <property name="driverClass" value="com.mysql.jdbc.Driver"/>
        <!-- 指定连接数据库的URL -->
        <property name="jdbcUrl" value="jdbc:mysql://localhost/j2ee"/>
        <!-- 指定连接数据库的用户名 -->
        <property name="user" value="root"/>
        <!-- 指定连接数据库的密码 -->
        <property name="password" value="32147"/>
        <!-- 指定连接数据库连接池的最大连接数 -->
        <property name="maxPoolSize" value="40"/>
        <!-- 指定连接数据库连接池的最小连接数 -->
        <property name="minPoolSize" value="1"/>
        <!-- 指定连接数据库连接池的初始化连接数 -->
        <property name="initialPoolSize" value="1"/>
        <!-- 指定连接数据库连接池的连接最大空闲时间 -->
 <property name="maxIdleTime" value="20"/>
    </bean>
    <!-- 定义Hibernate的SessionFactory Bean -->
    <bean id="sessionFactory" class="org.springframework.orm.hibernate3. 
    LocalSessionFactoryBean">
        <!-- 依赖注入数据源，注入的正是上文中定义的dataSource -->
        <property name="dataSource" ref="dataSource"/>
        <!-- mappingResources属性用来列出全部映射文件 -->
        <property name="mappingResources">
            <list>
                <!-- 以下用来列出所有的PO映射文件 -->
                <value>lee/Person.hbm.xml</value>
                <!-- 此处还可列出更多的PO映射文件 -->
            </list>
        </property>
          <!-- 定义Hibernate的SessionFactory属性 -->
        <property name="hibernateProperties">
             <props>
                <!-- 指定Hibernate的连接方言 -->
                <prop key="hibernate.dialect">org.hibernate.dialect. 
                MySQLDialect</prop>
                <!-- 指定启动应用时，是否根据Hibernate映射文件创建数据表 -->
                  <prop key="hibernate.hbm2ddl.auto">update</prop>
             </props>
        </property>
    </bean>
    <!-- 配置Person持久化类的DAO Bean -->
    <bean id="personDao" class="lee.PersonDaoImpl">
        <!-- 采用依赖注入来传入SessionFactory的引用 -->
        <property name="sessionFactory" ref="sessionFactory"/>
    </bean>
    <!-- 下面能以相同的方式配置更多的持久化Bean -->
    ...
    <bean id="myService" class="lee.MyServiceImp">
        <!-- 注入业务逻辑组件所必需的DAO组件 -->
        <property name="peronDdao" ref=" personDao "/>
        <!-- 此处可采用依赖注入更多的DAO组件 -->
        ...
    </bean>
    <!-- 配置控制器Bean，设置起作用域为Request -->
    <bean name="/login" class="lee.LoginAction" scope="request">
        <!-- 依赖注入控制器所必需的业务逻辑组件 -->
        <property name="myService" ref=" myService "/>
    </bean>
</beans>
```
在上面的配置文件中，同时配置了控制器Bean、业务逻辑组件Bean、DAO组件Bean以及一些基础资源Bean。各组件的组织被解耦到配置文件中，而不是在代码层次的低级耦合。
当客户端的HTTP请求向/login.do发送请求时，将被容器中的lee.LoginAction拦截，LoginAction调用myService Bean，myService Bean则调用personDao等系列DAO组件，整个流程将系统中的各组件有机地组织在一起。

注意：在实际应用中，很少会将DAO组件、业务逻辑组件以及控制组件都配置在同一个文件中。而是在不同配置文件中，配置相同一组J2EE应用组件。

### 使用声明式事务

* 针对不同的事务策略配置对应的事务管理器 
    {% codeblock %}
    <bean id="txManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
    <property name="dataSource" ref="dataSource"/>
    </bean>
    {% endcodeblock %}
* 使用`<tx:advice>`元素配置事务增强处理Bean，配置事务增强处理Bean时使用多个`<method../>`子元素为不同方法指定相应的事务语义
* 在`<aop:config../>`子元素中使用`<aop:advisor../>`元素配置自动事务代理
    {% codeblock %}
    <tx:advice id="txAdvice" transaction-manager="txManager">
        <tx:attributes>
            <tx:method name="get*" read-only="true" propagation="NOT_SUPPORTED"/>
            <tx:method name="save*"/>
        </tx:attributes>
    </tx:advice>
    
    <aop:config>
        <aop:pointcut
                expression="execution(* org.flyne.service.impl.*.*(..))"
                id="perform"/>
        <aop:advisor advice-ref="txAdvice" pointcut-ref="perform"/>
    </aop:config>
    {% endcodeblock %}
