title: Java编程思想笔记七
date: 2014-11-06 11:02:46
tags: Thinking in Java
categories: Java
description: thinking in java; java编程思想; 枚举类型;
---
## 枚举类型
### 基本enum特性

* Enum类是枚举的一个封装类，是所有枚举类型的超类，它是一个没有抽象方法的抽象类。Enum类实现了Comparable接口，所以它具有compareTo() 方法。同时它还实现了Serializable接口。
* ordinal() : 获取枚举元素声明时的顺序，从0开始计算 
* 可以使用"=="来比较两个枚举实例相同与否，由于编译器自动实现了equals()和hashCode()两个方法
* 调用getDeclaringClass()方法，我们就能知道其所属的enum类
* name() : 返回enum实例声明时的名字，与使用toString()方法效果相同
* valueOf() : Enum中的static方法，根据给定的名字返回相应的enum实例，如果不存在给定实例的名字，将会抛出异常。
* values() : 这个方法不是Enum提供的。

<!-- more -->

#### 将静态导入用于enum

如果使用静态导入不会使你的代码难以理解，那么使用静态导入还是有好处的。

在定义enum的同一个文件中，这种技巧无法使用；在默认包中定义enum，这种技巧也无法使用。

### 向enum中添加新方法

**基本上可以将enum看作一个常规的类，也就是说可以向enum添加方法，甚至可以由main方法**。

**如果打算添加自己的方法，那么必须在enum实例的最后添加一个分号，而且必须先定义enum实例，实例之前不能有任何方法，否则报错**。

因为我们只能在enum定义的内部使用其构造器创建enum实例，所以enum构造器声明为private并没有什么影响。

此外我们也可以覆盖enum的方法

### switch语句中的enum

一般情况下我们必须使用enum类型来修饰一个enum实例（Color.RED），但是case语句中却不必如此。

### values()的神秘之处

enum类都继承自Enum类，但是Enum类中并没有values()方法。**values()是由编译器添加的static方法。编译器还添加了一个只有一个参数的valueOf()方法，和一个static初始化语句块**。

如果将enum实例向上转型为Enum，那么values()方法就不可访问了。不过，在Class中有一个getEnumConstants()方法，所以即便Enum接口中没有values()方法，我们仍然可以通过Class对象取得所有enum实例。

### 实现，而非继承

**所有enum都继承了Enum类，所以enum不能再继承其他类，但是可以实现一个或多个接口**。

### 随机选取

工具类net.mindview.util.Enums可以实现enum实例的随机选择。

### 使用接口组织枚举

我们希望从enum继承子类，是由于有时我们希望扩展远enum中的元素，有时是因为我们希望使用子类将一个enum中的元素进行分组。

**在一个接口的内部，创建实现该接口的枚举，以此将元素进行分组，可以达到将枚举元素分类组织的目的**。

```
public interface Food {
  enum Appetizer implements Food {
    SALAD, SOUP, SPRING_ROLLS;
  }
  enum MainCourse implements Food {
    LASAGNE, BURRITO, PAD_THAI,
    LENTILS, HUMMOUS, VINDALOO;
  }
  enum Dessert implements Food {
    TIRAMISU, GELATO, BLACK_FOREST_CAKE,
    FRUIT, CREME_CARAMEL;
  }
  enum Coffee implements Food {
    BLACK_COFFEE, DECAF_COFFEE, ESPRESSO,
    LATTE, CAPPUCCINO, TEA, HERB_TEA;
  }
}
```

如果想创建一个“枚举的枚举”，那么可以创建一个新的enum，然后用其实例包装Food中的每一个enum类。

```
public enum Course {
  APPETIZER(Food.Appetizer.class),
  MAINCOURSE(Food.MainCourse.class),
  DESSERT(Food.Dessert.class),
  COFFEE(Food.Coffee.class);
  private Food[] values;
  private Course(Class<? extends Food> kind) {
    values = kind.getEnumConstants();
  }
  public Food randomSelection() {
    return Enums.random(values);
  }
}
```

另一种管理枚举的方法

