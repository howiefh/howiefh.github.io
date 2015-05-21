title: FreeMarker-程序开发指南笔记
date: 2015-05-02 09:20:06
tags: FreeMarker
categories: 
- Java
- FreeMarker
description: FreeMarker;Java模板引擎;程序开发
---

## 快速入门

* 使用 java.lang.String 来构建字符串。
* 使用 java.lang.Number 来派生数字类型。
* 使用 java.lang.Boolean 来构建布尔值。
* 使用 java.util.List 或 Java 数组来构建序列。
* 使用 java.util.Map 来构建哈希表。
* 使用你自己定义的 bean 类来构建哈希表， bean 中的项和 bean 的属性对应。例如product 中的 price 属性可以用 product.price 来获取。

<!-- more -->

```
import freemarker.template.*;
import java.util.*;
import java.io.*;
public class TestFTLDemo {
	public static void main(String[] args) throws Exception {
		/* 在整个应用的生命周期中，这个工作你应该只做一次。 */
		/* 创建和调整配置。 */
		Configuration cfg = new Configuration();
		cfg.setDirectoryForTemplateLoading(new File(
				"/where/you/store/templates"));
		cfg.setObjectWrapper(new DefaultObjectWrapper());
		/* 在整个应用的生命周期中，这个工作你可以执行多次 */
		/* 获取或创建模板 */
		Template temp = cfg.getTemplate("test.ftl");
		/* 创建数据模型 */
		Map root = new HashMap();
		root.put("user", "Big Joe");
		Map latest = new HashMap();
		root.put("latestProduct", latest);
		latest.put("url", "products/greenmouse.html");
		latest.put("name", "green mouse");
		/* 将模板和数据模型合并 */
		Writer out = new OutputStreamWriter(System.out);
		temp.process(root, out);
		out.flush();
	}
}
```

## 数据模型

在内部，模板中可用的变量都是实现了freemarker.template.TemplateModel 接口的 Java 对象。但在你自己的数据模型中，可以使用基本的 Java 集合类作为变量， 因为这些变量会在内部被替换为适当的TemplateModel 类型。这种功能特性被称作是 object wrapping 对象包装。对象包装功能可以透明地把任何类型的对象转换为实现了 TemplateModel 接口类型的实例。要注意一个类可以实现多个TemplateModel 接口，这就是为什么 FTL 变量可以有多种类型

### 标量

布尔值、数字、字符串、日期这四种标量每一种标量类型都是 TemplateTypeModel 接口的实现，这里的 Type 就是类型的名称（比如Boolean,Number,Scalar,Date）。 这些接口只定义了一个方法 type getAsType()；它返回变量的 Java 类型（boolean，Number， String 和 Date 各自代表的值）的值。这些接口的有一个实现类SimpleType 类。但是没有 SimpleBooleanModel 类型；为了代表布尔值，可以使用TemplateBooleanModel.TRUE 和 TemplateBooleanModel.FALSE 来单独使用。

Date有个问题，就是模板不知道它是date还是time还是datetime。TemplateDateModel 接口有两个方法：分别是java.util.Date getAsDate() 和int getDateType()。这个接口典型的实现是存储一个 java.util.Date 对象，加上一个整数来辨别“数据库存储的类型”。这个整数的值也必须是 TemplateDateModel 接口中的常量之一：DATE，TIME，DATETIME和UNKNOWN。通过内建函数date、time、datetime和string可以解决这个问题。

### 容器

#### 哈希表

哈希表是实现了 TemplateHashModel 接口的 Java 对象。TemplateHashModel 接口有两个方法：TemplateModel get(String key)，boolean isEmpty()。

TemplateHashModelEx 接口扩展了 TemplateHashModel 接口。它增加了更多的方法，使得可以使用内建函数 values 和 keys 来枚举哈希表中的子变量。经常使用的实现类是 SimpleHash，该类实现了 TemplateHashModelEx 接口。 

#### 序列

序列是实现了 TemplateSequenceModel 接口的 Java 对象。它包含两个方法：TemplateModel get(int index)和 int size()。

经常使用的实现类是 SimpleSequence， 该类内部使用一个 java.util.List 类型的对象存储它的子变量。

#### 集合

