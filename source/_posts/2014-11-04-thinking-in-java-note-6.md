title: Java编程思想笔记六
date: 2014-11-04 20:53:54
tags: thinking in java
categories: java
description: thinking in java; java编程思想; Java I/O系统;
---
## Java I/O 系统
### File类

File类是文件和目录路径名的抽象表示形式。

<!-- more -->

#### 目录列表器 

若在不含自变量（参数）的情况下调用list()，会获得 File 对象包含的一个完整列表。然而，若想对这个列表进行某些限制，就需要使用一个“目录过滤器”，该类的作用是指出应如何选择 File 对象来完成显示。

```
public interface FilenameFilter {
	boolean accept(File dir, String name);
}
```
File类的list()的重载方法接收一个FilenameFilter对象，并且会为此目录对象下的每个文件调用accept()方法，来判断该文件是否包含在内。这是一个策略模式的例子，因为list()实现了基本的功能，而且按照FilenameFilter的形式提供这个策略，以便完善list()在提供服务时所需的算法。

书中用实现接口，和匿名内部类的方式实现了FilenameFilter接口。Java SE8中引入了Lambda表达式，而FilenameFilter是“函数式接口”（只有一个方法）。我们还可以使用Lambda表达式实现，代码更加简洁。
```
import java.util.regex.*;
import java.io.*;
import java.util.*;

public class DirList4 {
  public static void main(final String[] args) {
    File path = new File(".");
    String[] list;
    if(args.length == 0) {
      list = path.list();
	} else {
	  final Pattern pattern = Pattern.compile(args[0]);
      list = path.list((dir, name) -> {
          return pattern.matcher(name).matches();
      });
	}
    Arrays.sort(list, String.CASE_INSENSITIVE_ORDER);
    for(String dirItem : list)
      System.out.println(dirItem);
  }
}
```

#### 目录使用工具

书中提供了目录使用工具类net.mindview.util.Directory，local()方法产生由本地目录中文件构成的File对象数组，walk()方法产生给定目录下的有整个目录树中所有文件构成的List<File>。

#### 目录的检查及创建

File类保存文件或目录的各种元数据信息，包括文件名、文件长度、最后修改时间、是否可读、获取当前文件的路径名，判断指定文件是否存在、获得当前目录中的文件列表，创建、删除文件和目录等方法。

### 输出和输入

我们很少用单个类创建自己的系统对象。一般情况下，我们都是将多个对象重叠在一起，提供期望的功能（这是装饰器设计模式）。

#### InputStream类型

InputStream 的作用是标志那些从不同起源地产生输入的类。这些起源地包括（每个都有一个相关的InputStream 子类）：

* 字节数组
* String 对象
* 文件
* “管道”，它的工作原理与现实生活中的管道类似：将一些东西置入一端，它们在另一端出来。
* 一系列其他流，以便我们将其统一收集到单独一个流内。
* 其他起源地，如 Internet 连接等

类                      | 功能                                                                   | 构建器参数／如何使用
---                     | ---                                                                    | ---
ByteArrayInputStream    | 允许内存中的一个缓冲区作为 InputStream 使用                            | 从中提取字节的缓冲区／作为一个数据源使用。通过将其同一个 FilterInputStream 对象连接，可提供一个有用的接口
StringBufferInputStream | 将一个 String 转换成 InputStream  一个 String（字串）。                | 基础的实施方案实际采用一个 StringBuffer（字串缓冲）／作为一个数据源使用。通过将其同一个 FilterInputStream 对象连接，可提供一个有用的接口
FileInputStream         | 用于从文件读取信息                                                     | 代表文件名的一个 String，或者一个 File 或 FileDescriptor 对象 ／作为一个数据源使用。通过将其同一个 FilterInputStream 对象连接，可提供一个有用的接口
PipedInputStream        | 产生为相关的 PipedOutputStream 写的数据。实现了“管道化”的概念        | PipedOutputStream／作为一个数据源使用。通过将其同一个 FilterInputStream 对象连接，可提供一个有用的接口
SequenceInputStream     | 将两个或更多的 InputStream 对象转换成单个 InputStream 使用             | 两个InputStream 对象或者一个 Enumeration，用于 InputStream 对象的一个容器／作为一个数据源使用。通过将其同一个
FilterInputStream       | 抽象类，作为装饰器的接口，装饰器为其他InputStream 类提供了有用的功能。 |

#### OutputStream类型

类                    | 功能                                                                     | 构建器参数／如何使用
---                   | ---                                                                      | ---
ByteArrayOutputStream | 在内存中创建一个缓冲区。我们发送给流的所有数据都会置入这个缓冲区。       | 可选缓冲区的初始大小／用于指出数据的目的地。若将其同 FilterOutputStream 对象连接到一起，可提供一个有用的接口
FileOutputStream      | 将信息发给一个文件                                                       | 用一个 String 代表文件名，或选用一个 File 或 FileDescriptor 对象／用于指出数据的目的地。若将其同 FilterOutputStream 对象连接到一起，可提供一个有用的接口
PipedOutputStream     | 我们写给它的任何信息都会自动成为相关的 PipedInputStream 的输出。         | 实现了“管道化”的概念PipedInputStream／为多线程处理指出自己数据的目的地／将其同 FilterOutputStream 对象连接到一起，便可提供一个有用的接口
FilterOutputStream    | 抽象类，作为装饰器的接口；装饰器为其他 OutputStream 类提供了有用的功能。 |

### 添加属性和有用的接口

