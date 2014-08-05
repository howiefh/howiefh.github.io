title: 代码整洁之道(二)
date: 2014-06-15 23:08:00
tags:
- Clean Code
categories:
- 编程
description: Clean Code, 代码整洁之道
---

## 对象和数据结构

### 数据抽象

隐藏实现并非只是在变量之间放上一个函数层那么简单。隐藏实现关乎抽象！类并不简单地用取值器或赋值器将其变量推向外界，而是暴露抽象接口，以便用户无需了解数据的实现就能操作数据本体。
<!-- more -->

```java
public interface Vehicle {
    double getFuelTankCapacityInGallons();
    double getGallonsOfGasoline();
}
```
```java
public interface Vehicle {
    double getPercentFuelRemaining();
}
```
上面代码可以确定前者里面都是些变量存取器，而却无法得知后者中的数据形态。

### 数据、对象的反对称性

对象与数据结构之间的二分原理：
过程式代码(使用数据结构的代码)便于在不改动既有数据结构的前提下添加新函数。面向对象代码便于在不改动既有函数的前提下添加新类。

反过来讲，过程式代码难以添加新数据结构，因为必须修改所有函数。面向对象代码难以添加新函数，因为必须修改所有类。

过程式代码
```java
public class Square {
    public Point topLeft;
    public double side;
}
public class Rectangle {
    public Point topLeft;
    public double height;
    public double width;
}
public class Circle {
    public Point center;
    public double radius;
}
public class Geometry {
    public final double PI = 3.141592653589793;
    public double area(Object shape) throws NoSuchShapeException 
    {
        if (shape instanceof Square) {
            Square s = (Square)shape;
            return s.side * s.side;
        }
        else if (shape instanceof Rectangle) {
            Rectangle r = (Rectangle)shape;
            return r.height * r.width;
        }
        else if (shape instanceof Circle) {
            Circle c = (Circle)shape;
            return PI * c.radius * c.radius;
        }
        throw new NoSuchShapeException();
    }
}
```
多态式形状代码
```java
public class Square implements Shape {
    private Point topLeft;
    private double side;
    public double area() {
        return side*side;
    }
}
public class Rectangle implements Shape {
    private Point topLeft;
    private double height;
    private double width;
    public double area() {
        return height * width;
    }
}
public class Circle implements Shape {
    private Point center;
    private double radius;
    public final double PI = 3.141592653589793;
    public double area() {
        return PI * radius * radius;
    }
}
```
如果需要添加新数据类型而不是新函数的时候。对象和面向对象就比较合适。需要添加新函数而不是数据类型的时候，过程式代码和数据结构更合适。

### 得墨忒耳律

对象应该隐藏数据，暴露操作。类C的方法f只应该调用以下对象的方法

- C
- 由f创建的对象
- 作为参数传递给f的对象
- 由C的实体变量持有的对象

方法不应调用由任何函数返回的对象的方法；下列代码违反了得墨忒耳律：
```java
final String outputDir = ctxt.getOptions().getStratchDir().getAbsolutePath()
```

#### 火车失事

上面的代码看上去像是一列火车。这样的代码应该避免。
```java
Options opts = ctxt.getOptions();
File scratchDir = opts.getScratchDir();
final String outputDir = scratchDir.getAbsolutePath();
```

如果ctxt, Options, ScratchDir 只是数据结构，没有任何操作，得墨忒耳律就不适用了。
```java
final String outputDir = ctxt.options.scratchDir.absolutePath;
```

#### 混杂

避免创造混合的结构，一半是对象，一半是数据结构。

#### 隐藏结构

通过隐藏内部结构，避免违反得墨忒耳律。

### 数据传送对象

最为精炼的数据结构，是一个只有公共变量、没有函数的类。这种数据结构有时被称为数据传送对象，或DTO(Data Transfer Objects)。DTO是非常有用的结构，尤其是在与数据库通信，或解析套接字传递的消息之类场景中。在应用程序代码里一系列将原始数据转换为数据库的翻译过程，它们往往是排头兵。

