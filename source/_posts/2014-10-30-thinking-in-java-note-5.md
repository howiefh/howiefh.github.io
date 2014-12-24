title: Java编程思想笔记五
date: 2014-10-30 11:54:53
tags: Thinking in Java
categories: Java
description: thinking in java; java编程思想; 数组; 容器深入研究
---
## 数组

### 数组为什么特殊

数组和其它容器之间的区别有三方面：效率、编译期类型检查和保存基本类型的能力，但是由于有了泛型容器和自动包装机制，现在最主要的区别就是效率。ArrayList效率低很多。
<!-- more -->

### 数组是第一级对象

数组标示符其实是一个引用，指向堆中创建的一个真实对象，可以作为数组初始化语法的一部分隐式的创建此对象，或者用new表达式显示的创建。只读成员length是唯一一个可以访问的字段或方法，通过length你知道的仅仅是数组的大小，而不是里面元素的个数。[]是访问数组对象的唯一方式。

对象数组和基本类型数组在使用上几乎是相同的，唯一区别是对象数组保存的是引用，基本类型数组直接保存基本类型的值。

新生成一个数组，其中所有引用被自动初始化为null，基本类型被初始化为0（boolean是false）。

初始化为指向一个BerylliumSphere引用的数组并给每个元素赋值
```
BerylliumSphere[] c = new BerylliumSphere[4];
for(int i = 0; i < c.length; i++)
    if(c[i] == null) // Can test for null reference
        c[i] = new BerylliumSphere();
```
聚集初始化语法创建数组对象：隐式的使用new语法在堆中创建(Aggregate initialization):
```
BerylliumSphere[] d = { new BerylliumSphere(),
        new BerylliumSphere(), new BerylliumSphere()
};
```
动态聚集初始化语法创建数组对象，这种方法可以在任意位置创建和初始化数组对象：(Dynamic aggregate initialization):
```
a = new BerylliumSphere[]{
        new BerylliumSphere(), new BerylliumSphere(),
};
```

### 返回一个数组

C或者C++中不能返回一个数组，而只能返回一个指向数组的指针，这回造成一些问题，使得控制数组的生命周期变得很困难，并且容易造成内存泄露。Java中，只需要直接返回一个数组即可。

### 多维数组

使用花括号创建多维数组，每对花括号括起来的集合都会把你带到下一级数组：
```
int[][] a = { { 1, 2, 3, }, { 4, 5, 6, }, };
System.out.println(Arrays.deepToString(a));
```
使用Arrays.deepToString()将多维数组转换为多个String

**粗糙数组**：数组中构成矩阵的每个向量都可以具有任意的长度
```
Random rand = new Random(47);
// 3-D array with varied-length vectors:
int[][][] a = new int[rand.nextInt(7)][][];
for(int i = 0; i < a.length; i++) {
    a[i] = new int[rand.nextInt(5)][];
    for(int j = 0; j < a[i].length; j++)
        a[i][j] = new int[rand.nextInt(5)];
}
System.out.println(Arrays.deepToString(a));
```
也可以使用聚集初始化语法创造粗糙数组。自动包装机制对数组初始化器也起作用

### 数组与泛型

通常，数组与泛型不能很好结合，你不能实例化具有参数化类型的数组。`Peel<Banana>[] peels = new Peel<>[10];`不合法，擦除会移除参数类型信息，而数组必须知道它们所持有的确切类型，以强制保证类型安全。


但是它允许你创建对这种数组的引用。你可以创建非泛型的数组，然后将其转型。
```
List<String>[] la = (List<String>[]) new ArrayList[10];
```
这样的问题是数组是协变类型的，因此List<String>[]也是一个Object[]，并且利用这点可以把ArrayList<Integer>赋值到数组中，不会有任何编译期或运行时错误。如果知道将来不会向上转型，并且需求也相对比较简单，那么你仍旧可以创建泛型数组。

你也可以参数化数组本身的类型：
```
class ClassParameter<T> {
    public T[] f(T[] arg) { return arg; }
}

class MethodParameter {
    public static <T> T[] f(T[] arg) { return arg; }
}
```
一般而言，泛型在类或方法的边界处很有效，而在类或方法的内部，擦除会使得泛型变得不适用，例如，你不能创建泛型数组：
```
// 非法！
//! array = new T[size];
array = (T[])new Object[size]; // "unchecked" Warning
// 非法！
//! public <U> U[] makeArray() { return new U[10]; }
```
由于试图创建的类型已被擦除，所以是类型未知的数组，你可以创建Object数组然后将其转型，但是会得到一个"不受检查"的警告，因为这个数组没有真正持有或动态检查类型T。

### 创建测试数据

#### Arrays.fill()

只能用同一个值（同一个对象引用，因此数组中所有元素都指向同一个对象）填充各个位置，可以填充整个数组或数组的某个区域。

#### 数据生成器

为了更灵活的创建更有意义的数组，可以使用数据生成器。
```
interface Generator<T> { T next(); } 
```

### Arrays实用功能

Arrays类有一套用于数组的静态方法（所有这些方法对各种基本类型和Object类而重载过）：