```
enum SecurityCategory {
  STOCK(Security.Stock.class), BOND(Security.Bond.class);
  Security[] values;
  SecurityCategory(Class<? extends Security> kind) {
    values = kind.getEnumConstants();
  }
  interface Security {
    enum Stock implements Security { SHORT, LONG, MARGIN }
    enum Bond implements Security { MUNICIPAL, JUNK }
  }
  public Security randomSelection() {
    return Enums.random(values);
  }
  public static void main(String[] args) {
    for(int i = 0; i < 10; i++) {
      SecurityCategory category =
        Enums.random(SecurityCategory.class);
      System.out.println(category + ": " +
        category.randomSelection());
    }
  }
}
```

### 使用EnumSet替代标志

EnumSet（可能）就是将一个long值作为比特向量，所以EnumSet非常快速高效。

allOf(Class<E> elementType) 创建一个包含指定元素类型的所有元素的 EnumSet。 
clone() 返回set的副本
complementOf(EnumSet<E> s) 创建一个其元素类型与指定 EnumSet 相同的 EnumSet，最初包含指定 set 中所不包含的此类型的所有元素。 
copyOf(Collection<E> c) 创建一个从指定 collection 初始化的枚举 set。 
copyOf(EnumSet<E> s) 创建一个其元素类型与指定 EnumSet 相同的 EnumSet，最初包含相同的元素（如果有的话）。 
noneOf(Class<E> elementType) 创建一个具有指定元素类型的空 EnumSet。 
of() 创建一个最初包含指定元素的EnumSet。有很多个重载版本，接收1到5个参数的，以及可变参数的，表现出EnumSet对性能的注重。 
range(E from, E to) 创建一个最初包含由两个指定端点所定义范围内的所有元素的EnumSet。 

### 使用EnumMap

EnumMap速度很快，只能讲enum的实例作为键来调用put()方法，其它操作和一般Map差不多。

需要在EnumMap的构造器中指定enum类型。

与EnumSet一样，enum实例定义时的次序决定了其在EnumMap中的顺序。

与常量相关的方法相比，EnumMap有一个优点，那EnumMap允许程序员改变值对象，而常量相关的方法在编译期就固定了。

### 常量相关的方法

**Java允许enum实例编写方法，从而为每个enum实例赋予各自不同的行为。你需要为enum定义一个或多个abstract方法，然后为每个enum实例实现该抽象方法**。

通过相应的enum实例，我们可以调用其上的方法。这通常也称为表驱动的代码，注意它与命令模式的区别。

```
enum LikeClasses {
  WINKEN { void behavior() { print("Behavior1"); } },
  BLINKEN { void behavior() { print("Behavior2"); } },
  NOD { void behavior() { print("Behavior3"); } };
  abstract void behavior();
}
```

enum实例的这种特性，很像是子类的行为。enum元素都是static final的。

除了实现abstract方法外，也可以覆盖常量相关的方法。

使用enum可以实现职责链，状态机。

### 多路分发

Java只支持单路分发。也就是说，如果要执行的操作包含了不止一个类型未知的对象时，那么Java的动态绑定机制只能处理其中一个类型。

例如，Number是各种数字的超类，a，b都是Number类对象，执行a.plus(b)时，java的动态绑定机制可以判断调用方法的对象a的确切类型，但是却不知道b的确切类型。

**解决问题的办法就是多路分发（在上例中只有两个分发，一般称之为两路分发）。如果想使用两路分发，那么就必须有两个方法调用：第一个方法调用决定第一个未知类型，第二个方法调用决定第二个未知的类型。例如在plus方法中再执行 b.plus(this)**

书中举了“石头、剪刀、布”的例子，使用enum、常量相关的方法、EnumMap、二维数组进行多路的分发。

## 注解

> 注解：注解把元数据与源代码文件结合起来，使得我们能够以由编译器来测试和验证格式，存储有关程序的额外信息。注解在实际的源代码级别保存所有的信息，而不是某种注释性文字。

Java SE5内置了三种，定义在java.lang中的注解：

1. @Override，表示当前的方法定义将覆盖超类中的方法。如果你不小心拼写错误，或者方法签名对不上被覆盖的方法，编译器就会发出错误提示。
2. @Deprecated，如果程序员使用了注解为它的元素，那么编译器会发出警告信息
3. @SuppressWarnings，关闭不当的编译器警告信息。在Java SE5之前的版本中，也可以使用该注解，不过会被忽略不起作用。