Active Record 是一种特殊的DTO 形式。他是拥有公共变量的数据结构，但通常会拥有save和find这样的可浏览方法。一般是对数据库表或其他数据源的直接翻译。

## 错误处理

### 使用异常而非返回码

### 先写Try-Catch-Finally语句

某种意义上说，try代码块就像是事务，catch代码块将程序维持在一种持续状态，无论try代码块发生什么均如此。最好先写出try-catch-finally 语句。这能帮你定义代码的用户应该期待什么，无论try代码块中执行的代码出什么错都一样。

### 使用不可控异常

可控异常：每个方法的签名都要列出它可能传递给调用者的所有异常。并且这些异常是函数类型的一部分，如果签名与代码所做的实际之事不合，则不能通过编译。可控异常不好的地方就是你对一个异常要层层声明，会破坏开放封闭原则。

### 给出异常发生的环境说明

应创建信息充分的错误消息，消息中，包括失败的操作和失败类型。

### 依调用者需要定义异常类

依据来源分类(组件或其他)或依据类型分类(设备、网络、编程)，最重要的是考虑它们如何被捕获。

```
ACMEPort port = new ACMEPort(12);
try {
    port.open();
} catch (DeviceResponseException e) {
    reportPortError(e);
    logger.log("Device response exception", e);
} catch (ATM1212UnlockedException e) {
    reportPortError(e);
    logger.log("Unlock exception", e);
} catch (GMXError e) {
    reportPortError(e);
    logger.log("Device response exception");
} finally {
    …
}
```
上面例子中有很多重复代码。可以通过打包来避免。事实上，对第三方的API打包是个良好习惯，这样可以降低对它的依赖，未来可以轻松地改用其他代码库。

```java
LocalPort port = new LocalPort(12);
try {
    port.open();
} catch (PortDeviceFailure e) {
    reportError(e);
    logger.log(e.getMessage(), e);
} finally {
    …
}

public class LocalPort {
    private ACMEPort innerPort;
    public LocalPort(int portNumber) {
        innerPort = new ACMEPort(portNumber);
    }
    public void open() {
        try {
            innerPort.open();
        } catch (DeviceResponseException e) {
            throw new PortDeviceFailure(e);
        } catch (ATM1212UnlockedException e) {
            throw new PortDeviceFailure(e);
        } catch (GMXError e) {
            109 Define the Normal Flow
                throw new PortDeviceFailure(e);
        }
    }
    …
}
```

### 定义常规流程

```java
try {
    MealExpenses expenses = expenseReportDAO.getMeals(employee.getID());
    m_total += expenses.getTotal();
} catch(MealExpensesNotFound e) {
    m_total += getMealPerDiem();
}
```
如果消耗事物就计入总额，如果没有，则员工得到补贴。但是使用异常打断了业务逻辑。

通过修改 ExpensereportDao 类，使方法getMeals()总返回MealExpense对象。如果没有消耗餐食，就返回一个餐食补贴的MealExpense对象。下面代码使用特例模式(创建一个类或配置一个对象来处理特例)。创建 PerDiemmealExpenses 类。
```java
MealExpenses expenses = expenseReportDAO.getMeals(employee.getID());
m_total += expenses.getTotal();

public class PerDiemMealExpenses implements MealExpenses {
    public int getTotal() {
        // return the per diem default
    }
}
```

### 别返回null值

```
List<Employee> employees = getEmployees();
if (employees != null) {
    for(Employee e : employees) {
        totalPay += e.getPay();
    }
}
```

避免返回null。对于上例可以返回空列表。
```
List<Employee> employees = getEmployees();
for(Employee e : employees) {
    totalPay += e.getPay();
}
public List<Employee> getEmployees() {
    if( .. there are no employees .. ) 
        return Collections.emptyList();
}
```

### 别传递null值

```java
public class MetricsCalculator 
{
    public double xProjection(Point p1, Point p2) {
        if (p1 == null || p2 == null) {
            throw InvalidArgumentException(
                    "Invalid argument for MetricsCalculator.xProjection");
        }
        return (p2.x – p1.x) * 1.5;
    }
}

public class MetricsCalculator 
{
    public double xProjection(Point p1, Point p2) {
        assert p1 != null : "p1 should not be null";
        assert p2 != null : "p2 should not be null";
        return (p2.x – p1.x) * 1.5;
    }
}
```
通过异常和断言可以检测参数为null。对于断言，会得到运行时错误。恰当的方法是禁止传入null值。

