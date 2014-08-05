title: 代码整洁之道(一)
date: 2014-06-10 17:16:24
tags:
- Clean Code
categories:
- 编程
description: Clean Code, 代码整洁之道
---

## 有意义的命名

### 名副其实
    
变量、函数或类名称应该告诉人们，它为什么会存在，它做什么事，应该怎么用。如以日计的消逝的时间可以命名为elapsedTimeInDays。

<!-- more -->
### 避免误导
    
1. 避免使用专有的计算机术语缩写做变量名，如hp,aix,sco
2. 不要在名称中直接写出容器类型名，如accountList可以用accountGroup,bunchOfAccounts,accounts来代替。
3. 避免使用不同之处较小的名称， XYZControllerForEfficientHandlingOfStringsin和XYZControllerForEfficientStorageOfStrings如果出现在一起，区分需要一定的时间。
4. 避免单独使用小写字母l和大写字母O做变量名。

### 做有意义区分

避免使用数字系列(如变量名a1,a2,a3)或废话(如Product,ProductInfo,ProductData是没有意义的区分，因为意思相近，避免废话就是避免变量名中出现冗余)。

### 使用读得出来的名称

使用读得出的名称，便于讨论，如变量genymdhms(生成日期，年月日时分秒)，可以命名为generationTimestamp

### 使用可搜索的名称

使用常变量代替数字常量，如用WORK_DAYS_PER_WEEK代替5；避免使用单字母变量名。数字常量和单字母变量都是不便于搜索的，比如e，或者5在每个程序、每个代码段都有可能出现。

单字母名称仅用于短方法中的本地变量，名称长短应与其作用域大小相对应。若变量或常量可能在代码中多处使用，则应赋予便于搜索的名称。

### 避免使用编码

没有必要在名称中加入类型(匈牙利命名法)或作用域(m_前缀标识成员变量)。接口没有必要加前导字母I。增加了修改变量、函数名或类名的难度。

### 避免思维映射

不应该让读者在脑中把你的名称翻译成他们熟知的名称。这种问题经常出现在选择是使用问题领域术语还是解决方案领域术语时。

一般只有程序员才会读你写的代码，所以尽管使用解决方案领域名称，当不能使用程序员熟悉的术语来给手头的工作命名，就采用所涉及的问题领域的名称，与所涉及问题领域更为贴近的代码，应当使用问题领域名称。

### 类名、方法名

类名应该是名词或名词短语，避免使用Manager、Processor、Data或Info这样的类名。

方法名应当是动词或动词短语。属性访问器，修改器和断言应根据其值命名，并加上get、set、is前缀。

重载构造器时，使用描述了参数的静态工厂方法名Complex fulcrumPoint = Complex.FromRealNumber(23,0)好于Complex fulcrumPoint = new Complex(23,0)

### 每个概念对应一个词

给每个抽象概念选一个词，并一以贯之。如使用fetch、retrieve和get来给在多个类中的同种方法命名。在一堆代码中有controller，又有manager，还有driver，就会令人困惑，它们之间有什么根本区别。

### 别用双关语

避免代码中一词多义。如多个类中有add方法，该方法通过加或连接两个值返回新值，在集合类中也有add方法，是向集合中添加元素，这样add方法就有了两个语义。在集合中就应该使用insert或append之类词来命名了。

### 添加有意义的语境

用良好命名的类、函数或命名空间来放置名称，来提供语境，否则就需要添加前缀来添加语境了。

假设有名为firstName,lastName,street,houseNumber,city,state, zipcode 的变量，他们在一起很明确能够成地址，可以放在一个Address类中。如果不这样，只能通过加前缀addrFirstName、addrLastName...添加语境。

### 不添加无意义的语境

如果有一个名为"加油站豪华版"(Gas Station Deluxe)的应用，在每个类加GSD前缀就不好了。现在的IDE都有自动提示功能，输入G会出现全部类的列表。

## 函数

### 短小

函数的第一条规则是短小，第二条规则还是短小。每行避免超过150个字符，避免超过20行。