装饰器必须拥有与它装饰的那个对象相同的接口，但装饰器亦可对接口作出扩展，这种情况见诸于几个特殊的“过滤器”类中

装饰器为我们提供了大得多的灵活性（因为可以方便地混合与匹配属性），但它们也使自己的代码变得更加复杂。原因在于 Java IO 库操作不便，我们必须创建许多类——“核心”IO 类型加上所有装饰器——才能得到自己希望的单个 IO 对象。

#### 通过 FilterInputStream 从 InputStream 里读入数据 

基本都是使用基本的InputStream类型作为构造器参数创建这些类对象。下面的最后两个类我们基本不会用到

类                    | 功能                                                                                                | 构建器参数／如何使用
---                   | ---                                                                                                 | ---
DataInputStream       | 与 DataOutputStream 联合使用，使自己能以机动方式读取一个流中的基本数据类型（int，char ，long 等等） | InputStream/ 包含了一个完整的接口，以便读取基本数据类型
BufferedInputStream   | 避免每次想要更多数据时都进行物理性的读取，告诉它“请先在缓冲区里找”                                | InputStream，没有可选的缓冲区大小／本身并不能提供一个接口，只是发出使用缓冲区的要求。要求同一个接口对象连接到一起
LineNumberInputStream | 跟踪输入流中的行号；可调用 getLineNumber()以及 setLineNumber(int)                                   | 只是添加对数据行编号的能力，所以可能需要同一个真正的接口对象连接
PushbackInputStream   | 有一个字节的后推缓冲区，以便后推读入的上一个字符                                                    | InputStream／通常由编译器在扫描器中使用，因为 Java 编译器需要它。一般不在自己的代码中使用

#### 通过 FilterOutputStream 向 OutputStream 里写入数据

类                   | 功能                                                                                                         | 构建器参数／如何使用
---                  | ---                                                                                                          | ---
DataOutputStream     | 与 DataInputStream 配合使用，以便采用方便的形式将基本数据类型（int，char，long等）写入一个数据流             | OutputStream ／包含了完整接口，以便我们写入基本数据类型
PrintStream          | 用于产生格式化输出。DataOutputStream 控制的是数据的“存储”，而 PrintStream 控制的是“显示”                 | OutputStream ，可选一个布尔参数，指示缓冲区是否与每个新行一同刷新／对于自己的OutputStream 对象，应该用“final”将其封闭在内。可能经常都要用到它
BufferedOutputStream | 用它避免每次发出数据的时候都要进行物理性的写入，要求它“请先在缓冲区里找”。可调用 flush()，对缓冲区进行刷新 | OutputStream ，可选缓冲区大小／本身并不能提供一个接口，只是发出使用缓冲区的要求。需要同一个接口对象连接到一起

PrintStream 内两个重要的方法是 print()和 println() 。另外，PrintStream也未完全国际化，不能以平台无关的方式处理换行动作。

### Reader 和 Writer

InputStream和OutputStream在以面向字节形式的I/O中扔可以提供极有价值的功能，Reader和Writer则提供兼容Unicode与面向字符的I/O功能。

“适配器”类：InputStreamReader 将一个 InputStream 转换成 Reader，OutputStreamWriter 将一个 OutputStream 转换成 Writer。

新类库的设计使得它的操作比旧类库更快。

#### 数据的来源和去处

最明智的做法是尽量尝试使用 Reader 和 Writer 类。若代码不能通过编译，便知道必须面向字节的类库。

来源和去处: Java 1.0 类          | 相应的 Java 1.1 类
---                              | ---
InputStream                      | Reader 适配器: InputStreamReader
OutputStream                     | Writer 适配器: OutputStreamWriter
FilelnputStream                  | FileReader
FileOutputStream                 | FileWriter
StringBufferlnputStream (已弃用) | StringReader
(没有相应的类)                   | StringWriter
ByteArrayInputStream             | CharArrayReader
ByteArrayOutputStream            | CharArrayWriter
PipedInputStream                 | PipedReader
PipedOutputStream                | PipedWriter

#### 更改数据流的行为

尽管 BufferedOutputStream 是 FilterOutputStream 的一个子类，但是 BufferedWriter 并不是 FilterWriter 的子类（尽管FilterWriter是一个抽象类，但没有任何子类，把它放在那里也只是把它作为一个占位符））。然而，两个类的接口是非常相似的

过滤器：Java 1.0 类   | 对应的 Java 1.1 类
---                   | ---
FilterInputStream     | FilterReader
FilterOutputStream    | FilterWriter （没有子类的抽象类）
BufferedInputStream   | BufferedReader（也有 readLine()）
BufferedOutputStream  | BufferedWriter
DataInputStream       | 使用 DataInputStream（除非要使用 readLine()，这时需要使用一个 BufferedReader）
PrintStream           | PrintWriter
LineNumberInputStream | LineNumberReader
StreamTokenizer       | StreamTokenizer （使用接收Reader的构造器）
PushBackInputStream   | PushBackReader

为了将向 PrintWriter 的过渡变得更加自然，它提供了能接受任何Writer对象又能接受任何 OutputStream 对象的构造器。
有一种PrintWriter构造器还有一个选项，就是“自动执行清空”选项(自动刷新缓存区)。如果构造器设置此选项，则在每个println()执行后，便会自动清空。

#### 未发生改变的类

没有对应 Java 1.1 类的 Java 1.0 类 
* DataOutputStream
* File
* RandomAccessFile
* SequenceInputStream

### 自我独立的类：RandomAccessFile

