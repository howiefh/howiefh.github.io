title: Java编程思想笔记四
date: 2014-10-17 09:58:25
tags: thinking in java
categories: java
description: thinking in java; java编程思想
---

## 类型信息

Java是如何让我们在运行时候识别对象和类的信息的
1. 传统的RTTI（运行时类型信息），它假定我们在编译时就已经知道了所有的类型
2. 反射机制，允许我们在运行的时候发现和使用类的信息
<!-- more -->

### 为什么需要RTTI

RTTI名字的含义：在运行时，识别一个对象的类型。
使用RTTI可以知道某个引用所指向的对象的确切类型。

### Class对象

每个类都有一个Class 对象，每当编写并且编译一个新类，就会产生一个Class对象（更恰当的说，是被保存在一个同名的.class文件中）。为了生成这个类的对象，运行这个程序的java虚拟机将使用被称为“类加载器”的子系统。

所有的类都是在对其第一次使用的时候，动态加载到JVM中的。当程序创建第一个对类的静态成员的引用时，就会加载这个类。这个证明构造器也是类的静态方法，即使在构造器之前并没有使用static关键字。

类加载器首先检查这个类的Class对象是否已加载。如果尚未加载，默认的类加载器就会根据类名查找.class文件。在这个类的字节码被加载时，它们会接受验证，确保其没有被破坏，并且不包含不良java代码。

forName()的调用会产生“副作用”：如果类还没有被加载就加载它。在加载的过程中，static子句被执行。注意，在传递给forName()的字符串中，你必须使用全限定名（包含包名）。

getSimpleName()不包含包名，getName()，getCanonicalName()包含包名。
isInterface()这个Class对象是否表示某个接口。
getInterfaces()返回的是Class对象，它们表示在感兴趣的Class对象中所包含的接口。
getSuperclass()返回其直接基类。
newInstance()创建新实例，会得到Object对象。使用newInstance()创建的实例的类必须有默认构造器。

#### 类字面常量

java还提供了另一种方法来生成对Class对象的引用，即使用类字面常量。如：
FancyToy.class;   

这样做不仅简单，而且更安全，因为它是在编译时候就会受到检查（因此不需要置于try语句块中），并且它根除了对forName()方法的调用，所以也更高效。

类字面常量不仅可以应用于普通的类，也可以应用于接口、数组、以及基本数据类型。另外，对于基本数据类型的包装类，还有一个标准的TYPE。TYPE字段是一个引用，指向对应的基本数据类型的Class对象，和.class是等效的。

当使用.class来创建对Class对象的引用的时候，不会自动初始化该Class对象，为了使用类而做的准备工作实际包含三个步骤：
1. 加载。由类加载器执行。该步骤将查找字节码，并从字节码中创建class对象。
2. 链接。验证类中的字节码，为静态域分配存储空间，并且需要的话，将解析这个类创建的对其他类的所有引用。
3. 初始化。如果该类具有超类，则对其进行初始化，执行静态初始化器和静态初始化模块。

* 仅使用.class语法来获得对类的引用不会引发初始化。但是，为了产生Class引用，Class.forName()立即就进行了初始化。
* 如果一个static final值是“编译期常量”，那么这个值不需要对类进行初始化就可以被读取。但是有例外，如果是通过一个静态方法赋值的，仍需要进行初始化。
* 如果是一个static域不是final，对它进行访问时，总是要求在它被读取之前，要先进行链接和初始化。

#### 泛化的Class引用

在Java SE5中，Class<?>优于平凡的Class，即便它们是等价的，并且平凡的Class如你所见，不会产生编译器警告信息。Class<?>的好处是它表示你并非碰巧或者由于疏忽，而使用了一个非具体的类引用，你就是选择了非具体的版本。

向Class引用添加泛型语法的原因仅仅是为了提供编译期类型检查，因此如果你操作有误，稍后立即就会发现这一点。