## 边界

### 使用第三方代码

第三方代码与我们的代码，这是一种边界。学会封装第三方代码。

### 浏览和学习边界

通过编写测试来遍览和理解第三方代码，即进行学习性测试。

### 学习log4j

### 学习性测试的好处不只是免费

当第三方代码更新时，可以通过学习性测试修改与测试不兼容。

### 使用尚不存在的代码

还有一种边界，那种把已知和未知分隔开的边界。有时候接口还没有定义，但是我们可从离未知部分很远处开始工作。

## 单元测试

### TDD三定律

1. 在编写不能通过的单元测试前，不可编写生产代码
2. 只可编写刚好无法通过的单元测试，不能编译也算不通过
3. 只可编写刚好足以通过当前失败测试的生产代码

### 保持测试整洁

### 整洁的测试

整洁的测试应该具有可读性。

"构造-操作-检验"模式，测试被分为三个环节。第一个环节构造测试数据，第二个环节操作测试数据，第三个环节检验操作是否得到预期的结果。

#### 面向特定领域的测试语言

包装API，构造特定领域的语言，便于阅读。

#### 双重标准

测试环境和生产环境采用不同的标准。

### 每个测试一个断言

**每个测试一个概念** ，一个测试中制作一件事。

### F.I.R.S.T

- 快速(Fast) 测试能够快速运行。
- 独立(Independent) 测试应该相互独立。
- 可重用(Repeatable) 测试应当可在任何环境中重复通过。
- 自足验证(Self-Validating) 测试应该有布尔值输出。
- 及时(Timely) 测试应该及时编写。

## 类

### 类的组织

先是公共静态变量，然后私有静态变量，跟着是私有实体变量，很少会有公共变量。公共函数出现在变量列表之后，被公共函数调用的私有工具函数紧跟公共函数后。

**封装**保持变量和工具函数的私有性，有时为了测试能够访问到，需要受保护的变量和工具函数。

### 类应该短小

根据类的权责来衡量长短，类的权责过多，类的长度就可能过长。

#### 单一权责原则

单一权责原则(SRP)，类或模块应有且只有一条加以修改的理由。类只应有一个权责--只有一条修改的理由。

#### 内聚

一个类中每个变量都被每个方法所使用，则该类具有最大的内聚性。

一般希望类有较高内聚性，保持函数和参数列表短小会使实体变量增多，这时需要将原有类拆分，使新类更为内聚。

#### 保持内聚性就会得到许多短小的类

### 为了修改而组织

通过扩展系统而不是修改现有代码来添加新特性。按照开放-闭合原则重新架构原有代码，在对原有代码重新拆分组织的时候，也使其同时满足单一权责原则。

**隔离修改** 依赖倒置原则(Dependency Inversion Principle, DIP)。类应当依赖于抽象而不是依赖于具体细节，使用抽象类和接口。

依赖于具体细节的客户类，当细节改变时，就会有风险。可以借助接口和抽象类来隔离这些细节带来的影响。

## 系统

### 将系统的构造与使用分开

软件系统应将起始过程和启动过程之后的运行时逻辑分离开，在起始过程中构建应用对象，也会存在互相缠结的依赖关系。

#### 分解main

将构造过程搬迁到main

#### 工厂

使用抽象工厂模式

#### 依赖注入

控制反转(Inversion of Control, IoC)的一种手段，另一种是依赖查找。Spring框架

### 扩容

“一开始就作对系统”纯属神话。我们应该只去实现今天的用户故事，然后重构，明天再扩展系统，实现新的用户故事

软件系统和物理系统可以类比，它们的架构都可以递增式的增长，只要我们持续将关注面恰当的切分

- 横贯式关注面
- 面向方面编程

### Java 代理

### 纯 Java AOP 框架