if、else、while语句等，其中的代码块应该只有一行。该行应该是一个函数调用。

### 只做一件事

函数应该做一件事，做好一件事，只做这一件事。

如果函数只是做了该函数名下同一抽象层上的步骤，则函数还是只做了一件事。

要判断函数是否不止做了一件事，还有一个方法，就是看是否能再拆除一个函数，该函数不仅只是单纯地重新诠释其实现。

如果函数中包含了太多区段，这个函数就需要拆开了。

### 每个函数一个抽象层级

要确保函数只做一件事，函数中的语句都要在同一抽象层级上。getHtml()等位于较高抽象层的概念，String pagePathName = PathParse.render(pagePath) 等位于中间抽象层的概念，.append("\n")等位于相当低的抽象层的概念。

自顶向下读代码：向下规则

每个函数后面都跟着位于下一抽象层级的函数，这样一来，在查看函数列表时，就能循抽象层级向下阅读了。

### switch语句

```java
public Money calculatePay(Employee e) throws InvalidEmployeeType {
    switch (e.type) {
        case COMMISSIONED:
            return calculateCommissionedPay(e);
        case HOURLY:
            return calculateHourlyPay(e);
        case SALARIED:
            return calculateSalariedPay(e);
        default:
            throw new InvalidEmployeeType(e.type);
    }
}
```

上面函数有好几个问题。首先，太长，出现新雇员类型的话还会变的更长。其次，明显做了不止一件事。第三，违反了单一权责原则(只有一项职责，换言之，只有一个动机才会去修改已经写好的代码)，因为有好几个修改它的理由，第四，违反了开放闭合原则(软件实体应该是可扩展，而不可修改的。也就是说，对扩展是开放的，而对修改是封闭的。)，因为每当添加新类型时，就必须修改代码。

该问题的解决方案是将switch语句埋到抽象工厂底下，该工厂使用switch语句为Employee的派生物创建适当的实体，而不同的函数，如calculatePay, isPayday, deliverPay等，则由Employee 接口多态的接受派遣。

对于switch，如果只出现一次，用于创建多态对象，而且隐藏在继承关系中，在系统其它部分看不到。

```
public abstract class Employee {
    public abstract boolean isPayday();
    public abstract Money calculatePay();
    public abstract void deliverPay(Money pay);
}
public interface EmployeeFactory {
    public Employee makeEmployee(EmployeeRecord r) throws InvalidEmployeeType;
}
public class EmployeeFactoryImpl implements EmployeeFactory {
    public Employee makeEmployee(EmployeeRecord r) throws InvalidEmployeeType {
        switch (r.type) {
            case COMMISSIONED:
                return new CommissionedEmployee(r) ;
            case HOURLY:
                return new HourlyEmployee(r);
            case SALARIED:
                return new SalariedEmploye(r);
            default:
                throw new InvalidEmployeeType(r.type);
        }
    }
}
```

### 使用描述性的名称

如isTestable 或 includeSetupAndTeardownPages。长而具有描述性的名称，要比描述性的长注释好。函数名应该使用一些容易阅读的单词能描述清楚其功能。

命名方式要保持一直，使用与模块名一脉相承的短语、名词和动词给函数命名。例如includeSetupAndTeardownPages、includeSetupPages、includeSuiteSetupPage和includeSetupPage等。

### 函数参数

没有参数好于一个参数，一个参数好于两个参数，连个参数好于三个参数，应尽量避免三个以上参数。

参数与函数名出于不同的抽象层级，它要求你了解目前并不特别重要的细节；测试的话还需要确保参数的各种组合都有运行正常的测试用例，这很困难。

#### 一元函数的普遍形式

- 传入参数，将其转换为其它什么，然后输出
- 传入参数，改变系统状态。事件。

#### 标识参数

向函数传入布尔值，相当于宣布本函数不止做一件事。如render(Boolean isSuite)应该把函数一分为二：renderForSuite()和renderForSingleTest()

#### 二元函数