#### 新的转型语法

Java SE5还添加了用于Class引用的转型语法，即cast()方法：

### 类型转换前先做检查

我们知道RTTI的形式包括：
1. 传统的类型转换 (Shape)
2. 代表对象的类型的Class对象
3. 关键字instanceof
    * instanceof，如果编写了许多的instanceof表达式，就说明你的设计存在瑕疵。
    * 动态instanceof，即Class.isInstance方法提供了一种解决过多使用instanceof表达式的方法，但是一般效率稍微低一些。

### 注册工厂

使用工厂方法设计模式，将对象的创建工作交给类自己去完成。

### instanceof与Class的等价性

1. instanceof和isInstance()保持了类型的概念，它指的是“你是这个类吗？或者你是这个类的派生类吗?”
2. 如果用==或equal()比较实际的Class对象，就没有考虑继承--它或者是这个确切的类型，或者不是。

### 反射：运行时候的类信息

运行时获取类信息的两个动机：
1. 集成开发环境中检查可用的方法。
2. 远程方法调用（RMI）。允许将一个java程序将对象分部到多态机器上。

Class类和java.lang.reflect类库对反射进行了支持，该类库包含Field、Method、Constructor类。

Constructor的newInstance()方法，Method的invoke()方法，Field的一系列get()和set()方法，Class的getFields()、getMethods()、getConstructors()方法都是常用到的方法。

反射在java中用来支持其它特性，如对象序列化和JavaBean。

**默认构造器会自动被赋予与类一样的访问权限**

### 动态代理

通过调用静态方法Proxy.newProxyInstance()可以创建动态代理，这个方法需要得到一个类加载器（你通常可以从已经被加载的对象中获取其类加载器，然后传递给它），一个你希望该代理实现的接口列表（不是类或者抽象类），以及InvocationHandle接口的一个实现。

在动态代理上所做的所有调用都会被重定向到单一的调用处理器上，它的工作是揭示调用的类型并确定相应的对策。

### 空对象

通过空对象，你可以假设所有的对象都是有效的，而不必浪费编程精力去检查null。到处使用空对象没有任何意义--有时检查null就可以了，有时可以合理假设不会遇到null，有时探测NullPointerException异常也可以。空对象最有用的地方在于它更靠近数据，因为对象表示的是问题空间内的实体。

### 接口与类型信息

看起来没有任何方式可以阻止反射到达并调用那些非公共访问权限的方法。对于域来说，的确如此，即便是private域。final域实际上在遭遇修改时是安全的。

不要太早关注程序的效率问题，这是个诱人的陷阱，最好首先让程序运作起来，然后再考虑它的速度，如果要解决效率问题可以使用profiler。

## 泛型

一般的类和方法，只能使用具体的类型：要么是基本类型，要么是自定义的类。如果要编写可以应用于多种类型的代码，这种刻板的限制对代码的束缚就会很大。

多态，接口都算是一种泛化机制，将方法的参数类型设为基类或接口，这样的方法更加通用一些。有时多态和接口还是有限制，要使代码应用于某种不具体的类型，而不是指定的接口或类。

Java SE5提供了泛型的概念，其实现了参数化类型的概念。但是相比有些语言的泛型机制，Java的泛型并不是纯粹的，有很多的局限。

### 简单泛型

暂时并不指定类型，而是在使用的时候在指定具体使用什么类型。
```
public class Holder<T>{
    private T a;
    public static void main(String[] args){
        Holder<String> holder = new Holder();    
    }
}
```

#### 一个元组类库

使用元组，可以解决方法调用一次返回多个对象的需求。

元组，它是将一组对象直接打包存储于其中的一个单一对象。这个容器对象允许读取其中元素，但是不允许存放新的对象。
```
public class TwoTuple<A,B> {
    public final A first;
    public final B second;
    public TwoTuple(A a, B b){first = a; second = b;}
}
```