### AspectJ 的方面

### 测试驱动系统框架

### 优化决策

### 明智使用添加了可论价值的标准

### 系统需要领域特定语言

领域特定语言允许所有抽象层级和应用程序中的所有领域，从高级策略到底层细节，使用POJO(Plain Old Java Object, 简单的Java对象)来表达。

## 迭进 

### 通过跌进设计达到整洁目的

简单设计四条规则：

- 运行所有测试
- 不可重复
- 表达了程序员的意图
- 尽可能减少类和方法的数量

### 运行所有测试

全面测试并通过所有测试的系统，就是可测试的系统。测试越多，就越能使代码遵循DIP，SRP原则。通过依赖注入，接口和抽象等工具可以尽可能减少耦合。

### 重构

在重构过程中，可以应用有关优秀软件设计的一切知识。提升内聚性，降低耦合度，切分关注面，模块化系统性关注面，缩小函数和类的尺寸，选用更好的名称，如此等等。

### 不可重复

消除重复代码。模板方法模式是一种移除高层级重复的通用技巧。

### 表达力

- 选好名称
- 保持函数和类尺寸短小来表达
- 通过采用标准命名法来表达。例如采用设计模式中的标准模式名，COMMAND或VISTOR。

### 尽可能少的类和方法

这条规则是优先级最低的。

## 并发编程

### 为什么要并发

并发是一种解耦策略。把做什么(目的)和何时(时机)做分解开。

### 并发防御原则

#### 单一权责原则

方法/类/组件应当只有一个修改的理由。分离并发相关代码与其他代码。

#### 推论：限制数据作用域

两个线程修改共享对象的同一字段时，可能互相干扰。解决方案是采用synchronized关键字在代码中保护一块使用共享对象的临界区。更好的办法是限制临界区的数量。

#### 推论：使用数据复本

使用对象复本避免共享数据。

#### 推论：线程应尽可能地独立

尽量不与其它线程共享数据。尝试将数据分解到可被独立线程(可能在不同处理器上)操作的独立子集。

### 了解Java库

掌握java.util.concurrent,java.util.concurrent.atomic,java.util.concurrent.locks。

类 CuncurrentHashMap,ReentrantLock,Semaphore,CountDownLatch。

### 了解执行模型

基础定义

| 类型     |                                                                                                                                            描述 |
|----------|-------------------------------------------------------------------------------------------------------------------------------------------------|
| 限定资源 |                                                                           并发环境中有固定尺寸或数量的资源。例如数据库连接和固定尺寸读/写缓存等 |
| 互斥     |                                                                                                    每一时刻仅有一个线程能访问共享数据或共享资源 |
| 线程饥饿 |             一个或一组线程在很长时间内或永久被停止。例如，总是让执行得快的线程先执行，假如执行得快的线程没完没了，则执行时间长的线程就会"挨饿" |
| 死锁     |                                       两个或多个线程互相等待执行结束。每个线程都拥有其他线程需要的资源，得不到其他线程拥有的资源，就无法终止。 |
| 活锁     | 执行次序一致的线程，每个都想要起步，但发现其他线程已经"在路上"，由于竞步的原因，线程会持续尝试起步，但在很长时间内却无法如愿，甚至永远无法启动 |

#### 生产者-消费者模型

一个或多个生产者线程创建某些工作，并置于缓存或队列中。一个或多个消费者线程从队列中获取并完成这些工作。生产者和消费者之间的队列是一种限定资源。

#### 读者-作者模型

有一个写者很多读者，多个读者可以同时读文件，但写者在写文件时不允许有读者在读文件，同样有读者在读文件时写者也不去能写文件。

#### 宴席哲学家

假设有五位哲学家围坐在一张圆形餐桌旁，做以下两件事情之一：吃饭，或者思考。吃东西的时候，他们就停止思考，思考的时候也停止吃东西。餐桌中间有一大碗意大利面，每两个哲学家之间有一只餐叉。因为用一只餐叉很难吃到意大利面，所以假设哲学家必须用两只餐叉吃东西。他们只能使用自己左右手边的那两只餐叉。