| 方法           | 说明                                             |
|----------------|--------------------------------------------------|
| equals()       | 比较两个数字是否相等                             |
| deepEquals()   | 用于多维数组比较                                 |
| fill()         | 填充数组                                         |
| sort()         | 数组排序                                         |
| binarySearch() | 在已经排序的数组中查找元素                       |
| toString       | 产生数组的String表示                             |
| hashCode()     | 产生数组的散列码                                 |
| asList()       | 接受任意的序列或数组作为其参数，并转换为List容器 |

#### 复制数组

System.arraycopy(): 复制数组，比用for循环复制要快很多，该方法对有所类型做了重载，下面是处理int数组的例子：
注意复制对象数组的时候，只是浅复制。另外，System.arraycopy()不会执行自动包装和自动拆包，两个数组必须具有相同的类型。

#### 数组的比较

Arrays.equals(): 相等的条件：元素个数相等，对应位置的元素也相等。

#### 数组元素的比较

程序设计的基本目标是“将保持不变的事物与发生改变的事物相分离”。使用策略设计模式，可以将“会发生变化的代码”封装在单独的类中，你可以将策略对象传递给总是相同的代码，这些代码将使用策略来完成其算法。

Java有两种方式来提供比较功能。第一种是通过类实现Comparable接口（此接口只有一个compareTo()方法）。
第二种是创建实现了Comparator接口的单独的类。这种方法在已有的类并没有实现Comparable接口或实现了该接口但是实现方式不太满意的时候使用。

Collections的reverseOrder方法可以产生一个Comparator，可以反转自然的排序顺序：

#### 数组排序

使用内置的排序方法，可以对任意的基本类型数组排序，也可以对对象数组排序，只要该对象实现了Comparable接口，或者具有相关联的Comparator:
Java标准库中的排序算法针对正排序的特殊类型进行了优化： 针对基本类型的快速排序；针对对象设计的“稳定归并排序”。所以无需担心排序的性能问，除非确实确定了排序不分是程序效率的瓶颈。

#### 在已排序的数组中查找

如果数组排好序了，可以使用Arrays.binarySearch()进行查找，对未排序的数组使用binarySearch，会产生意想不到的结果。

* 查找到了则返回大于等于0的整数
* 否则返回负值，表示保持数组排序状态下此目标所应该插入的位置，此负值计算方法： `-(插入点) - 1`

如果使用Comparator排序对象数组（基本类型数组无法使用Comparator进行排序）了，使用binarySearch对对象数组进行排序的时候必须提供同样的Comparator

优先容器而不是数组，只有在证明性能成为问题，并且切换到数组对性能有所帮助时，你才应该将程序重构为使用数组。

## 容器深入研究

### 完整的容器分类法