每当你创建描述符性质的类或接口时，一旦其中包括了重复性的工作，那就可以考虑使用注解来简化与自动化该过程。

### 基本语法

从语法角度看，注解的使用方式几乎和修饰符的使用一样。

#### 定义注解

包 java.lang.annotation 中包含所有定义自定义注解所需用到的原注解和接口。**如接口 java.lang.annotation.Annotation 是所有注解继承的接口,并且是自动继承，不需要定义时指定，类似于所有类都自动继承Object**。

```
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface UseCase {
    public int id();
    public String description() default “no description”;
}
public class PasswordUtils {
    @UseCase(id=47, description=”Password must contain at least one numeric”)
    public boolean validatePassword(String password) {
        return password.matches(“\\w*\\d\\w*”);
    }
}
```
**定义注解时会需要一些元注解，@Target定义注解应用的地方；@Retention定义注解应用的级别**。

注解中，一般都会包含一些元素以表示某些值。当分析处理注解时，程序或工具可以利用这些值。注解的元素看起来就像接口的方法，唯一的区别是你可以为其指定默认值。没有元素的注解称为标记注解。

description元素有一个default值，如果在注解某个方法时没有给出description的值，则该注解的处理器就会使用此元素的默认值。

#### 元注解

元注解专职负责注解其他的注解。Java只内置了三种标准注解以及四种元注解。元注解定义如下：

接口        | 说明
---         | ---
@Target     | 定义注解应用的地方。包括：CONSTRUCTOR-构造器声明；FIELD-域声明；LOCAL_VARIABLE-局部变量声明；METHOD-方法声明；PACKAGE-包声明；PARAMETER-参数声明；TYPE-类、接口或enum声明
@Retention  | 定义注解应用的级别。包括：SOURCE-注解将被编译器丢弃；CLASS-注解在class文件中可用，但会被VM丢弃；RUNTIME-VM将在运行期也保留注解，因此可通过反射机制读取注解信息
@Documented | 将此注解包含在JavaDoc中
@Inherited  | 允许子类继承父类中的注解

### 编写注解处理器

使用注解的过程中，重要的部分是创建与使用注解处理器。Java SE5扩展了反射机制API，以帮助构造该类工具；同时，提供外部工具apt帮助解析带有注解的Java代码。
```
public class UseCaseTracker {
    public static void trackUseCases(List<Integer> useCases, Class<?> cl) {
        for (Method m : cl.getDeclaredMethods()) {
            UseCase uc = m.getAnnotation(UseCase.class);
            if (uc != null) {
                System.out.println(“Found Use Case: ” + uc.id() 
                + “ ” + uc.description());
                useCases.remove(new Integer(uc.id()));
            }
        }
        for (int i : UseCases) {
            System.out.println(“Warning: Missing use case-” + i);
        }
    }
}
```
**反射方法getDeclaredMethods()与getAnnotation()均属于AnnotationElement接口，Class、Method、Field均实现了该接口。getAnnotation()方法返回指定类型的注解对象。使用反射获取到注解对象之后，类似使用调用方法的方式获取注解的值，如uc.id()等**。

#### 注解元素

**注解元素可用基本类型包括：所有基本类型、String、Class、enum、Annotation以及所有前面这些类型的数组。不允许使用任何包装类型，注解可以嵌套**。

**因为注解是由编译器计算而来的，因此，所有元素值必须是编译期常量**。

如果元素值是一个数组，要将它的值用大括号括起来`@Test(array={"a","b"})`，如果只有一个值，也可以省去括号。

#### 默认值限制

**注解元素不能有不确定的值，也就是说，元素必须要么具有默认值，要么使用注解时提供元素的值**。
**不能以null作为其值。为了绕开这个约束，可以定义一些特殊的值，例如空字符串或负数，以表示某个元素不存在**。

#### 生成外部文件

部分Framework需要提供额外信息如XML描述文件才能与源代码协同工作，此时同一个类拥有两个单独的信息源，这常导致代码同步问题。但是使用注解，则可将所有信息都保存在JavaBean源文件中。

@Target注解中指定的每一个ElementType就是一个约束，它告诉编译器，这个自定义的注解只能应用于该类型。程序员可以指定enum ElementType中的某个值，或者以逗号分隔的形式指定多个值。如果想要将注解应用于所有ElementType，那么可以省去@Target元注解，不过这并不常见。