RandomAccessFile 适用于由大小已知的记录组成的文件，所以我们能用 seek()从一条记录移至另一条，然后读取或修改那些记录。

RandomAccessFile 类似 DataInputStream 和 DataOutputStream 的联合使用。其中，getFilePointer()用于了解当前在文件的什么地方，seek()用于移至文件内的一个新地点，length() 用于判断文件的最大长度。此外，构建器要求使用另一个变量（与 C 的 fopen()完全一样），指出是读（"r"），还是读写（"rw" ）。

BufferedInputStream 确实允许我们标记一个位置（使用 mark()，它的值容纳于单个内部变量中），并用 reset()重设那个位置。

### I/O流的经典适用方式

* 缓冲输入文件
	{% codeblock %}
	BufferedReader in = new BufferedReader(new FileReader(filename));
	StringBuffer sb = new StringBuffer();
	while((s=in.readLine())!=null)
		sb.append(s+"\n");
	in.close();
	{% endcodeblock %}
	readLine()方法会去掉换行符
* 从内存输入
	{% codeblock %}
	String str = "hello world";
	StringReader in = new StringReader(str);
	int c;
	while((c=in.read())!=-1)
		System.out.println((char)c);
	{% endcodeblock %}
* 格式化的内存输入 
	{% codeblock %}
	DataInputStream in = new DataInputStream(new ByteArrayInputStream("FormattedMemoryInput.java".getBytes())); 
	while(in.available() != 0) 
		System.out.print((char)in.readByte()); 
	{% endcodeblock %}
	可以使用available()方法查看还有多少可供存取的字符。必须为ByteArrayInputStream提供字节数组。available()的工作方式会随着所读取的媒介类型的不同而有所不同，字面意思就是“在没有阻塞的情况下所能读取的字节数”。
* 基本的文件输出
	{% codeblock %}
	BufferedReader in = new BufferedReader(new FileReader(filename));
	PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter("file.out"))); 
	//PrintWriter out = new PrintWriter("file.out");  //Java SE5提供了更加快捷的构造器，仍然使用缓存，但是不用自己实现
	int lineCount = 1; 
	String s; 
	while((s = in.readLine()) != null ) 
		out.println(lineCount++ + ": " + s); 
	out.close(); 
	in.close();
	{% endcodeblock %}
* 存储和恢复数据
	为了输出可供另一个流恢复的数据，我们需要用DataInputStream写入数据，并用DataInputStream恢复数据。当使用DataOutputStream时，写字符串并且让DataInputStream能够恢复它的唯一可靠的做法就是使用UTF-8，在这个示例中是用writeUTF()和readUTF()来实现的。Java使用的UTF-8的变体，所以使用其他语言恢复数据时，需要编写一些特殊的代码。
	{% codeblock %}
	DataOutputStream out = new DataOutputStream(new BufferedOutputStream(new FileOutputStream("Data.txt"))); 
	out.writeDouble(3.14159); 
	out.writeUTF("That was pi"); 
	out.writeDouble(1.41413); 
	out.writeUTF("Square root of 2"); 
	out.close(); 
	DataInputStream in = new DataInputStream(new BufferedInputStream(new FileInputStream("Data.txt"))); 
	System.out.println(in.readDouble()); 
	// Only readUTF() will recover the 
	// Java-UTF String properly: 
	System.out.println(in.readUTF()); 
	System.out.println(in.readDouble()); 
	System.out.println(in.readUTF()); 
	{% endcodeblock %}
* 读写随机访问文件
	{% codeblock %}
	import java.io.*; 
	public class UsingRandomAccessFile { 
		static String file = "rtest.dat"; 
		static void display() throws IOException { 
			RandomAccessFile rf = new RandomAccessFile(file, "r"); 
			for(int i = 0; i < 7; i++) 
				System.out.println("Value " + i + ": " + rf.readDouble()); 
			System.out.println(rf.readUTF()); 
			rf.close(); 
		} 
		public static void main(String[] args) throws IOException { 
			RandomAccessFile rf = new RandomAccessFile(file, "rw"); 
			for(int i = 0; i < 7; i++) 
				rf.writeDouble(i*1.414); 
			rf.writeUTF("The end of the file"); 
			rf.close(); 
			display(); 
			rf = new RandomAccessFile(file, "rw"); 
			rf.seek(5*8); 
			rf.writeDouble(47.0001); 
			rf.close(); 
			display(); 
		} 
	} 
	{% endcodeblock %}
* 管道流
	{% codeblock %}
	PipedInputStream pin = new PipedInputStream();
    PipedOutputStream pout = new PipedOutputStream();
    pin.connect(pout); // 输入流与输出流连接 
	{% endcodeblock %}

### 文件读写的实用工具

书中提供了工具类net.mindview.util.TextFile。可以使用java.util.Scanner类。但是只能用于读取文件，而不能用于写入文件。

### 标准I/O

#### 从标准输入中读取

Java 提供了System.in，System.out 以及 System.err。System.out 已预封装成一个 PrintStream 对象。System.err 同样是一个 PrintStream，但 System.in 是一个原始的 InputStream ，未进行任何封装处理。这意味着尽管能直接使用 System.out 和 System.err，但必须事先封装 System.in，否则不能从中读取数据。

```
BufferedReader stdin = new BufferedReader(new InputStreamReader(System.in)); 
String s;
while((s = stdin.readLine()) != null && s.length()!= 0) 
	System.out.println(s); 
// An empty line or Ctrl-Z terminates the program 
```