### 警惕同步方法之间的依赖

### 保持同步区域微小

尽可能减小同步区域

### 很难编写正确的关闭代码

尽早考虑关闭问题，尽早令其工作正常。这会花费比你预期更多的时间。检查既有算法，因为这可能比想象的难得多。

### 测试线程代码

#### 将伪失败看作可能的线程问题

#### 先使非线程代码可工作

#### 编写可插拔的线程代码

#### 编写可调整的线程代码

#### 运行多于处理器数量的线程

#### 在不同平台上运行

#### 装置试错代码

两种装置方法

- 硬编码。手工向代码中插入wait(),sleep(),yield()和priority()方法。
- 自动化。使用Aspect-Oriented Framework、CGLIB或ASM之类工具通过编程来装置代码。

## 逐渐改进

单元测试使用JUnit，验收测试用FitNesse以wiki页形式写成。
Clover检查单元测试覆盖了哪些代码。

## 味道与启发

### 注释 

C1. 不恰当的信息

作者、最后修改时间等信息应该在版本控制系统中，而不是注释中。

C2. 废弃的注释 

过时、无关或不正确的注释就是废弃的注释，必须马上更新或者删除。 

C3. 冗余注释 

注释应该谈及代码自身没提到的东西，否则就是冗余的。如果代码已经能够充分自描述，就没有必要再添加注释。

C4. 糟糕的注释 

值得编写的注释必须正确写出最好的注释，如果不是就不要写。 

C5. 注释掉的代码 

注释掉的代码必须删除。 

### 环境 

E1. 需要多步才能实现的构建 

构建系统应该是单步的小操作。应当能用单个命令签出系统，并用单个指令构建它。 

E2. 需要多步才能实现的测试 

应当只需要单个指令就可以运行所有单元测试。 

### 函数 

F1. 过多的参数 

函数参数应该越少越好，没参数最好，一个次之，两个、三个再次之，坚决避免有3个参数的函数。

F2. 输出参数 

输出参数违反直觉，抵制输出参数。如果函数非要修改什么东西的状态，修改它所在对象的状态就好了。

F3. 标识参数

布尔值参数一般宣告函数做了不止一件事，应该消灭掉。 

F4. 死函数 

永不被调用函数应该删除掉。 
 
### 一般性问题 

G1. 一个源文件存在多个语言

尽量减少源文件语言的数量和范围。 

G2. 明显的行为未被实现 

遵循“最少惊异原则”，函数或者类应该实现其他程序员有理由期待的行为，不要让其他程序员看代码才清楚函数的作用。 

G3. 不正确的边界行为 

代码应该有正确的行为，追索每种边界条件并进行全面测试。 

G4. 忽视安全 

关注可能引起问题的代码，注重安全与稳定。 

G5. 重复 

消除重复代码，多使用多态，模板，设计模式等手段。 

G6. 在错误的抽象层级上的代码 

抽象类和派生类概念模型必须完整分离，与实现细节有关的代码不应该在基类中出现。这条规则同样适用于源文件、组件和模块，较低层级的概念应该和较高层级的概念分离。 

G7. 基类依赖于派生类 

通常基类应该对派生类一无所知。 

G8. 信息过多 

类中的方法、变量越少越好，函数知道的变量越少越好，隐藏所有实现，公开接口越少越好，保持低耦合度。

G9. 死代码 

删除不被执行的代码，这类代码可以在if,try/catch,switch/case中找到，以及不会被调用的代码

G10. 垂直分隔 

变量和函数的定义应该靠近被调用代码。 

G11. 前后不一致 

变量方法命名应该从一而终，保持一致，让代码便于阅读和修改。

G12. 混淆视听 

没有实现的默认构造器，没用的变量，从不被调用的函数，没有信息量的注释应该清理掉。 

G13. 人为耦合 

不互相依赖的东西不该耦合。不要随便放置函数、常量和变量的声明。

G14. 特性依恋 

类的方法应该只对自身的方法和变量感兴趣，不应该垂青其他类的方法和变量。当方法通过某个对象的访问器和修改器操作该对象内部数据，则它依恋于该对象所属类的范围。 