![完整的容器分类法](http://fh-1.qiniudn.com/full_container_taxonomy.png)
虚线框表示abstract类，Abstract开头的类是部分实现了特定接口的工具。

### 填充容器

static方法`Collections.fill()`、`Collections.nCopies()`只复制一个对象引用来填充整个容器，并且只对List对象有用，但是所产生的列表可以传递给构造器或`addAll()`方法。

`Collections.fill()`方法只能替换已经在List中存在的元素，而不能添加新的元素。

`Object.toString()`：该类的名字+该对象的散列码(无符号十六进制表示，通过调用`hashCode()`生成的)

#### 一种Generator解决方案

所有的Collection子类型都有一个接收另一个Collection对象的构造器，用所接收的Collection对象中的元素来填充新的容器。 

#### Map生成器

可以使用工具来创建任何用于Map或Collection的生成数据集，然后通过构造器或`Map.putAll()`和`Collection.addAll()`方法来初始化Map和Collection。

#### 使用Abstract类

对于产生用于容器的测试数据问题，另一种解决方式是创建定制的Collection和Map实现。每个java.util容器都有其自己的Abstract类，它们提供了该容器的部分实现，因此你必须做的只是去实现那些产生想要的容器所必需的方法。如果所产生的容器是只读的，那么你提供的方法数量将减少到最少。

亨元：在普通的解决方案需要过多的对象，或者产生普通对象太占用空间时使用亨元。亨元模式使得对象的一部分可以被具体化，因此，与对象中的所有事物都包含在对象内部不同，我们可以在更高效的外部表中查找对象的一部分或整体（或者通过其他节省空间的计算来产生对象的一部分或整体）。 

为了创建只读的Map，可以继承AbstractMap并实现`entrySet()`，为了创建只读的Set，可以继承AbstractSet并实现`iterator()`和`size()`。

net/mindview/util/Countries.java代码:`FlyweightMap`必须实现`entrySet()`方法，它需要定制的Set实现和定制的`Map.Entry`类。这里正是亨元部分：每个`Map.Entry`对象都只存储了它的索引，而不是实际的键和值。当你调用`getKey()`和`getValue()`时，它们会使用该索引来返回恰当的DATA元素。EntrySet可以确保它的size不会大于DATA。

### Collection的功能方法

也是Set或List可以执行的操作(List还有额外的功能),Map不是继承自Collection的。

方法                                      | 描述 
---                                       | ---
`boolean add(T)`                          | 确保容器持有具有泛型类型T的参数。如果没有将此参数添加进容器，则返回false（这是可选的方法）
`boolean addAll(Collection<? extends T>)` | 添加参数中所有元素。只要添加了任意元素就返回true（可选）
`void clear()`                            | 移除容器中的所有元素(可选)
`boolean contains(T)`                     | 如果容器中已经持有具有泛型类型T此参数，则返回true
`boolean containsAll(Collection<?>)`      | 如果容器持有此参数中的所有元素，则返回true
`boolean isEmpty()`                       | 容器中没有元素时返回true。
`Iterator<T> iterator()`                  | 返回一个Iterator<T>，可以用来遍历容器中的所有元素。
`boolean remove(Object)`                  | 如果参数在容器中，则移除此元素的一个实例。如果做了移除动作，则返回true(可选的)
`boolean removeAll(Collection<?>)`        | 移除参数中的所有元素。只要有移除动作发生就返回true。（可选的）
`boolean retainAll(Collection<?>)`        | 只保存参数中的元素（应用集合论的“交集”概念）。只要Collection发生了改变就返回true。(可选)
`int size()`                              | 返回容器中元素的数目
`Object[] toArray()`                      | 返回一个数组，该数组包含容器中的所有元素。
`<T> T[] toArray(T[] a)`                  | 返回一个数组，该数组包含容器中的所有元素。返回结果的运行时类型与参数数组a的类型相同，而不是单纯的Object。

**请注意，其中不包括随机访问选择元素的get()方法。因为Collection包括Set，而Set是自己维护内部顺序的（这使得随机访问变得没有意义）。因此，如果想检查Collection中的元素，就必须使用迭代器。**

### 可选操作

执行各种不同的添加和移除的方法在Collection接口中都是可选操作。这意味着实现类并不需要为这些方法提供功能定义。

这是一种不寻常的接口定义方式。接口是面向对象设计中的契约，它声明“无论你选择如何实现该接口，我保证你可以向该接口（描述正式的interface关键字和“任何类或子类支持的方法”）发送这些消息。”但是可选操作违反了这个非常基本的原则，它声明调用这些方法将不会执行有意义的行为，相反，它们会抛出异常。这看起来好像是编译器类型安全被抛弃了。 

事情并不那么糟。如果一个操作是可选的，编译器仍旧会严格要求你只能调用该接口中的方法。这与动态语言不同，动态语言可以在任何对象上调用任何方法，并且可以在运行时发现某个特定调用是否可以工作。

为什么你会将方法定义为可选的呢？那是因为这样做可以防止在设计中出现接口爆炸的情况。“未获支持的操作”这种方式可以实现Java容器类库的一个重要目标：容器应该易学易用。未获支持的操作是一种特例，可以延迟到需要时再实现。但是，为了让这种方式能够工作：

- UnsupportedOperationException必须是一种罕见事情。即，对于大多数类来说，所有操作都应该可以工作，只有在特例中才会有未获支持的操作。在Java容器类库中确实如此，因为你在90%的时间里面使用的容器类，如ArrayList、LinkedList、HashSet和HashMap，以及其他的具体实现，都支持所有的操作。这种设计留下了一个“后门”，如果你想创建新的Collection，但是没有为Collection接口中的所有方法都提供有意义的定义，那么它仍旧适合现有的类库。
- 如果一个操作是未获支持的，那么在实现接口的时候可能就会导致UnsupportedOperationException异常，而不是将产品交给客户以后才出现异常，这种情况是有道理的。毕竟，它表示编程上有错误：使用了不正确的接口实现。

值得注意的是，未获支持的操作只有在运行时才能探测到，因此它们表示动态类型检查。如果你以前使用的是像C++这样的静态类型语言，那么可能会觉得Java也只是另一种静态类型语言，但是它还有大量的动态类型机制，因此很难说它到底是哪一种类型的语言。

#### 未获支持的操作

最常见的未获支持的操作，都来源于背后由固定尺寸的数据结构支持的容器。当你用Arrays.asList()将数组转换为List时，就会得到这样的容器。你还可以通过使用Collection类中“不可修改”的方法，选择创建任何会抛出UnsupportedOperationException的容器（包括Map）。

因为`Arrays.asList()`会生成一个List，它基于一个固定大小的数组，任何会引起对底层数据结构的尺寸进行修改的方法都会产生一个`UnsupportedOperationException`异常，以表示对未获支持操作的调用（一个编程错误）。

注意，应该把`Arrays.asList()`的结果作为构造器的参数传递给任何Collection（或者使用`addAll()`方法或`Collections.addAll()`静态方法），这样可以生成允许使用所有的方法的普通容器。Collections类中的“不可修改”的方法（unmodifiableList()）将容器包装到一个代理中，只要你执行任何视图修改容器的操作，这个代理都会产生`UnsupportedOperationException`异常。使用这些方法的目标就是产生“常量”容器对象。

`Arrays.asList()`返回固定尺寸的List，而`Collections.unmodifiableList()`产生不可修改的列表。

### List的功能方法

基本的List使用：调用`add()`添加对象，使用`get()`一次取出一个元素，以及调用`iterator()`获取用于该序列的Iterator。


### Set和存储顺序

类                             | 描述
---                            | ---
Set(interface)                 | 存入Set的每个元素都必须是唯一的，因为Set不保存重复元素。加入Set的元素必须定义equals()方法以确保对象唯一性。Set与Collection有完全一样的接口。Set接口不保证维护元素的次序。
HashSet                        | 如果没有其他的限制，这就应该是你默认的选择，因为它对速度进行了优化，为快速查找而设计的Set。存入HashSet的元素必须定义hashCode()
TreeSet（SortedSet的唯一实现） | 保存次序的Set，底层为树结构。使用它可以从Set中提取有序的序列。元素必须实现Comparable接口
LinkedHashSet                  | 具有HashSet的查询速度，且内部使用链表维护元素的顺序（插入的次序））。于是在使用迭代器遍历Set时，结果会按元素插入的次序显示。元素也必须定义hashCode()方法

你必须为散列存储和树形存储都创建一个`equals()`方法，但是**`hashCode()`只有在这个类将会被置于`HashSet`(这是有可能的，因为它通常是你的Set实现的首先)或者`LinkedHashSet`中时才是必须的。**但是，对于良好的编程风格而言，你应该在覆盖`eqauls()`方法时，总是同时覆盖`hashCode()`方法。

在`compareTo()`中，我没有使用“简洁明了”的形式`return i – i2`，因为这是一个常见的编程错误，它只有在i和i2都是无符号的int时才能正确工作。对于Java的有符号int，它就会出错，因为int不够大，不足以表现两个有符号的int的差。例如i是很大的正整数，而j是很大的负整数，`i-j`就会溢出并且返回负值，这就不正确了。

#### SortedSet

`SortedSet`中的元素可以保证处于排序状态： 
`Comparator comparator()` 返回当前Set使用的Comparator；或者返回null，表示以自然方式排序。
`Object first()`返回容器中的第一个元素
`Object last()`返回容器中的最末一个元素
`SortedSet subSet(fromElement,toElement)`生成此Set的子集，范围从fromElement(包含)到toElement(不包含)
`SortedSet headSet(toElement)`生成此Set的子集，由小于toElement的元素组成
`SortedSet tailSet(fromElement)` 生成此Set的子集，由大于或等于fromElement的元素组成

### 队列

除了并发应用，Queue在Java SE5中仅有的两个实现是`LinkedList`和`PriotityQueue`，它们的差异在于排序行为而不是性能。 

除了优先级队列，`Queue`将精确地按照元素被置于`Queue`中的顺序产生它们。

#### 双向队列

可以在任何一端添加或移除元素

在`LinkedList`中包含支持双向队列的方法，但是在Java标准类库中没有任何显式的用于双向队列的接口。因此`LinkedList`无法去实现这样的接口，你也无法像在前面的实例中转型到`Queue`那样去向上转型到`Deque`。但是，你可以使用组合来创建一个`Deque`类，并直接从LinkedList中暴露相关的方法。

### 理解Map

#### 性能

散列码是“相对唯一的”、用以代表对象的int值，它是通过将该对象的某些信息进行转换而生成的。

class                       | description
---                         | ---
HashMap(默认选择，速度最快) | Map基于散列表的实现（它取代了Hashtable）。插入和查询“键值对”的开销是固定的。可以通过构造器设置容量和负载因子，以调整容器的性能。
LinkedHashMap               | 类似于HashMap，但是迭代遍历它时，取得“键值对”的顺序是其插入次序，或者是最近最少使用(LRU)的次序。只比HashMap慢一点；而在迭代访问时反而更快，因为它使用链表维护内部次序。
TreeMap                     | 基于红黑树的实现。查看“键”或“键值对”时，它们会被排序（次序由Comparable或Comparator决定）。TreeMap的特点在于，所得到的结果是经过排序的。TreeMap是唯一的带有subMap()方法的Map，它可以访问一个子树。
WeakHashMap                 | 弱键(weak key)映射，允许释放映射所指向的对象；这是为解决某类特殊问题而设计的。如果映射之外没有引用指向某个“键”，则此“键”可以被垃圾回收器回收
ConcurrentHashMap           | 一种线程安全的Map，它不涉及同步加锁。
IdentityHashMap             | 使用==代替equals()对“键”进行比较的散列映射。专为解决特殊问题而设计的。

对Map中使用的键的要求与对Set中的元素的要求一样，任何键都必须具有一个`equals()`方法；如果键被用于散列Map，那么它必须还具有恰当的`hashCode()`方法；如果键被用于`TreeMap`，那么它必须实现`Comparable`。

#### SortedMap

使用`SortedMap`(`TreeMap`是其现阶段的唯一实现)，可以确保键处于排序状态。这使得它具有额外的功能。

`Comparator comparator()`：返回当前Map使用的Comparator；或者返回null，表示以自然方式排序。`K firstKey()`返回Map中的第一个键。`K lastKey()`返回Map中的最末一个键。`SortedMap subMap(K fromKey, K toKey)`生成此Map的子集，范围由fromKey（包含）到toKey（不包含）的键确定。`SortedMap headMap(K toKey)`生成此Map的子集，由键小于toKey的所有键值对组成。`SortedMap tailMap(K fromKey)`生成此Map的子集，由键大于或等于fromKey的所有键值对组成。

#### LinkedHashMap

为了提高速度，`LinkedHashSet`散列化所有的元素，但是在遍历键值对时，却又以元素的插入顺序返回键值对。此外，可以在构造器中设定`LinkedHashSet`，使之采用基于访问的最少使用(LRU)算法，于是没有被访问过的（可被看作需要删除的）元素就会出现在队列的前面。对于需要定期清理元素以节省空间的程序来说，此功能使得程序很容易得以实现。

### 散列与散列码

标准类库中的类被用作`HashMap`的键，它用得很好，因为它具备了键所需的全部性质。当你创建用作`HashMap`的键的类，有可能会忘记在其中放置必需的方法，而这是通常会犯的一个错误。

#### 正确的equals()方法必须满足下列5个条件：

- 自反性。对任意x，`x.equals(x)`一定返回true。
- 对称性。对任意x和y，如果`y.equals(x)`返回true，则`x.equals(y)`也返回true。 
- 传递性。对任意x、y、z，如果`x.equals(y)`返回true，`y.equals(z)`返回true，则`x.equals(z)`一定返回true。
- 一致性。对任意x和y，如果对象中用于等价比较的信息没有改变，那么无论调用`x.equals(y)`多少次，返回的结果应该保持一致，要么一直是true，要么一直是false。
- 对任何不是null的x，`x.equals(null)`一定返回false。

再次强调，默认的`Object.equals()`只是比较对象的地址，所以一个`Groundhog(3)`并不等于另一个`Groundhog(3)`。因此，如果要使用自己的类作为HashMap的键，必须同时重载`hashCode()`和`equals()`。

`hashCode()`并不需要总是能够返回唯一的标识码，但是`equals()`方法必须严格地判断两个对象是否相同。
`instanceof`悄悄地检查了此对象是否为`null`，因为如果`instanceof`左边的参数为`null`，它会返回`false`。

#### 理解hashCode()

如果不为你的键覆盖`hashCode()`和`equals()`，那么使用散列的数据结构（`HashSet`，`HashMap`，`LinkedHashSet`或`LinkedHashMap`）就无法正确处理你的键。

`entrySet()`的恰当实现应该在Map中提供视图，而不是副本，并且这个视图允许对原始映射表进行修改（副本就不行）。 
在MapEntry中的eqauls()方法必须同时检查键和值。

#### 为速度而散列

散列的价值在于速度：散列使得查询得以快速进行。由于瓶颈位于键的查询速度，因此解决方案之一就是保持键的排序状态，然后使用`Collections.binarySearch()`进行查询。

存储一组元素最快的数据结构是数组，所以使用它来表示键的信息（请小心留意，我是说键的信息，而不是键本身）。数组并不保存键本身。而是通过键对象生成一个数字，将其作为数组的下标。这个数字就是散列码，由定义在Object中的、且可能由你的类覆盖的`hashCode()`方法（在计算机科学的术语中称为散列函数）生成。

为解决数组容量被固定的问题，不同的键可以产生相同的下标。也就是说，可能会有冲突。因此，数组多大就不重要了，任何键总能在数组中找到它的位置。通常，冲突由外部链接处理：数组并不直接保存值，而是保持值的list。然后对list中的值使用equals()方法进行线性的查询。这部分的查询自然会比较慢，但是，如果散列函数好的话，数组的每个位置就只有较少的值。因此，不是查询整个list，而是快速地跳到数组的某个位置，只对很少的元素进行比较。这便是HashMap会如此快的原因。

散列表中的槽位通常称为桶位(bucket)。

为使散列分布均匀，桶的数量通常使用质数。事实证明，质数实际上并不是散列桶的理想容量。近来，（经过广泛的测试）Java的散列函数都使用2的整数次方。对现在的处理器来说，除法与求余是最慢的操作。使用2的整数次方长度的散列表，可以用掩码代替除法。因为`get()`是使用最多的操作，求余数的%操作是其开销最大的部分，而使用2的整数次方可以消除此开销（也可能对hashCode()有些影响）。

#### 覆盖hashCode()

设计`hashCode()`时最重要的因素就是：无论何时，对同一个对象调用`hashCode()`都应该生成同样的值。如果在将一个对象用`put()`添加进HashMap时产生一个`hashCode()`，而用`get()`取出时却产生了另一个`hashCode()`值，那么就无法重新取得该对象了。

此外，也不应该使`hashCode()`依赖于具有唯一性的对象信息，尤其是使用this的值，这只能产生很糟糕的`hashCode()`。因为这样做无法生成一个新的键，使之与`put()`中原始的键值对中的键相同。应该使用对象内有意义的识别信息。

对于String而言，`hashCode()`明显是基于String的内容的。

因此，要想使`hashCode()`实用，它必须速度快并且必须有意义。也就是说，它必须基于对象的内容生成散列码。散列码不必是独一无二的（应该更关注生成速度，而不是唯一性），但是通过`hashCode()`和`equals()`，必须能够完全确定对象的身份。

因为在生成桶的下标前，`hashCode()`还需要做进一步的处理，所以散列码的生成范围并不重要，只要是`int`即可。

还有另外一个影响因素：好的`hashCode()`应该能够产生分布均匀的散列码。如果散列码都集中在一块，那么`HashMap`或者`HashSet`在某些区域的负载会很重，这样就不如分布均匀的散列函数快。

- 给`int`变量result赋予某个非零常量
- 为对象内每个有意义的域f(即每个可以做equals()操作的域)计算出一个int散列码e:

域类型                                 | 计算                                                           
---                                    | ---                                                            
boolean                                | `c=(f?0:1)`                                                    
byte、char、short或int                 | `c=(int)f`                                                     
long                                   | `c=(int)(f^(f>>>32))`                                          
float                                  | `c=Float.floatToIntBits(f);`                                   
double                                 | `long l = Double.doubleToLongBits(f);<br/>c=(int)(l ^ (l>>>32))`
Object，其equals()调用这个域的equals() | `c=f.hashCode()`                                               
数组                                   | 对每个元素应用上述规则                                         

- 合并计算得到的散列码： 
    result = 37*resutl + c;
- 返回result。
- 检查`hashCode()`最后生成的结果，确保相同的对象有相同的散列码。

**编写正确的hashCode()和equals()类库**
Apache的Jakarta Commons项目中有很多工具可以帮助你编写正确的`hashCode()`和`equals()`。

### 选择接口的不同实现

只有四种容器：`Map`、`List`、`Set`和`Queue`。`Hashtable`、`Vector`和`Stack`的“特征”是，它们是过去遗留下来的类，目的只是为了支持老的程序。（最好不要在新的程序中使用它们）。

### 性能测试框架

为了防止代码重复以及为了提供测试的一致性，将测试过程的基本功能放置到了一个测试框架中。(模板方法设计模式)

通常System.nanoTime()所产生的值的粒度都会大于1（这个粒度会随机器和操作系统的不同而不同），因此，在结果中可能会存在在某些时间点上的重合。

#### 对List的选择

最佳的做法可能是将ArrayList作为默认首选，只有你需要使用额外的功能，或者当程序的性能因为经常从表中间进行插入和删除而变坏的时候，才去选择LinkedList。如果使用的是固定数量的元素，那么既可以选择使用背后有数组支持的List(就像Arrays.asList产生的列表)，也可以选择真正的数组。
CopyOnWriteArrayList是List的一个特殊实现，专门用于并发编程。

#### 微基准测试的危险

在编写所谓的微基准测试时，你必须要当心，不能做太多的假设，并且要将你的测试窄化。你还必须仔细地确保你的测试运行足够长的时间，以产生有意义的数据，并且要考虑到某些Java HotSpot技术只有在程序运行了一段时间之后才会踢爆问题（这对于短期运行的程序来说也很重要）。根据计算机和所使用的JVM的不同，所产生的结果也会有所不同。

剖析器可以把性能分析工作做得比你好。Java提供了一个剖析器。

#### 对Set的选择

HashSet的性能基本上总是比TreeSet好，特别是在添加和查询元素时，而这两个操作也是最重要的操作。TreeSet存在的唯一原因是它可以维持元素的排序状态，所以，只有当需要一个排好序的Set时，才应该使用TreeSet。因为其内部结构支持排序，并且因为迭代是我们更有可能执行的操作，所以，用TreeSet迭代通常比用HashSet要快。

注意，对于插入操作，LinkedHashSet比HashSet的代价更高；这是由维护链表所带来额外开销造成的。

#### 对Map的选择

除了IdentityHashMap，所有的Map实现的插入操作都会随着Map尺寸的变大而明显变慢。但是，查找的代价通常比插入要小得多，这是个好消息，因为我们执行查找元素的操作要比执行插入元素的操作多得多。

Hashtable的性能大体上与HashMap相当。因为HashMap是用来代替Hashtable的，因此它们使用了相同的底层存储和查找机制。
TreeMap通常比HashMap要慢。与使用TreeSet一样，TreeMap是一种创建有序列表的方式。树的行为是：总是保证有序，并且不必进行特殊的排序。一旦你填充了一个TreeMap，就可以调用keySet()方法来获取键的Set视图，然后调用toArray()来产生由这些键构成的数组。之后，你可以使用静态方法Arrays.binarySearch()在排序数组中快速查找对象。当然，这只有在HashMap的行为不可接受的情况下才有意义，因为HashMap本身就被设计为可以快速查找键。你还可以很方便地通过单个的对象创建操作，或者是调用putAll()，从TreeMap中创建HashMap。最后，当使用Map时，你的第一选择应该是HashMap，只有在你要求Map始终保持有序时，才需要使用TreeMap。
LinkedHashMap在插入时比HashMap慢一点，因为它维护了散列数据结构的同时还要维护链表（以保持插入顺序）。这是由于这个列表，使得其迭代速度更快。
IdentityHashMap则具有完全不同的性能，因为它使用==而不是equals()来比较元素。

**HashMap的性能因子**
可以通过手工调整HashMap来提高其性能，从而满足我们特定应用的需求。
容量：表中的桶位数
初始容量：表在创建时所拥有的桶位数。HashMap和HashSet都具有允许你指定初始容量的构造器。
尺寸：表中当前存储的项数。
负载因子：尺寸/容量。空表的负载因子是0，而半满表的负载因子是0.5，依次类推。负载轻的表产生冲突的可能性小，因此对于插入和查找都是最理想的（但是会减慢使用迭代器进行遍历的过程）。HashMap和HashSet都具有允许你指定负载因子的构造器，表示当负载情况达到该负载因子的水平时，容器将自动增加其容量（桶位数），实现方式是使容量大致加倍，并重新将现有对象分布到新的桶位集中（则被称为再散列）

HashMap使用的默认负载因子是0.75（只有当表达到四分之三满时，才进行再散列），这个因子在时间和空间代价之间达到了平衡。更高的负载因子可以减低表所需的空间，但是会增加查找代价，这很重要，因为查找是我们在大多数时间里所做的操作（包括get()和put()）。
如果你知道将在HashMap中存储多少项，那么创建一个具有恰当大小的初始容量将可以避免自动再散列的开销。

### 实用方法(java.util.Collections)

- 产生Collection或者Collection的具体子类型的动态类型安全的视图。在不可能使用静态检查版本时使用这些方法。
    {% codeblock %}
    checkedCollection(Collection<T>, Class<T> type)
    checkedList(List<T>,Class<T> type)
    checkedMap(Map<K,V>,Class<K> keyType,Class<V> valueType)
    checkedSet(Set<T>,Class<T> type)
    checkedSortedMap(SortedMap<K,V>,Class<K> keyType,Class<V> valueType)
    checkedSortedSet(SortedSet<T>,Class<T> type)
    {% endcodeblock %}
- 返回参数Collection中最大或最小的元素——采用Collection内置的自然比较法
    {% codeblock %}
    max(Collection)
    min(Collection)
    {% endcodeblock %}
- 返回参数Collection中最大或最小的元素——采用Comparator进行比较
    {% codeblock %}
    max(Collection,Comparator)
    min(Collection,Comparator)
    {% endcodeblock %}
- 返回target在source中第一次出现的位置，或者在找不到时返回-1
    `indexOfSubList(List source，List target)`
- 返回target在source中最后一次出现的位置，或者在找不到时返回-1
    `lastIndexOfSubList(List source，List target)`
- 使用newVal替换所有的oldVal
    `replaceAll(List<T>,T oldVal,T newVal)`
- 逆转所有元素的次序
    `reverse(List)`
- 返回一个Comparator，它可以逆转实现了`Comparator<T>`的对象集合的自然顺序。第二个版本可以逆转所提供的Comparator的顺序
    {% codeblock %}
    reverseOrder()
    reverseOrder(Comparator<T>)
    {% endcodeblock %}
- 所有元素向后移动distance个位置，将末尾的元素循环到前面来
    `rotate(List,int idstance)`
- 随机改变指定列表的顺序。第一种形式提供了其自己的随机机制，你可以通过第二种形式提供自己的随机机制
    {% codeblock %}
    shuffle(List)
    shuffle(List,Random)
    {% endcodeblock %}
- 使用`List<T>`中的自然顺序排序。第二种形式允许提供用于排序的Comparator
    {% codeblock %}
    sort(List)
    sort(List,Random)
    {% endcodeblock %}
- 将src中的元素复制到dest
    `copy(List<? super T> dest,List<? extends T> src)`
- 交换list中位置i和位置j的元素。通常比你自己写的代码快。
    `swap(List,int i,int j)`
- 用对象x替换list中的所有元素
    `fill(List<? super T>,T x)`
- 返回大小为n的`List<T>`,此List不可改变，其中的引用都指向x。
    `nCopies(int n,T x)`
- 当两个集合没有任何相同元素时，返回true
    `disjoint(Collection,Collection)`
- 返回Collection中等于x的元素的个数
    `frequency(Collection,Object x)`
- 返回不可变的空List、Map或Set。这些方法都是泛型的，因此所产生的结果将被参数化为所希望的类型
    {% codeblock %}
    emptyList()
    emptyMap()
    emptySet()
    {% endcodeblock %}
- 产生不可变的`Set<T>`、`List<T>`或`Map<K,V>`,它们都只包含基于所给定参数的内容而形成的单一项。
    {% codeblock %}
    singleton(T x)
    singletonList(T x)
    singletonMap(K key,V value)
    {% endcodeblock %}
- 产生一个`ArrayList<T>`，它包含的元素的顺序，与（旧式的）Enumeration(Iterator的前身)返回这些元素的顺序相同。用来转换遗留的老代码。
    `list(Enumeration<T> e)`
- 为参数生成一个旧式的`enumeration<T>`
    `enumeration(Collection<T>)`

注意：min()和max()能作用于Collection对象，所以你无需担心Collection是否应该被排序(只有在执行binarySearch()之前，才确实需要对List或数组进行排序)
与使用数组进行查询和排序一样，如果使用Comparator进行排序，那么binarySearch()必须使用相同的Comparator。

#### 设定Collection或Map为不可修改

对特定类型的“不可修改的”方法的调用并不会产生编译时的检查，但是转换完成后，任何会改变容器内容的操作都会引起UnsupportedOperationException异常。
无论哪一种情况，在将容器设为只读之前，必须填入有意义的数据。装载数据后，就应该使用“不可修改的”方法返回的引用去替换掉原本的引用。这样，就不必担心无意中修改了只读的内容。另一方面，此方法允许你保留一份可修改的容器，作为类的private成员，然后通过某个方法调用返回该容器的“只读”的引用。这样一来，就只有你可以修改容器的内容，而别人只能读取。

#### Collection或Map的同步控制

Collections类有办法能够自动同步整个容器。其语法与“不可修改的”方法相似。

快速报错
Java容器有一种保护机制，能够防止多个进程同时修改同一个容器的内容。Java容器类类库采用快速报错机制(fail-fast)。它会探查容器上的任何除了你的进程所进行的操作以外的所有变化，一旦它发现其他进程修改了容器，就会立刻抛出ConcurrentModificationException异常。这就是“快速报错”的意思——即，不是使用复制的算法在事后来检查问题。
“快速报错”机制的工作原理：只需创建一个迭代器，然后向迭代器所指向的Collection添加点什么

在容器取得迭代器之后，又有东西被放入到了该容器中。当程序的不同部分修改同一个容器时，就可能导致容器的状态不一致，所以，此异常提醒你，应该修改代码。在此例中，应该添加完所有的元素之后，再获取迭代器。

ConcurrentHashMap、CopyOnWriteArrayList、CopyOnWriteArraySet都使用了可以避免ConcurrentModificationException 的技术

### 持有引用

java.lang.ref类库包含了一组类，这些类为垃圾回收提供了更大的灵活性。当存在可能会耗尽内存的大对象的时候，这些类显得特别有用。有三个继承自抽象类Reference的类：SoftReferenct、WeakReference和PhantomReference。当垃圾回收器正在考察的对象只能通过某个Reference对象才“可获得”时，上述这些不同的派生类为垃圾回收器提供了不同级别的间接性指示。

对象是可获得的（reachable），是指此对象可在程序中的某处找到。这意味着你在栈中有一个普通的引用，而它正指向此对象；也可能是你的引用指向某个对象，而那个对象含有另一引用指向正在讨论的对象；也可能有更多的中间链接。如果一个对象是“可获得的”，垃圾回收器就不能释放它，因为它仍然为你的程序所用。如果一个对象不是“可获得的”，那么你的程序将无法使用到它，所以将其回收是安全的。

如果想继续持有对某个对象的引用，希望以后还能够访问到该对象，但是也希望能够允许垃圾回收器释放它，这时就应该使用Reference对象。这样，你可以继续使用该对象，而在内存消耗殆尽的时候又允许释放该对象。

以Reference对象作为你和普通引用之间的媒介（代理），另外，一定不能有普通的引用指向那个对象，这样就能达到上述的目的。（普通的引用指没有经Reference对象包装过的引用。）如果垃圾回收器发现某个对象通过普通引用是可获得的，该对象就不会被释放。

SoftReference、WeakReference和PhantomReference由强到弱排列，对应不同级别的“可获得”。SoftReference用以实现内存敏感的高速缓存。WeakReference是为实现“规范映射”（canonicalizing mapping）而设计的，它不妨碍垃圾回收器回收映射的“键”（或“值”）。“规范映射”中对象的实例可以在程序的多处被同时使用，以节省存储空间。PhantomReference用以调度回收前的清理工作，它比Java终止机制更灵活。

使用SoftReference和WeakReference时，可以选择是否要将它们放入ReferenceQueue（用作“回收前清理工作”的工具）。而PhantomReference只能依赖于ReferenceQueue。

#### WeakHashMap

容器类中有一种特殊的Map，即WeakHashMap，它被用来保存WeakReference。它使得规范映射更易于使用。在这种映射中，每个值只保存一份实例以节省存储空间。当程序需要那个“值”的时候，便在映射中查询现有的对象，然后使用它（而不是重新再创建）。映射可将值作为其初始化中的一部分，不过通常是在需要的时候才生成“值”。

这是一种节约存储空间的技术，因为WeakHashMap允许垃圾回收器自动清理键和值，所以它显得十分便利。对于向WeakHashMap添加键和值的操作，则没有什么特殊要求。映射会自动使用WeakReference包装它们。允许清理元素的触发条件是：不再需要此键了。

运行此程序，会看到垃圾回收器每个三个键就跳过一个，因为那个键的普通引用被存入keys数组，所以那些对象不能被垃圾回收器回收。

### Java 1.0/1.1的容器

避免使用Vector,Enumeration,Hashtable,Stack,BitSet，尽量使用ArrayList,Iterator,HashMap,LinkedList,EnumSet来替代它们。

#### BitSet

如果想要高效率地存储大量“开/关”信息，BitSet是很好的选择。不过它的效率仅是对空间而言；如果需要高效的访问时间，BitSet比本地数组稍慢一点。

BitSet的最小容量是long:64位。如果存储的内容比较小，例如8位，那么BitSet就浪费了一些空间。

如果拥有一个可以命名的固定的标志集合，那么EnumSet和BitSet相比，通常是一种更好的选择，因为EnumSet允许你按照名字而不是数字位的位置进行操作，因此可以减少错误。EnumSet还可以防止你因不注意而添加新的标志位置，这种行为能够引发严重的、难以发现的缺陷。你应该使用BitSet而不是EnumSet的理由只包括：只有在运行时才知道需要多少个标志；对标志命名不合理；需要BitSet中的某些特殊操作。