first和second并没有声明为private，这是否违反了Java编程的安全性原则，实际上final声明提供了相同的安全保险，而这种格式更加简洁明了。（如果是private的，还需要提供get方法）

可以通过继承机制实现更长的元组。

### 泛型接口

泛型也可以应用于接口。例如生成器（generator），这是一种专门负责创建对象的类。实际上，这是工厂方法设计模式的一种应用。不过，当使用生成器创建新的对象时，它不需要任何参数，而工厂方法一般需要参数。
```
public interface Generator<T>{T next();}
```
Java泛型的一个局限性：**基本类型无法作为类型参数**。不过Java提供了自动打包和自动拆包机制。

### 泛型方法

一个基本的指导原则：无论何时，只要你能做到，你就应该尽量使用泛型方法。也就是说，如果使用泛型方法可以取代将整个类泛型化，那么就应该只使用泛型方法，因为它可以使事情更清楚明白。另外，对于一个static的方法而言，无法访问泛型类的类型参数，所以，如果static方法需要使用泛型能力，就必须使其成为泛型方法。

```
public <T> void function(T i){}  //将泛型参数列表置于返回类型之前
```
当使用泛型类时，必须在创建对象的时候指定类型参数的值，而使用泛型方法的时候，通常不必指明参数类型，因为编译器会为我们找出具体的类型。这称为类型参数推断（type argument inference）。因此，我们可以像调用普通方法一样调用f()，而且就好像是f()被无限次地重载过。