集合是实现了 TemplateCollectionModel 接口的 Java 对象。这个接口只定义了一个方法：TemplateModelIterator iterator() 。TemplateModelIterator 接口和 java.util.Iterator 相似，但是它返回 TemplateModels 而不是Object，而且它能抛出TemplateModelException 异常。通常使用的实现类是 SimpleCollection。

### 方法

方法变量在存于实现了 TemplateMethodModel 接口的模板中。这个接口仅包含一个方法： TemplateModel exec(java.util.List arguments)。当使用方法调用表达式调用方法时，exec 方法将会被调用。形参将会包含 FTL方法调用形参的值。exec 方法的返回值给出了 FTL 方法调用表达式的返回值。TemplateMethodModelEx 接口扩展了 TemplateMethodModel 接口。

```
class IndexOfMethod implements TemplateMethodModel {
	public TemplateModel exec(List args) throws TemplateModelException {
		if (args.size() != 2) {
			throw new TemplateModelException("Wrong arguments");
		}
		return new SimpleNumber(((String) args.get(1)).indexOf((String) args.get(0)));
	}
}
root.put("indexOf", new IndexOfMethod());
```
在模板中调用
```
<#assign x = "something">
${indexOf("met", x)}
${indexOf("foo", x)}
```

### 指令

可以使用 TemplateDirectiveModel 接口在 Java 代码中实现自定义指令。

```
/**
 * FreeMarker 的用户自定义指令在逐步改变 它嵌套内容的输出转换为大写形式
 * <p>
 * <b>指令内容</b>
 * </p>
 * <p>
 * 指令参数：无
 * <p>
 * 循环变量：无
 * <p>
 * 指令嵌套内容：是
 */
class UpperDirective implements TemplateDirectiveModel {
	public void execute(Environment env, Map params, TemplateModel[] loopVars,
			TemplateDirectiveBody body) throws TemplateException, IOException {
		// 检查参数是否传入
		if (!params.isEmpty()) {
			throw new TemplateModelException("This directive doesn't allow parameters.");
		}
		if (loopVars.length != 0) {
			throw new TemplateModelException("This directive doesn't allow loop variables.");
		}
		// 是否有非空的嵌入内容
		if (body != null) {
			// 执行嵌入体部分，和 FTL 中的<#nested>一样，除了
			// 我们使用我们自己的 writer 来代替当前的 output writer.
			body.render(new UpperCaseFilterWriter(env.getOut()));
		} else {
			throw new RuntimeException("missing body");
		}
	}

	/**
	 * {@link Writer}改变字符流到大写形式， 而且把它发送到另外一个{@link Writer}中。
	 */
	private static class UpperCaseFilterWriter extends Writer {
		private final Writer out;
		UpperCaseFilterWriter(Writer out) {
			this.out = out;
		}
		public void write(char[] cbuf, int off, int len) throws IOException {
			char[] transformedCbuf = new char[len];
			for (int i = 0; i < len; i++) {
				transformedCbuf[i] = Character.toUpperCase(cbuf[i + off]);
			}
			out.write(transformedCbuf);
		}
		public void flush() throws IOException {
			out.flush();
		}
		public void close() throws IOException {
			out.close();
		}
	}
}
root.put("upper", new UpperDirective());
```
然后在模板中使用
```
[@upper]
hello world!
[#list ["red","blue","white","black"] as color]
${color}
[/#list]
[/@upper]
```

### 节点

节点变量有下列属性， 它们都由 TemplateNodeModel 接口的方法提供。

* 基本属性：
    * TemplateSequenceModel getChildNodes()：一个节点的子节点序列（除非这个节点是叶子节点，这时方法返回一个空序列或者是 null）。子节点本身应该也是节点变量。
    * TemplateNodeModel getParentNode()：一个节点只有一个父节点（除非这个节点是节点树的根节点，这时方法返回 null）。
* 可选属性。如果一个属性在具体的使用中没有意义，那对应的方法应该返回 null：
    * String getNodeName()：节点名称也是宏的名称，当使用 recurse和 visit 指令时，它用来控制节点。因此， 如果想通过节点使用这些指令，那么节点的名称是必须的。
    * String getNodeType()：在 XML 技术中： "element"， "text"，"comment"等类型。 如果这些信息可用，就是通过 recurse 和 visit 指令来查找节点的默认处理宏。而且，它对其他有具体用途的应用程序也是有用的。
    * String getNamespaceURI()：这个节点所属的命名空间（和用于库的 FTL 命名空间无关）。例如，在 XML 中，这就是元素和属性所属 XML 命名空间的 URI。 这个信息如果可用，就是通过 recurse 和 visit 指令来查找存储控制宏的 FTL 命名空间。