G15. 选择算子参数 

避免布尔类型参数，及其他用于选择函数行为的参数，使用多个函数，多态代替。 

G16. 晦涩的意图 

代码要尽可能具有表达力，明白的意图比高效和性能重要。不使用联排表达式、匈牙利语标记法和魔术数。 

G17. 位置错误的权责 

“最少惊异原则”，把代码放在读者想到的地方，而不是对自己方便的地方。 

G18. 不恰当的静态方法 

通常应该倾向使用非静态方法。如果要使用静态方法，必须确保没机会打算让它有多态行为。 

G19. 使用解释性变量 

把计算过程打散成一系列命名良好的中间值使程序更加可读性。 
```
String key = match.group(1);
String value = match.group(2);
headers.put(key.toLowerCase(),value);
```
key和value就解释了第一个，第二个解释组是什么。

G20. 函数名称应该表达其行为 

如果必须查看源代码才能知道函数的行为，函数名就应该改变。

G21. 理解算法 

在完成函数之前，确认已经理解了它是怎么工作的。

G22. 把逻辑依赖改为物理依赖 

依赖应该是明显而不应该是假设的依赖。 

G23. 用多态替代if/else或switch/case 

G24. 遵循标准约定 

G25. 用命名常量替代魔术数 

魔术数不仅是说数字，也泛指不能自我描述的符号。

G26. 准确 

代码中的含糊和不准确要么是意见不同的结果，要么源于懒散，都必须消除。 

G27. 结构甚于约定 

G28. 封装条件 

把if或while语句的条件封装成方法。 

G29. 避免否定性条件 

尽可能使用肯定性条件。 

G30. 函数只该做一件事 

拆分做了多件事的函数

G31. 掩蔽时序耦合 

创建顺序队列暴露时序耦合，每个函数都产生一下函数所需参数，就可保障正确的时序。 

G32. 别随意 

代码不能随意，需要谨慎考虑。 

G33. 封装边界条件 

例如：+1或-1操作封装起来。 

G34. 函数应该只在一个抽象层级上 

封装不在一个抽象层级上的代码，保持每个函数只在一个抽象层级上。 

G35. 在较高层级放置可配置数据 

把配置数据和常量放到较高抽象层级

G36. 避免传递浏览 

“得墨忒耳律”，也称编写害羞代码，让直接协作者提供所需的服务，而不要逛遍整个系统。 

### JAVA 

J1. 通过使用通配符避免过长的导入清单 

J2. 不要继承常量 

J3. 常量VS.枚举 

使用枚举enum代替常量。 

### 名称 

N1. 采用描述性名称 

名称对应可读性有90%的作用，必须认真命名。 

N2. 名称应与抽象层级相符 

不要取沟通实现的名称：取反映类或函数抽象层级的名称。 

N3. 尽可能使用标准命名法 

N4. 无歧义的名称 

N5. 为较大作用范围选用较长名称 

N6. 避免编码 

不要使用匈牙利语命名法，不应该在名称中包含类型或范围的信息，例如：m_，f等前缀。 

N7. 名称应该说明副作用 

名称应该说明类、变量或函数的所有信息，不应该隐藏副作用。

### 测试 

T1. 测试不足 

保证足够的测试。确保所有条件和计算都被测试到。 

T2. 使用覆盖率工具 

覆盖率工具可以更好地找到测试不足的模块、类、函数。 

T3. 别略过小测试 

T4. 被忽略的测试就是对不确定事物的疑问 

用@Ignore表达我们对需求的疑问。 

T5. 测试边界条件 

边界判读错误很常见，必须测试边界条件。 

T6. 全面测试相近的缺陷 

缺陷趋向于扎堆，如果在函数中发现一个缺陷，那么就全面测试这个函数。 

T7. 测试失败的模式有启发性 

你可以通过测试失败找到问题所在。 

T8. 测试覆盖率的模式有启发性 

通过测试覆盖率检查，往往可以找到测试失败的线索。 

T9. 测试应该快速 

慢测试会导致时间紧时会跳过，导致可能出现问题。