writeField(name) 比 writeField(outputStream,name)好懂。应该尽量将二元转为一元，可以把writeFiled方法写入成outputStream的成员之一。从而能这样用：outputStream.writeField(name)。或者，也可以把outputStream写成当前类的成员变量，从而无需再传递它。还可以分离出类似FieldWriter 的新类，在其构造器中采用outputStream，并且包含write方法。

一般二元函数的参数应该是自然的组合(如new Point(0,0))或自然的排序

#### 参数对象

如果函数看来需要两个、三个或三个以上参数，就说明其中一些参数应该封装成类了。
如:
```
Circle makeCircle(double x, double y, double radius);
Circle makeCircle(Point center, double radius);
```

#### 参数列表

如果可变参数和类型为List的单个参数没什么区别，String.format可以当二元函数。
public String format(String format, Object...args)

#### 动词和关键字

选择合适动词\名词为函数和参数命名，如write(name)，即"write" 一个 "name"。如果改为writeField(name)，则进一步表明"name"是一个"field"

assertEqual(expected,actual)比assertExpectedEqualsActual(expected,actual)要好。

### 无副作用

```
public class UserValidator {
    private Cryptographer cryptographer;
    public boolean checkPassword(String userName, String password) {
        User user = UserGateway.findByName(userName);
        if (user != User.NULL) {
            String codedPhrase = user.getPhraseEncodedByPassword();
            String phrase = cryptographer.decrypt(codedPhrase, password);
            if ("Valid Password".equals(phrase)) {
                Session.initialize();
                return true;
            }
        }
        return false;
    }
}
```
上面的代码不仅验证了密码而且还初始化了会话。而函数名并没有暗示会初始化会话。只有在初始化会话安全的时候调用该函数才是安全的，可以将函数重命名为checkPasswordAndInitializeSession，虽然还是违反了只做一件事。

避免使用输出参数，如果函数必须修改某种状态，就修改所属对象的状态吧。

### 分隔指令和询问

函数要么做什么事，要么回答什么事，二者不可得兼。考虑：
public boolean set（String attribute, String value)
此函数设置一个属性值，成功返回true，否则返回false
if(set("username","bob"))
如果读者不清楚，会以为是在问username属性是否之前已设置为bob。或username属性是否已成功设置为bob。
if(attributeExists("username")){
    setAttribute("username","bob")
}

### 使用异常代替返回错误码

使用返回错误码轻微违反了分隔指令和询问原则。使用异常，错误处理代码也能从主路径代码中分离出来。
```
if (deletePage(page) == E_OK) {
    if (registry.deleteReference(page.name) == E_OK) {
        if (configKeys.deleteKey(page.name.makeKey()) == E_OK){
            logger.log("page deleted");
        } else {
            logger.log("configKey not deleted");
        }
    } else {
        logger.log("deleteReference from registry failed");
    }
} else {
    logger.log("delete failed");
    return E_ERROR;
}
//下面使用try catch
try {
    deletePage(page);
    registry.deleteReference(page.name);
    configKeys.deleteKey(page.name.makeKey());
}
catch (Exception e) {
    logger.log(e.getMessage());
}
```

#### 抽离try catch代码块

最好把try catch代码块的主体部分抽离出来，另外形成函数。
```
public void delete(Page page) {
    try {
        deletePageAndAllReferences(page);
    }
    catch (Exception e) {
        logError(e);
    }
}
private void deletePageAndAllReferences(Page page) throws Exception {
    deletePage(page);
    registry.deleteReference(page.name);
    configKeys.deleteKey(page.name.makeKey());
}
private void logError(Exception e) {
    logger.log(e.getMessage());
}
```
delete函数只与错误处理有关。deletePageAndAllReference函数只与完全删除一个page有关。

#### 错误处理就是一件事

函数只做一件事，处理错误的函数不应该再做其他事，这就意味着如果含有try关键字，则try应该为函数的第一个单词。

#### Error.java依赖磁铁

返回错误码意味着某处有类或枚举定义了所有错误码。那么其它地方都要引用这个文件。如果Error.java修改，其它文件可能也要修改。

### 别重复自己

消除函数中的重复的代码。

