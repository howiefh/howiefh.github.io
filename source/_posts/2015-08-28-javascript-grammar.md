title: JavaScript 基本语法
date: 2015-08-28 12:14:28
tags: JavaScript
categories: JavaScript
description: JavaScript 基本语法，ECMAScript 6，语法，变量，数据类型，操作符，语句，函数，箭头函数，Generator函数，尾调用优化，模块，错误处理，基本类型和引用类型，执行环境和作用域，垃圾回收
---
[JavaScript 基本语法](2015/08/28/javascript-grammar/)，[JavaScript 引用类型](2015/08/28/javascript-reference-type/)，[JavaScript 面向对象程序设计、函数表达式和异步编程](2015/08/28/javascript-oop-function-expression-and-async/)三篇笔记是对《JavaScript 高级程序设计》和 [《ECMAScript 6入门》](https://github.com/ruanyf/es6tutorial/tree/5a5f9d8d492d0f925cbb6e09b10ebed9d2078d40)两本书的总结整理。

# 简介
一个完整的JavaScript实现应该由三个不同的部分组成：核心（ECMAScript）、文档对象模型（DOM）、浏览器对象模型（BOM）

JavaScript实现了ECMAScript，Adobe ActionScript同样也实现了ECMAScript。

<!-- more -->
# HTML中使用JavaScript
## script元素
使用`<script>`元素的方式有两种：直接在页面中嵌入 JavaScript 代码和包含外部 JavaScript文件。 在使用`<script>`元素嵌入 JavaScript代码时，只须为`<script>`指定 type 属性。

包含在`<script>`元素内部的JavaScript代码将被从上至下依次解释。就拿前面这个例子来说，解释器会解释一个函数的定义，然后将该定义保存在自己的环境当中。在解释器对`<script>`元素内部的所有代码求值完毕以前，页面中的其余内容都不会被浏览器加载或显示。 在使用`<script>`嵌入JavaScript代码时，记住不要在代码中的任何地方出现`</script>`字符串。例如，浏览器在加载下面所示的代码时就会产生一个错误： `<script type="text/javascript"> function sayScript(){ alert("</script>"); } </script>` 因为按照解析嵌入式代码的规则，当浏览器遇到字符串`</script>`时，就会认为那是结束的`</script>`

如果是在 XHTML文档中，也可以省略前面示例代码中结束的`</script>`标签，例如： `<script type="text/javascript" src="example.js" />` 但是，不能在 HTML文档使用这种语法。原因是这种语法不符合 HTML规范

为了避免延迟浏览器出现空白，现代Web应用程序一般都把全部JavaScript引用放在`<body>`元素中页面内容的后面，

按照惯例，外部 JavaScript文件带有.js扩展名。但这个扩展名不是必需的，因为浏览器不会检查包含 JavaScript的文件的扩展名。这样一来，使用 JSP、PHP或其他服务器端语言动态生成 JavaScript代码也就成为了可能。但是，服务器通常还是需要看扩展名决定为响应应用哪种 MIME 类型。如果不使用.js 扩展名，请确保服务器能返回正确的MIME类型。 需要注意的是，带有 src 属性的`<script>`元素不应该在其`<script>`和`</script>`标签之间再包含额外的 JavaScript代码。如果包含了嵌入的代码，则只会下载并执行外部脚本文件，嵌入的代码会被忽略。

无论如何包含代码，只要不存在 defer 和 async 属性，浏览器都会按照`<script>`元素在页面中出现的先后顺序对它们依次进行解析

HTML 4.01为`<script>`标签定义了defer属性。这个属性的用途是表明脚本在执行时不会影响页面的构造。也就是说，脚本会被延迟到整个页面都解析完毕后再运行。因此，在`<script>`元素中设置defer

在现实当中，延迟脚本并不一定会按照顺序执行，也不一定会在 DOMContentLoaded 事件触发前执行，因此最好只包含一个延迟脚本。 前面提到过，defer 属性只适用于外部脚本文件。这一点在 HTML5 中已经明确规定，因此支持HTML5的实现会忽略给嵌入脚本设置的 defer 属性

指定async属性的目的是不让页面等待两个脚本下载和执行，从而异步加载页面其他内容。为此，建议异步脚本不要在加载期间修改DOM。 异步脚本一定会在页面的 load 事件前执行，但可能会在 DOMContentLoaded 事件触发之前或之后执行。

同样与defer类似，async只适用于外部脚本文件，并告诉浏览器立即下载文件。但与defer不同的是，标记为async的脚本并不保证按照指定它们的先后顺序执行。

保证让相同代码在 XHTML中正常运行的第二个方法，就是用一个 CData片段来包含 JavaScript代码。在XHTML（XML）中，CData片段是文档中的一个特殊区域，这个区域中可以包含不需要解析的任意格式的文本内容。

但由于所有浏览器都已经支持 JavaScript，因此也就没有必要再使用下面这种格式了。

```
//<!--
代码
//-->
```

## 嵌入代码和外部文件
一般认为最好的做法还是尽可能使用外部文件来包含 JavaScript代码。可维护性，可缓存，适应未来

## 文档模式
文档模式是：混杂模式（quirks mode）和标准模式（standards mode）。混杂模式会让IE的行为与（包含非标准特性的）IE5相同，而标准模式则让IE的行为更接近标准行为。虽然这两种模式主要影响CSS内容的呈现，但在某些情况下也会影响到 JavaScript的解释执行。

对于准标准模式，则可以通过使用过渡型（transitional）或框架集型（frameset）文档类型来触发，

如果在文档开始处没有发现文档类型声明，则所有浏览器都会默认开启混杂模式。但采用混杂模式不是什么值得推荐的做法，因为不同浏览器在这种模式下的行为差异非常大，如果不使用某些 hack 技术，跨浏览器的行为根本就没有一致性可言。

## noscript
包含在`<noscript>`元素中的内容只有在这些情况下才会显示出来：浏览器不支持脚本；浏览器支持脚本，但脚本被禁用。

## ECMAScript 6
在 Chrome 地址栏中输入 chrome://flags/#enable-javascript-harmony，启用实验性 JavaScript

[Firefox 支持的 ECMAScript 6 特性](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/New_in_JavaScript/ECMAScript_6_support_in_Mozilla)

各个平台对ECMAScript 6的支持情况可以查看 <https://kangax.github.io/compat-table/es6/>

鉴于现在浏览器并没有完全支持ECMASctipt6，所以可以用ES6的方式编写代码，之后用[Babel](https://babeljs.io/)或谷歌的[Traceur](https://github.com/google/traceur-compiler)进行转码

另外node中使用可以加参数`--harmony`

# 基本概念
## 语法
ECMAScript中的一切（变量、函数名和操作符）都区分大小写

标识符可以是按照下列格式规则组合起来的一或多个字符：第一个字符必须是一个字母、下划线（`_`）或一个美元符号（`$`）；其他字符可以是字母、下划线、美元符号或数字。 标识符中的字母也可以包含扩展的ASCII或Unicode字母字符（如À和Æ），但我们不推荐这样做。 按照惯例，ECMAScript标识符采用驼峰大小写格式，也就是第一个字母小写，剩下的每个单词的首字母大写

C风格的注释，包括单行注释和块级注释

ECMAScript中的语句以一个分号结尾；如果省略分号，则由解析器确定语句的结尾。最好不省略分号，省略分号，解释器会猜测在什么位置加分号，这样可能会照成与预期不同的结果。如
```
return //浏览器在这里加入分号，然后1+2就不会被返回了
    1 + 2
```

要在整个脚本中启用严格模式，可以在顶部添加如下代码： "use strict";

## 变量
### 通过var声明
ECMAScript 的变量是松散类型的，所谓松散类型就是可以用来保存任何类型的数据。定义变量应该使用var操作符（不使用var操作符将会定义一个全局变量，这种方式不被推荐），后面跟一个变量名。`var message`像这样只是声明一个变量，并没有初始化，它的值将是undefined。

变量声明具有hoisting机制，JavaScript引擎在执行的时候，会把所有变量的声明都提升到当前作用域的最前面。
```
var v = "hello";
(function(){
  console.log(v);
  var v = "world";
  var f = function(){};
})();
```
执行结果是undefined。这就是因为变量提升，上面的代码实际上会是这样的

```
var v;
v = "hello";
(function(){
  //覆盖全局的v变量，并且没有初始化所以是undefined
  var v,f;
  console.log(v);
  v = "world";
  //函数表达式不会被提升，但是函数声明会，后面还会讲
  f = function(){};
})();
```

严格模式下，不能定义名为eval或arguments的变量，否则会导致语法错误。

### 通过let声明
ES6中还可以使用let生命变量不同的是let声明的变量只在其所在代码块内有效（意味着ES6支持块级作用域了），并且不会发生“变量提升“现象（注意引号，当进入包含let的作用域，let所声明的变量以创建但是不可以使用，读写都会抛错，直到声明语句）。let不允许在相同作用域内，重复声明同一个变量。

```
(function(){
  var v = "world";
  if (true) {
    v = 'hello';
    let v;
  }
})();
```
只要块级作用域内存在let命令，它所声明的变量就“绑定”（binding）这个区域，不再受外部的影响。上面的代码中if块内v通过let声明，不再受外部变量v影响，但是由于在let声明前对v赋值，所以会报错。

总之，在代码块内，使用let命令声明变量之前，该变量都是不可用的。这在语法上，称为“暂时性死区”（temporal dead zone，简称TDZ）。

下面两个函数中使用let重复声明变量都会报错
```
function () {
  let a = 10;
  var a = 1;
}
function () {
  let a = 10;
  let a = 1;
}
```

### 通过const声明
ECMAScript6中const也用来声明变量，但是声明的是常量。一旦声明，常量的值就不能改变。const的作用域与let命令相同：只在声明所在的块级作用域内有效；不存在“变量提升“现象，只能在声明的位置后面使用；也不可重复声明。和Java中final有点类似，不可变是指其指向的对象不可变，但是对象内部属性可以变。
```
const foo = {};
foo.prop = 123;
foo.prop // 123
foo = {} // 不起作用
```
如果真的想将对象冻结，应该使用Object.freeze方法。
```
const foo = Object.freeze({});
foo.prop = 123; // 不起作用
```
除了将对象本身冻结，对象的属性也应该冻结。
```
var constantize = (obj) => {
  Object.freeze(obj);
  Object.keys(obj).forEach( (key, value) => {
    if ( typeof obj[key] === 'object' ) {
      constantize( obj[key] );
    }
  });
};
```
const声明的常量只在当前代码块有效。如果想设置跨模块的常量，可以采用下面的写法。

```
// constants.js 模块
export const A = 1;
export const B = 3;
export const C = 4;
// test1.js 模块
import * as constants from './constants';
console.log(constants.A); // 1
console.log(constants.B); // 3
// test2.js 模块
import {A, B} from './constants';
console.log(A); // 1
console.log(B); // 3
```

ES6规定，var和function声明的全局变量，属于全局对象的属性；let命令、const命令、class命令声明的全局变量，不属于全局对象的属性。
```
var a = 1;
//这里this即全局变量，在浏览器中就是window，node中是global
this.a;
let b = 1;
this.b; //undefined
```
模块中运行的全局变量，都是当前模块的属性，而不是node顶层对象的属性。

## 数据类型
ECMAScript中有5种简单数据类型（也称为基本数据类型）：Undefined、Null、Boolean、Number和String。还有1种复杂数据类型——Object，其本质是一组**无序**的名值对组成

ES6引入了一种新的基本数据类型Symbol，是一种特殊的、不可变的数据类型，可以作为对象属性的标识符使用。

现在共有七种数据类型：Undefined, Null, Boolean, String, Symbol, Number和Object.

### typeof
typeof的返回值
* "undefined" 如果这个值未定义
* "boolean" 如果这个值是布尔值
* "string" 如果这个值是字符串
* "number" 如果这个值是数值
* "object" 如果这个值是对象或者null
* "function" 如果这个值是函数
* "symbol" 如果这个值是Symbol类型（ES6新增）

**从技术角度讲，函数在ECMAScript中是对象**

typeof操作符的操作数可以是变量（message），也可以是数值字面量。注意，typeof是一个操作符而不是函数，因此例子中的圆括号尽管可以使用，但不是必需的。

### Undefined
Undefined类型只有一个值，即特殊的undefined。在使用var声明变量但未对其加以初始化时，这个变量的值就是undefined

对未初始化和未声明的变量执行 typeof 操作符都返回 undefined 值，但是如果直接访问未声明的变量就会报错了。

对于尚未声明过的变量，只能执行一项操作，即使用typeof操作符检测其数据类型，这也是typeof存在的最大意义了。

### Null
Null类型是第二个只有一个值的数据类型，这个特殊的值是 null。从逻辑角度来看，null 值表示一个空对象指针，而这也正是使用 typeof 操作符检测 null 值时会返回"object"的原因

实际上，undefined值是派生自null值的，`null == undefined`将会返回true。

如果定义的变量准备在将来用于保存对象，那么最好将该变量初始化为null而不是其他值。这样一来，只要直接检查null 值就可以知道相应的变量是否已经保存了一个对象的引用

### Boolean
可以对任何数据类型的值调用Boolean()函数，而且总会返回一个Boolean值，你也可以在任何数据前加`!!`使其转化为Boolean类型。

转换规则

数据类型  | 转换为true的值           | 转换为false的值
---       | ---                      | ---
Boolean   | true                     | false
String    | 非空字符串               | ""
Number    | 非零数字值（包括无穷大） | 0和NaN
Object    | 任何对象                 | null
Undefined | n/a（不适用）            | undefined

### Number
八进制字面量在严格模式下是无效的

默认情况下，ECMAScript会将那些小数点后面带有 6个零以上的浮点数值转换为以 e表示法表示的数值（例如，0.0000003会被转换成3e-7）

如果浮点数值本身表示的就是一个整数（如1.0），那么该值也会被转换为整数

永远不要测试某个特定的浮点数值。 关于浮点数值计算会产生舍入误差的问题，有一点需要明确：这是使用基于IEEE754数值的浮点计算的通病，ECMAScript并非独此一家；其他使用相同数值格式的语言也存在这个问题。

所谓浮点数值，就是该数值中必须包含一个小数点，并且小数点后面必须至少有一位数字。虽然小数点前面可以没有整数，但我们不推荐这种写法

isNaN()函数。这个函数接受一个参数，该参数可以是任何类型，而函数会帮我们确定这个参数是否“不是数值”

ECMAScript能够表示的最小数值保存在 Number.MIN_VALUE 中——在大多数浏览器中，这个值是 5e-324；能够表示的最大数值保存在Number.MAX_VALUE中——在大多数浏览器中，这个值是1.7976931348623157e+308。如果某次计算的结果得到了一个超出JavaScript数值范围的值，那么这个数值将被自动转换成特殊的 Infinity 值

要想确定一个数值是不是有穷的（换句话说，是不是位于最小和最大的数值之间），可以使用 isFinite()函数

NaN，即非数值（Not a Number）是一个特殊的数值，这个数值用于表示一个本来要返回数值的操作数未返回数值的情况（这样就不会抛出错误了）。例如，在其他编程语言中，任何数值除以0都会导致错误，从而停止代码执行。但在ECMAScript中，任何数值除以0会返回NaN（实际上只有0除以0才会返回NaN，正数除以0返回Infinity，负数除以0返回-Infinity），因此不会影响其他代码的执行。 NaN本身有两个非同寻常的特点。首先，任何涉及 NaN 的操作（例如 NaN/10）都会返回 NaN，这个特点在多步计算中有可能导致问题。其次，NaN与任何值都不相等，包括NaN本身

有3个函数可以把非数值转换为数值：Number()、parseInt()和parseFloat()（可以在字符串前加`+`将其转为数字，如`+'10'`）。第一个函数，即转型函数 Number()可以用于任何数据类型，而另两个函数则专门用于把字符串转换成数值

parseInt这个函数提供第二个参数：转换时使用的基数（即多少进制）。

parseInt()函数在转换字符串时，更多的是看其是否符合数值模式。它会忽略字符串前面的空格，直至找到第一个非空格字符。如果第一个字符不是数字字符或者负号，parseInt()就会返回 NaN；也就是说，用 parseInt()转换空字符串会返回 NaN（Number()对空字符返回0）。如果第一个字符是数字字符，parseInt()会继续解析第二个字符，直到解析完所有后续字符或者遇到了一个非数字字符。例如，"1234blue"会被转换为1234，因为"blue"会被完全忽略。类似地，"22.5"会被转换为22，因为小数点并不是有效的数字字符。

除了第一个小数点有效之外，parseFloat()与 parseInt()的第二个区别在于它始终都会忽略前导的零。parseFloat()可以识别前面讨论过的所有浮点数值格式，也包括十进制整数格式。但十六进制格式的字符串则始终会被转换成0。由于parseFloat()只解析十进制值，因此它没有用第二个参数指定基数的用法。最后还要注意一点：如果字符串包含的是一个可解析为整数的数（没有小数点，或者小数点后都是零），parseFloat()会返回整数。

### String
与PHP中的双引号和单引号会影响对字符串的解释方式不同，ECMAScript中的这两种语法形式没有什么区别。

转义字符被作为一个字符来解析

数值、布尔值、对象和字符串值（没错，每个字符串也都有一个toString()方法，该方法返回字符串的一个副本）都有toString()方法。但null和undefined值没有这个方法。 多数情况下，调用toString()方法不必传递参数。但是，在调用数值的toString()方法时，可以传递一个参数：输出数值的基数

不知道要转换的值是不是null或undefined的情况下，还可以使用转型函数String()，这个函数能够将任何类型的值转换为字符串。

可以使用加号`+`操作符把某个值与以空字符加在一起来转换为字符串。
要把某个值转换为字符串，可以使用加号操作符（3.5 节讨论）把它与一个字符串（""）加在一起。

### Symbol
Symbol，表示独一无二的值。对象的属性名现在可以有两种类型，一种是原来就有的字符串，另一种就是新增的Symbol类型。凡是属性名属于Symbol类型，就都是独一无二的，可以保证不会与其他属性名产生冲突。

注意，Symbol函数前不能使用new命令，否则会报错。这是因为生成的Symbol是一个原始类型的值，不是对象。也就是说，由于Symbol值不是对象，所以不能添加属性。基本上，它是一种类似于字符串的数据类型。

Symbol函数可以接受一个字符串作为参数，表示对Symbol实例的描述，主要是为了在控制台显示，或者转为字符串时，比较容易区分。

注意，Symbol函数的参数只是表示对当前Symbol值的描述，因此相同参数的Symbol函数的返回值是不相等的。

Symbol值不能与其他类型的值进行运算，会报错。但是，Symbol值可以转为字符串。
```
var sym = Symbol('My symbol');
var a = "your symbol is " + sym; //报错
String(sym) // 'Symbol(My symbol)'
sym.toString() // 'Symbol(My symbol)'
```
对象属性名使用Symbol
```
var mySymbol = Symbol();

// 第一种写法
var a = {};
a[mySymbol] = 'Hello!';

// 第二种写法
var a = {
  [mySymbol]: 'Hello!'
};

// 第三种写法
var a = {};
Object.defineProperty(a, mySymbol, { value: 'Hello!' });

// 以上写法都得到同样结果
a[mySymbol] // "Hello!"
```
注意，Symbol值作为对象属性名时，不能用点运算符。同理，在对象的内部，使用Symbol值定义属性时，Symbol值必须放在方括号之中。
```
let obj = {
  [s](arg) { ... }
};
```
Symbol类型还可以用于定义一组常量，保证这组常量的值都是不相等的。
```
log.levels = {
  DEBUG: Symbol('debug'),
  INFO: Symbol('info'),
  WARN: Symbol('warn'),
};
log(log.levels.DEBUG, 'debug message');
log(log.levels.INFO, 'info message');
```
还有一点需要注意，Symbol值作为属性名时，该属性还是公开属性，不是私有属性。

**属性名遍历**
Symbol作为属性名，该属性不会出现在for...in、for...of循环中，也不会被Object.keys()、Object.getOwnPropertyNames()返回。但是，它也不是私有属性，有一个Object.getOwnPropertySymbols方法，可以获取指定对象的所有Symbol属性名。

Object.getOwnPropertySymbols方法返回一个数组，成员是当前对象的所有用作属性名的Symbol值。

**Symbol.for**方法接受一个字符串作为参数，然后搜索有没有以该参数作为名称的Symbol值。如果有，就返回这个Symbol值，否则就新建并返回一个以该字符串为名称的Symbol值。

```
var a = Symbol('foo');
var b = Symbol('foo');
var s1 = Symbol.for('foo');
var s2 = Symbol.for('foo');
s1 === s2 // true

a === s2 // false
a === b // false
```

`Symbol.for()`与`Symbol()`这两种写法，都会生成新的Symbol。它们的区别是，前者会被登记在全局环境中供搜索，后者不会。`Symbol.for()`不会每次调用就返回一个新的Symbol类型的值，而是会先检查给定的key是否已经存在，如果不存在才会新建一个值。由于Symbol()写法没有登记机制

**Symbol.keyFor**方法返回一个已登记的Symbol类型值的key。

```
var s1 = Symbol.for("foo");
Symbol.keyFor(s1) // "foo"

var s2 = Symbol("foo");
Symbol.keyFor(s2) // undefined
```
需要注意的是，`Symbol.for`为Symbol值登记的名字，是全局环境的，可以在不同的iframe或service worker中取到同一个值。
```
iframe = document.createElement('iframe');
iframe.src = String(window.location);
document.body.appendChild(iframe);

iframe.contentWindow.Symbol.for('foo') === Symbol.for('foo') // true
```

**内置的Symbol值**

除了定义自己使用的Symbol值以外，ES6还提供一些内置的Symbol值，指向语言内部使用的方法。

**对象的Symbol.hasInstance属性**，指向一个内部方法。该对象使用instanceof运算符时，会调用这个方法，判断该对象是否为某个构造函数的实例。比如，`foo instanceof Foo`在语言内部，实际调用的是`Foo[Symbol.hasInstance](foo)`。

**对象的Symbol.isConcatSpreadable属性**，指向一个方法。该对象使用Array.prototype.concat()时，会调用这个方法，返回一个布尔值，表示该对象是否可以扩展成数组。

```
class A1 extends Array {
  [Symbol.isConcatSpreadable]() {
    return true;
  }
}
class A2 extends Array {
  [Symbol.isConcatSpreadable]() {
    return false;
  }
}
let a1 = new A1();
a1[0] = 3;
a1[1] = 4;
let a2 = new A2();
a2[0] = 5;
a2[1] = 6;
[1, 2].concat(a1).concat(a2)
// [1, 2, 3, 4, [5, 6]]
```

**对象的Symbol.isRegExp属性**，指向一个方法。该对象被用作正则表达式时，会调用这个方法，返回一个布尔值，表示该对象是否为一个正则对象。

**对象的Symbol.match属性**，指向一个函数。当执行`str.match(myObject)`时，如果该属性存在，会调用它，返回该方法的返回值。

**对象的Symbol.replace属性**，指向一个方法，当该对象被String.prototype.replace方法调用时，会返回该方法的返回值。

**对象的Symbol.search属性**，指向一个方法，当该对象被String.prototype.search方法调用时，会返回该方法的返回值。

**对象的Symbol.split属性**，指向一个方法，当该对象被String.prototype.split方法调用时，会返回该方法的返回值。

**对象的Symbol.iterator属性**，指向一个方法，即该对象进行for...of循环时，会调用这个方法，返回该对象的Iterator对象。

```javascript
class Collection {
  *[Symbol.iterator]() {
    let i = 0;
    while(this[i] !== undefined) {
      yield this[i];
      ++i;
    }
  }
}

let myCollection = new Collection();
myCollection[0] = 1;
myCollection[1] = 2;

for(let value of myCollection) {
  console.log(value);
}
// 1
// 2
```

**对象的Symbol.toPrimitive属性**，指向一个方法。该对象被转为原始类型的值时，会调用这个方法，返回该对象对应的原始类型值。

**对象的Symbol.toStringTag属性**，指向一个方法。在该对象上面调用`Object.prototype.toString`方法时，如果这个属性存在，它的返回值会出现在toString方法返回的字符串之中，表示对象的类型。也就是说，这个属性可以用来定制`[object Object]`或`[object Array]`中object后面的那个字符串。

```
class Collection {
  get [Symbol.toStringTag]() {
    return 'xxx';
  }
}
var x = new Collection();
Object.prototype.toString.call(x) // "[object xxx]"
```

**对象的Symbol.unscopables属性**，指向一个对象。该对象指定了使用with关键字时，哪些属性会被with环境排除。

```
Array.prototype[Symbol.unscopables]
// {
//   copyWithin: true,
//   entries: true,
//   fill: true,
//   find: true,
//   findIndex: true,
//   keys: true
// }

Object.keys(Array.prototype[Symbol.unscopables])
// ['copyWithin', 'entries', 'fill', 'find', 'findIndex', 'keys']
```
上面代码说明，数组有6个属性，会被with命令排除。

```
// 没有unscopables时
class MyClass {
  foo() { return 1; }
}

var foo = function () { return 2; };

with (MyClass.prototype) {
  foo(); // 1
}

// 有unscopables时
class MyClass {
  foo() { return 1; }
  get [Symbol.unscopables]() {
    return { foo: true };
  }
}

var foo = function () { return 2; };

with (MyClass.prototype) {
  foo(); // 2
}
```

### Object
```
var o = new Object();
```

在ECMAScript中，如果不给构造函数传递参数，则可以省略后面的那一对圆括号。

Object每个实例都具有下列属性和方法
* Constructor：保存用于创建当前对象的函数，即构造函数
* hasOwnProperty(propertyName)：用于检查给定的属性在当前对象实例中（而不是在实例的原型中）是否存在，propertyName必须是字符串
* isPrototypeOf(object)：用于检查传入的对象是否是另一个对象的原型
* propertyIsEnumerable(propertyName)：用于检查给定的属性是否能够使用for-in语句来枚举。参数必须是字符串
* toLocaleString()：返回对象的字符串表示，与执行环境的地区对应
* toString()：返回对象的字符串表示
* valueOf()：分返回对象的字符串、数值或布尔值表示。通常与toString方法返回值相同。

在ECMAScript中，（就像 Java 中的 java.lang.Object 对象一样）Object 类型是所有它的实例的基础

## 操作符
### 一元操作符(`++,--,+,-`)
ECMAScript 操作符的与众不同之处在于，它们能够适用于很多值，例如字符串、数字值、布尔值，甚至对象。不过，在应用于对象时，相应的操作符通常都会调用对象的valueOf()和（或）toString()方法，以便取得可以操作的值。

应用于非数值的值时，递增和递减操作符执行前，该值会被转换为数值，然后在执行递增递减。对象是先调用它们的valueOf()和（或）toString()方法，再转换得到的值。

在对非数值应用一元加操作符时，该操作符会像Number()转型函数一样对这个值执行转换。如`+'10' === 10 //true`

### 位操作符(`~,&,|,^,<<,>>,>>>`)
负数同样以二进制码存储，但使用的格式是二进制补码

ECMAScript中的所有数值都以IEEE-754 64位格式存储，但位操作符并不直接操作64位的值。而是先将64位的值转换成32位的整数，然后执行操作，最后再将结果转换回64位。对于开发人员来说，由于64位存储格式是透明的，因此整个过程就像是只存在32位的整数一样。但这个转换过程也导致了一个严重的副效应，即在对特殊的NaN和Infinity值应用位操作时，这两个值都会被当成0来处理

默认情况下，ECMAScript 中的所有整数都是有符号整数

计算补码的过程

(1) 求这个数值绝对值的二进制码（例如，要求-18的二进制补码，先求18的二进制码）； (2) 求二进制反码，即将0替换为1，将1替换为0； (3) 得到的二进制反码加1

按位非操作的本质：操作数的负值减1

按位异或操作符由一个插入符号（^）表示

左移操作会以0来填充空位

有符号右移在移位过程中，原数值中也会出现空位。只不过空位出现在原数值的左侧、符号位的右侧。而此时ECMAScript会用符号位的值来填充所有空位

首先，无符号右移操作符由3个大于号（>>>）表示，无符号右移是以0来填充空位，其次，无符号右移操作符会把负数的二进制码当成正数的二进制码

### 布尔操作符(`!,&&,||`)
逻辑非操作符首先会将操作数转换为布尔值然后再计算。参考前面的Boolean转换表

同时使用两个逻辑非操作符，实际上就会模拟 Boolean()转型函数的行为。如`!!'' //false`

逻辑与和逻辑或在有一个操作数不是布尔值情况下不一定返回布尔值，遵循下列规则：
* 如果第一个操作数是对象，则返回第二个操作数
* 如果第二个操作数是对象，则只有在第一个操作数的求值结果为true的情况下才返回该对象
* 如果两个操作数都是对象，则返回第二个操作数
* 如果有一个操作数是null，则返回null
* 如果有一个操作数是NaN，则返回NaN
* 如果有一个操作数是undefined，则返回undefined

逻辑或遵循规则
* 如果第一个操作数是对象，则返回第一个操作数
* 如果第一个操作数是求值结果为false，则返回第二个操作数
* 如果两个操作数都是对象，则返回第一个操作数
* 如果两个操作数都是null，则返回null
* 如果两个操作数都是NaN，则返回NaN
* 如果两个操作数都是undefined，则返回undefined

### 乘性操作符(`*,/,%`)
在操作数为非数值的情况下会执行自动的类型转换。如果参与乘性计算的某个操作数不是数值，后台会先使用Number()转型函数将其转换为数值。也就是说，空字符串将被当作0，布尔值true将被当作1。

乘法
* 如果操作数都是数值，执行常规的乘法计算，即两个正数或两个负数相乘的结果还是正数，而如果只有一个操作数有符号，那么结果就是负数。如果乘积超过了ECMAScript数值的表示范围，则返回Infinity或-Infinity；
* 如果有一个操作数是NaN，则结果是NaN；
* 如果是Infinity与0相乘，则结果是NaN；
* 如果是Infinity与非0数值相乘，则结果是Infinity或-Infinity，取决于有符号操作数的符号；
* 如果是Infinity与Infinity相乘，则结果是Infinity；
* 如果有一个操作数不是数值，则在后台调用Number()将其转换为数值，然后再应用上面的 规则。

除法
* 如果操作数都是数值，执行常规的除法计算，即两个正数或两个负数相除的结果还是正数，而如果只有一个操作数有符号，那么结果就是负数。如果商超过了ECMAScript数值的表示范围，则返回Infinity或-Infinity；
* 如果有一个操作数是NaN，则结果是NaN；
* 如果是Infinity被Infinity除，则结果是NaN；
* 如果是零被零除，则结果是NaN；
* 如果是非零的有限数被零除，则结果是Infinity或-Infinity，取决于有符号操作数的符号；
* 如果是Infinity被任何非零数值除，则结果是Infinity或-Infinity，取决于有符号操作数的符号；
* 如果有一个操作数不是数值，则在后台调用Number()将其转换为数值，然后再应用上面的 规则。

求模
* 如果操作数都是数值，执行常规的除法计算，返回除得的余数；
* 如果被除数是无穷大值而除数是有限大的数值，返回NaN；
* 如果被除数是有限大的数值而除数是零，返回NaN；
* 如果Infinity被Infinity除，返回NaN；
* 如果被除数是有限大的数值而除数是无穷大值，返回被除数；
* 如果被除数是零，返回零；
* 如果有一个操作数不是数值，则在后台调用Number()将其转换为数值，然后再应用上面的 规则。

### 加性操作符(`+,-`)
加法
* 如果有一个操作数是NaN，则结果是NaN；
* 如果是Infinity加Infinity，则结果是Infinity；
* 如果是-Infinity加-Infinity，则结果是-Infinity；
* 如果是Infinity加-Infinity，则结果是NaN；
* 如果是+0加+0，则结果是+0；
* 如果是-0加-0，则结果是-0；
* 如果是+0加-0，则结果是+0。

不过，如果有一个操作数是字符串，那么就要应用如下规则：
* 如果两个操作数都是字符串，则将第二个操作数与第一个操作数拼接起来；
* 如果只有一个操作数是字符串，则将另一个操作数转换为字符串，然后再将两个字符串拼接 起来。 如果有一个操作数是对象、数值或布尔值，则调用它们的toString()方法取得相应的字符串值，然后再应用前面关于字符串的规则。对于undefined和null，则分别调用String()函数并取得字符串"undefined"和"null"。

减法
* 如果两个操作数都是数值，则执行常规的算术减法操作并返回结果；
* 如果有一个操作数是NaN，则结果是NaN；
* 如果是Infinity减Infinity，则结果是NaN；
* 如果是-Infinity减-Infinity，则结果是NaN；
* 如果是Infinity减-Infinity，则结果是Infinity；
* 如果是-Infinity减Infinity，则结果是-Infinity；
* 如果是+0减+0，则结果是+0；
* 如果是+0减-0，则结果是-0；
* 如果是-0减-0，则结果是+0；
* 如果有一个操作数是字符串、布尔值、null或undefined，则先在后台调用Number()函数将其转换为数值，然后再根据前面的规则执行减法计算。如果转换的结果是NaN，则减法的结果就是NaN；
* 如果有一个操作数是对象，则调用对象的valueOf()方法以取得表示该对象的数值。如果得到的值是NaN，则减法的结果就是NaN。如果对象没有valueOf()方法，则调用其toString()方法并将得到的字符串转换为数值。

### 关系操作符(`>,<,>=,<=`)

对于字符串实际比较的是两个字符串中对应位置的每个字符的字符编码值

* 如果两个操作数都是数值，则执行数值比较。
* 如果两个操作数都是字符串，则比较两个字符串对应的字符编码值。
* 如果一个操作数是数值，则将另一个操作数转换为一个数值，然后执行数值比较。
* 如果一个操作数是对象，则调用这个对象的valueOf()方法，用得到的结果按照前面的规则执行比较。如果对象没有valueOf()方法，则调用toString()方法，并用得到的结果根据前面的规则执行比较。
* 如果一个操作数是布尔值，则先将其转换为数值，然后再执行比较。
任何操作数与NaN比较都将返回false

按照常理，如果一个值不小于另一个值，则一定大于或等于那个值，然而，在与NaN进行比较时，下面两个比较操作的结果都返回了false。
```
var res1 = NaN < 3  //false
var res2 = NaN >= 3 //false
```

### 相等操作符(`===,!==,==,!=`)

相等和不相等——先转换再比较，全等和不全等——仅比较而不转换。

在转换不同的数据类型时，相等和不相等操作符遵循下列基本规则：
* 如果有一个操作数是布尔值，则在比较相等性之前先将其转换为数值——false转换为0，而true转换为1；
* 如果一个操作数是字符串，另一个操作数是数值，在比较相等性之前先将字符串转换为数值；
* 如果一个操作数是对象，另一个操作数不是，则调用对象的valueOf()方法，用得到的基本类型值按照前面的规则进行比较； 这两个操作符在进行比较时则要遵循下列规则。
* null和undefined是相等的。
* 要比较相等性之前，不能将null和undefined转换成其他任何值。
* 如果有一个操作数是NaN，则相等操作符返回false，而不相等操作符返回true。重要提示：即使两个操作数都是NaN，相等操作符也返回false；因为按照规则，NaN不等于NaN。
* 如果两个操作数都是对象，则比较它们是不是同一个对象。如果两个操作数都指向同一个对象，则相等操作符返回true；否则，返回false。

由于相等和不相等操作符存在类型转换问题，而为了保持代码中数据类型的完整性，推荐使用全等和不全等操作符。

### 条件操作符(`boolean_expression?true_value:false_value`)
和Java中一样

### 逗号操作符(`,`)
在用于赋值时，逗号操作符总会返回表达式中的最后一项
```
var num = (5,1,3,8,0) //num值为0
```
### 赋值操作符(`=以及*=、+=等复合赋值运算符`)
赋值与复合赋值和其他语言无太大区别。
### 解构赋值
ECMAScript6允许按照一定模式，从数组和对象中提取值，对变量进行赋值，这被称为解构（Destructuring）。下面是数组解构赋值的例子
```
var [a, b, c] = [1, 2, 3]; // a即为1，b为2，c为3
let [,,third] = ["foo", "bar", "baz"];//third为"baz"
let [head, ...tail] = [1, 2, 3, 4]; //head为1，tail为[2,3,4]，...操作符后面再说
var [foo, [[bar], baz]] = [1, [[2], 3]];
```
上面代码表示，可以从数组中提取值，按照对应位置，对变量赋值。

如果解构不成功，变量的值就等于undefined。以下几种情况都属于解构不成功，foo的值都会等于undefined（下面的代码在一些环境下会抛异常）。这是因为原始类型的值，会自动转为对象，比如数值1转为new Number(1)，从而导致foo取到undefined。
```
var [foo] = [];
var [foo] = 1;
var [foo] = false;
var [foo] = NaN;
var [bar, foo] = [1];
```
另一种情况是不完全解构，即等号左边的模式，只匹配一部分的等号右边的数组。这种情况下，解构依然可以成功。

```
let [x, y] = [1, 2, 3]; //x = 1, y = 2
let [a, [b], d] = [1, [2, 3], 4];// a = 1, b = 2, d = 4
```
如果对undefined或null进行解构，会报错。

```
// 报错
let [foo] = undefined;
let [foo] = null;
```
这是因为解构只能用于数组或对象。其他原始类型的值都可以转为相应的对象，但是，undefined和null不能转为对象，因此报错。

解构赋值允许指定默认值。
```
var [foo = true] = []; //foo = true
[x, y='b'] = ['a'] // x='a', y='b'
[x, y='b'] = ['a', undefined] // x='a', y='b'
```
注意，ES6内部使用严格相等运算符（===），判断一个位置是否有值。所以，如果一个数组成员不严格等于undefined，默认值是不会生效的。

```
var [x = 1] = [undefined];// x = 1
var [x = 1] = [null]; //x = null
```
上面代码中，如果一个数组成员是null，默认值就不会生效，因为null不严格等于undefined。

解构赋值不仅适用于var命令，也适用于let和const命令。对于Set结构（ECMAScript6新增），也可以使用数组的解构赋值。事实上，只要某种数据结构具有Iterable接口，都可以采用数组形式的解构赋值。

```
function* fibs() {
  var a = 0;
  var b = 1;
  while (true) {
    yield a;
    [a, b] = [b, a + b];
  }
}
var [first, second, third, fourth, fifth, sixth] = fibs();
sixth // 5
```
上面代码中，fibs是一个Generator函数，原生具有Iterable接口。解构赋值会依次从这个接口获取值。

解构不仅可以用于数组，还可以用于对象。对象的解构与数组有一个重要的不同。数组的元素是按次序排列的，变量的取值由它的位置决定；而对象的属性没有次序，变量必须与属性同名，才能取到正确的值。
```
var { bar, foo } = { foo: "aaa", bar: "bbb" };//bar = "bbb", foo = "aaa"
var { baz } = { foo: "aaa", bar: "bbb" }; //baz = undefined
var obj = {
  p: [
    "Hello",
    { y: "World" }
  ]
};

var { p: [x, { y }] } = obj; //x = "Hello", y = "World"
```

如果左边变量名和右边属性名不一致
```
var { foo: baz } = { foo: "aaa", bar: "bbb" }; //baz = "aaa"
```

默认值生效的条件是，对象的属性值严格等于undefined。
```
var {x = 3} = {x: undefined}; //x = 3
var {x = 3} = {x: null}; //x = null
```

如果要将一个已经声明的变量用于解构赋值，必须非常小心。
```
// 错误的写法
var x;
{x} = {x:1};
// SyntaxError: syntax error
```

上面代码的写法会报错，因为JavaScript引擎会将{x}理解成一个代码块，从而发生语法错误。只有不将大括号写在行首，避免JavaScript将其解释为代码块，才能解决这个问题。
```
// 正确的写法
({x} = {x:1});
```

对象的解构赋值，可以很方便地将现有对象的方法，赋值到某个变量。
```
let { log, sin, cos } = Math;
```
上面代码将Math对象的对数、正弦、余弦三个方法，赋值到对应的变量上，使用起来就会方便很多。

字符串也可以解构赋值。这是因为此时，字符串被转换成了一个类似数组的对象。类似数组的对象都有一个length属性，因此还可以对这个属性解构赋值。
```
const [a, b, c, d, e] = 'hello';//a = "h", b = "e", c = "l", d = "l", e = "o"
let {length : len} = 'hello'; //len = 5
```

函数的参数也可以使用解构。
```
function add([x, y]){
  return x + y;
}
add([1, 2]) // 3
```

函数参数的解构也可以使用默认值。

```
function move({x = 0, y = 0} = {}) {
  return [x, y];
}
move({x: 3, y: 8}); // [3, 8]
move({x: 3}); // [3, 0]
move({}); // [0, 0]
move(); // [0, 0]
```
注意，指定函数参数的默认值时，不能采用下面的写法。

```
function move({x, y} = { x: 0, y: 0 }) {
  return [x, y];
}
move({x: 3, y: 8}); // [3, 8]
move({x: 3}); // [3, undefined]
move({}); // [undefined, undefined]
move(); // [0, 0]
```
上面代码是为函数move的参数指定默认值，而不是为变量x和y指定默认值，所以会得到与前一种写法不同的结果。

变量的解构赋值用途很多。

1）交换变量的值
```
[x, y] = [y, x];
```
上面代码交换变量x和y的值，这样的写法不仅简洁，而且易读，语义非常清晰。

2）从函数返回多个值

函数只能返回一个值，如果要返回多个值，只能将它们放在数组或对象里返回。有了解构赋值，取出这些值就非常方便。
```
// 返回一个数组
function example() {
  return [1, 2, 3];
}
var [a, b, c] = example();
// 返回一个对象
function example() {
  return {
    foo: 1,
    bar: 2
  };
}
var { foo, bar } = example();
```

3）函数参数的定义

解构赋值可以方便地将一组参数与变量名对应起来。
```
// 参数是一组有次序的值
function f([x, y, z]) { ... }
f([1, 2, 3])

// 参数是一组无次序的值
function f({x, y, z}) { ... }
f({x:1, y:2, z:3})
```

4）提取JSON数据

解构赋值对提取JSON对象中的数据，尤其有用。

```
var jsonData = {
  id: 42,
  status: "OK",
  data: [867, 5309]
}
let { id, status, data: number } = jsonData;
console.log(id, status, number)
// 42, OK, [867, 5309]
```

上面代码可以快速提取JSON数据的值。

5）函数参数的默认值

```
jQuery.ajax = function (url, {
  async = true,
  beforeSend = function () {},
  cache = true,
  complete = function () {},
  crossDomain = false,
  global = true,
  // ... more config
}) {
  // ... do stuff
};
```

指定参数的默认值，就避免了在函数体内部再写var foo = config.foo || 'default foo';这样的语句。

6）遍历Map结构

任何部署了Iterable接口的对象，都可以用for...of循环遍历。Map结构原生支持Iterable接口，配合变量的解构赋值，获取键名和键值就非常方便。
```
var map = new Map();
map.set('first', 'hello');
map.set('second', 'world');

for (let [key, value] of map) {
  console.log(key + " is " + value);
}
// first is hello
// second is world
```

如果只想获取键名，或者只想获取键值，可以写成下面这样。
```
// 获取键名
for (let [key] of map) {
  // ...
}
// 获取键值
for (let [,value] of map) {
  // ...
}
```

7）输入模块的指定方法

加载模块时，往往需要指定输入那些方法。解构赋值使得输入语句非常清晰。
```
const { SourceMapConsumer, SourceNode } = require("source-map");
```


## 语句
if, do-while,while,for,label,break,continue,switch和Java没有太大差别。

推崇始终使用代码块，即使要执行的只有一行代码

像 do-while 这种后测试循环语句最常用于循环体中的代码至少要被执行一次的情形。

加标签的语句一般都要与for语句等循环语句配合使用。

break和 continue 语句都可以与 label 语句联合使用，从而返回代码中特定的位置。这种联合使用的情况多发生在循环嵌套的情况下

建议如果使用label语句，一定要使用描述性的标签，同时不要嵌套过多的循环

switch语句在比较值时使用的是全等操作符，因此不会发生类型转换（例如，字符串"10"不等于数值10）。

首先，可以在switch语句中使用任何数据类型（在很多其他语言中只能使用数值），无论是字符串，还是对象都没有问题。其次，每个case的值不一定是常量，可以是变量，甚至是表达式。
### for-in
由于 ECMAScript中不存在块级作用域（ES6已有），因此在循环内部定义的变量也可以在外部访问到

ECMAScript对象的属性没有顺序。因此，通过 for-in 循环输出的属性名的顺序是不可预测的

for-in语句是一种精准的迭代语句，可以用来枚举对象的属性。

建议在使用for-in循环之前，先检测确认该对象的值不是null或undefined。

```
for(var propName in window) {
    document.write(propName);
}
```

### with
由于大量使用with语句会导致性能下降，同时也会给调试代码造成困难，因此在开发大型应用程序时，不建议使用with语句。

定义with语句的目的主要是为了简化多次编写同一个对象的工作，如下面的例子所示：
```
var qs = location.search.substring(1);
var hostName = location.hostname;
var url = location.href;
```

上面几行代码都包含location对象。如果使用with 语句，可以把上面的代码改写成如下所示：
```
with(location){
    var qs = search.substring(1);
    var hostName = hostname;
    var url = href;
}
```

这个重写后的例子中，使用with 语句关联了location 对象。这意味着在with 语句的代码块内部，每个变量首先被认为是一个局部变量，而如果在局部环境中找不到该变量的定义，就会查询location对象中是否有同名的属性。如果发现了同名属性，则以location对象属性的值作为变量的值。 严格模式下不允许使用with语句，否则将视为语法错误
### for-of
ES6借鉴C++、Java、C#和Python语言，引入了for...of循环，作为遍历所有数据结构的统一的方法。一个数据结构只要部署了`Symbol.iterator`方法，就被视为具有Iterable接口，就可以用for...of循环遍历它的成员。也就是说，for...of循环内部调用的是数据结构的`Symbol.iterator`方法。

for...of循环可以使用的范围包括数组、Set和Map结构及其entries,values,keys方法返回的对象、某些类似数组的对象（比如arguments对象、DOM NodeList对象）、后文的Generator对象，以及字符串。

数组原生具备Iterable接口，for...of循环本质上就是调用`Symbol.iterator`产生的Iterator对象，可以用下面的代码证明。

```
const arr = ['red', 'green', 'blue'];
let iterator  = arr[Symbol.iterator]();

for(let v of arr) {
  console.log(v); // red green blue
}

for(let v of iterator) {
  console.log(v); // red green blue
}
```

JavaScript原有的for...in循环，只能获得对象的键名，不能直接获取键值。ES6提供for...of循环，允许遍历获得键值。
```
var arr = ["a", "b", "c", "d"];
for (a in arr) {
  console.log(a); // 0 1 2 3
}
for (a of arr) {
  console.log(a); // a b c d
}
```

Set和Map结构也原生具有Iterable接口，可以直接使用for...of循环。
```
var engines = Set(["Gecko", "Trident", "Webkit", "Webkit"]);
for (var e of engines) {
  console.log(e);
}
// Gecko
// Trident
// Webkit

var es6 = new Map();
es6.set("edition", 6);
es6.set("committee", "TC39");
es6.set("standard", "ECMA-262");
for (var [name, value] of es6) {
  console.log(name + ": " + value);
}
// edition: 6
// committee: TC39
// standard: ECMA-262
```
上面代码演示了如何遍历Set结构和Map结构。值得注意的地方有两个，首先，遍历的顺序是按照各个成员被添加进数据结构的顺序。其次，Set结构遍历时，返回的是一个值，而Map结构遍历时，返回的是一个数组，该数组的两个成员分别为当前Map成员的键名和键值。

并不是所有类似数组的对象都具有iterator接口，一个简便的解决方法，就是使用Array.from方法将其转为数组。

```
let arrayLike = { length: 2, 0: 'a', 1: 'b' };

// 报错
for (let x of arrayLike) {
  console.log(x);
}
// 正确
for (let x of Array.from(arrayLike)) {
  console.log(x);
}
```

通过for-of遍历对象，一种解决方法是，使用`Object.keys`方法将对象的键名生成一个数组，然后遍历这个数组。
```
for (var key of Object.keys(someObject)) {
  console.log(key + ": " + someObject[key]);
}
```

在对象上部署iterator接口的代码，参见本章前面部分。一个方便的方法是将数组的`Symbol.iterator`属性，直接赋值给其他对象的`Symbol.iterator`属性。比如，想要让for...of循环遍历jQuery对象，只要加上下面这一行就可以了。

```
jQuery.prototype[Symbol.iterator] =
  Array.prototype[Symbol.iterator];
```

另一个方法是使用Generator函数将对象重新包装一下。

**与其他遍历语法的比较**

以数组为例，JavaScript提供多种遍历语法。最原始的写法就是for循环。

```
for (var index = 0; index < myArray.length; index++) {
  console.log(myArray[index]);
}
```

这种写法比较麻烦，因此数组提供内置的forEach方法。

```
myArray.forEach(function (value) {
  console.log(value);
});
```

这种写法的问题在于，无法中途跳出forEach循环，break命令或return命令都不能奏效。

for...in循环可以遍历数组的键名。

```
for (var index in myArray) {
  console.log(myArray[index]);
}
```

for...in循环有几个缺点。

1. 数组的键名是数字，但是for...in循环是以字符串作为键名“0”、“1”、“2”等等。

2. for...in循环不仅遍历数字键名，还会遍历手动添加的其他键，甚至包括原型链上的键。

3. 某些情况下，for...in循环会以任意顺序遍历键名。

总之，for...in循环主要是为遍历对象而设计的，不适用于遍历数组。

for...of循环相比上面几种做法，有一些显著的优点。

```
for (let value of myArray) {
  console.log(value);
}
```

* 有着同for...in一样的简洁语法，但是没有for...in那些缺点。
* 不同用于forEach方法，它可以与break、continue和return配合使用。
* 提供了遍历所有数据结构的统一操作接口。

## 函数

严格模式对函数有一些限制：
* 不能把函数命名为eval或arguments；
* 不能把参数命名为eval或arguments；
* 不能出现两个命名参数同名的情况。 如果发生以上情况，就会导致语法错误，代码无法执行。

return语句也可以不带有任何返回值。在这种情况下，函数在停止执行后将返回undefined值。

即便你定义的函数只接收两个参数，在调用这个函数时也未必一定要传递两个参数。可以传递一个、三个甚至不传递参数，而解析器永远不会有什么怨言。之所以会这样，原因是ECMAScript中的参数在内部是用一个数组来表示的。函数接收到的始终都是这个数组，而不关心数组中包含哪些参数（如果有参数的话）。如果这个数组中不包含任何元素，无所谓；如果包含多个元素，也没有问题。实际上，在函数体内可以通过arguments对象来访问这个参数数组，从而获取传递给函数的每一个参数。

其实，arguments对象只是与数组类似（它并不是Array的实例），因为可以使用方括号语法访问它的每一个元素（即第一个元素是arguments[0]，第二个元素是arguments[1]，以此类推），使用length属性来确定传递进来多少个参数。

```
function doAdd(num1, num2) {
    arguments[1] = 10;
    alert(arguments[0] + num2);
}
```
arguments对象为其内部属性以及函数形式参数创建getter和setter函数。因此改变形参的值会影响arguments对象的值，但是严格模式不允许创建getter和setter方法。

严格模式对如何使用 arguments 对象做出了一些限制。首先，像前面例子中那样的赋值会变得无效。也就是说，即使把 arguments[1]设置为 10，num2 的值仍然还是 undefined。其次，重写arguments的值会导致语法错误（代码将不会执行）。 ECMAScript中的所有参数传递的都是值，不可能通过引用传递参数。

**没有重载**
没有函数签名，真正的重载是不可能做到的。 如果在ECMAScript中定义了两个名字相同的函数，则该名字只属于后定义的函数。

## 箭头函数
### 基本用法
ES6允许使用“箭头”（=>）定义函数（和Java8中lambda表达式有点类似）
```
// 基本用法
(param1, param2, paramN) => { statements }
(param1, param2, paramN) => expression // equivalent to:  => { return expression; }

// 如果只有一个参数可以省略圆括号
singleParam => { statements }
singleParam => expression

//如果没有参数，则需要一个圆括号
() => { statements }

//如果返回一个对象，必须在对象外面加上括号。
params => ({foo: bar})

// 支持Rest参数
(param1, param2, ...rest) => { statements }
// 支持变量解构
({param1, param2}) => { statements }
```

箭头函数的一个用处是简化回调函数。
```
// 正常函数写法
[1,2,3].map(function (x) {
  return x * x;
});
// 箭头函数写法
[1,2,3].map(x => x * x);
```
### 使用注意点
箭头函数有几个使用注意点。
* 函数体内的this对象，绑定定义时所在的对象，而不是使用时所在的对象。
* 不可以当作构造函数，也就是说，不可以使用new命令，否则会抛出一个错误。
* 不可以使用arguments对象，该对象在函数体内不存在。
* 不可以使用yield命令，因此箭头函数不能用作Generator函数。

上面四点中，第一点尤其值得注意。this对象的指向是可变的，但是在箭头函数中，它是固定的。下面的代码是一个例子，将this对象绑定定义时所在的对象。

```
var handler = {
  id: "123456",

  init: function() {
    document.addEventListener("click",
      event => this.doSomething(event.type), false);
  },

  doSomething: function(type) {
    console.log("Handling " + type  + " for " + this.id);
  }
};
```
上面代码的init方法中，使用了箭头函数，这导致this绑定handler对象，否则回调函数运行时，this.doSomething这一行会报错，因为此时this指向document对象。

由于this在箭头函数中被绑定，所以不能用call()、apply()、bind()这些方法去改变this的指向。

### 嵌套的箭头函数
箭头函数内部，还可以再使用箭头函数。下面是一个ES5语法的多重嵌套函数。

下面是一个部署管道机制（pipeline）的例子，即前一个函数的输出是后一个函数的输入。
```
//pipeline參數是...funcs，返回值是val => funcs.reduce((a, b) => b(a), val);
//addThenMult參數是val，返回值是 funcs.reduce((a, b) => b(a), val);
const pipeline = (...funcs) =>
  val => funcs.reduce((a, b) => b(a), val);

const plus1 = a => a + 1;
const mult2 = a => a * 2;
const addThenMult = pipeline(plus1, mult2);

addThenMult(5)
// 12
```
如果觉得上面的写法可读性比较差，也可以采用下面的写法。
```
const plus1 = a => a + 1;
const mult2 = a => a * 2;
mult2(plus1(5)) // 12
```

箭头函数还有一个功能，就是可以很方便地改写λ演算。
```
// λ演算的写法
fix = λf.(λx.f(λv.x(x)(v)))(λx.f(λv.x(x)(v)))
// ES6的写法
var fix = f => (x => f(v => x(x)(v)))
               (x => f(v => x(x)(v)));
```

## Generator 函数
### 基本概念
Generator函数是ES6提供的一种异步编程解决方案，语法行为与传统函数完全不同。

Generator函数有多种理解角度。从语法上，首先可以把它理解成一个函数的内部状态的遍历器（也就是说，Generator函数是一个状态机）。它每调用一次，就进入下一个内部状态。Generator函数可以控制内部状态的变化，依次遍历这些状态。

形式上，Generator函数是一个普通函数，但是有两个特征。一是，function命令与函数名之间有一个星号；二是，函数体内部使用yield语句，定义遍历器的每个成员，即不同的内部状态（yield语句在英语里的意思就是“产出”）。

```
function* helloWorldGenerator() {
  yield 'hello';
  yield 'world';
  return 'ending';
}

var hw = helloWorldGenerator();
```
上面代码定义了一个Generator函数helloWorldGenerator，它内部有两个yield语句“hello”和“world”，即该函数有三个状态：hello，world和return语句（结束执行）。

然后，Generator函数的调用方法与普通函数一样，也是在函数名后面加上一对圆括号。不同的是，调用Generator函数后，该函数并不执行，返回的也不是函数运行结果，而是一个Iterator对象（该对象同时实现了Iterable接口，并且调用该对象的`Symbol.iterator`方法返回该对象自身）。

下一步，必须调用Iterator对象的next方法，使得指针移向下一个状态。也就是说，每次调用next方法，内部指针就从函数头部或上一次停下来的地方开始执行，直到遇到下一个yield语句（或return语句）为止。换言之，Generator函数是分段执行的，yield命令是暂停执行的标记，而next方法可以恢复执行。

```
hw.next() // { value: 'hello', done: false }
hw.next() // { value: 'world', done: false }
hw.next() // { value: 'ending', done: true }
hw.next() // { value: undefined, done: true }
```
第三次调用，Generator函数从上次yield语句停下的地方，一直执行到return语句（如果没有return语句，就执行到函数结束）。next方法返回的对象的value属性，就是紧跟在return语句后面的表达式的值（如果没有return语句，则value属性的值为undefined），done属性的值true，表示遍历已经结束。第四次调用，此时Generator函数已经运行完毕，next方法返回对象的value属性为undefined，done属性为true。以后再调用next方法，返回的都是这个值。

总结一下，调用Generator函数，返回一个实现了Iterator接口的对象，用来操作内部指针。以后，每次调用Iterator对象的next方法，就会返回一个实现了IteratorResult接口的对象。value属性表示当前的内部状态的值，是yield语句后面那个表达式的值；done属性是一个布尔值，表示是否遍历结束。

### yield语句
由于Generator函数返回的Iterator对象，只有调用next方法才会遍历下一个内部状态，所以其实提供了一种可以暂停执行的函数。yield语句就是暂停标志。

Iterator对象next方法的运行逻辑如下。

1. 遇到yield语句，就暂停执行后面的操作，并将紧跟在yield后面的那个表达式的值，作为返回的对象的value属性值。
2. 下一次调用next方法时，再继续往下执行，直到遇到下一个yield语句。
3. 如果没有再遇到新的yield语句，就一直运行到函数结束，直到return语句为止，并将return语句后面的表达式的值，作为返回的对象的value属性值。
4. 如果该函数没有return语句，则返回的对象的value属性值为undefined。

需要注意的是，yield语句后面的表达式，只有当调用next方法、内部指针指向该语句时才会执行，因此等于为JavaScript提供了手动的“惰性求值”（Lazy Evaluation）的语法功能。

```
function* gen{
  yield  123 + 456;
}
```

上面代码中，yield后面的表达式`123 + 456`，不会立即求值，只会在next方法将指针移到这一句时，才会求值。

yield语句与return语句既有相似之处，也有区别。相似之处在于，都能返回紧跟在语句后面的那个表达式的值。区别在于每次遇到yield，函数暂停执行，下一次再从该位置继续向后执行，而return语句不具备位置记忆的功能。一个函数里面，只能执行一次（或者说一个）return语句，但是可以执行多次（或者说多个）yield语句。正常函数只能返回一个值，因为只能执行一次return；Generator函数可以返回一系列的值，因为可以有任意多个yield。从另一个角度看，也可以说Generator生成了一系列的值，这也就是它的名称的来历（在英语中，generator这个词是“生成器”的意思）。

Generator函数可以不用yield语句，这时就变成了一个单纯的暂缓执行函数。

```
function* f() {
  console.log('执行了！')
}

var generator = f();

setTimeout(function () {
  generator.next()
}, 2000);
```

上面代码中，函数f如果是普通函数，在为变量generator赋值时就会执行。但是，函数f是一个Generator函数，就变成只有调用next方法时，函数f才会执行。

另外需要注意，yield语句不能用在普通函数中，否则会报错。

```
(function (){
  yield 1;
})()
// SyntaxError: Unexpected number
```
上面代码在一个普通函数中使用yield语句，结果产生一个句法错误。

下面是另外一个例子。

```
var arr = [1, [[2, 3], 4], [5, 6]];

var flat = function* (a){
  a.forEach(function(item){
    if (typeof item !== 'number'){
      yield* flat(item);
    } else {
      yield item;
    }
  }
};

for (var f of flat(arr)){
  console.log(f);
}
```

上面代码也会产生句法错误，因为forEach方法的参数是一个普通函数，但是在里面使用了yield语句。一种修改方法是改用for循环。

```
var arr = [1, [[2, 3], 4], [5, 6]];

var flat = function* (a){
  var length = a.length;
  for(var i =0;i<length;i++){
    var item = a[i];
    if (typeof item !== 'number'){
      yield* flat(item);
    } else {
      yield item;
    }
  }
};

for (var f of flat(arr)){
  console.log(f);
}
// 1, 2, 3, 4, 5, 6
```

### 与Iterator的关系
调用Generator函数返回一个Iterator对象。这里的Iterator对象也实现了Iterable接口，Symbol.iterator方法执行后，返回自身。

```
function* gen(){
  // some code
}

var i = gen();

i[Symbol.iterator]() === i // true
```

### next方法的参数

yield语句本身没有返回值，或者说总是返回undefined。next方法可以带一个参数，该参数就会被当作上一个yield语句的返回值。

```
function* f() {
  for(var i=0; true; i++) {
    var reset = yield i;
    if(reset) { i = -1; }
  }
}

var g = f();

g.next() // { value: 0, done: false }
g.next() // { value: 1, done: false }
g.next(true) // { value: 0, done: false }
```

上面代码先定义了一个可以无限运行的Generator函数f，如果next方法没有参数，每次运行到yield语句，变量reset的值总是undefined。当next方法带一个参数true时，当前的变量reset就被重置为这个参数（即true），因此i会等于-1，下一轮循环就会从-1开始递增。

这个功能有很重要的语法意义。Generator函数从暂停状态到恢复运行，它的上下文状态（context）是不变的。通过next方法的参数，就有办法在Generator函数开始运行之后，继续向函数体内部注入值。也就是说，可以在Generator函数运行的不同阶段，从外部向内部注入不同的值，从而调整函数行为。

再看一个例子。

```
function* foo(x) {
  var y = 2 * (yield (x + 1));
  var z = yield (y / 3);
  return (x + y + z);
}

var a = foo(5);

a.next() // Object{value:6, done:false}
a.next() // Object{value:NaN, done:false}
a.next() // Object{value:NaN, done:false}
```
上面代码中，第二次运行next方法的时候不带参数，导致y的值等于`2 * undefined`（即NaN），除以3以后还是NaN，因此返回对象的value属性也等于NaN。第三次运行Next方法的时候不带参数，所以z等于undefined，返回对象的value属性等于`5 + NaN + undefined`，即NaN。

如果向next方法提供参数，返回结果就完全不一样了。

```
var it = foo(5);

it.next() // { value:6, done:false }
it.next(12) // { value:8, done:false }
it.next(13) // { value:42, done:true }
```
上面代码第一次调用next方法时，返回`x+1`的值6；第二次调用next方法，将上一次yield语句的值设为12，因此y等于24，返回`y / 3`的值8；第三次调用next方法，将上一次yield语句的值设为13，因此z等于13，这时x等于5，y等于24，所以return语句的值等于42。

注意，由于next方法的参数表示上一个yield语句的返回值，所以第一次使用next方法时，不能带有参数。V8引擎直接忽略第一次使用next方法时的参数，只有从第二次使用next方法开始，参数才是有效的。

### for...of循环

for...of循环可以自动遍历Generator函数，且此时不再需要调用next方法。

```
function *foo() {
  yield 1;
  yield 2;
  yield 3;
  yield 4;
  yield 5;
  return 6;
}

for (let v of foo()) {
  console.log(v);
}
// 1 2 3 4 5
```

上面代码使用for...of循环，依次显示5个yield语句的值。这里需要注意，一旦next方法的返回对象的done属性为true，for...of循环就会中止，且不包含该返回对象，所以上面代码的return语句返回的6，不包括在for...of循环之中。

下面是一个利用generator函数和for...of循环，实现斐波那契数列的例子。

```
function* fibonacci() {
  let [prev, curr] = [0, 1];
  for (;;) {
    [prev, curr] = [curr, prev + curr];
    yield curr;
  }
}

for (let n of fibonacci()) {
  if (n > 1000) break;
  console.log(n);
}
```

从上面代码可见，使用for...of语句时不需要使用next方法。

### throw方法

Generator函数还有一个特点，它可以在函数体外抛出错误，然后在函数体内捕获。

```
var g = function* () {
  while (true) {
    try {
      yield;
    } catch (e) {
      if (e != 'a') throw e;
      console.log('内部捕获', e);
    }
  }
};

var i = g();
i.next();

try {
  i.throw('a');
  i.throw('b');
} catch (e) {
  console.log('外部捕获', e);
}
// 内部捕获 a
// 外部捕获 b
```

上面代码中，迭代器i连续抛出两个错误。第一个错误被Generator函数体内的catch捕获，然后Generator函数执行完成，于是第二个错误被函数体外的catch捕获。

注意，上面代码的错误，是用Iterator对象的throw方法抛出的，而不是用throw命令抛出的。后者只能被函数体外的catch语句捕获。

```
var g = function* () {
  while (true) {
    try {
      yield;
    } catch (e) {
      if (e != 'a') throw e;
      console.log('内部捕获', e);
    }
  }
};

var i = g();
i.next();

try {
  throw new Error('a');
  throw new Error('b');
} catch (e) {
  console.log('外部捕获', e);
}
// 外部捕获 [Error: a]
```

上面代码之所以只捕获了a，是因为函数体外的catch语句块，捕获了抛出的a错误以后，就不会再继续执行try语句块了。

如果Generator函数内部部署了try...catch代码块，那么Iterator对象的throw方法抛出的错误，不影响下一次遍历，否则遍历直接终止。

```
var gen = function* gen(){
  yield console.log('hello');
  yield console.log('world');
}

var g = gen();
g.next();

try {
  g.throw();
} catch (e) {
  g.next();
}
// hello
```

上面代码只输出hello就结束了，因为第二次调用next方法时，遍历器状态已经变成终止了。但是，如果使用throw命令抛出错误，不会影响遍历器状态。

```
var gen = function* gen(){
  yield console.log('hello');
  yield console.log('world');
}

var g = gen();
g.next();

try {
  throw new Error();
} catch (e) {
  g.next();
}
// hello
// world
```

上面代码中，throw命令抛出的错误不会影响到遍历器的状态，所以两次执行next方法，都取到了正确的操作。

这种函数体内捕获错误的机制，大大方便了对错误的处理。如果使用回调函数的写法，想要捕获多个错误，就不得不为每个函数写一个错误处理语句。

```
foo('a', function (a) {
  if (a.error) {
    throw new Error(a.error);
  }

  foo('b', function (b) {
    if (b.error) {
      throw new Error(b.error);
    }

    foo('c', function (c) {
      if (c.error) {
        throw new Error(c.error);
      }

      console.log(a, b, c);
    });
  });
});
```

使用Generator函数可以大大简化上面的代码。

```
function* g(){
  try {
    var a = yield foo('a');
    var b = yield foo('b');
    var c = yield foo('c');
  } catch (e) {
    console.log(e);
  }

  console.log(a, b, c);
}
```

反过来，Generator函数内抛出的错误，也可以被函数体外的catch捕获。

```
function *foo() {
  var x = yield 3;
  var y = x.toUpperCase();
  yield y;
}

var it = foo();

it.next(); // { value:3, done:false }

try {
  it.next(42);
} catch (err) {
  console.log(err);
}
```
上面代码中，第二个next方法向函数体内传入一个参数42，数值是没有toUpperCase方法的，所以会抛出一个TypeError错误，被函数体外的catch捕获。

一旦Generator执行过程中抛出错误，就不会再执行下去了。如果此后还调用next方法，将返回一个value属性等于undefined、done属性等于true的对象，即JavaScript引擎认为这个Generator已经运行结束了。

### `yield*`语句
如果yield命令后面跟的是一个Iterable对象，需要在yield命令后面加上星号，表明它返回的是一个Iterable对象。这被称为`yield*`语句。

```
let delegatedIterator = (function* () {
  yield 'Hello!';
  yield 'Bye!';
}());

let delegatingIterator = (function* () {
  yield 'Greetings!';
  yield* delegatedIterator;
  yield 'Ok, bye.';
}());

for(let value of delegatingIterator) {
  console.log(value);
}
// "Greetings!
// "Hello!"
// "Bye!"
// "Ok, bye."
```

上面代码中，delegatingIterator是代理者，delegatedIterator是被代理者。由于`yield* delegatedIterator`语句得到的值，是一个Iterable对象，所以要用星号表示。运行结果就是使用一个Iterable对象，遍历了多个Generator函数，有递归的效果。

`yield*`语句等同于在Generator函数内部，部署一个for...of循环。

```
function* concat(iter1, iter2) {
  yield* iter1;
  yield* iter2;
}

// 等同于
function* concat(iter1, iter2) {
  for (var value of iter1) {
    yield value;
  }
  for (var value of iter2) {
    yield value;
  }
}
```

上面代码说明，`yield*`不过是for...of的一种简写形式，完全可以用后者替代前者。

如果`yield*`后面跟着一个数组，由于数组原生支持Iterable对象，因此就会遍历数组成员。

```
function* gen(){
  yield* ["a", "b", "c"];
}

gen().next() // { value:"a", done:false }
```

上面代码中，yield命令后面如果不加星号，返回的是整个数组，加了星号就表示返回的是Iterable对象。

如果被代理的Generator函数有return语句，那么就可以向代理它的Generator函数返回数据。

```
function* foo() {
  yield 2;
  yield 3;
  return "foo";
}

function* bar() {
  yield 1;
  var v = yield *foo();
  console.log( "v: " + v );
  yield 4;
}

var it = bar();

it.next(); //
it.next(); //
it.next(); //
it.next(); // "v: foo"
it.next(); //
```

上面代码在第四次调用next方法的时候，屏幕上会有输出，这是因为函数foo的return语句，向函数bar提供了返回值。

`yield*`命令可以很方便地取出嵌套数组的所有成员。

```
function* iterTree(tree) {
  if (Array.isArray(tree)) {
    for(let i=0; i < tree.length; i++) {
      yield* iterTree(tree[i]);
    }
  } else {
    yield tree;
  }
}

const tree = [ 'a', ['b', 'c'], ['d', 'e'] ];

for(let x of iterTree(tree)) {
  console.log(x);
}
// a
// b
// c
// d
// e
```

下面是一个稍微复杂的例子，使用`yield*`语句遍历完全二叉树。

```
// 下面是二叉树的构造函数，
// 三个参数分别是左树、当前节点和右树
function Tree(left, label, right) {
  this.left = left;
  this.label = label;
  this.right = right;
}

// 下面是中序（inorder）遍历函数。
// 由于返回的是一个Iterator对象，所以要用generator函数。
// 函数体内采用递归算法，所以左树和右树要用yield*遍历
function* inorder(t) {
  if (t) {
    yield* inorder(t.left);
    yield t.label;
    yield* inorder(t.right);
  }
}

// 下面生成二叉树
function make(array) {
  // 判断是否为叶节点
  if (array.length == 1) return new Tree(null, array[0], null);
  return new Tree(make(array[0]), array[1], make(array[2]));
}
let tree = make([[['a'], 'b', ['c']], 'd', [['e'], 'f', ['g']]]);

// 遍历二叉树
var result = [];
for (let node of inorder(tree)) {
  result.push(node);
}

result
// ['a', 'b', 'c', 'd', 'e', 'f', 'g']
```

### 作为对象属性的Generator函数

如果一个对象的属性是Generator函数，可以简写成下面的形式。

```
let obj = {
  * myGeneratorMethod() {
    ···
  }
};
```
上面代码中，myGeneratorMethod属性前面有一个星号，表示这个属性是一个Generator函数。

它的完整形式如下，与上面的写法是等价的。
```
let obj = {
  myGeneratorMethod: function* () {
    // ···
  }
};
```

### 构造函数是Generator函数

这一节讨论一种特殊情况：构造函数是Generator函数。

```
function* F(){
  yield this.x = 2;
  yield this.y = 3;
}
```
上面代码中，函数F是一个构造函数，又是一个Generator函数。这时，使用new命令就无法生成F的实例了，因为F返回的是一个Iterator对象。

```
'next' in (new F()) // true
```

那么，这个时候怎么生成对象实例呢？

我们知道，如果构造函数调用时，没有使用new命令，那么内部的this对象，绑定当前构造函数所在的对象（比如window对象）。因此，可以生成一个空对象，使用bind方法绑定F内部的this。这样，构造函数调用以后，这个空对象就是F的实例对象了。

```
var obj = {};
var f = F.bind(obj)();

f.next();
f.next();
f.next();

console.log(obj); // { x: 2, y: 3 }
```

上面代码中，首先是F内部的this对象绑定obj对象，然后调用它，返回一个Iterator对象。这个对象执行三次next方法（因为F内部有两个yield语句），完成F内部所有代码的运行。这时，所有内部属性都绑定在obj对象上了，因此obj对象也就成了F的实例。

### Generator函数推导

ES7在数组推导的基础上，提出了Generator函数推导（Generator comprehension）。

```
let generator = function* () {
  for (let i = 0; i < 6; i++) {
    yield i;
  }
}

let squared = ( for (n of generator()) n * n );
// 等同于
// let squared = Array.from(generator()).map(n => n * n);

console.log(...squared); // 0 1 4 9 16 25
```

“推导”这种语法结构，不仅可以用于数组，ES7将其推广到了Generator函数。for...of循环会自动调用Iterator对象的next方法，将返回值的value属性作为数组的一个成员。

Generator函数推导是对数组结构的一种模拟，它的最大优点是惰性求值，即直到真正用到时才会求值，这样可以保证效率。请看下面的例子。
```
let bigArray = new Array(100000);
for (let i = 0; i < 100000; i++) {
  bigArray[i] = i;
}

let first = bigArray.map(n => n * n)[0];
console.log(first);
```
上面例子遍历一个大数组，但是在真正遍历之前，这个数组已经生成了，占用了系统资源。如果改用Generator函数推导，就能避免这一点。下面代码只在用到时，才会生成一个大数组。

```
let bigGenerator = function* () {
  for (let i = 0; i < 100000; i++) {
    yield i;
  }
}
let squared = ( for (n of bigGenerator()) n * n );

console.log(squared.next());
```

### Generator与状态机

Generator是实现状态机的最佳结构。比如，下面的clock函数就是一个状态机。

```
var ticking = true;
var clock = function() {
  if (ticking)
    console.log('Tick!');
  else
    console.log('Tock!');
  ticking = !ticking;
}
```
上面代码的clock函数一共有两种状态（Tick和Tock），每运行一次，就改变一次状态。这个函数如果用Generator实现，就是下面这样。

```
var clock = function*(_) {
  while (true) {
    yield _;
    console.log('Tick!');
    yield _;
    console.log('Tock!');
  }
};
```
上面的Generator实现与ES5实现对比，可以看到少了用来保存状态的外部变量ticking，这样就更简洁，更安全（状态不会被非法篡改）、更符合函数式编程的思想，在写法上也更优雅。Generator之所以可以不用外部变量保存状态，是因为它本身就包含了一个状态信息，即目前是否处于暂停态。

### Generator与协程
协程（coroutine）是一种程序运行的方式，可以理解成“协作的线程”或“协作的函数”。协程既可以用单线程实现，也可以用多线程实现。前者是一种特殊的子例程，后者是一种特殊的线程。

1. **协程与子例程的差异**

    传统的“子例程”（subroutine）采用堆栈式“后进先出”的执行方式，只有当调用的子函数完全执行完毕，才会结束执行父函数。协程与其不同，多个线程（单线程情况下，即多个函数）可以并行执行，但是只有一个线程（或函数）处于正在运行的状态，其他线程（或函数）都处于暂停态（suspended），线程（或函数）之间可以交换执行权。也就是说，一个线程（或函数）执行到一半，可以暂停执行，将执行权交给另一个线程（或函数），等到稍后收回执行权的时候，再恢复执行。这种可以并行执行、交换执行权的线程（或函数），就称为协程。

    从实现上看，在内存中，子例程只使用一个栈（stack），而协程是同时存在多个栈，但只有一个栈是在运行状态，也就是说，协程是以多占用内存为代价，实现多任务的并行。

2. **协程与普通线程的差异**

    不难看出，协程适合用于多任务运行的环境。在这个意义上，它与普通的线程很相似，都有自己的执行上下文、可以分享全局变量。它们的不同之处在于，同一时间可以有多个线程处于运行状态，但是运行的协程只能有一个，其他协程都处于暂停状态。此外，普通的线程是抢先式的，到底哪个线程优先得到资源，必须由运行环境决定，但是协程是合作式的，执行权由协程自己分配。

    由于ECMAScript是单线程语言，只能保持一个调用栈。引入协程以后，每个任务可以保持自己的调用栈。这样做的最大好处，就是抛出错误的时候，可以找到原始的调用栈。不至于像异步操作的回调函数那样，一旦出错，原始的调用栈早就结束。

    Generator函数是ECMAScript 6对协程的实现，但属于不完全实现。Generator函数被称为“半协程”（semi-coroutine），意思是只有Generator函数的调用者，才能将程序的执行权还给Generator函数。如果是完全执行的协程，任何函数都可以让暂停的协程继续执行。

    如果将Generator函数当作协程，完全可以将多个需要互相协作的任务写成Generator函数，它们之间使用yield语句交换控制权。

### 应用

Generator可以暂停函数执行，返回任意表达式的值。这种特点使得Generator有多种应用场景。

**异步操作的同步化表达**

Generator函数的暂停执行的效果，意味着可以把异步操作写在yield语句里面，等到调用next方法时再往后执行。这实际上等同于不需要写回调函数了，因为异步操作的后续操作可以放在yield语句下面，反正要等到调用next方法时再执行。所以，Generator函数的一个重要实际意义就是用来处理异步操作，改写回调函数。

```
function* loadUI() {
  showLoadingScreen();
  yield loadUIDataAsynchronously();
  hideLoadingScreen();
}
var loader = loadUI();
// 加载UI
loader.next()

// 卸载UI
loader.next()
```

上面代码表示，第一次调用loadUI函数时，该函数不会执行，仅返回一个Iterator对象。下一次对该Iterator对象调用next方法，则会显示Loading界面，并且异步加载数据。等到数据加载完成，再一次使用next方法，则会隐藏Loading界面。可以看到，这种写法的好处是所有Loading界面的逻辑，都被封装在一个函数，按部就班非常清晰。

Ajax是典型的异步操作，通过Generator函数部署Ajax操作，可以用同步的方式表达。

```
function* main() {
  var result = yield request("http://some.url");
  var resp = JSON.parse(result);
  console.log(resp.value);
}

function request(url) {
  makeAjaxCall(url, function(response){
    it.next(response);
  });
}

var it = main();
it.next();
```

上面代码的main函数，就是通过Ajax操作获取数据。可以看到，除了多了一个yield，它几乎与同步操作的写法完全一样。注意，makeAjaxCall函数中的next方法，必须加上response参数，因为yield语句构成的表达式，本身是没有值的，总是等于undefined。

下面是另一个例子，通过Generator函数逐行读取文本文件。

```
function* numbers() {
  let file = new FileReader("numbers.txt");
  try {
    while(!file.eof) {
      yield parseInt(file.readLine(), 10);
    }
  } finally {
    file.close();
  }
}
```
上面代码打开文本文件，使用yield语句可以手动逐行读取文件。

**控制流管理**

如果有一个多步操作非常耗时，采用回调函数，可能会写成下面这样。

```
step1(function (value1) {
  step2(value1, function(value2) {
    step3(value2, function(value3) {
      step4(value3, function(value4) {
        // Do something with value4
      });
    });
  });
});
```

采用Promise改写上面的代码。

```
Q.fcall(step1)
  .then(step2)
  .then(step3)
  .then(step4)
  .then(function (value4) {
    // Do something with value4
  }, function (error) {
    // Handle any error from step1 through step4
  })
  .done();
```

上面代码已经把回调函数，改成了直线执行的形式，但是加入了大量Promise的语法。Generator函数可以进一步改善代码运行流程。

```
function* longRunningTask() {
  try {
    var value1 = yield step1();
    var value2 = yield step2(value1);
    var value3 = yield step3(value2);
    var value4 = yield step4(value3);
    // Do something with value4
  } catch (e) {
    // Handle any error from step1 through step4
  }
}
```

然后，使用一个函数，按次序自动执行所有步骤。

```
scheduler(longRunningTask());

function scheduler(task) {
  setTimeout(function() {
    var taskObj = task.next(task.value);
    // 如果Generator函数未结束，就继续调用
    if (!taskObj.done) {
      task.value = taskObj.value
      scheduler(task);
    }
  }, 0);
}
```

注意，yield语句是同步运行，不是异步运行（否则就失去了取代回调函数的设计目的了）。实际操作中，一般让yield语句返回Promise对象。

```
var Q = require('q');

function delay(milliseconds) {
  var deferred = Q.defer();
  setTimeout(deferred.resolve, milliseconds);
  return deferred.promise;
}

function* f(){
  yield delay(100);
};
```
上面代码使用Promise的函数库Q，yield语句返回的就是一个Promise对象。

多个任务按顺序一个接一个执行时，yield语句可以按顺序排列。多个任务需要并列执行时（比如只有A任务和B任务都执行完，才能执行C任务），可以采用数组的写法。

```
function* parallelDownloads() {
  let [text1,text2] = yield [
    taskA(),
    taskB()
  ];
  console.log(text1, text2);
}
```
上面代码中，yield语句的参数是一个数组，成员就是两个任务taskA和taskB，只有等这两个任务都完成了，才会接着执行下面的语句。

**部署Iterable接口**

利用Generator函数，可以在任意对象上部署Iterable接口。

```
function* iterEntries(obj) {
  let keys = Object.keys(obj);
  for (let i=0; i < keys.length; i++) {
    let key = keys[i];
    yield [key, obj[key]];
  }
}

let myObj = { foo: 3, bar: 7 };

for (let [key, value] of iterEntries(myObj)) {
  console.log(key, value);
}
// foo 3
// bar 7
```

上述代码中，myObj是一个普通对象，通过iterEntries函数，就有了Iterable接口。

下面是一个对数组部署Iterable接口的例子，尽管数组原生具有这个接口。

```
function* makeSimpleGenerator(array){
  var nextIndex = 0;

  while(nextIndex < array.length){
    yield array[nextIndex++];
  }
}

var gen = makeSimpleGenerator(['yo', 'ya']);

gen.next().value // 'yo'
gen.next().value // 'ya'
gen.next().done  // true
```

**作为数据结构**

Generator可以看作是数据结构，更确切地说，可以看作是一个数组结构，因为Generator函数可以返回一系列的值，这意味着它可以对任意表达式，提供类似数组的接口。

```
function *doStuff() {
  yield fs.readFile.bind(null, 'hello.txt');
  yield fs.readFile.bind(null, 'world.txt');
  yield fs.readFile.bind(null, 'and-such.txt');
}
```

上面代码就是依次返回三个函数，但是由于使用了Generator函数，导致可以像处理数组那样，处理这三个返回的函数。

```
for (task of doStuff()) {
  // task是一个函数，可以像回调函数那样使用它
}
```

实际上，如果用ES5表达，完全可以用数组模拟Generator的这种用法。

```
function doStuff() {
  return [
    fs.readFile.bind(null, 'hello.txt'),
    fs.readFile.bind(null, 'world.txt'),
    fs.readFile.bind(null, 'and-such.txt')
  ];
}
```

上面的函数，可以用一模一样的for...of循环处理！两相一比较，就不难看出Generator使得数据或者操作，具备了类似数组的接口。

## 尾调用优化
尾调用（Tail Call）是函数式编程的一个重要概念，就是指某个函数的最后一步是调用另一个函数。

```
function f(x){
  return g(x);
}

//下面三种情况都不是尾调用
function f(x){
  let y = g(x);
  return y;
}

function f(x){
  return g(x) + 1;
}

function f(x){
  g(x);
}
```
最后一种情况等同于下面的代码。
```
function f(x){
  g(x);
  return undefined;
}
```
尾调用不一定出现在函数尾部，只要是最后一步操作即可。
```
function f(x) {
  if (x > 0) {
    return m(x)
  }
  return n(x);
}
```
上面代码中，函数m和n都属于尾调用，因为它们都是函数f的最后一步操作。

我们知道，函数调用会在内存形成一个“调用记录”，又称“调用帧”（call frame），保存调用位置和内部变量等信息。如果在函数A的内部调用函数B，那么在A的调用帧上方，还会形成一个B的调用帧。等到B运行结束，将结果返回到A，B的调用帧才会消失。如果函数B内部还调用函数C，那就还有一个C的调用帧，以此类推。所有的调用帧，就形成一个“调用栈”（call stack）。

尾调用由于是函数的最后一步操作，所以不需要保留外层函数的调用帧，因为调用位置、内部变量等信息都不会再用到了，只要直接用内层函数的调用帧，取代外层函数的调用帧就可以了。

“尾调用优化”（Tail call optimization），即只保留内层函数的调用帧。如果所有函数都是尾调用，那么完全可以做到每次执行时，调用帧只有一项，这将大大节省内存。这就是“尾调用优化”的意义。

注意，只有不再用到外层函数的内部变量，内层函数的调用帧才会取代外层函数的调用帧，否则就无法进行“尾调用优化”。
```
function addOne(a){
  var one = 1;
  function inner(b){
    return b + one;
  }
  return inner(a);
}
```
上面的函数不会进行尾调用优化，因为内层函数inner用到了，外层函数addOne的内部变量one。

函数调用自身，称为递归。如果尾调用自身，就称为尾递归。

递归非常耗费内存，因为需要同时保存成千上百个调用帧，很容易发生“栈溢出”错误（stack overflow）。但对于尾递归来说，由于只存在一个调用帧，所以永远不会发生“栈溢出”错误。

尾递归的实现，往往需要改写递归函数，确保最后一步只调用自身。做到这一点的方法，就是把所有用到的内部变量改写成函数的参数。
```
function factorial(n) {
  if (n === 1) return 1;
  return n * factorial(n - 1);
}

factorial(5) //120
```
对上面的递归优化
```
function tailFactorial(n, total) {
  if (n === 1) return total;
  return tailFactorial(n - 1, n * total);
}

function factorial(n) {
  return tailFactorial(n, 1);
}

factorial(5) // 120
```

函数式编程有一个概念，叫做柯里化（currying），意思是将多参数的函数转换成单参数的形式。这里也可以使用柯里化。
```
function currying(fn, n) {
  return function (m) {
    return fn.call(this, m, n);
  };
}

function tailFactorial(n, total) {
  if (n === 1) return total;
  return tailFactorial(n - 1, n * total);
}

const factorial = currying(tailFactorial, 1);

factorial(5) // 120
```
上面代码通过柯里化，将尾递归函数 tailFactorial 变为只接受1个参数的 factorial 。

第二种方法就简单多了，就是采用ES6的函数默认值。
```
function factorial(n, total = 1) {
  if (n === 1) return total;
  return factorial(n - 1, n * total);
}

factorial(5) // 120
```
递归本质上是一种循环操作。纯粹的函数式编程语言没有循环操作命令，所有的循环都用递归实现，这就是为什么尾递归对这些语言极其重要。

## ES7可能支持函數綁定
箭头函数可以绑定this对象，大大减少了显式绑定this对象的写法（call、apply、bind）。但是，箭头函数并不适用于所有场合，所以ES7提出了“函数绑定”（function bind）运算符，用来取代call、apply、bind调用。虽然该语法还是ES7的一个提案，但是Babel转码器已经支持。

函数绑定运算符是并排的两个双引号（::），双引号左边是一个对象，右边是一个函数。该运算符会自动将左边的对象，作为上下文环境（即this对象），绑定到右边的函数上面。

## 模块
在ES6之前，社区制定了一些模块加载方案，最主要的有CommonJS和AMD两种。前者用于服务器，后者用于浏览器。ES6在语言规格的层面上，实现了模块功能，而且实现得相当简单，完全可以取代现有的CommonJS和AMD规范，成为浏览器和服务器通用的模块解决方案。

ES6模块的设计思想，是尽量的静态化，使得编译时就能确定模块的依赖关系，以及输入和输出的变量。CommonJS和AMD模块，都只能在运行时确定这些东西。比如，CommonJS模块就是对象，输入时必须查找对象属性。ES6模块不是对象，而是通过export命令显式指定输出的代码，输入时也采用静态命令的形式。所以，ES6可以在编译时就完成模块编译，效率要比CommonJS模块高。

模块功能由三个命令构成：export，import和module。export命令用于用户自定义模块，规定对外接口；import命令用于输入其他模块提供的功能，同时创造命名空间（namespace），防止函数名冲突；module用于整体输入其它模块的提供的功能。

简单实例
```
// lib/math.js
export function sum(x, y) {
  return x + y;
}
export var pi = 3.141593;
// app.js
import * as math from "lib/math";
console.log(math.pi);
```

### export命令
ES6允许将独立的JS文件作为模块，也就是说，允许一个JavaScript脚本文件调用另一个脚本文件。该文件内部的所有变量、函数、类，外部无法获取，必须使用export关键字输出，一种输出方式是只需要在原有声明变量、函数、类语句前加export，另一种方式是在export后使用大括号指定需要输出的变量、函数、类，并且中间用逗号分隔。下面是一个JS文件，里面使用export命令输出变量。

```
// profile.js
export var name = 'Michael';
export var year = 1958;
```

另外一种写法。

```
// profile.js
var name = 'Michael';
var year = 1958;

export {name, year};
```

上面代码在export命令后面，使用大括号指定所要输出的一组变量。它与前一种写法（直接放置在var语句前）是等价的，但是应该优先考虑使用这种写法。因为这样就可以在脚本尾部，一眼看清楚输出了哪些变量。

### import命令
使用export命令定义了模块的对外接口以后，其他JS文件就可以通过import命令加载这个模块（文件）。

```
// main.js
import {name, year} from './profile';

function setHeader(element) {
  element.textContent = name;
}
```

上面代码属于另一个文件main.js，import命令就用于加载profile.js文件，并从中输入变量。import命令接受一个对象（用大括号表示），里面指定要从其他模块导入的变量名。大括号里面的变量名，必须与被导入模块（profile.js）对外接口的名称相同。

如果想为输入的变量重新取一个名字，import语句中要使用as关键字，将输入的变量重命名。

```
import { name as nickName } from './profile';
```

ES6支持多重加载，即所加载的模块中又加载其他模块。

```
import { Vehicle } from './Vehicle';

class Car extends Vehicle {
  move () {
    console.log(this.name + ' is spinning wheels...')
  }
}

export { Car }
```

如果在一个模块之中，先输入后输出同一个模块，import语句可以与export语句写在一起。

```
export { es6 as default } from './someModule';

// 等同于
import { es6 } from './someModule';
export default es6;
```

上面代码中，export和import语句可以结合在一起，写成一行。但是从可读性考虑，不建议采用这种写法，应该采用标准写法。

### 模块的整体输入
下面是一个circle.js文件，它输出两个方法area和circumference。

```
// circle.js
export function area(radius) {
  return Math.PI * radius * radius;
}

export function circumference(radius) {
  return 2 * Math.PI * radius;
}
```

然后，main.js文件输入circle.js模块。

```
// main.js
import * as circle from 'circle';

console.log("圆面积：" + circle.area(4));
console.log("圆周长：" + circle.circumference(14));
```

### module命令
module命令可以取代import语句，达到整体输入模块的作用。

```
// main.js
module circle from 'circle';

console.log("圆面积：" + circle.area(4));
console.log("圆周长：" + circle.circumference(14));
```
module命令后面跟一个变量，表示输入的模块定义在该变量上。

### export default命令
使用import的时候，用户需要知道所要加载的变量名或函数名，否则无法加载。但是，用户肯定希望快速上手，未必愿意阅读文档，去了解模块有哪些属性和方法。

为了给用户提供方便，让他们不用阅读文档就能加载模块，就要用到`export default`命令，为模块指定默认输出。

```
// export-default.js
export default function () {
  console.log('foo');
}
```

上面代码是一个模块文件`export-default.js`，它的默认输出是一个函数。

其他模块加载该模块时，import命令可以为该匿名函数指定任意名字。

```
// import-default.js
import customName from './export-default';
customName(); // 'foo'
```
上面代码的import命令，可以用任意名称指向`export-default.js`输出的方法。需要注意的是，这时import命令后面，不使用大括号。

export default命令用在非匿名函数前，也是可以的。

```
// export-default.js
export default function foo() {
  console.log('foo');
}

// 或者写成
function foo() {
  console.log('foo');
}
export default foo;
```
上面代码中，foo函数的函数名foo，在模块外部是无效的。加载的时候，视同匿名函数加载。

下面比较一下默认输出和正常输出。

```
import crc32 from 'crc32';
// 对应的输出
export default function crc32(){}

// 需要使用大括号
import { crc32 } from 'crc32';
// 对应的输出
export function crc32(){};
```

`export default`命令用于指定模块的默认输出。显然，一个模块只能有一个默认输出，因此`export deault`命令只能使用一次。所以，import命令后面才不用加大括号，因为只可能对应一个方法。

本质上，`export default`就是输出一个叫做default的变量或方法，然后系统允许你为它取任意名字。所以，下面的写法是有效的。

```
// modules.js
export default function (x, y) {
  return x * y;
};
// app.js
import { default } from 'modules';
```

有了`export default`命令，输入模块时就非常直观了，以输入jQuery模块为例。

```
import $ from 'jquery';
```

如果想在一条import语句中，同时输入默认方法和其他变量，可以写成下面这样。

```
import customName, { otherMethod } from './export-default';
```

如果要输出默认的值，只需将值跟在`export default`之后即可。

```
export default 42;
```

`export default`也可以用来输出类。

```
// MyClass.js
export default class { ... }

// main.js
import MyClass from 'MyClass'
let o = new MyClass();
```

### 模块的继承
模块之间也可以继承。

假设有一个circleplus模块，继承了circle模块。

```
// circleplus.js
export * from 'circle';
export var e = 2.71828182846;
export default function(x) {
    return Math.exp(x);
}
```

上面代码中的“export *”，表示输出circle模块的所有属性和方法，export default命令定义模块的默认方法。

这时，也可以将circle的属性或方法，改名后再输出。

```
// circleplus.js
export { area as circleArea } from 'circle';
```

上面代码表示，只输出circle模块的area方法，且将其改名为circleArea。

加载上面模块的写法如下。

```
// main.js
module math from "circleplus";
import exp from "circleplus";
console.log(exp(math.e));
```

上面代码中的`import exp`表示，将circleplus模块的默认方法加载为exp方法。

### ES6模块的转码
浏览器目前还不支持ES6模块，为了现在就能使用，可以将转为ES5的写法。

#### ES6 module transpiler
[ES6 module transpiler](https://github.com/esnext/es6-module-transpiler)是square公司开源的一个转码器，可以将ES6模块转为CommonJS模块或AMD模块的写法，从而在浏览器中使用。

首先，安装这个转玛器。

```
$ npm install -g es6-module-transpiler
```

然后，使用`compile-modules convert`命令，将ES6模块文件转码。

```
$ compile-modules convert file1.js file2.js
```

o参数可以指定转码后的文件名。

```
$ compile-modules convert -o out.js file1.js
```

#### SystemJS
另一种解决方法是使用[SystemJS](https://github.com/systemjs/systemjs)。它是一个垫片库（polyfill），可以在浏览器内加载ES6模块、AMD模块和CommonJS模块，将其转为ES5格式。它在后台调用的是Google的Traceur转码器。

使用时，先在网页内载入system.js文件。

```
<script src="system.js"></script>
```

然后，使用`System.import`方法加载模块文件。

```
<script>
  System.import('./app');
</script>
```

上面代码中的`./app`，指的是当前目录下的app.js文件。它可以是ES6模块文件，`System.import`会自动将其转码。

需要注意的是，`System.import`使用异步加载，返回一个Promise对象，可以针对这个对象编程。下面是一个模块文件。

```
// app/es6-file.js:
export class q {
  constructor() {
    this.es6 = 'hello';
  }
}
```

然后，在网页内加载这个模块文件。

```
<script>
System.import('app/es6-file').then(function(m) {
  console.log(new m.q().es6); // hello
});
</script>
```

## 错误处理
### try-catch 语句
ECMA-262 第 3 版引入了 try-catch 语句,作为 JavaScript 中处理异常的一种标准方式。基本的语法如下所示,显而易见,这与 Java 中的 try-catch 语句是完全相同的。
```
try{
// 可能会导致错误的代码
} catch(error){
// 在错误发生时怎么处理
}
```
也就是说,我们应该把所有可能会抛出错误的代码都放在 try 语句块中,而把那些用于错误处理的代码放在 catch 块中。如果 try 块中的任何代码发生了错误,就会立即退出代码执行过程,然后接着执行 catch 块。此时, catch 块会接收到一个包含错误信息的对象。

内置使用内置的Error对象具有两个标准属性name和message

* **name**：错误名称
* **message**：错误提示信息
* **stack**：错误的堆栈（非标准属性，但是大多数平台支持）

使用 try-catch 最适合处理那些我们无法控制的错误。假设你在使用一个大型 JavaScript 库中的函数,该函数可能会有意无意地抛出一些错误。由于我们不能修改这个库的源代码,所以大可将对该函数的调用放在 try-catch 语句当中,万一有什么错误发生,也好恰当地处理它们。

在明明白白地知道自己的代码会发生错误时,再使用 try-catch 语句就不太合适了。例如,如果传递给函数的参数是字符串而非数值,就会造成函数出错,那么就应该先检查参数的类型,然后再决定如何去做。在这种情况下,不应用使用 try-catch 语句。

### finally 子句
finally都是可选的，但 finally 子句一经使用,其代码无论如何都会执行。换句话说, try 语句块中的代码全部正常执行, finally 子句会执行;如果因为出错而执行了 catch 语句块, finally 子句照样还会执行。

```
function fn(){
  try {
    var x = 1;
    throw new Error('error');
  } catch (e) {
    console.log('x=' + x);
    return x;
  } finally {
    x = 2;
    console.log('x=' + x);
  }
}
```
上面代码说明，即使有return语句在前，finally代码块依然会得到执行，且在其执行完毕后，并不影响return语句要返回的值。

### 错误类型
ECMA-262 定义了下列 7 种错误类型: Error,EvalError,RangeError,ReferenceError,SyntaxError,TypeError,URIError

#### EvalError
如果没有把 eval() 当成函数调用,就会抛出EvalError错误。一些浏览器不会正确抛出这个错误。

#### RangeError
RangeError是当一个值超出有效范围时发生的错误。主要有几种情况，一是数组长度为负数，二是Number对象的方法参数超出范围，以及函数堆栈超过最大值。

```
new Array(-1);
(1234).toExponential(21);
new Array(Number.MAX_VALUE);
```

#### ReferenceError
ReferenceError是引用一个不存在的变量时发生的错误。另一种触发场景是，将一个值分配给无法分配的对象，比如对函数的运行结果或者this赋值。

```
undefinedVar;
console.log() = 1;
this = 1;
```

#### SyntaxError
SyntaxError是解析代码时发生的语法错误。

```
// 变量名错误
var 1a;
// 缺少括号
console.log 'hello');
```

#### TypeError
TypeError是变量或参数不是预期类型时发生的错误。比如，对字符串、布尔值、数值等原始类型的值使用new命令，就会抛出这种错误，因为new命令的参数应该是一个构造函数。访问不存在的方法时也会抛出该错误。

```
new 123
var obj = {};
obj.unknownMethod()
```

#### URIError
URIError是URI相关函数的参数不正确时抛出的错误，主要涉及encodeURI()、decodeURI()、encodeURIComponent()、decodeURIComponent()、escape()和unescape()这六个函数。

```
decodeURI('%2')
```
### 抛出错误
与 try-catch 语句相配的还有一个 throw 操作符,用于随时抛出自定义错误。抛出错误时,必须要给 throw 操作符指定一个值,这个值是什么类型,没有要求。下列代码都是有效的。

```
throw 12345;
throw "Hello world!";
throw true;
throw { name: "JavaScript"};
```
在遇到 throw 操作符时,代码会立即停止执行。仅当有 try-catch 语句捕获到被抛出的值时,代码才会继续执行。

通过使用某种内置错误类型,可以更真实地模拟浏览器错误。每种错误类型的构造函数接收一个参数,即实际的错误消息。下面是一个例子。

```
throw new Error("error");
```
这行代码抛出了一个通用错误,带有一条自定义错误消息。浏览器会像处理自己生成的错误一样,来处理这行代码抛出的错误。

在创建自定义错误消息时最常用的错误类型是 Error 、 RangeError 、 ReferenceError 和 TypeError 。

另外,利用原型链还可以通过继承 Error 来创建自定义错误类型

```
function UserError(message) {
   this.message = message || "默认信息";
   this.name = "UserError";
}

UserError.prototype = new Error();
UserError.prototype.constructor = UserError;
```
浏览器对待继承自 Error 的自定义错误类型,就像对待其他错误类型一样。如果要捕获自己抛出的错误并且把它与浏览器错误区别对待的话,创建自定义错误是很有用的。

要针对函数为什么会执行失败给出更多信息,抛出自定义错误是一种很方便的方式。应该在出现某种特定的已知错误条件,导致函数无法正常执行时抛出错误。换句话说,浏览器会在某种特定的条件下执行函数时抛出错误。

说到抛出错误与捕获错误,我们认为只应该捕获那些你确切地知道该如何处理的错误。捕获错误的目的在于避免浏览器以默认方式处理它们;而抛出错误的目的在于提供错误发生具体原因的消息。

### 错误( error )事件
任何没有通过 try-catch 处理的错误都会触发 window 对象的 error 事件。在任何 Web 浏览器中, onerror 事件处理程序都不会创建 event 对象,但它可以接收三个参数:错误消息、错误所在的 URL 和行号。多数情况下,只有错误消息有用,因为 URL 只是给出了文档的位置,而行号所指的代码行既可能出自嵌入的 JavaScript 代码,也可能出自外部的文件。

只要发生错误,无论是不是浏览器生成的,都会触发 error 事件,并执行这个事件处理程序。然后,浏览器默认的机制发挥作用,像往常一样显示出错误消息。像下面这样在事件处理程序中返回false ,可以阻止浏览器报告错误的默认行为。

```
window.onerror = function(message, url, line){
    alert(message);
    return false;
};
```
通过返回 false ,这个函数实际上就充当了整个文档中的 try-catch 语句,可以捕获所有无代码处理的运行时错误。这个事件处理程序是避免浏览器报告错误的最后一道防线,理想情况下,只要可能就不应该使用它。只要能够适当地使用 try-catch 语句,就不会有错误交给浏览器,也就不会触发error 事件。

图像也支持 error 事件。只要图像的 src 特性中的 URL 不能返回可以被识别的图像格式,就会触发 error 事件。

### 常见的错误类型
错误处理的核心,是首先要知道代码里会发生什么错误。由于 JavaScript 是松散类型的,而且也不会验证函数的参数,因此错误只会在代码运行期间出现。一般来说,需要关注三种错误:

* 类型转换错误
* 数据类型错误
* 通信错误

类型转换错误发生在使用某个操作符,或者使用其他可能会自动转换值的数据类型的语言结构时。在使用相等(==)和不相等(!=)操作符,或者在 if 、 for 及 while 等流控制语句中使用非布尔值时, 最常发生类型转换错误。强烈建议使用全等操作符（===,!==）。

```
if (str3){ //绝对不要这样!!!
}
if (typeof str3 == "string"){//合理的比较
}
```

JavaScript 是松散类型的,也就是说,在使用变量和函数参数之前,不会对它们进行比较以确保它们的数据类型正确。为了保证不会发生数据类型错误,只能依靠开发人员编写适当的数据类型检测代码。在将预料之外的值传递给函数的情况下,最容易发生数据类型错误。大体上来说,基本类型的值应该使用 typeof 来检测,而对象的值则应该使用 instanceof 来检测。

JavaScript 与服务器之间的任何一次通信,都有可能会产生错误。

第一种通信错误与格式不正确的 URL 或发送的数据有关。最常见的问题是在将数据发送给服务器之前,没有使用 encodeURIComponent() 对数据进行编码。

对于查询字符串,应该记住必须要使用 encodeURIComponent() 方法。为了确保这一点,有时候可以定义一个处理查询字符串的函数,例如:
```
function addQueryStringArg(url, name, value){
    if (url.indexOf("?") == -1){
        url += "?";
    } else {
        url += "&";
    }
    url += encodeURIComponent(name) + "=" + encodeURIComponent(value);
    return url;
}
```

### 区分致命错误和非致命错误

* 非致命错误
    *不影响用户的主要任务;
    * 只影响页面的一部分;
    * 可以恢复;
    * 重复相同操作可以消除错误。
* 致命错误
    * 应用程序根本无法继续运行;
    * 错误明显影响到了用户的主要操作;
    * 会导致其他连带错误。

### 把错误记录到服务器
可以把错误回写到服务器，标明来自前端。
```
function logError(sev, msg){
    var img = new Image();
    img.src = "log.php?sev=" + encodeURIComponent(sev) + "&msg=" +
    encodeURIComponent(msg);
}
```
这个 logError() 函数接收两个参数:表示严重程度的数值或字符串(视所用系统而异)及错误消息。其中,使用了 Image 对象来发送请求,这样做非常灵活,主要表现如下几方面。

* 所有浏览器都支持 Image 对象,包括那些不支持 XMLHttpRequest 对象的浏览器。
* 可以避免跨域限制。通常都是一台服务器要负责处理多台服务器的错误,而这种情况下使用XMLHttpRequest 是不行的。
* 在记录错误的过程中出问题的概率比较低。大多数 Ajax 通信都是由 JavaScript 库提供的包装函数来处理的,如果库代码本身有问题,而你还在依赖该库记录错误,可想而知,错误消息是不可能得到记录的。

# 变量、作用域和内存问题
## 基本类型和引用类型的值
引用类型的值是保存在内存中的对象。与其他语言不同，JavaScript不允许直接访问内存中的位置，也就是说不能直接操作对象的内存空间。在操作对象时，实际上是在操作对象的引用而不是实际的对象（和Java类似）。为此，引用类型的值是按引用访问的

很多语言中，字符串以对象的形式来表示，因此被认为是引用类型的。ECMAScript放弃了这一传统。

ECMAScript 变量可能包含两种不同数据类型的值：基本类型值和引用类型值。基本类型值指的是简单的数据段，而引用类型值指那些可能由多个值构成的对象。

我们不能给基本类型的值添加属性，尽管这样做不会导致任何错误

ECMAScript 中所有函数的参数都是按值传递的

当从一个变量向另一个变量复制引用类型的值时，同样也会将存储在变量对象中的值复制一份放到为新变量分配的空间中。不同的是，这个值的副本实际上是一个指针，而这个指针指向存储在堆中的一个对象。复制操作结束后，两个变量实际上将引用同一个对象。

在向参数传递基本类型的值时，被传递的值会被复制给一个局部变量（即命名参数，或者用ECMAScript的概念来说，就是 arguments 对象中的一个元素）。在向参数传递引用类型的值时，会把这个值在内存中的地址复制给一个局部变量，因此这个局部变量的变化会反映在函数的外部

如果使用instanceof 操作符检测基本类型的值，则该操作符始终会返回false，因为基本类型不是对象。

如果变量的值是一个对象或null，则typeof操作符会返回"object"

ECMA-262规定任何在内部实现[[Call]]方法的对象都应该在应用 typeof 操作符时返回"function"。由于Safari 5及之前版本和Chrome 7及之前版本浏览器中的正则表达式也实现了这个方法，因此对正则表达式应用 typeof 会返回"function"。在IE和Firefox中，对正则表达式应用typeof会返回"object"。

## 执行环境及作用域
标识符解析是沿着作用域链一级一级地搜索标识符的过程。搜索过程始终从作用域链的前端开始，然后逐级地向后回溯，直至找到标识符为止（如果找不到标识符，通常会导致错误发生）。

执行环境定义了变量或函数有权访问的其他数据，决定了它们各自的行为。每个执行环境都有一个与之关联的变量对象（variable object），环境中定义的所有变量和函数都保存在这个对象中。虽然我们编写的代码无法访问这个对象，但解析器在处理数据时会在后台使用它。 全局执行环境是最外围的一个执行环境。根据 ECMAScript实现所在的宿主环境不同，表示执行环境的对象也不一样。在Web浏览器中，全局执行环境被认为是 window 对象，因此所有全局变量和函数都是作为window对象的属性和方法创建的。某个执行环境中的所有代码执行完毕后，该环境被销毁，保存在其中的所有变量和函数定义也随之销毁（全局执行环境直到应用程序退出——例如关闭网页或浏览器——时才会被销毁）。 每个函数都有自己的执行环境。当执行流进入一个函数时，函数的环境就会被推入一个环境栈中。而在函数执行之后，栈将其环境弹出，把控制权返回给之前的执行环境。ECMAScript 程序中的执行流正是由这个方便的机制控制着。 当代码在一个环境中执行时，会创建变量对象的一个作用域链（scope chain）。作用域链的用途，是保证对执行环境有权访问的所有变量和函数的有序访问。作用域链的前端，始终都是当前执行的代码所在环境的变量对象。如果这个环境是函数，则将其活动对象（activation object）作为变量对象。活动对象在最开始时只包含一个变量，即arguments对象（这个对象在全局环境中是不存在的）。作用域链中的下一个变量对象来自包含（外部）环境，而再下一个变量对象则来自下一个包含环境。这样，一直延续到全局执行环境；全局执行环境的变量对象始终都是作用域链中的最后一个对象。

内部环境可以通过作用域链访问所有的外部环境，但外部环境不能访问内部环境中的任何变量和函数。这些环境之间的联系是线性、有次序的。每个环境都可以向上搜索作用域链，以查询变量和函数名；但任何环境都不能通过向下搜索作用域链而进入另一个执行环境。

```
var color = 'blue';
function changeColor(){
    function swapColors(){
    }
}
```
作用域链中包含 swapColors->changeColor->window三个对象

### 延长作用域链
当执行流进入下列任何一个语句时，作用域链就会得到加长：
* try-catch语句的catch块；
* with语句。

这两个语句都会在作用域链的前端添加一个变量对象。对with语句来说，会将指定的对象添加到作用域链中。对catch语句来说，会创建一个新的变量对象，其中包含的是被抛出的错误对象的声明

```
function buildUrl(){
  var qs = '?debug=true';
  with(location) {
    var url = href + qs;
  }
  return url;
}
```
with 语句接收的是location 对象，因此其变量对象中就包含了location 对象的所有属性和方法，而这个变量对象被添加到了作用域链的前端

### JavaScript没有块级作用域
* 声明变量
    在函数内部，最接近的环境就是函数的局部环境；在with语句中，最接近的环境是函数环境。如果初始化变量时没有使用var声明，该变量会自动被添加到全局环境。

    严格模式下，初始化未经声明的变量会导致错误。建议还是要用var声明变量，当然可以边声明边初始化。

* 查询标识符
    搜索过程从作用域链的前端开始，向上逐级查询与给定名字匹配的标识符。

    如果局部环境中存在着同名标识符，就不会使用位于父环境中的标识符

    {% codeblock %}
    var color = 'blue';
    function getColor(){
      var color = 'red';
      return color;
    }
    alert(getColor());
    {% endcodeblock %}

    位于局部变量 color 的声明之后的代码，如果不使用 window.color 都无法访问全局 color变量。

ECMASctipt6中let实际上为JavaScript增加了块级作用域。另外，ES6也规定，函数本身的作用域，在其所在的块级作用域之内。
```
function f() { console.log('I am outside!'); }
(function () {
  if(false) {
    // 重复声明一次函数f
    function f() { console.log('I am inside!'); }
  }

  f();
}());
```
上面代码在ES5中运行，会得到“I am inside!”，但是在ES6中运行，会得到“I am outside!”。这是因为ES5存在函数提升，不管会不会进入if代码块，函数声明都会提升到当前作用域的顶部，得到执行；而ES6支持块级作用域，不管会不会进入if代码块，其内部声明的函数皆不会影响到作用域的外部。

需要注意的是，如果在严格模式下，函数只能在顶层作用域和函数内声明，其他情况（比如if代码块、循环代码块）的声明都会报错。

## 垃圾收集
### 标记清除
JavaScript 中最常用的垃圾收集方式是标记清除（mark-and-sweep）。

### 引用计数
另一种不太常见的垃圾收集策略叫做引用计数（reference counting）。

IE中的COM对象的垃圾收集机制采用的就是引用计数策略，只要在IE中涉及COM对象，就会存在循环引用的问题

循环引用指的是对象A中包含一个指向对象B的指针，而对象B中也包含一个指向对象A的引用。即使A、B不再被使用，但是由于其引用计数不为0，并不会被释放。

IE9把BOM和DOM对象都转换成了真正的JavaScript对象。

### 性能问题
垃圾收集器是周期性运行的，而且如果为变量分配的内存数量很可观，那么回收工作量也是相当大的。

### 管理内存
一旦数据不再有用，最好通过将其值设置为 null 来释放其引用——这个做法叫做解除引用（dereferencing）。这一做法适用于大多数全局变量和全局对象的属性。局部变量会在它们离开执行环境时自动被解除引用