注解嵌套：

```
@Target(ElementType.FIELD)
@Retention(RetentionPolicy.RUNTIME)
public @interface Constraints {
    boolean primaryKey() default false;
    boolean allowNull() default true;
    boolean unique() default false;
}

@Target(ElementType.FIELD)
@Retention(RetentionPolicy.RUNTIME)
public @interface SQLString {
    int value() default 0;
    String name() default “”;
    Constraints constraints() default @Constraints(unique=true);
}
```
SQLString中元素constraints的类型就是一个注解。

快捷方式：
**注解中定义了名为value的元素，且在应用该注解时，若该元素是唯一需赋值元素，则无需使用名-值对语法，只需在括号内给出value值即可**。

```
pubic class Member {
    @SQLString(30)
    String firstName;
    @SQLString(value = 30, constraints = @Constraints(primaryKey = true))
    String handler;
}
```
其中`@SQLString(30)`就是只提供了一个值。

**变通之道**
嵌套注解有时会使代码非常复杂，可以同时使用两个注解类型来注解一个域。

#### 注解不支持继承

**由于注解没有继承机制，所以要获得近似多态的行为，使用getDeclaredAnnotations()是唯一的办法（Field类中提供该方法）**。

### 使用apt处理注解

> apt工具及其关联的API已被javac和标准注释处理API javax.annotation.processing 和 javax.lang.model取代。

与Javac一样，apt被设计为操作Java源文件，而不是编译后的类；自定义的每个注解都需要自己的处理器，而apt工具能够很容易的将多个注解处理器组合在一起。使用apt时必须指明一个工厂类，或者指明能找到apt所需工厂类的路径，apt需要工厂类来为其指明正确的处理器；使用apt生成注解处理器时，无法利用Java反射机制，因为操作的是源代码。

使用apt，以书中的annotations包为例。
首先，确保CLASSPATH变量中有tools.jar包，然后`cd TIJ4-code`，执行`javac annotations\InterfaceExtractorProcessorFactory.java`编译完成后，然后执行`apt -factory annotations.InterfaceExtractorProcessorFactory annotations\Multiplier.java -s annotations`

### 将观察者模式应用于apt

mirror API提供了对访问者设计模式的支持。
一个访问者会遍历某个数据结构或一个对象的集合，对其中的每一个对象执行一个操作，该数据结构无需有序，而你对每个对象执行的操作，都是特定于此对象的类型。这就是操作与对象解耦，也就是说，你可以添加新的操作，而无需向类的定义中添加方法。

### 基于注解单元测试

单元测试工具：JUnit。作者在书中提供了一个工具类库。

javassist应用于字节码工程。

### javac处理注解

Java SE 6 引入了一个新的功能，叫做 可插入注解处理（Pluggable Annotation Processing） 框架，它提供了标准化的支持来编写自定义的注解处理器。之所以称为“可插入”，是因为注解处理器可以动态插入到 javac 中，并可以对出现在 Java 源文件中的一组注解进行操作。此框架具有两个部分：一个用于声明注解处理器并与其交互的 API -- 包 javax.annotation.processing -- 和一个用于对 Java 编程语言进行建模的 API -- 包 javax.lang.model。

下面的例子可以提取出一个类中的public方法，构造成一个新的接口。
InterfaceExtractorProcessor.java 文件