## 注释

能用代码表达的，尽量不要用注释表达。因为代码总会变，但是有时注释并不是总随着代码改变，程序员都很懒的，更新代码但是不去更新注释，错误的注释比不加注释更加可怕。

应该保证注释可维护，有关联，精确。

### 用代码来阐述

```
// Check to see if the employee is eligible for full benefits
if ((employee.flags & HOURLY_FLAG) && (employee.age > 65)) 
```
尽量用代码来描述意图，而不是注释。
```
if (employee.isEligibleForFullBenefits())
```

### 好注释

#### 法律信息

比如版权及著作权声明就要放在每个源文件开头。这类注释不应该是整个合同或者法典，而应该指向一份外部文档。

#### 提供信息的注释

有时提供基本信息也是有用的。
```
// format matched kk:mm:ss EEE, MMM dd, yyyy
Pattern timeMatcher = Pattern.compile("\\d*:\\d*:\\d* \\w*, \\w* \\d*, \\d*");
```
上述代码，解释了正则表达式的用意。但是如果把代码转移到转换日期和时间格式的类中，此处的注释可能就多此一举了。

#### 对意图的解释

注释不仅提供有关实现的有用价值，而且还提供了某个决定后面的意图。

```
public int compareTo(Object o)
{
    if(o instanceof WikiPagePath)
    {
        WikiPagePath p = (WikiPagePath) o;
        String compressedName = StringUtil.join(names, "");
        String compressedArgumentName = StringUtil.join(p.names, "");
        return compressedName.compareTo(compressedArgumentName);
    }
    return 1; // we are greater because we are the right type.
}
```
作者在对比两个对象时将他的类放置在比其他类更高的位置。

#### 阐释

有时注释把某些晦涩难懂的参数或返回值的意义翻译为某种可读形式。
```
assertTrue(a.compareTo(a) == 0); // a == a
assertTrue(a.compareTo(b) != 0); // a != b
assertTrue(a.compareTo(b) == -1); // a < b
assertTrue(b.compareTo(a) == 1); // b > a
```
#### 警告

用于警告其他程序员代码运行或代码不这样实现会出现某种后果的注释。

#### TODO注释

提醒某个删除某个不必要的特性，或要求别人注意某个问题，或提示对依赖于某个计划事件的修改。

#### 放大

注释可以用来放大某种看来不合理之物的重要性

#### 公共API中的Javadoc

编写良好的公共API

### 坏注释

#### 喃喃自语

如果只是因为自己觉得应该或因过程需要就添加注释，这类注释就是无用的。任何迫使读者查看其它模块的注释都是失败的。

#### 多余的注释

如果添加代码只是叫人话更多时间去读，而没有提供有用信息，没有提供代码的意义或没有给出代码的意图或逻辑，这样的注释一般是多余。

#### 误导性注释

```
// Utility method that returns when this.closed is true. Throws an exception
// if the timeout is reached.
public synchronized void waitForClose(final long timeoutMillis) throws Exception
{
    if(!closed)
    {
        wait(timeoutMillis);
        if(!closed)
            throw new Exception("MockResponseSender could not be closed");
    }
}
```
调用上述代码，在this.closed变为true时并不立即返回。方法只是在判断this.closed为true时才返回。

#### 循规式注释

要求每个变量，每个方法都必须有注释是没有必要的。

#### 日志式注释

现在使用版本控制系统，没有必要在代码中添加每次修改代码的记录。

#### 废话注释

下面的注释就是废话
```
/**
* Returns the day of the month.
*
* @return the day of the month.
*/
public int getDayOfMonth() {
return dayOfMonth;
}
```

#### 能用函数或变量时就别用注释

```
// does the module from the global list <mod> depend on the
// subsystem we are part of?
if (smodule.getDependSubsystems().contains(subSysMod.getSubSystem()))
```
可以修改成下面的代码
```
ArrayList moduleDependees = smodule.getDependSubsystems();
String ourSubSystem = subSysMod.getSubSystem();
if (moduleDependees.contains(ourSubSystem))
```