在 FTL 这里，节点属性的直接使用可以通过内建函数 node 完成， 还有 visit 和 recurse 宏。

### 对象包装

Template.process()可以接收任何Java对象，不一定是TemplateModel，因为末班实现是会用合适的TemplateModel对象来替换原有对象。替换在获取自变量时必须会发生，因为getter方法返回TemplateModel，而不是Object。

替换策略通过ObjectWrapper实现，

* ObjectWrapper.DEFAULT_WRAPPER：它使用 SimpleScalar 来替换String， SimpleNumber 来替换 Number， SimpleSequence 来替换 List和数组，SimpleHash 来替换Map，TemplateBooleanModel.TRUE 或 TemplateBooleanModel.FALSE 来替换 Boolean，freemarker.ext.dom.NodeModel 来替换 W3C 组织定义的 DOM 模型节点类型。对于Jython 类型的对象，包装器会调用 freemarker.ext.jython.JythonWrapper。而对于其他对象，则会调用 BEAN_WRAPPER。
* ObjectWrapper.BEANS_WRAPPER：它可以通过 Java 的反射机制来获取到Java Bean 的属性和其他任意对象类型的成员变量。

如果在数据模型中放了任意的对象，那么DEFAULT_WRAPPER 就会调用BEANS_WRAPPER 来包装这个对象

```
root.put("person", new Person(1, "Jack"));
```

Person类有两个字段id和name。这里Person类必须是public的，而且字段需要提供getter方法。如果还有公开方法，那么公开方法名不能和字段名相同。否则会抛出异常。

## 配置

配置对象是freemarker.template.Configuration 的实例，可以通过构造方法来创建它。一个应用程序通常只使用一个共享的 Configuration 实例。

### 共享变量

Shared variables 共享变量是为所有模板所定义的变量。可以使用setSharedVariable 方法向配置实例中添加共享变量。

```
cfg.setSharedVariable("wrap", new WrapDirective());
cfg.setSharedVariable("company", "Foo Inc.");
```
如果配置对象在多线程环境中使用，不要使用 TemplateModel 实现类来作为共享变量，因为它是线程不安全的。这也是基于 Servlet 的 Web 站点的典型情况。

### 配置信息

Settings 配置信息是影响 FreeMarker 行为的已经被命名的值。

Environment中能覆盖Template中的配置信息，Template中能覆盖Configuration中的配置信息。

Configuration可以通过setter方法或setSetting方法设置配置信息。

```
myCfg.setLocale(java.util.Locale.ITALY);
myCfg.setNumberFormat("0.####");
myCfg.setSetting("locale","it_IT");
myCfg.setSetting("number_format","0.####");
```

Template层不需要设置配置信息。

Environment层这里有两种设置方法

```
Environment env =
myTemplate.createProcessingEnvironment(root, out);
env.setLocale(java.util.Locale.ITALY);
env.setNumberFormat("0.####");
env.process(); // 处理模板
```
或在模板中直接使用指令
```
<#setting locale="it_IT">
<#setting number_format="0.####">
```

### 模板加载

#### 内建模板加载器

在 Configuration 中可以使用下面的方法来方便建立三种模板加载。（每种方法都会在其内部新建一个模板加载器对象，然后创建 Configuration 实例来使用它。）

```
void setDirectoryForTemplateLoading(File dir);
void setClassForTemplateLoading(Class cl, String prefix);
void setServletContextForTemplateLoading(Object servletContext, String path);
```
上述的第一种方法在磁盘的文件系统上设置了一个明确的目录，它确定了从哪里加载模板。

第二种调用方法使用了一个 Class 类型的参数和一个前缀。这是让你来指定什么时候通过相同的机制来加载模板，不过是用 Java 的 ClassLoader 来加载类。 这就意味着传入的 Class 参数会被用来调用 Class.getResource()方法来找到模板。参数 prefix是给模板的名称来加前缀的。在实际运行的环境中，类加载机制是首选用来加载模板的方法，因为通常情况下，从类路径下加载文件的这种机制， 要比从文件系统的特定目录位置加载安全而且简单。 在最终的应用程序中，所有代码都使用.jar 文件打包也是不错的，这样用户就可以直接执行包含所有资源的.jar 文件了。