`Scanner scanner = new Scanner(System.in);`也可以从标准输入中读取，System.in和大多数流一样，通常应该对它缓存。

#### 将System.out转换成PrintWriter

`PrintWriter(OutputStream out, boolean autoFlush)`，此构造器可以实现，第一个参数设置为System.out，第二个参数设为true，以便开启自动刷新缓存区的功能，否则，你可能看不到输出。

#### 标准I/O重定向

System类提供了`setIn(InputStream)`，`setOut(PrintStream)`，`setErr(PrintStream)`三个静态方法重定向标准I/O，我们可以将其重定向到文件中，以便查看。I/O 重定向操纵的是字节流，而不是字符流。

### 进程控制

工具类net.mindview.util.OSExecute可以运行外部程序，并将产生的输出发送到控制台。

```
String command = "ls";
Process process = new ProcessBuilder(command.split(" ")).start(); 
BufferedReader results = new BufferedReader(new InputStreamReader(process.getInputStream())); 
String s; 
while((s = results.readLine())!= null) 
	System.out.println(s); 
BufferedReader errors = new BufferedReader(new InputStreamReader(process.getErrorStream())); 
// Report errors and return nonzero value 
// to calling process if there are problems: 
while((s = errors.readLine())!= null) { 
	System.err.println(s); 
	err = true; 
}
```

### 新I/O

JDK 1.4的`java.nio.*`包中引入了新的Java I/O类库，其目的在于提高速度。实际上，旧的I/O包已经使用nio重新实现过，以便充分利用这种速度提高。

速度的提高来自于所使用的结构更接近于操作系统执行I/O的方式：通道和缓冲器。我们没有和通道交互，只是和缓冲器交互，并把缓冲器派送到通道。通道要么从缓冲器获得数据，要么向缓冲器发送数据。

唯一直接与通道交互的缓冲器是`ByteBuffer`，可以存储未加工字节的缓冲器。通过告知分配多少存储空间来创建一个`ByteBuffer`对象，并且还有一个方法选择集，用于以原始的字节形式或基本数据类型输出和读取数据。但是，没办法输出或读取对象，即使是字符串对象也不行。这是大多数操作系统中更有效的映射方式。

旧I/O类库中有三个类（`FileInputStream`、`FileOutputStream`、`RandomAccessFile`）被修改了，用以产生`FileChannel`。注意这些都是字节操纵流，与底层的nio性质一致。`Reader`和`Writer`这种字符模式类不能用于产生通道；但是`java.nio.channels.Channels`类提供了实用方法，用以在通道中产生`Reader`和`Writer`。

`getChannel()`将会产生一个`FileChannel`。通道是一种相当基础的东西：可以向它传送用于读写的`ByteBuffer`，并且可以锁定文件的某些区域用于独占式访问。

将字节存放在`ByteBuffer`的方法之一是：使用一种“put”方法直接对它们进行填充，填入一个或多个字节，或基本数据类型的值。也可以使用`wrap()`方法将已存在的字节数组“包装”到ByteBuffer中。一旦如此，就不再复制底层的数组，而是把它作为所产生的ByteBuffer的存储器，称之为数组支持的`ByteBuffer`。

对于只读操作，必须显式的使用静态的`allocate()`方法来分配`ByteBuffer`，分配的大小单位是字节。nio的目标就是快速移动大量数据，因此`ByteBuffer`的大小就显得尤为重要--实际上，这里使用的1K可能比通常使用的小一点（必须通过实际运行应用程序来找到最佳尺寸）。

甚至达到更高的速度也有可能，方法就是使用`allocateDirect()`而不是`allocate()`，以产生一个与操作系统有更高耦合性的“直接”缓冲器。但是，这种分配的开支会更大，并且具体实现也随操作系统的不同而不同，因此必须再次实际运行应用程序来查看直接缓冲是否可以使程序获得速度上的优势。

一旦调用`read()`来告知`FileChannel`向`ByteBuffer`存储字节，就必须调用缓冲器上的`flip()`,让它做好让别人读取字节的准备。（适用于获取最大速度）如果打算使用缓冲器执行进一步的`read()`操作，也必须得调用`clear()`来为每个`read()`做好准备。

```
private static final int BSIZE = 1024;
public static void main(String[] args) throws IOException {
	if(args.length != 2){
		System.out.println("arguments: sourcefile destfile");
		System.exit(1);
	}
	FileChannel in = new FileInputStream(args[0]).getChannel(),
			out = new FileOutputStream(args[1]).getChannel();
	ByteBuffer buffer = ByteBuffer.allocate(BSIZE);
	while(in.read(buffer) != -1){
		buffer.flip();//Prepare for writing
		out.write(buffer);
		buffer.clear();//Prepare for reading
	}
}
```

当`FileChannel.read()`返回-1时（一个分界符，源于Unix和C），表示已经到达了输入的末尾。每次`read()`操作之后，就会将数据输入到缓冲器中，`flip()`则是准备缓冲器以便它的信息可以由`write()`提取。`write()`操作之后，信息仍在缓冲器中，接着`clear()`操作则对所有的内部指针重新安排，以便缓冲器在另一个`read()`操作期间能够做好接收数据的准备。

特殊方法`transferTo()`和`transferFrom()`允许将一个通道和另一个通道直接相连。

```
FileChannel in = new FileInputStream(args[0]).getChannel(),
		out = new FileOutputStream(args[1]).getChannel();
in.transferTo(0, in.size(), out);
//Or:
//out.transferFrom(in, 0, in.size());
```

#### 转换数据