#### 位置标记

把特定函数放在下面的标记下
```
//actions///////////////////
```
尽量少用这种标记栏，如果使用太多，就会被读者直接忽视。

#### 括号后面注释

```
while(){
}//while 
```
如果这样做了，说明函数可能需要缩短了。

#### 归属与署名

```
//added bi rick
```
版本控制系统可以记录是谁何时修改代码。

#### 注释掉代码

版本控制工具可以恢复删掉的代码。所以不要注释代码。

#### HTML注释

不要在注释中加HTML标签，影响阅读，这样的标签本应该是由抽取注释的工具生成的。

#### 非本地信息

确保注释描述了离它最近的代码。
```
/**
* Port on which fitnesse would run. Defaults to <b>8082</b>.
*
* @param fitnessePort
*/
public void setFitnessePort(int fitnessePort)
{
this.fitnessePort = fitnessePort;
}
```

上面代码中并没有注释中给出的默认端口号的相关部分。

#### 信息过多

别在注释中添加有趣的历史性话题或无关的细节描述。

#### 不明显的联系

注释及其描述的代码之间的联系应该显而易见。

```
/*
* start with an array that is big enough to hold all the pixels
* (plus filter bytes), and an extra 200 bytes for header info
*/
this.pngBytes = new byte[((this.width + 1) * this.height * 3) + 200];
```
过滤器字节是什么？与+1还是+3有关？为什么要用200？注释的作用是解释未能自行解释的代码，显然这里没有。

#### 函数头

短函数不需要太多描述。为短函数选个好名字就好了。

#### 非公共代码中的API

如果没有打算做公共API代码，就没有必要使用javadoc了。

## 格式

### 垂直格式

尽量使用短文件，代码行数一般在200行左右，最长控制在500行。

#### 向报纸学习

源文件应该向报纸文章那样，名称应当简单且一目了然。名称本身应该足够告诉我们是否在正确的模块中。源文件最顶部应该给出高层次概念和算法。细节应该往下渐次展开，直至找到源文件中最底层的函数和细节。

#### 概念间垂直方向上的区隔

所有代码都是从上往下读，从左往右读。每行展现一个表达式或一个句子。每组代码行展示一条完整的思路。这些思路应该使用空白行区隔开。

封包声明，导入包声明和每个函数之间都应该有空白行隔开。

#### 垂直方向上的靠近

紧密相关的代码应该互相靠近。

#### 垂直距离

- 变量声明

    变量声明应尽可能靠近其使用位置。因为函数很短，本地变量应该在函数顶部出现。

    循环中的控制变量(`for(Test each:tests)`each即控制变量)。

    在较长的函数中，变量也可能在某个代码块顶部，或在循环之前声明。

- 实体变量(类的内部变量)

    应该在类顶部声明。

- 相关函数

    若某个函数调用了另外一个，就应该把他们放到一起，而且调用者应该尽可能放在被调用者上面。这样可以增强代码可读性。

- 概念相关

    概念相关的代码应该放在一起。相关性越强，彼此之间的距离就应该越短。

#### 垂直顺序

被调用函数应该放在执行调用的函数下面。最重要的概念应该先出来，并以包括最少细节的方式表述。底层细节应该最后出现。

### 横向格式

一行字符应该最多不超120个

#### 水平方向上的区隔和靠近

可以通过空格字符将彼此紧密相关的事物连接在一起(表强调)，也用空格字符把相关性较弱的事物分隔开

赋值操作符两边加操作符，达到强调目的。不要在函数名和括号间加空格，因为函数和参数关系密切。

空格的另一种用法是强调其前面的运算符。

#### 水平对齐

不使用对齐。

#### 缩进

类声明不缩进，类中方法相对类声明缩进一个层级。方法的实现相对方法声明缩进一个层级。代码块的实现相对于其容器代码块缩进一个层级。

#### 空范围

while或for语句体为空时，确保空范围体的缩进，用括号包围起来。把分号放在循环语句后很难让人分辨。

### 团队规则

如果在一个团队，就使用团队规则。