第三种调用方式需要 Web 应用的上下文和一个基路径作为参数，这个基路径是 Web 应用根路径（ WEB-INF 目录的上级目录）的相对路径。那么加载器将会从 Web 应用目录开始加载模板。尽管加载方法对没有打包的.war 文件起作用，因为它使用了ServletContext.getResource()方法来访问模板，注意这里我们指的是“目录”。

#### 从多个位置加载

如果需要从多个位置加载模板，那就不得不为每个位置都实例化模板加载器对象，将它们包装到一个被成为 MultiTemplateLoader 的特殊模板加载器

```
FileTemplateLoader ftl1 = new FileTemplateLoader(new File("/tmp/templates"));
FileTemplateLoader ftl2 = new FileTemplateLoader(new File("/usr/data/templates"));
ClassTemplateLoader ctl = new ClassTemplateLoader(getClass(), "");
TemplateLoader[] loaders = new TemplateLoader[] { ftl1, ftl2, ctl };
MultiTemplateLoader mtl = new MultiTemplateLoader(loaders);
cfg.setTemplateLoader(mtl);
```

FreeMarker 将会尝试从/tmp/templates 目录加载模板，如果在这个目录下没有发现请求的模板，它就会继续尝试从/usr/data/templates 目录下加载，如果还是没有发现请求的模板，那么它就会使用类加载器来加载模板。

#### 从其他资源加载模板

需要自己实现加载器实现freemarker.cache.TemplateLoader 或freemarker.cache.URLTemplateLoader 接口

#### 模板路径

强烈建议模板加载器使用 URL 风格的路径

### 模板缓存

FreeMarker 是会缓存模板的（假设使用 Configuration 对象的方法来创建 Template 对象）。这就是说当调用 getTemplate 方法时， FreeMarker 不但返回了Template 对象的结果，而且还会将它存储在缓存中，当下一次再以相同（或相等）路径调用 getTemplate 方法时，那么它只返回缓存的 Template 实例， 而不会再次加载和解析模板文件了。

如果更改了模板文件，当下次调用模板时， FreeMarker 将会自动重新载入和解析模板。然而，要检查模板文件是否改变内容了是需要时间的，有一个 Configuration 级别的设置被称作为“更新延迟”可以用来配置这个时间。这个时间就是从上次对某个模板检查更新后， FreeMarker 再次检查模板所要间隔的时间。 其默认值是 5 秒。如果想要看到模板立即更新的效果，那么就要把它设置为 0。要注意某些模板加载器也许在模板更新时可能会有问题。例如，典型的例子就是在基于类加载器的模板加载器就不会注意到模板文件内容的改变。

当调用了 getTemplate 方法时，与此同时 FreeMarker 意识到这个模板文件已经被
移除了，所以这个模板也会从缓存中移除。 如果 Java 虚拟机认为会有内存溢出时，默认情况它会将任意的模板从缓存中移除。此外，你还可以使用 Configuration 对象的clearTemplateCache 方法手动清空缓存。

何时将一个被缓存了的模板清除的实际应用策略是由配置的属性 cache_storage来确定的，通过这个属性可以配置任何 CacheStorage 的实现。对于大多数用户来说，使用 freemarker.cache.MruCacheStorage 就足够了。这个缓存存储实现了二级最近使用的缓存。在第一级缓存中，组件都被强烈引用到特定的最大数目（引用次数最多的组件不会被 Java 虚拟机抛弃，而引用次数很少的组件则相反）。当超过最大数量时，最近最少使用的组件将被送至二级缓存中，在那里它们被很少引用，直到达到另一个最大的数目。引用强度的大小可以由构造方法来指定。例如，设置强烈部分为 20，轻微部分为 250：