`java.nio.CharBuffer`的`toString()`方法返回一个包含缓冲器中所有字符的字符串。Bytebuffer可以看做是具有`asCharBuffer()`方法的`CharBuffer`

缓冲器容纳的是普通的字节，为了把它们转换成字符，要么在输入它们的时候对其进行编码（这样，它们输出时才具有意义，否则会有乱码），要么在将其从缓冲器输出时对它们进行解码。java.nio.charset.Charset类提供了把数据编码成多种不同类型的字符集的工具

缓存器的`rewind()`方法：返回到数据开始部分
`System.getProperty(“file.encoding”)`发现默认字符集，产生代表字符集名称的字符串。

#### 获取基本类型

`ByteBuffer`只能保存字节类型的数据，但是它具有从其所容纳的字节中产生出各种不同基本类型值的方法。 

分配一个`ByteBuffer`之后，缓冲器（ByteBuffer）自动把自己的内容置为零。 

向`ByteBuffer`插入基本类型数据的最简单的方法是：利用`asCharBuffer()`、`asShortBuffer()`等获得该缓冲器上的视图，然后使用视图的`put()`方法。此方法适用于所有基本数据类型。使用`ShorBuffer`的`put()`方法时，需要进行类型转换（注意类型转换会截取或改变结果）。而其他所有的视图缓冲器在使用`put()`方法时，不需要进行类型转换。

#### 视图缓冲器

视图缓冲器（view buffer）可以让我们通过某个特定的基本数据类型的视窗查看其底层的`ByteBuffer`。`ByteBuffer`依然是实际存储数据的地方，“支持”着前面的视图，因此，对视图的任何修改都会映射成为对`ByteBuffer`中数据的修改。视图还允许从`ByteBuffer`一次一个地（与`ByteBuffer`所支持的方式相同）或者成批地（放入数组中）读取基本类型值。

```
ByteBuffer bb = ByteBuffer.allocate(BSIZE);
IntBuffer ib = bb.asIntBuffer();
//Store an array of int:
ib.put(new int[]{11,42,47,99,143,811,1016});
//Absolute location read and write:
System.out.println(ib.get(3));
ib.put(3,1811);
//Setting a new limit before rewinding the buffer.
ib.flip();
while(ib.hasRemaining()){
	int i = ib.get();
	System.out.println(i);
}
```

`get()`和`put()`方法调用直接访问底层`ByteBuffer`中的某个整数位置。注意，这些通过直接与`ByteBuffer`对话访问绝对位置的方式也同样适用于基本类型。 

一旦底层的`ByteBuffer`通过视图缓冲器填满了整数或其他类型数据时，就可以直接被写到通道中了。使用视图缓冲器可以把任何数据都转化成某一特定的基本类型。
	
**字节存放次序**

不同的机器可能会使用不同的字节排序方法来存储数据。“big endian”（高位字节优先）将高位字节存放在地址最低的存储器单元。“litter endian”（低位字节优先）则是将高位字节放在地址最高的存储器单元。当存储量大于一个字节时，像`int`、`float`等，就要考虑字节的顺序问题了。`ByteBuffer`是以高字节优先的形式存储数据的，并且数据在网上传送时也常常使用高位优先的形式。可以使用带有参数的`ByteOrder.BIG_ENDIAN`或`ByteOrder.LITTLE_ENDIAN`的`order()`方法改变`ByteBuffer`的字节排序方式。 

如果以`short`(`ByteBuffer.asShortBuffer`)形式读取数据，得到的数字是97（二进制的形式为00000000 01100001）；但是如果将`ByteBuffer`更改成低位优先形式，得到的数字却是24832（01100001 00000000） 

`ByteBuffer`有足够的空间，以存储作为外部缓冲器的`charArray`中的所有字节，因此可以调用`array()`方法显示视图底层的字节。`array()`方法是“可选的”，并且只能对由数组支持的缓冲器调用此方法；否则，将会抛出`UnsupportedOperationException`。 

#### 用缓冲器操纵数据
 
注意，**`ByteBuffer`是将数据移进移出通道的唯一方式，并且只能创建一个独立的基本类型缓冲器，或者使用“as”方法从`ByteBuffer`中获得**。也就是说，不能把基本类型的缓冲器转换成`ByteBuffer`。然而，由于可以经由视图缓冲器将基本类型数据移进移出ByteBuffer，所以这也不是什么真正的限制了。 

#### 缓冲器的细节

Buffer由数据和可以高效地访问及操纵这些数据的四个索引（mark（标记）、position（位置）、limit（界限）、capacity（容量））组成。

方法              | 说明
---               | ---
capacity( )       | 返回缓冲区容量
clear( )          | 清空缓冲区，将position设置为0，limit设置为容量。我们可以调用此方法覆写缓冲区。
flip( )           | 将position和limit设置为0，此方法用于准备从缓冲区读取已经写入的数据。
limit( )          | 返回limit值
limit(int lim)    | 设置limit值
mark( )           | 将mark设置为position
reset()           | 将position设置为mark
rewind()          | 将position设置为0，mark设置为-1
position( )       | 返回position值
position(int pos) | 设置position值
remaining( )      | 返回(limit - position)
hasRemaining( )   | 若有介于position和limit之间的元素，则返回true

io.UsingBuffers的例子可以很好的理解这些方法。尽管可以通过对某个char数组调用`wrap()`方法（`CharBuffer java.nio.CharBuffer.wrap(CharSequence csq)`）来直接产生一个`CharBuffer`，但是在本例中取而代之的是分配一个底层的`ByteBuffer`，产生的`CharBuffer`只是`ByteBuffer`上的一个视图而已。这里要强调的是，我们总是以操纵`ByteBuffer`为目标，因为它可以和通道进行交互。 