类型推断只对赋值操作有效，但是现在，[Java SE7和Java SE8对类型推断做了一些改进](http://my.oschina.net/benhaile/blog/184390)
**java7的泛型类型推断改进**
在以前的版本中使用泛型类型，需要在声明并赋值的时候，两侧都加上泛型类型。例如：
```
Map<String, String> myMap = new HashMap<String, String>();
```
在Java SE 7中，这种方式得以改进，现在你可以使用如下语句进行声明并赋值：
```
Map<String, String> myMap = new HashMap<>(); //注意后面的"<>"
```
在这条语句中，编译器会根据变量声明时的泛型类型自动推断出实例化HashMap时的泛型类型。再次提醒一定要注意new HashMap后面的“<>”，只有加上这个“<>”才表示是自动类型推断，否则就是非泛型类型的HashMap，并且在使用编译器编译源代码时会给出一个警告提示。

但是：Java SE 7在创建泛型实例时的类型推断是有限制的：只有构造器的参数化类型在上下文中被显著的声明了，才可以使用类型推断，否则不行。例如：下面的例子在java 7无法正确编译（但现在在java8里面可以编译，因为根据方法参数来自动推断泛型的类型）：
```
List<String> list = new ArrayList<>();
list.add("A");// 由于addAll期望获得Collection<? extends String>类型的参数，因此下面的语句无法通过
list.addAll(new ArrayList<>());
```
**Java8的泛型类型推断改进**
java8里面泛型的目标类型推断主要2个：
1. 支持通过方法上下文推断泛型目标类型
2. 支持在方法调用链路当中，泛型类型推断传递到最后一个方法
让我们看看官网的例子
```
class List<E> {
   static <Z> List<Z> nil() { ... };
   static <Z> List<Z> cons(Z head, List<Z> tail) { ... };
   E head() { ... }
}
```
根据JEP101的特性，我们在调用上面方法的时候可以这样写
```
//通过方法赋值的目标参数来自动推断泛型的类型，这个不是新特性
List<String> l = List.nil();
//而不是显示的指定类型
//List<String> l = List.<String>nil();
//通过前面方法参数类型推断泛型的类型
List.cons(42, List.nil());
//而不是显示的指定类型
//List.cons(42, List.<Integer>nil());
```
**显示的类型说明**，在点操作符和方法名之间插入尖括号，然后把类型置于尖括号内。
* 类.<实际类型参数...>method()
* 对象.<实际类型参数...>method()
* this.<实际类型参数...>method()

匿名内部类与泛型：
```
new Generator<Customer>(){
    public Customer next(){return new Customer();}
}
```
从泛型类继承
```
class Shelf extends Arraylist<Product>{}
```

### 擦除

**在泛型代码内部，无法获得任何有关泛型参数类型的信息**

Java泛型是使用擦除来实现的，这意味着当你在使用泛型时，任何具体的类型信息都被擦除了，你唯一知道的就是你在使用一个对象。因此List<String>和List<Integer>在**运行时**事实上是相同的类型。

C++中的模板
```
#include <iostream> 
using namespace std; 
template<class T> class Manipulator { 
    T obj; 
    public: 
    Manipulator(T x) { obj = x; } 
    void manipulate() { obj.f(); } 
}; 
class HasF { 
    public: 
    void f() { cout << "HasF::f()" << endl; } 
}; 
int main() { 
    HasF hf; 
    Manipulator<HasF> manipulator(hf); 
    manipulator.manipulate(); 
} /* Output: 
HasF::f() 
///:~
```
在C++中，可以知道T的具体类型，进而准确调用该类的f()方法。Java中的话实现类似的代码就会有些麻烦了。
```
public class HasF { 
    public void f() { System.out.println("HasF.f()"); } 
} 
class Manipulator<T> { 
    private T obj; 
    public Manipulator(T x) { obj = x; } 
    // Error: cannot find symbol: method f(): 
    public void manipulate() { obj.f(); } 
} 
public class Manipulation { 
    public static void main(String[] args) { 
        HasF hf = new HasF();
        Manipulator<HasF> manipulator = 
        new Manipulator<HasF>(hf); 
        manipulator.manipulate(); 
    } 
} ///:~
```
上面的代码没有通过编译，就是由于擦除，会将T替换为Object，这样就没法调用f()方法了。可以使用边界来解决这个问题。
```
class Manipulator<T extends HasF> { 
    private T obj; 
    public Manipulator(T x) { obj = x; } 
    public void manipulate() { obj.f(); } 
} 
```
泛型类型参数将擦除到它的第一个边界（他可能有多个边界，只能有一个类做边界，而且必须是第一个边界）。类型参数的擦除，编译器实际上会把类型参数替换为它的擦除，就像上面的例子，T擦除到了HasF，就好像在类的声明中用HasF替换了T一样。

只有当你希望使用的类型参数比某个具体类型（以及它的所有子类型）更加“泛化”时--也就是说，当你希望代码能够跨多个类工作时，使用泛型才是有帮助的。

泛型类型只有在静态类型检查期间才出现，在此之后，程序中的所有泛型类型都将被擦除，替换为它们的非泛型上界。诸如List<T>这样的类型将被擦除为List，而普通的类型变量在未指定边界的情况下将被擦除为Object。

擦除的核心动机是它使得泛化的客户端可以使用非泛化的类库，反之亦然，这经常被称为“迁移兼容性”。

#### 擦除的问题

泛型不能用于显式地引用运行时类型的操作之中，例如转型、instanceof操作和new表达式。因为类型信息会丢失，必须时刻提醒自己，只是看起来像拥有有关参数的类型信息而已。

在整个类的各个地方，类型T都在被替换，无论何时，必须时刻提醒自己“它只是个Object”。

#### 边界处的的动作

```
public class SimpleHolder {
    private Object obj;
    public void set(Object obj) {this.obj = obj;}
    public Object get() {return obj;}
    public static void main(String[] args) {
        SimpleHolder holder = new SimpleHolder();
        holder.set("item");
        String s = (String)holder.get();
    }
}

public class GenericHolder<T>{
    private T obj;
    public void set(T obj) {this.obj = obj;}
    public T get() {return obj;}
    public static void main(String[] args) {
        GenericHolder<String> holder = new GenericHolder<>();
        holder.set("item");
        String s = holder.get();
    }
}
```
上面代码实现了非泛型和泛型版本的相似的两个类通过`javap -c` 命令反编译可以发现字节码是相同的，就是说在运行时使用泛型的代码和普通代码没有什么区别。泛型中的所有动作都发生在边界处--对传递进来的值进行额外的编译期检查，并插入对传递出去的值的转型。这有助于澄清对擦除的混淆，记住，“边界就是发生动作的地方”。

### 擦除的补偿

Java泛型在instanceof、创建类型实例，创建数组、转型时都会有问题。有时必须通过引入类型标签（即你的类型的Class对象）进行补偿。使用动态的isInstance()方法，而不是instanceof。

#### 创建类型实例

解决方案是传递一个工厂对象，并使用它来创建新的实例。最便利的工厂对象就是Class对象。
```
class ClassAsFactory<T>{
    T x;
    public ClassAsFactory(Class<T> kind){
        try{
            x = kind.newInstance();
        } catch(Exception e){
            throw new RuntimeException(e);
        }
    }
}
```
但是对于没有默认构造器的类，上述方法不能奏效了。可以使用显示的工厂。
```
interface FactoryI<T>{
    T create();
}
class Foo2<T>{
    private T x;
    public <F extends FactoryI<T>> Foo2(F factory){
        x = factory.create();
    }
}
class IntegerFactory implements Factory<Integer>{
    public Integer create(){
        return new Integer(0);
    }
}
```
另一种方式是模板方法设计模式。

#### 泛型数组

解决方案是在任何想要创建泛型数组的地方都使用ArrayList。
如果非要用泛型数组，可以创建Object数组，然后转型。但是如果返回该泛型数组还是需要再进行一次转型。
```
T[] array;
public Constructor(int sz){
    array = (T[]) new Object[sz];
}
```
使用类型标记
```
T[] array;
public Constructor(Class<T> type, int sz){
    array = (T[]) Array.newInstance(type, sz);
}
```

### 通配符

**协变**就是子类型可以被当作基类型使用。

如果实际数组类型是Apple[]，你应该只能在其中放置Apple或Apple的子类型，这在编译期和运行期都可以工作。编译器也允许放入Fruit类型但是运行时会抛出异常。与数组不同，泛型没有内建的协变类型。这是因为数组在语言中是完全定义的，因此可以内建了编译期和运行时的检查。

```
public class CompilerIntelligence {
    public static void main(String[] args){
        List<? extends Fruit> flist1 = new ArrayList<>();
        //flist1.add(new Apple()); //Compile Error
        flist1.add(null);
        Fruit f = flist1.get(0);
        List<? extends Fruit> flist2 = Arrays.asList(new Apple());
        Apple a = (Apple) flist2.get(0);
        flist2.contains(new Apple());
        flist2.indexOf(new Apple());
    }
}
```
查看ArrayList文档，add()方法接受泛型类型的参数，contains()和indexOf()方法接受Object类型的参数。因此，当指定ArrayList<? extends Fruit>时，add()的参数就变成"? extends Fruit"。从这个描述中，编译器并不知道确切的类型，因此它不接受任何类型的Fruit。contains()和indexOf()方法参数类型是Object类型。不涉及任何通配符，编译器将允许这个调用。

**逆变**

超类型通配符。可以声明通配符是由某个特定类的任何基类来界定的，方法是指定`<? super MyClass>`，可以使用类型参数：`<? super T>`(不能声明类型参数为`<T super MyClass>`)
```
List<? super Apple> flist = new ArrayList<>();
flist.add(new Apple()); 
flist.add(new Jonathan()); 
//flist.add(new Fruit()); //Compile Error
```
Apple是下界，这样你就知道向其中添加Apple或Apple的子类型是安全的，而添加Fruit是不安全的了。

小结：
子类型通配符(指定上界)：如<? extends Apple>，Apple是指定的上界，表示可以接收Apple或Apple的任意子类, 但是现在还不确定是什么。这种不确定性带来的问题是无法写入（传递给一个方法）。
超类型通配符(指定下界)：如<? super Apple>，Apple是指定的下界，表示可以接收Apple或Apple的任意超类, 但是现在还不确定是什么。确保是Apple或Apple的任意超类，所以可以写入。

**无界通配符**

无界通配符`<?>`看起来意味着“任何事物”，因此使用无界通配符好像等价于使用原生类型。

List实际上表示“持有任何Object类型的原生List”，而List<?>表示“具有某种特定类型的非原生List，只是我们不知道那种类型是什么。”

**捕获转换**

有一种情况特别需要使用<?>而不是原生类型。
```
public class CaptureConversion {
  static <T> void f1(Holder<T> holder) {
    T t = holder.get();
    System.out.println(t.getClass().getSimpleName());
  }
  static void f2(Holder<?> holder) {
    f1(holder); // Call with captured type
  }	
  @SuppressWarnings("unchecked")
  public static void main(String[] args) {
    Holder raw = new Holder<Integer>(1);
    // f1(raw); // Produces warnings
    f2(raw); // No warnings
    Holder rawBasic = new Holder();
    rawBasic.set(new Object()); // Warning
    f2(rawBasic); // No warnings
    // Upcast to Holder<?>, still figures it out:
    Holder<?> wildcarded = new Holder<Double>(1.0);
    f2(wildcarded);
  }
} /* Output:
Integer
Object
Double
*///:~
```
参数类型在调用f2()的过程中被捕获，因此它可以在对f1()调用中被使用。

### 问题

#### 任何基本类型都不能作为类型参数

解决之道是自动包装机制。但是自动包装机制不能作用于数组。

类泛型无法在静态方法中工作。

#### 实现参数化接口

一个类不能同时实现同一个泛型接口的两种辩题，由于擦除的原因，这两个变体会变成相同的接口。
```
interface Payable<T>{}
class Employee implements Payable<Employee> {}
class Hourly extends Employee implements Payable<Hourly> {}
```
有趣的是，去掉泛型参数后可以。

#### 转型和警告

泛型没有消除对转型的需要。
```
List<Widget> lw = List.class.cast(in.readObject());
```
不能转型成实际类型（`List<Widget>`），即不能声明
```
List<Widget> lw = List<Widget>.class.cast(in.readObject());
//或
List<Widget> lw = (List<Widget>)List.class.cast(in.readObject());
```

#### 重载

由于擦除的原因，重载方法将产生相同的类型签名。

#### 基类劫持了接口

```
public class ComparablePet implements Comparable<ComparablePet> {
  public int compareTo(ComparablePet arg) { return 0; }
} ///:~
class Cat extends ComparablePet implements Comparable<Cat>{
  // Error: Comparable cannot be inherited with
  // different arguments: <Cat> and <Pet>
  public int compareTo(Cat arg) { return 0; }
} ///:~
```
如果基类已经确定了泛型参数，那么导出类不能再指定其它泛型参数。但是指定相同的泛型参数是可以的，但是直接继承就可以了。

### 自限定类型

```
class SelfBounded<T extends Selfbounded<T>>{}
```

古怪的循环泛型（CRG）：基类用导出类替代其参数。这意味着泛型基类变成了一种其所有导出类的公共功能的模板，但是这些功能对于其所有参数和返回值，将使用导出类型。
```
public class BasicHolder<T> {
  T element;
  void set(T arg) { element = arg; }
  T get() { return element; }
  void f() {
    System.out.println(element.getClass().getSimpleName());
  }
} ///:~

class Subtype extends BasicHolder<Subtype> {}

public class CRGWithBasicHolder {
  public static void main(String[] args) {
    Subtype st1 = new Subtype(), st2 = new Subtype();
    st1.set(st2);
    Subtype st3 = st1.get();
    st1.f();
  }
} /* Output:
Subtype
*///:~
```
自限定可以保证类型参数必须与正在被定义的类相同。
```
class SelfBounded<T extends SelfBounded<T>> {
  T element;
  SelfBounded<T> set(T arg) {
    element = arg;
    return this;
  }
  T get() { return element; }
}

class A extends SelfBounded<A> {}
class B extends SelfBounded<A> {} // Also OK

class C extends SelfBounded<C> {
  C setAndGet(C arg) { set(arg); return get(); }
}	

class D {}
// Can't do this:
// class E extends SelfBounded<D> {}
// Compile error: Type parameter D is not within its bound

// Alas, you can do this, so you can't force the idiom:
class F extends SelfBounded {}
```
自限定也可以用于泛型方法，防止方法被应用除自限定参数之外的任何事物。

**参数协变**
自限定类型的价值在于它们可以产生协变参数类型--方法参数类型会随着子类变化而变化。

自限定类型可以限制重载，方法的参数类型会协变，使得子类中不能即含有基类型参数的方法，又含有子类型参数的方法，而如果不是自限定的，则可以重载

### 动态类型安全

java.util.Collections中提供来一组便利工具，可以解决类型检查的问题。它们是：静态方法checkedCollection()、checkedList()、checkedMap()、checkedSet()、checkedSortedMap()和checkedSortedSet()。这些方法每一个都会将你希望动态检查的容器当做第一个参数接受，并将你希望强制要求的类型作为第二个参数接受。如果向Java SE5之前的代码传递泛型容器，可能会导致类似“将猫插入狗队列”的问题，使用这些方法可以确保不出现这种问题。

### 异常

由于擦除的原因，将泛型应用于异常是非常受限的。catch语句不能捕获泛型类型的异常，泛型类也不能直接或间接继承自Throwable。但是，类型参数可能会在一个方法的throws子句中用到。
```
interface Processor<T,E extends Exception>{
    void process(List<T> resultCollector) throws E;
}
```

### 混型

混型最基本的概念是混合多个类的能力，以产生一个可以表示混型中所有类型的类。混型的价值之一是它们可以将特性和行为一致地应用于多个类之上。C++有多重继承机制，模板，可以方便地实现混型。

* 与接口混合
    Java中推荐解决方案是使用接口产生混型效果。基本上使用代理。
* 使用装饰器模式
    装饰器是通过使用组合和形式化结构来实现的，而混型是基于继承的。其明显缺陷是它只能有效地工作于装饰中的一层（最后一层），只是一种局限的解决方案。
* 与动态代理混合
    更接近真正的混型

### 潜在类型机制

潜在类型机制使得你可以横跨类继承结构，调用不属于某个公共接口的方法。因此实际上一段代码可以声明：“我不关心你是什么类型，只要你可以speack()和sit()即可”。潜在类型机制是一种代码组织和复用机制。python和C++均支持潜在类型机制。

### 对潜在类型机制的补偿

* 反射
    利用Method的invoke()方法可以动态地确定所需要的方法。但是类型检查转移到了运行时。
* 用适配器仿真潜在类型机制
    潜在类型机制将在这里实现什么？他意味着你可以编写代码声明：“我不关心我在这里使用的类型，只要它具有这些方法即可”。实际上潜在类型机制创建了 一个包含所需方法的隐式接口。从拥有的接口编写代码来产生我们需要的接口，这是适配器设计模式的一个典型示例。

### 将函数对象用作策略

书中前一节的示例代码中添加对象，这是多个类的公共操作，但是这个操作没有在任何我们可以指定的基类中表示。使用策略设计模式，将“变化的事物”完全隔离到一个函数对象中。函数对象就是在某种程度上行为像函数的对象，一般会有一个相关方法。

Java中添加泛型，使得编译期类型检查成为可能。