或者，使用 MruCacheStorage 缓存，它是默认的缓存存储实现。当创建了一个新的 Configuration 对象时，它使用一个 maxStrongSize 值为0 的 MruCacheStorage 缓存来初始化，maxSoftSize 的值是Integer.MAX_VALUE（也就是说在实际中，是无限大 的）。 但是使用非 0 的 maxStrongSize 对于高负载的服务器来说也许是一个更好的策略，对于少量引用的组件来说，如果资源消耗已经很高的话， Java 虚拟机往往会引发更高的资源消耗，因为它不断从缓存中抛出经常使用的模板，这些模板还不得不再次加载和解析。

### 错误控制

#### 可能的异常 

当加载和解析模板时发生异常： 调用了 Configuration.getTemplate(...) 方法， FreeMarker 就要把模板文件加载到内存中然后来解析它（除非模板已经在Configuration 对象中被缓存了）。 在这期间，有两种异常可能发生：

* 因模板文件没有找到而发生的 IOException 异常，或在读取文件时发生其他的 I/O 问题。比如没有读取文件的权限，或者是磁盘错误。这些错误的发出者是TemplateLoader 对象，可以将它设置到 Configuration 对象中。（为了正确起见：这里所说的”文件”，是简化形式。例如，模板也可以存储在关系型数据库的表中。这是 TemplateLoader 所要做的事。）
* 根据FTL语言的规则，模板文件发生语法错误时会导致 freemarker.core.ParseException 异常。当获得 Template 对象（ Configuration.getTemplate(...)）时，这种错误就会发生，而不是当执行（Template.process(...) ）模板的时候。这种异常是IOException 异常的一个子类。

当执行（处理）模板时发生的异常，也就是当调用了 Template.process(...)方法时会发生的两种异常：
* 当试图写入输出对象时发生错误而导致的 IOException 异常。
* 当执行模板时发生的其它问题而导致的freemarker.template.TemplatException 异常。比如，一个频繁发生的错误，就是当模板引用一个不存在的变量。默认情况下，当TemplatException 异常发生时， FreeMarker 会用普通文本格式在输出中打印出 FTL 的错误信息和堆栈跟踪信息。然后通过再次抛出 TemplatException异常而中止模板的执行，然后就可以捕捉到 Template.process(...)方法抛出的异常了。而这种行为是可以来定制的。FreeMarker也会经常写 TemplatException 异常的日志。

#### 根据 TemplateException 来制定处理方式

Configuration中通过setTemplateExceptionHandler可以制定处理方式

```
class MyTemplateExceptionHandler implements TemplateExceptionHandler {
	public void handleTemplateException(TemplateException te, Environment env,
			java.io.Writer out) throws TemplateException {
		try {
			out.write("[ERROR: " + te.getMessage() + "]");
		} catch (IOException e) {
			throw new TemplateException("Failed to print error message. Cause: " + e, env);
		}
	}
}
cfg.setTemplateExceptionHandler(new MyTemplateExceptionHandler());
```

FreeMarker 本身带有这些预先编写的错误控制器：

* TemplateExceptionHandler.DEBUG_HANDLER：打印堆栈跟踪信息（包括 FTL 错误信息和 FTL 堆栈跟踪信息）和重新抛出的异常。这是默认的异常控制器（也就是说，在所有新的 Configuration 对象中，它是初始配置的）。
* TemplateExceptionHandler.HTML_DEBUG_HANDLER：DEBUG_HANDLER 相同，但是它可以格式化堆栈跟踪信息，那么就可以在 Web 浏览器中来阅读错误信息。当你在制作 HTML 页面时，建议使用它而不是DEBUG_HANDLER。
* TemplateExceptionHandler.IGNORE_HANDLER：简单地压制所有异常（但是要记住， FreeMarker 仍然会写日志）。它对处理异常没有任何作用，也不会重新抛出异常。
* TemplateExceptionHandler.RETHROW_HANDLER：简单重新抛出所有异常而不会做其它的事情。这个控制器对 Web 应用程序（假设你在发生异常之后不想继续执行模板）来说非常好，因为它在生成的页面发生错误的情况下，给了你很多对 Web应用程序的控制权。

#### 在模板中明确地处理错误

你可以在模板中直接控制错误。通常这不是一个好习惯（尽量保持模板简单，技术含量不要太高），但有时仍然需要：

* 控制不存在/为空的变量：请阅读模板开发指南/模板/表达式/处理不存在的值部分。
* 在发生障碍的“ porlets” 中留存下来

## 其他

### 变量