#### 内存映射文件

内存映射文件允许我们创建和修改那些因为太大而不能放入内存的文件。有了内存映射文件，我们就可以假定整个文件都放在内存中，而且可以完全把它当作非常大的数组来访问。这种方法极大地简化了用于修改文件的代码。
```
import java.io.RandomAccessFile;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
public class LargeMappedFiles {
	static int length = 0X8FFFFFF;// 128MB
	public static void main(String[] args) throws Exception {
		MappedByteBuffer out = new RandomAccessFile("test.data", "rw")
				.getChannel().map(FileChannel.MapMode.READ_WRITE, 0, length);
		for(int i = 0; i < length; i++){
			out.put((byte)'x');
		}
		System.out.println("Finished writing");
		for(int i = length/2; i < length/2 + 6;i++){
			System.out.print((char)out.get(i));
		}
	}
}
```
为了既能写又能读，先由RandomAccessFile开始，获得该文件上的通道，然后调用map()产生MappedByteBuffer，这是一种特殊类型的直接缓冲器。注意必须指定映射文件的初始位置和映射区域的长度，这意味着可以映射某个大文件的较小的部分。

MappedByteBuffer由ByteBuffer继承而来，因此它具有ByteBuffer的所有方法（包括asCharBuffer()）。
只有一部份文件放入了内存，文件的其他部分被交换了出去，用这种方式，很大的文件（可达2GB）也可以很容易地修改。注意底层操作系统的文件映射工具是用来最大化地提高性能。

**性能**

尽管“映射写”似乎要用到FileOutputStream，但是映射文件中的所有输出必须使用RandomAccessFile。
即使建立映射文件的花费很大，但是整体受益比起I/O流来说还是很显著的。

#### 文件加锁

文件锁对其他的操作系统进程是可见的，因为Java的文件加锁直接映射到了本地操作系统的加锁工具。

通过对FileChannel调用tryLock()或lock()，就可以获得整个文件的FileLock。（SocketChannel、DatagramChannel和ServerSocketChannel不需要加锁，因为它们是从单进程实体继承而来，我们通常不再两个进程之间共享网络socket）。tryLock()是非阻塞式的，它设法获得锁，但是如果不能获得（当其他一些进程已经持有相同的锁，并且不共享时），它将直接从方法调用返回。lock()则是阻塞式的，它要阻塞进程直至锁可以获得，或调用lock()的线程中断，或调用lock()的通道关闭。使用FileLock.release()可以释放锁。

```
tryLock(long position, long size, boolean shared)
lock(long position, long size, boolean shared)
```

加锁的区域有size-position决定。第三个参数指定是否是共享锁。
锁的类型可以通过FileLock.isShared()进行查询。

**对映射文件的部分加锁**
文件映射通常用于极大的文件。我们需要对这种巨大的文件进行部分加锁，以便其他进程可以修改文件中未被加锁的部分。

### 压缩

 压缩类              | 功能
 ---                 | ---
CheckedInputStream   | GetCheckSum()为任何 InputStream 产生校验和（不仅是解压）
CheckedOutputStream  | GetCheckSum()为任何 OutputStream 产生校验和（不仅是解压）
DeflaterOutputStream | 用于压缩类的基础类
ZipOutputStream      | 一个 DeflaterOutputStream，将数据压缩成 Zip 文件格式
GZIPOutputStream     | 一个 DeflaterOutputStream，将数据压缩成 GZIP 文件格式
InflaterInputStream  | 用于解压类的基础类
ZipInputStream       | 一个 DeflaterInputStream，解压用 Zip 文件格式保存的数据
GZIPInputStream      | 一个 DeflaterInputStream，解压用 GZIP 文件格式保存的数据

#### 用GZIP进行简单压缩

GZIP接口非常简单，因此如果我们只想对单个数据流（而不是一系列互异数据）进行压缩，那么它可能是比较适合的选择。

```
BufferedReader in = new BufferedReader(new FileReader(args[0]));
BufferedOutputStream out = new BufferedOutputStream(new GZIPOutputStream(new FileOutputStream("test.gz")));
BufferedReader in2 = new BufferedReader(new InputStreamReader(new GZIPInputStream(new FileInputStream("test.gz"))));
```
#### 用Zip进行简单压缩

java对zip支持更加全面，利用该库可以方便保存多个文件。使用的是标准zip格式，所以能与当前那些可通过因特网下载的压缩工具很好地协作。
两种Checksum类型：Adler32（快一些）和CRC32（慢一些，但是更准确）