```
package annotations;

import javax.annotation.processing.*;
import java.io.*;
import java.util.*;
import javax.tools.*;
import javax.lang.model.*;
import javax.lang.model.util.*;
import javax.lang.model.element.*;

@SupportedAnnotationTypes("annotations.ExtractInterface")
@SupportedSourceVersion(SourceVersion.RELEASE_8)
public class InterfaceExtractorProcessor extends AbstractProcessor {
    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv) {
        for (Element e : roundEnv.getElementsAnnotatedWith(ExtractInterface.class)) {
            Set<ExecutableElement> interfaceMethods = new HashSet<>();
            ExtractInterface annot = e.getAnnotation(ExtractInterface.class);
            for(ExecutableElement m : ElementFilter.methodsIn(e.getEnclosedElements())) {
                if(m.getModifiers().contains(Modifier.PUBLIC) &&
                        !(m.getModifiers().contains(Modifier.STATIC))
                        )
                    interfaceMethods.add(m);
            }
            if(interfaceMethods.size() > 0) {
                try {
                    JavaFileObject sourceFile = processingEnv.getFiler().createSourceFile(
                            annot.value());
                    PrintWriter writer = new PrintWriter(sourceFile.openWriter());
                    writer.println("package " +
                            processingEnv.getElementUtils().getPackageOf(e).getQualifiedName() +";");
                    writer.println("public interface " +
                            annot.value() + " {");

                    for(ExecutableElement m : interfaceMethods) {
                        writer.print("  public ");
                        writer.print(m.getReturnType() + " ");
                        writer.print(m.getSimpleName() + " (");
                        int i = 0;
                        
                        for(VariableElement parm : m.getParameters()) {
                            writer.print(parm.asType() + " " +
                                    parm.getSimpleName());
                            if(++i < m.getParameters().size())
                                writer.print(", ");
                        }
                        writer.println(");");
                    }
                    writer.println("}");
                    writer.close();
                } catch(IOException ioe) {
                    throw new RuntimeException(ioe);
                }
            }
        } 
        return true;
    }
} ///:~
```

ExtractInterface.java文件

```
package annotations;
import java.lang.annotation.*;

@Target(ElementType.TYPE)
@Retention(RetentionPolicy.SOURCE)
public @interface ExtractInterface {
  public String value();
} ///:~

```
Multiplier.java文件

```
package annotations;
@ExtractInterface("IMultiplier")
public class Multiplier {
  public int multiply(int x, int y) {
    int total = 0;
    for(int i = 0; i < x; i++)
      total = add(total, y);
    return total;
  }
  private int add(int x, int y) { return x + y; }
  public static void main(String[] args) {
    Multiplier m = new Multiplier();
    System.out.println("11*16 = " + m.multiply(11, 16));
  }
} 
```

自定义注解处理器继承 AbstractProcessor（这是 Processor 接口的默认实现），并覆盖 process() 方法。

注解处理器类将使用两个类级别的注解 @SupportedAnnotationTypes 和 @SupportedSourceVersion 来装饰。 SupportedSourceVersion 注解指定注解处理器支持的最新的源版本。SupportedAnnotationTypes 注解指示此特定的注解处理器对哪些注解感兴趣。例如，如果处理器只需处理 Java Persistence API (JPA) 注解，则将使用 @SupportedAnnotationTypes ("javax.persistence.*")。值得注意的一点是，如果将支持的注解类型指定为 @SupportedAnnotationTypes("*")，即使没有任何注解，仍然会调用注解处理器。这允许我们有效利用建模 API 以及 Tree API 来执行通用的源码处理。使用这些 API，可以获得与修改符、字段、方法等有关的大量有用的信息。

是否调用注解处理器取决于源码中存在哪些注解，哪些处理器配置为可用，哪些注解类型是可用的后处理器进程。注解处理可能发生在多个轮回中。例如，在第一个轮回中，将处理原始输入 Java 源文件；在第二个轮回中，将考虑处理由第一个轮回生成的文件，等等。自定义处理器应覆盖 AbstractProcessor 的 process()。此方法接受两个参数：

* 源文件中找到的一组 TypeElements/ 注解。
* 封装有关注解处理器当前处理轮回的信息的 RoundEnvironment。

如果处理器声明其支持的注解类型，则 process() 方法返回 true，而不会为这些注解调用其他处理器。否则，process() 方法返回 false 值，并将调用下一个可用的处理器（如果存在的话）。

我们使用下面的调用来创建源文件。

```
JavaFileObject sourceFile = processingEnv.getFiler().createSourceFile(annot.value());
PrintWriter writer = new PrintWriter(sourceFile.openWriter());
```

Java SE 6 的 javac 实用程序提供一个称为 -processor 的选项，来接受要插入到的注解处理器的完全限定名。

```
javac -processor ProcessorClassName1,ProcessorClassName2,...  sourceFiles
```

先编译注解处理器
```
javac annotations/InterfaceExtractorProcessor.java
```
然后运行
```
javac -processor annotations.InterfaceExtractorProcessor annotations/Multiplier.java
```
接口文件IMultiplier.java已经在当前路径下生成。