当你想要读取一个变量时， FreeMarker 将会以这种顺序来查找，直到发现了完全匹配的的变量名称才会停下来

1. 在 Environment 对象中：
    1. 如果在循环中，在循环变量的集合中。循环变量是由 （ 如 list 指令）来创建的。
    2. 如果在宏中，在宏的局部变量集合中。局部变量可以由 local 指令创建。而且，宏的参数也是局部变量。
    3. 在当前的命名空间中。可以使用 assign 指令将变量放到一个命名空间中。
    4. 在由 global 指令创建的变量集合中。FTL 将它们视为数据模型的普通成员变量一样来控制它们。也就是说，它们在所有的命名空间中都可见，你也可以像访问一个数据模型中的数据一样来访问它们。
2. 在传递给 process 方法的数据模型对象中。
3. 在 Configuration 对象存储的共享变量集合中。

1.4, 2,3 共同构成了全局变量的集合

### 编码

输入编码

可以使用配置对象的setEncoding(Locale locale, String encoding)方法来填充编码表；编码表初始化时是空的。默认的初始编码是系统属性 file.encoding 的值，但是可以通过 setDefaultEncoding 方法来设置一个不同的默认值。

输出编码

原则上， FreeMarker 不处理输出内容的字符集问题，因为 FreeMarker 将输出内容都写入了 java.io.Writer 对象中。而 Writer 对象是由封装了 FreeMarker（比如 Web应用框架）的软件生成的，那么输出内容的字符集就是由封装软件来控制的。而 FreeMarker有一个称为 output_encoding（开始于 FreeMarker 2.3.1 版本之后）的设置。封装软件应该使用这个设置（ Writer 对象使用的字符集） 来通知 FreeMarker 在输出中（ 否则 FreeMarker 不能找到它）使用哪种字符集。 

为独立模板设置编码

```
Writer w = new OutputStreamWriter(out, outputCharset);
Environment env = template.createProcessingEnvironment(dataModel, w);
env.setOutputEncoding(outputCharset);
env.process();
```

### 多线程

在多线程运行环境中， Configuration 实例， Template 实例和数据模型应该是永远不能改变（只读）的对象。也就是说， 创建和初始化它们（如使用 set...方法） 之后， 就不能再修改它们了（ 比如不能再次调用 set...方法）。 

不鼓励你编写修改数据模型对象或共享变量的方法。多试试使用存储在环境对象（这个对象是为独立的 Template.process 调用而创建的，用来存储模板处理的运行状态）中的变量，所以最好不要修改那些由多线程使用的数据。

### Bean 的包装

当 出 现 下 面 这 些 情 况 时 ， 你 会 想 使 用 BeansWrapper 包 装 器 来 代 替 DefaultObjectWrapper：
在模板执行期间，数据模型中的 Collection 和 Map 应该被允许修改。（ DefaultObjectWrapper 会阻止这样做，因为当它包装对象时创建了数据集合的拷贝，而这些拷贝都是只读的。）
如果 array， Collection 和 Map 对象的标识符当在模板中被传递到被包装对象的方法时，必须被保留下来。 也就是说，那些方法必须得到之前包装好的同类对象。
如果在之前列出的 Java API 中的类（ 如 String， Map， List 等），应该在模板中可见。还有，默认情况下它们是不可见的，但是可以设置获取的可见程度

#### 安全性

默认情况下，不能访问模板制作时认为是不安全的一些方法。比如，不能使用同步方法（ wait， notify， notifyAll），线程和线程组的管理方法（ stop， suspend，resume， setDaemon ， setPriority ），反射相关方法（ Field setXxx ，Method.invoke， Constructor.newInstance， Class.newInstance，Class.getClassLoader 等）， System 和 Runtime 类中各种有危险性的方法（ exec， exit， halt， load 等）。 BeansWrapper 也有一些安全级别（被称作“方法暴露的级别”）， 默认的级别被称作为 EXPOSE_SAFE，它可能对大多数应用程序来说是适用的。没有安全保证的级别称作是 EXPOSE_ALL，它允许你调用上述的不安全的方法。一个严格的级别是 EXPOSE_PROPERTIES_ONLY，它只会暴露出 bean 属性的 getters方法。最后，一个称作是 EXPOSE_NOTHING 的级别，它不会暴露任何属性和方法。这种情况下，你可以通过哈希表模型接口访问的那些数据只是 map 和资源包中的项，还有，可以从通用 get(Object) 方法和 get(String)方法调用返回的对象，所提供的受影响的对象就有这样的方法。