```
import java.util.zip.*;
import java.io.*;
import java.util.*;
import static net.mindview.util.Print.*;
public class ZipCompress {
  public static void main(String[] args)
  throws IOException {
    FileOutputStream f = new FileOutputStream("test.zip");
    CheckedOutputStream csum =
      new CheckedOutputStream(f, new Adler32());
     ZipOutputStream zos = new ZipOutputStream(csum);
     BufferedOutputStream out =
      new BufferedOutputStream(zos);
    zos.setComment("A test of Java Zipping");
    // No corresponding getComment(), though.
    for(String arg : args) {
      print("Writing file " + arg);
      BufferedReader in =
        new BufferedReader(new FileReader(arg));
      zos.putNextEntry(new ZipEntry(arg));
      int c;
      while((c = in.read()) != -1)
        out.write(c);
      in.close();
      out.flush();
    }
    out.close();
    // Checksum valid only after the file has been closed!
    print("Checksum: " + csum.getChecksum().getValue());
    // Now extract the files:
    print("Reading file");
    FileInputStream fi = new FileInputStream("test.zip");
    CheckedInputStream csumi =
      new CheckedInputStream(fi, new Adler32());
    ZipInputStream in2 = new ZipInputStream(csumi);
    BufferedInputStream bis = new BufferedInputStream(in2);
    ZipEntry ze;
    while((ze = in2.getNextEntry()) != null) {
      print("Reading file " + ze);
      int x;
      while((x = bis.read()) != -1)
        System.out.write(x);
    }
    if(args.length == 1)
    print("Checksum: " + csumi.getChecksum().getValue());
    bis.close();
    // Alternative way to open and read Zip files:
    ZipFile zf = new ZipFile("test.zip");
    Enumeration e = zf.entries();
    while(e.hasMoreElements()) {
      ZipEntry ze2 = (ZipEntry)e.nextElement();
      print("File: " + ze2);
      // ... and extract the data as before
    }
    /* if(args.length == 1) */
  }
} /* (Execute to see output) *///:~
```
对于要加入压缩档的每一个文件，都必须调用 putNextEntry()，并将其传递给一个 ZipEntry 对象。ZipEntry 对象包含了一个功能全面的接口，利用它可以获取和设置 Zip 文件内那个特定的 Entry（入口）上能够接受的所有数据：名字、压缩后和压缩前的长度、日期、CRC 校验和、额外字段的数据、注释、压缩方法以及它是否一个目录入口等等。然而，虽然 Zip 格式提供了设置密码的方法，但 Java 的 Zip 库没有提供这方面的支持。而且尽管 CheckedInputStream 和 CheckedOutputStream 同时提供了对 Adler32 和CRC32 校验和的支持，但是 ZipEntry 只支持 CRC 的接口。这虽然属于基层 Zip 格式的限制，但却限制了我们使用速度更快的 Adler32。

为解压文件，ZipInputStream 提供了一个 getNextEntry()方法，能在有的前提下返回下一个 ZipEntry 。作为一个更简洁的方法，可以用 ZipFile 对象读取文件。该对象有一个 entries()方法，可以为 ZipEntry 返回一个 Enumeration（枚举）。

使用 GZIP 或 Zip 库时并不仅仅限于文件——可以压缩任何东西，包括要通过网络连接发送的数据。

#### Java档案文件

```
jar [选项] 说明[详情单] 输入文件
```
其中，“选项”用一系列字母表示（不必输入连字号或其他任何指示符）和tar命令类似。如下所示：

* c 创建新的或空的压缩档
* t 列出目录表 
* x 解压所有文件
* x file 解压指定文件
* f 指出“我准备向你提供文件名”。若省略此参数，jar 会假定它的输入来自标准输入；或者在它创建文件时，输出会进入标准输出内
* m 指出第一个参数将是用户自建的详情表文件的名字
* v 产生详细输出，对 jar 做的工作进行巨细无遗的描述
* O 只保存文件；不压缩文件（用于创建一个 JAR 文件，以便我们将其置入自己的类路径中）
* M 不自动生成详情表文件

### 对象序列化

如果需要一个更严格的持久性机制，可以考虑像Hibernate之类的工具。对象序列化加入到语言中是为了支持两种主要特性，一是Java的远程方法调用（Remote Method Invocation，RMI）；二是Java Beans，后者由 Java 1.1 引入。使用一个 Bean 时，它的状态信息通常在设计期间配置好。

对象实现了Serializable接口，序列化对象就会很简单。首先要创建某些 OutputStream 对象，然后将其封装到 ObjectOutputStream 对象内。此时，只需调用 writeObject() 即可完成对象的序列化，并将其发送给 OutputStream。相反的过程是将一个InputStream 封装到 ObjectInputStream 内，然后调用 readObject()。和往常一样，我们最后获得的是指向一个上溯造型 Object 的句柄，所以必须下溯造型，以便能够直接设置。

对象序列化特别“聪明”的一个地方是它不仅保存了对象的“全景图”，而且能追踪对象内包含的所有句柄并保存那些对象；接着又能对每个对象内包含的句柄进行追踪；以此类推。我们有时将这种情况称为“对象网”

#### 寻找类

另一台计算机上的程序要想利用序列化的文件内容还原对象，必须保证Java虚拟机能找到相关class文件。

#### 序列化的控制

通过实现 Externalizable 接口，用它代替 Serializable 接口，便可控制序列化的具体过程。这个 Externalizable 接口扩展了 Serializable，并增添了两个方法：writeExternal()和 readExternal() 。在序列化和重新装配的过程中，会自动调用这两个方法，以便我们执行一些特殊操作。

与恢复一个 Serializable（可序列化）对象不同。在后者的情况下，对象完全以它保存下来的二进制位为基础恢复，不存在构建器调用。而对一个 Externalizable 对象，所有普通的默认构建行为都会发生（包括在字段定义时的初始化），而且会调用 readExternal()。必须注意这一事实——特别注意所有默认的构建行为都会进行——否则很难在自己的 Externalizable 对象中产生正确的行为。所以默认构造器得是public的，否则会抛出异常。

为了让一切正常运作起来，千万不可仅在 writeExternal()方法执行期间写入对象的重要数据（没有默认的行为可用来为一个 Externalizable 对象写入所有成员对象）的，而是必须在 readExternal()方法中也恢复那些数据。

**transient（临时）关键字**

即使那种信息在对象中具有“private”（私有）属性，但一旦经序列化处理，人们就可以通过读取一个文件，或者拦截网络传输得到它。为解决这个问题，可以用transient（临时）逐个字段地关闭序列化

**Externalizable 的替代方法**

我们可以实现 Serializable 接口，并添加（注意是“添加”，而非“覆盖”或者“实现”）名为 writeObject() 和 readObject()的方法。一旦对象被序列化或者重新装配，就会分别调用那两个方法。也就是说，只要提供了这两个方法，就会优先使用它们，而不考虑默认的序列化机制。
这些方法必须含有下列准确的签名：
```
private void writeObject(ObjectOutputStream stream) throws IOException;
private void readObject(ObjectInputStream stream) throws IOException, ClassNotFoundException
```
从设计的角度出发，情况变得有些扑朔迷离。首先，大家可能认为这些方法不属于基础类或者 Serializable接口的一部分，它们应该在自己的接口中得到定义。但请注意它们被定义成“private”，这意味着它们只能由这个类的其他成员调用。然而，我们实际并不从这个类的其他成员中调用它们，而是由ObjectOutputStream 和 ObjectInputStream 的 writeObject() 及 readObject()方法来调用我们对象的writeObject() 和 readObject()方法。

我们调用 ObjectOutputStream.writeObject()的时候，我们传递给它的 Serializable 对象似乎会被检查是否实现了自己的 writeObject() 。若答案是肯定的是，便会跳过常规的序列化过程，并调用writeObject() 。readObject()也同样。

在我们的 writeObject() 内部，可以调用 defaultWriteObject()，从而决定执行默认的writeObject()。准备通过默认机制写入对象的非 transient 部分，那么必须调用 defaultWriteObject()，令其作为writeObject() 中的第一个操作；并调用 defaultReadObject()，令其作为 readObject()的第一个操作。

#### 使用持久性

针对一个字节数组应用对象的序列化，从而实现对任何 Serializable（可序列化）对象的一个“全面复制”（全面复制意味着复制的是整个对象网，而不仅是基本对象和它的句柄）。

只要将所有东西都序列化到单独一个数据流里，就能恢复获得与以前写入时完全一样的对象网，不会不慎造成对象的重复（实际两个引用都是指向同一个对象，但是如果分开写入不同的流，恢复时，会重复恢复出不同的对象）。

如果想保存系统状态，最安全的做法是当作一种“原子”操作序列化。应将构成系统状态的所有对象都置入单个容器内，并在一次操作里完成那个容器的写入。这样一来，同样只需一次方法调用，即可成功恢复之。

如将一个 static 字段置入基础类，结果只会产生一个字段，因为 static 字段未在衍生类中复制。假如想序列化 static 值，必须亲自动手。

### XML

书中提到了javax.xml.*类库，XOM类库。此外还有dom4j。

### Preferences

userNodeForPackage()用于个别用户偏好，systemNodeForPackage()用于通用的安装配置。在非静态方法内部，通常用getClass() 标识节点，静态方法中可以用.class。
keys()方法以String[]的形式返回。
put()，get()有系列针对基本类型的方法
get()如果没有这个条目，将使用第二个参数设置该条目。

```
Preferences prefs = Preferences.userNodeForPackage(PreferencesDemo.class); 
int usageCount = prefs.getInt("UsageCount", 0); 
usageCount++; 
prefs.putInt("UsageCount", usageCount); 
```
第一次运行程序时，UsageCount值为0，随后引用中，他将会是非零值。

数据存储在哪里，不同的系统会不同，例如在windows中，就使用注册表。

**Properties**

Properties 类表示了一个持久的属性集。Properties 可保存在流中或从流中加载。属性列表中每个键及其对应值都是一个字符串。 

一个属性列表可包含另一个属性列表作为它的“默认值”；如果未能在原有的属性列表中搜索到属性键，则搜索第二个属性列表。（重载的构造器提供了这种功能） 

因为 Properties 继承于 Hashtable，所以可对 Properties 对象应用 put 和 putAll 方法。但不建议使用这两个方法，因为它们允许调用者插入其键或值不是 String 的项。相反，应该使用 setProperty 方法。如果在“不安全”的 Properties 对象（即包含非 String 的键或值）上调用 store 或 save 方法，则该调用将失败。类似地，如果在“不安全”的 Properties 对象（即包含非 String 的键）上调用 propertyNames 或 list 方法，则该调用将失败。 

load(Reader) / store(Writer, String) 方法按下面所指定的、简单的面向行的格式在基于字符的流中加载和存储属性。除了输入/输出流使用 ISO 8859-1 字符编码外，load(InputStream) / store(OutputStream, String) 方法与 load(Reader)/store(Writer, String) 对的工作方式完全相同。可以使用 Unicode 转义来编写此编码中无法直接表示的字符；转义序列中只允许单个 'u' 字符。可使用 native2ascii 工具对属性文件和其他字符编码进行相互转换。 

loadFromXML(InputStream) 和 storeToXML(OutputStream, String, String) 方法按简单的 XML 格式加载和存储属性。默认使用 UTF-8 字符编码，但如果需要，可以指定某种特定的编码。XML 属性文档具有以下 DOCTYPE 声明： 

 <!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
 注意，导入或导出属性时不 访问系统 URI (http://java.sun.com/dtd/properties.dtd)；该系统 URI 仅作为一个唯一标识 DTD 的字符串： 

**JSON**

json类库将在Java SE9中加入