#### 访问静态变量

从 BeansWrapper.getStaticModels() 方法返回的 TemplateHashModel 对象可以用来创建哈希表模型来访问静态方法和任意类型的字段。
```
BeansWrapper wrapper = BeansWrapper.getDefaultInstance();
TemplateHashModel staticModels = wrapper.getStaticModels();
TemplateHashModel fileStatics = (TemplateHashModel) staticModels.get("java.io.File");
root.put("File", fileStatics);
```
模板中使用
```
<#list File.listRoots() as fileSystemRoot>...</#list>
```

如果使用，将带来更多自由
```
root.put("statics", BeansWrapper.getDefaultInstance().getStaticModels());
```
可以这样使用
```
${statics["java.lang.System"].currentTimeMillis()} 
```
注意，这样会有更多的安全隐患，比如，如果方法暴露级别对 EXPOSE_ALL 是很弱的，那么某些人可以使用这个模型调用 System.exit()方法。

#### 访问枚举类型

BeansWrapper.getDefaultInstance()返回的对象可以被用作创建访问枚举类型值的哈希表模型

```
BeansWrapper wrapper = BeansWrapper.getDefaultInstance();
TemplateHashModel enumModels = wrapper.getEnumModels();
TemplateHashModel roundingModeEnums = (TemplateHashModel)enumModels.get("java.math.RoundingMode");
root.put("RoundingMode", roundingModeEnums);
```
使用
```
RoundingMode.UP
```

更自由的方式
```
root.put("enums", BeansWrapper.getDefaultInstance().getEnumModels());
```
使用

```
${enums["java.math.RoundingMode"].UP}
```

### 日志

默认情况下， FreeMarker 会按如下顺序来查找日志包，而且会自动使用第一个发现的包： SLF4J，Apache Commons Logging，Log4J，Avalon， java.util.logging。 然而，如果在 freemarker.log.Logger 类用合适的参数中调用静态的 selectLoggerLibrary 方法，而且在使用任何 FreeMarker 类之前记录信息，你可以明确地选择一个日志包，或者关闭日志功能。

### 在 Servlet 中使用 FreeMarker

1. 复制 freemarker.jar 到（从 FreeMarker 发布包的 lib 目录中）你的 Web
应用程序的 WEB-INF/lib 目录下。
2. 将下面的部分添加到 Web 应用程序的 WEB-INF/web.xml 文件中（调整它是否
需要）。
```
<servlet>
<servlet-name>freemarker</servlet-name>
<servlet-class>
freemarker.ext.servlet.FreemarkerServlet
</servlet-class>
<!-- FreemarkerServlet 设置: -->
<init-param>
<param-name>TemplatePath</param-name>
<param-value>/</param-value>
</init-param>
<init-param>
<param-name>NoCache</param-name>
<param-value>true</param-value>
</init-param>
<init-param>
<param-name>ContentType</param-name>
<param-value>text/html; charset=UTF-8</param-value>
<!-- 强制使用 UTF-8 作为输出编码格式! -->
</init-param>
<!-- FreeMarker 设置: -->
<init-param>
<param-name>template_update_delay</param-name>
<param-value>0</param-value>
<!-- 0 只对开发使用! 否则使用大一点的值. -->
</init-param>
<init-param>
<param-name>default_encoding</param-name>
<param-value>ISO-8859-1</param-value>
<!-- 模板文件的编码方式. -->
</init-param>
<init-param>
<param-name>number_format</param-name>
<param-value>0.##########</param-value>
</init-param>
<load-on-startup>1</load-on-startup>
</servlet>
<servlet-mapping>
<servlet-name>freemarker</servlet-name>
<url-pattern>*.ftl</url-pattern>
</servlet-mapping>
...
<!-- 为了阻止从 Servlet 容器外部访问 MVC 的视图层组件。
RequestDispatcher.forward/include 应该起到作用。
移除下面的代码可能开放安全漏洞!
-->
<security-constraint>
<web-resource-collection>
<web-resource-name>
FreeMarker MVC Views
</web-resource-name>
<url-pattern>*.ftl</url-pattern>
</web-resource-collection>
<auth-constraint>
<!-- 不允许任何人访问这里 -->
</auth-constraint>
</security-constraint>
```

它是怎么工作的？让我们来看看 JSP 是怎么工作的。许多 servlet 容器处理 JSP 时使用一个映射为*.jsp 的 servlet 请求 URL 格式。 这样 servlet 就会接收所有 URL 是以.jsp结尾的请求，查找请求 URL 地址中的 JSP 文件，内部编译完后交给 Servlet，然后调用 生 成 信 息 的 serlvet 来 生 成 页 面 。 这 里 为 URL 类 型 是 *.ftl 映射的 FreemarkerServlet 也是相同功能，只是 FTL 文件不会编译给 Servlet，而是给 Template 对象，之后 Template 对象的 process 方法就会被调用来生成
页面。

Freemarker现在页面中寻找变量，其次在 HttpServletRequest中寻找，然后在 HttpSession，最后在ServletContext中

FreemarkerServlet 也会在数据模型中放置 3 个哈希表，这样你就可以直接访问 3 个对象中的属性了。这些哈希表变量是： Request， Session， Application（和ServletContext 对应）。它还会暴露另外一个名为 RequestParameters 的哈希表，这个哈希表提供访问 HTTP 请求中的参数。

FreemarkerServlet 也有很多初始参数。它可以被设置从任意路径来加载模板，从类路径下，或相对于 Web 应用程序的目录。你可以设置模板使用的字符集。你还可以设置想使用的对象包装器等。

通过子类别， FreemarkerServlet 易于定制特殊需要。那就是说，你需要对所有模板添加一个额外的可用变量，使用 servlet 的子类，覆盖 preTemplateProcess()方法，在模板被执行前，将你需要的额外数据放到模型中。或者在 servlet 的子类中，在Configuration 中设置这些全局的变量作为共享变量。

#### 包含其它Web应用程序资源中的内容

```
<@include_page path="path/to/some.jsp"/>
```
和使用 JSP 指令是相同的：
```
<jsp:include page="path/to/some.jsp">
```
`<@include_page ...>`会开始一个独立的 HTTP 请求处理。

除了参数 path 之外，你也可以用布尔值（当不指定时默认是 true）指定一个名为 inherit_params 可选的参数来指定被包含的页面对当前的请求是否可见 HTTP 请求中的参数。

最后，你可以指定一个名为 params 的可选参数，来指定被包含页面可见的新请求参数。 如果也传递继承的参数，那么指定参数的值将会得到前缀名称相同的继承参数的值。params 的值必须是一个哈希表类型，它其中的每个值可以是字符串，或者是字符串序列（如果你需要多值参数）。

```
<@include_page path="path/to/some.jsp" inherit_params=true params={"foo": "99", "bar": ["a", "b"]}/>
```

如果“foo”有值“111”和“123”，那么现在它会有“99”，“111”，“123”。

#### 在 FTL 中使用 JSP 客户化标签

FreemarkerServlet 将一个哈希表类型的 JspTaglibs 放到数据模型中，就可以使用它来访问 JSP 标签库了。

```
<#assign html=JspTaglibs["/WEB-INF/struts-html.tld"]>
<#assign bean=JspTaglibs["/WEB-INF/struts-bean.tld"]>
<html>
<body>
<h1><@bean.message key="welcome.title"/></h1>
<@html.errors/>
<@html.form action="/query">
Keyword: <@html.text property="keyword"/><br>
Exclude: <@html.text property="exclude"/><br>
<@html.submit value="Send"/>
</@html.form>
</body>
</html>
```

因为 JSP 客户化标签是在 JSP 环境中来书写操作的，它们假设变量（在 JSP 中常被指代“beans”）被存储在 4 个范围中： page 范围， request 范围， session 范围和 application 范围。FTL 没有这样的表示法（ 4 种范围），但是 FreemarkerServlet 给客户化标签提供仿真的环境，这样就可以维持 JSP 范围中的“ beans”和 FTL 变量之间的对应关系。对于自定义的JSP标签，请求，会话和应用范围是和真实JSP相同的：javax.servlet.ServletContext，HttpSession 和 ServerRequest 对象中的属性。从 FTL 的角度来看，这三种范围都在数据模型中
