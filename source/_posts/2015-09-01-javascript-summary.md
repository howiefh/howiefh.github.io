title: JavaScript 总结
date: 2015-09-01 10:22:17
tags: JavaScript
categories: JavaScript
description: JavaScript 总结，涉及变量，数据类型，操作符，语句，函数，模块，错误处理，垃圾回收，面向对象编程，原生类型，异步编程；声明提升，typeof，对象的类定义，undefined & null，类型转换，Symbol，Number，模板字符串，标签模板，ES6中的`...`，解构赋值，for-in，with，for-of，函数声明和表达式，arguments，this，函数返回值，默认参数，rest参数，扩展运算符，箭头函数，Generator函数，尾调用优化，作用域，闭包，对象，继承，Object，Array，Date，RegExp，Function，Boolean，Number，String，Global，Math，Map，WeakMap，Set，WeakSet，Proxy，Reflect，Promise，回调函数，async函数；属性类型，对象使用和属性，原型，创建对象，class，共享变量，静态变量，私有变量，静态私有变量，模块模式，增强的模块模式，原型链，继承方法，extends
---
这篇是对前面[JavaScript 基本语法](2015/08/28/javascript-grammar/)，[JavaScript 引用类型](2015/08/28/javascript-reference-type/)，[JavaScript 面向对象程序设计、函数表达式和异步编程](2015/08/28/javascript-oop-function-expression-and-async/)三篇笔记的总结。

<!-- more -->
# 变量
有三个关键字可以用于声明变量：var,let,const。后面两个是ES6新加的。如果没有使用任何关键字，变量是全局变量（不推荐）。

var 声明的变量会被提升到当前作用域的最前面，它的作用域范围也就是当前作用域，即使它是在语句块中声明。

let、const 声明的变量会绑定当前语句块（暂时性死区，temporal dead zone，简称TDZ），被声明之后才可以使用。只在声明所在的块级作用域内有效；不存在“变量提升“现象，只能在声明的位置后面使用；也不可重复声明。不同的是const声明之后不可变，如果声明的是对象，不能再指向另一个对象，但是对象属性可以变。使用Object.freeze方法可以使对象属性也不可变。

```javascript
var a = 0;
function foo(){
  //if中的声明语句会被提升到这里
  //var a;
  if(false) {
    var a = 1;
  }
  a = 10;
  console.log(a);//10
}
function bar(){
  {
    console.log(b); //ReferenceError: can't access lexical declaration `b' before initialization
    let b = 2;
  }
  console.log(b); //ReferenceError: b is not defined
}
function baz(){
  {
    const c = 2;
  }
  console.log(c); //ReferenceError: c is not defined
}
```

ES6规定，var和function声明的全局变量，属于全局对象的属性；let命令、const命令、class命令声明的全局变量，不属于全局对象的属性。

## 声明提升
var 声明的变量，function声明的函数会被提升到当前作用域顶端。只有声明才会提升，表达式不会。

# 数据类型
共有七种数据类型：Undefined, Null, Boolean, String, Symbol, Number和Object.

前六种是简单（基本）数据类型，其中Boolean, String, Number有基本包装类型，每当读取一个基本类型值的时候，后台就会创建一个对应的基本包装类型的对象

ES6新加了Symbol类型，是一种特殊的、不可变的数据类型，可以作为对象属性的标识符使用。

## typeof

* “undefined” 如果这个值未定义
* “boolean” 如果这个值是布尔值
* “string” 如果这个值是字符串
* “number” 如果这个值是数值
* “object” 如果这个值是对象或者null
* “function” 如果这个值是函数
* “symbol” 如果这个值是Symbol类型（ES6新增）

实际上JavaScript中函数也是对象。

大体上来说,基本类型的值应该使用 typeof 来检测,而对象的值则应该使用 instanceof 来检测。

## 对象的类定义
JavaScript 标准文档只给出了一种获取 [[Class]] 值的方法，那就是使用 Object.prototype.toString。

```javascript
function is(type, obj) {
    var clas = Object.prototype.toString.call(obj).slice(8, -1);
    return obj !== undefined && obj !== null && clas === type;
}
is('String', 'test'); // true
is('String', new String('test')); // true
```
上面例子中，Object.prototype.toString 方法被调用，this 被设置为了需要获取 [[Class]] 值的对象。

Object.prototype.toString 返回一种标准格式字符串，所以上例可以通过 slice 截取指定位置的字符串，如下所示：
```javascript
Object.prototype.toString.call([])    // "[object Array]"
Object.prototype.toString.call({})    // "[object Object]"
Object.prototype.toString.call(2)    // "[object Number]"
```

## undefined & null
这两种类型分别都只有一个值，分别是undefined和null。

未声明的变量或声明后没有初始化的变量都是undefined的，typeof会返回undefined。全局变量中有undefined变量，其值也是undefined。函数中没有定义return或return没有显示返回任何内容时返回值会是undefined。函数参数没有显示传递值也会是undefined。

null 值表示一个空对象指针，而这也正是使用 typeof 操作符检测 null 值时会返回”object”的原因

实际上，undefined值是派生自null值的，`null == undefined`将会返回true。

## 类型转换
在使用相等(==)和不相等(!=)操作符,或者在 if 、 for 及 while 等流控制语句中使用非布尔值时, 最常发生类型转换。避免隐式类型转换，可能会带来不期望的结果。尽量使用`===`,`!==`替代`==`,`!=`。

最好是使用显示类型转换，如下
```javascript
//转为数值
var n1 = +'123'; //123 和下面等效
var n2 = Number('123'); //123
var n3 = parseInt('123.3blue'); //123
var n4 = parseInt('blue123'); //NaN
var n5 = parseInt('0123.23', 8); //83
var n6 = parseFloat('123.23.12blue'); //123.23
//转为字符串
var s1 = '' + 123; //"123" 和下面等效
var s2 = String(123);//"123"
//转为布尔值
var b1 = !!'123';//true 和下面等效
var b3 = Boolean('123');//true
```
技巧
```javascript
'' + 10 === '10'; // true
+'10' === 10; // true
!!'foo';   // true
```
内置类型（比如 Number 和 String）的构造函数在被调用时，使用或者不使用 new 的结果完全不同。

```javascript
new Number(10) === 10;     // false, 对象与数字的比较
Number(10) === 10;         // true, 数字与数字的比较
new Number(10) + 0 === 10; // true, 由于隐式的类型转换
```

布尔类型转换规则

数据类型  | 转换为true的值           | 转换为false的值
---       | ---                      | ---
Boolean   | true                     | false
String    | 非空字符串               | ""
Number    | 非零数字值（包括无穷大） | 0和NaN
Object    | 任何对象                 | null
Undefined | n/a（不适用）            | undefined

## Symbol
Symbol，表示独一无二的值。对象的属性名现在可以有两种类型，一种是原来就有的字符串，另一种就是新增的Symbol类型。凡是属性名属于Symbol类型，就都是独一无二的，可以保证不会与其他属性名产生冲突。

Symbol 不可以使用new关键字，Symbol函数可以接受字符串参数使其返回值容易被区分，只是作为描述，即使参数相同Symbol函数返回值也不等。

Symbol值作为对象属性名时，不能用点运算符。同理，在对象的内部，使用Symbol值定义属性时，Symbol值必须放在方括号之中。

Symbol作为属性名，该属性不会出现在for…in、for…of循环中，也不会被Object.keys()、Object.getOwnPropertyNames()返回。但是，它也不是私有属性，有一个Object.getOwnPropertySymbols方法，可以获取指定对象的所有Symbol属性名。

Symbol.for方法接受一个字符串作为参数，然后搜索有没有以该参数作为名称的Symbol值。如果有，就返回这个Symbol值，否则就新建并返回一个以该字符串为名称的Symbol值。注意，Symbol函数是总是返回新的值。

Symbol.keyFor方法返回一个已登记的Symbol类型值的key。

```javascript
var a = Symbol('foo');
var b = Symbol('foo');
var s1 = Symbol.for('foo');
var s2 = Symbol.for('foo');
s1 === s2 // true
a === b // false

a === s2 // false
Symbol.keyFor(s1) // "foo"
Symbol.keyFor(a) // undefined
```
除了定义自己使用的Symbol值以外，ES6还提供一些内置的Symbol值：对象的Symbol.hasInstance属性，对象的Symbol.iterator属性等等。

## Number
最小数值和最大数值分别为Number.MIN_VALUE，Number.MAX_VALUE

NaN，即非数值（Not a Number）是一个特殊的数值，这个数值用于表示一个本来要返回数值的操作数未返回数值的情况（这样就不会抛出错误了）。例如，在其他编程语言中，任何数值除以0都会导致错误，从而停止代码执行。但在ECMAScript中，0除以0会返回NaN，正数除以0返回Infinity，负数除以0返回-Infinity，因此不会影响其他代码的执行。 NaN本身有两个非同寻常的特点。首先，任何涉及 NaN 的操作（例如 NaN/10）都会返回 NaN，这个特点在多步计算中有可能导致问题。其次，NaN与任何值都不相等，包括NaN本身

ES6提供了二进制和八进制数值的新的写法，分别用前缀0b和0o表示。

## 模板字符串
模板字符串（template string）是增强版的字符串，用反引号（\`）标识。它可以当作普通字符串使用，也可以用来定义多行字符串，或者在字符串中嵌入变量。模板字符串中嵌入变量，需要将变量名写在`${}`之中。
```javascript
// 普通字符串
`In JavaScript '\n' is a line-feed.`
// 多行字符串
`In JavaScript this is
 not legal.`
console.log(`string text line 1
string text line 2`);
// 字符串中嵌入变量
var name = "Bob", time = "today";
console.log(`\`Hello ${name}, how are you ${time}?\`
${'Mr. ' + name}
`);
```

## 标签模板
模板字符串的功能，不仅仅是上面这些。它可以紧跟在一个函数名后面，该函数将被调用来处理这个模板字符串。这被称为“标签模板”功能（tagged template）。

函数tag依次会接收到多个参数。
```javascript
function tag(stringArr, ...values){ // ...  }
```
tag函数的第一个参数是一个数组，该数组的成员是模板字符串中那些没有变量替换的部分，也就是说，变量替换只发生在数组的第一个成员与第二个成员之间、第二个成员与第三个成员之间，以此类推。

tag函数的其他参数，都是模板字符串各个变量被替换后的值。由于本例中，模板字符串含有两个变量，因此tag会接受到value1和value2两个参数。

tag函数所有参数的实际值如下。

* 第一个参数：['Hello ', ' world ', '']
* 第二个参数: 15
* 第三个参数：50

```javascript
String.raw`Hi\n${2+3}!`; // "Hi\\n5!"

String.raw`Hi\u000A!`; // 'Hi\\u000A!'

String.raw({ raw: 'test' }, 0, 1, 2); // 't0e1s2t'
```

# 操作符
ECMAScript 操作符的与众不同之处在于，它们能够适用于很多值，例如字符串、数字值、布尔值，甚至对象。不过，在应用于对象时，相应的操作符通常都会调用对象的valueOf()和（或）toString()方法，以便取得可以操作的值。

* 一元操作符(`++,--,+,-`)
    在对非数值应用一元加操作符时，该操作符会像Number()转型函数一样对这个值执行转换。如`+'10' === 10 //true`
* 位操作符(`~,&,|,^,<<,>>,>>>`)
    ECMAScript中的所有数值都以IEEE-754 64位格式存储，但位操作符并不直接操作64位的值。而是先将64位的值转换成32位的整数，然后执行操作，最后再将结果转换回64位。对于开发人员来说，由于64位存储格式是透明的，因此整个过程就像是只存在32位的整数一样。但这个转换过程也导致了一个严重的副效应，即在对特殊的NaN和Infinity值应用位操作时，这两个值都会被当成0来处理

    默认情况下，ECMAScript 中的所有整数都是有符号整数
* 布尔操作符(`!,&&,||`)
    非操作符对于非布尔值会先将其转换为布尔值在计算。

    与、或操作符，对于非布尔值，可以理解为先将其转为布尔值在计算，但是返回值仍旧是原值而不是转换后的布尔值。如`null && 1`可以理解为`false && true`。由于短路效应，第一个操作数是false那么就直接将第一个操作数返回，即返回null。再比如`NaN || obj`可以理解为`false || true`，短路效应要到表达式的值就是第二个操作数的值，即obj。
* 乘性操作符(`*,/,%`)
    在操作数为非数值的情况下会执行自动的类型转换。如果参与乘性计算的某个操作数不是数值，后台会先使用Number()转型函数将其转换为数值。也就是说，空字符串将被当作0，布尔值true将被当作1。

    注意`0 * Infinity = NaN`， `Infinity / Infinity = NaN`， `0 / 0 = NaN`， `Infinity % 有限大的数值 = NaN`， `有限大的数值 % 0= NaN`， `Infinity % Infinity = NaN`
* 加性操作符(`+,-`)
    `+` 如果有操作数是字符串会拼接字符串。拼接时其他类型调用toString()方法

    注意`Infinity + (-Infinity) = NaN`， `Infinity -Infinity = NaN`， `-Infinity -(-Infinity) = NaN`

    减法，如果有一个操作数是字符串、布尔值、null或undefined，则先在后台调用Number()函数将其转换为数值，然后再根据前面的规则执行减法计算。如果转换的结果是NaN，则减法的结果就是NaN；如果有一个操作数是对象，则调用对象的valueOf()方法以取得表示该对象的数值。如果得到的值是NaN，则减法的结果就是NaN。如果对象没有valueOf()方法，则调用其toString()方法并将得到的字符串转换为数值。
* 关系操作符(`>,<,>=,<=`)
    对于字符串实际比较的是两个字符串中对应位置的每个字符的字符编码值

    如果一个操作数是布尔值，则先将其转换为数值，然后再执行比较。
* 相等操作符(`===,!==,==,!=`)
    `==,!=` 比较规则

    * 如果有一个操作数是布尔值，则在比较相等性之前先将其转换为数值——false转换为0，而true转换为1；
    * 如果一个操作数是字符串，另一个操作数是数值，在比较相等性之前先将字符串转换为数值；
    * 如果一个操作数是对象，另一个操作数不是，则调用对象的valueOf()方法，用得到的基本类型值按照前面的规则进行比较； 这两个操作符在进行比较时则要遵循下列规则。
    * null和undefined是相等的。
    * 要比较相等性之前，不能将null和undefined转换成其他任何值。
    * 如果有一个操作数是NaN，则相等操作符返回false，而不相等操作符返回true。重要提示：即使两个操作数都是NaN，相等操作符也返回false；因为按照规则，NaN不等于NaN。
    * 如果两个操作数都是对象，则比较它们是不是同一个对象。如果两个操作数都指向同一个对象，则相等操作符返回true；否则，返回false。
* 条件操作符(`boolean_expression?true_value:false_value`)
* 逗号操作符(`,`)
* 赋值操作符(`=以及*=、+=等复合赋值运算符`)

## ES6中的`...`
rest参数可以在函数参数和解构时使用，`...`后面的变量是一个数组，可以将一个序列存入这个数组。

扩展操作符可以看作rest参数的逆操作，可以将一个数组转变为一个序列，可以在函数调用和解构时使用。

```javascript
function foo(...a){}
foo(...[1,2,4]);
var [...a] = [1,2,4]; // a = [1,2,4]
var [a] = [...[1,2]]; // a = 1
```

## 解构赋值
ECMAScript6允许按照一定模式，从数组和对象中提取值，对变量进行赋值，这被称为解构（Destructuring）。

```javascript
var [a, b, c] = [1, 2, 3]; // a即为1，b为2，c为3
var [,,third] = ["foo", "bar", "baz"];//third为"baz"
var [head, ...tail] = [1, 2, 3, 4]; //head为1，tail为[2,3,4]
var [foo, [[bar], baz]] = [1, [[2], 3]];
var [x = 1] = [undefined];// x = 1
var [x = 1] = [null]; //x = null
```
实际赋值操作符右边只要是实现了Iterable接口的对象就行，所以Set、Map、Generator函数的返回值都可以。
```javascript
var set = new Set().add('a').add('b');
var [a, b] = set; //a = "a",b = "b"
```
解构不仅可以用于数组，还可以用于对象。对象的解构与数组有一个重要的不同。数组的元素是按次序排列的，变量的取值由它的位置决定；而对象的属性没有次序，变量必须与属性同名，才能取到正确的值。
```javascript
var { bar, foo } = { foo: "aaa", bar: "bbb" };//bar = "bbb", foo = "aaa"
var { baz } = { foo: "aaa", bar: "bbb" }; //baz = undefined
var obj = {
  p: [
    "Hello",
    { y: "World" }
  ]
};
var { p: [x, { y }] } = obj; //x = "Hello", y = "World"
//默认值生效的条件是，对象的属性值严格等于undefined。
var {x = 3} = {x: undefined}; //x = 3
var {x = 3} = {x: null}; //x = null
```

如果左边变量名和右边属性名不一致
```javascript
var { foo: baz } = { foo: "aaa", bar: "bbb" }; //baz = "aaa"
```
如果要将一个已经声明的变量用于解构赋值，必须非常小心。
```javascript
// 错误的写法
var x;
{x} = {x:1}; // SyntaxError: syntax error
```

上面代码的写法会报错，因为JavaScript引擎会将{x}理解成一个代码块，从而发生语法错误。只有不将大括号写在行首，避免JavaScript将其解释为代码块，才能解决这个问题。
```javascript
// 正确的写法
({x} = {x:1});
```
对象的解构赋值，可以很方便地将现有对象的方法，赋值到某个变量。
```javascript
let { log, sin, cos } = Math;
```
函数参数也可以使用解构。
```javascript
function move({x = 0, y = 0} = {}) {
  return [x, y];
}
move({x: 3, y: 8}); // [3, 8]
move({x: 3}); // [3, 0]
move({}); // [0, 0]
move(); // [0, 0]
```

解构的主要应用

1）交换变量的值
```javascript
[x, y] = [y, x];
```
2）从函数返回多个值
```javascript
// 返回一个数组
function example() {
  return [1, 2, 3];
}
var [a, b, c] = example(); //a = 1, b = 2, c = 3
```
3）函数参数的定义
```javascript
// 参数是一组无次序的值
function f({x, y, z}) { ... }
f({x:1, y:2, z:3})
```
4）提取JSON数据
```javascript
var jsonData = {
  id: 42,
  data: [867, 5309]
}
let { id, data: number } = jsonData;
console.log(id, number) // 42, [867, 5309]
```
5）函数参数的默认值
```javascript
jQuery.ajax = function (url, {
  async = true,
  beforeSend = function () {},
  cache = true,
  // ... more config
}) {
  // ... do stuff
};
```
6）遍历Map结构
```javascript
var map = new Map()
    .set('first', 'hello')
    .set('second', 'world');

for (let [key, value] of map) {
  console.log(key + " is " + value);
}
// 获取键名
for (let [key] of map) { // ...  }
// 获取键值
for (let [,value] of map) { // ...  }
```
7）输入模块的指定方法
```javascript
const { SourceMapConsumer, SourceNode } = require("source-map");
```

# 语句
ECMAScript 中的语句以一个分号结尾;如果省略分号,则由解析器确定语句的结尾，为了避免自动插入都好改变代码行为，最好加上分号。
```javascript
return //直接返回了
 {}
```

if, do-while,while,for,label,break,continue,switch和Java没有太大差别。

switch语句在比较值时使用的是全等操作符，因此不会发生类型转换（例如，字符串"10"不等于数值10）。

首先，可以在switch语句中使用任何数据类型（在很多其他语言中只能使用数值），无论是字符串，还是对象都没有问题。其次，每个case的值不一定是常量，可以是变量，甚至是表达式。

## for-in
for-in 语句是一种精准的迭代语句,可以用来枚举对象的属性（包括原型链上的属性）。对于数组则是遍历下标

## with
由于大量使用with语句会导致性能下降，同时也会给调试代码造成困难，因此在开发大型应用程序时，不建议使用with语句。
```javascript
with(location){
    var qs = search.substring(1);
    var hostName = hostname;
    var url = href;
}
```javascript
使用with 语句关联了location 对象。这意味着在with 语句的代码块内部，每个变量首先被认为是一个局部变量，而如果在局部环境中找不到该变量的定义，就会查询location对象中是否有同名的属性。如果发现了同名属性，则以location对象属性的值作为变量的值。 严格模式下不允许使用with语句，否则将视为语法错误

## for-of
实现了Iterable接口的对象都可以用于for-of循环。for-of循环可以使用的范围包括数组、Set和Map结构及其entries,values,keys方法返回的对象、某些类似数组的对象（比如arguments对象、DOM NodeList对象）、Generator函数返回的对象，以及字符串。

并不是所有类似数组的对象都具有iterator接口，一个简便的解决方法，就是使用Array.from方法将其转为数组。
```javascript
let arrayLike = { length: 2, 0: 'a', 1: 'b' };
Array.from(arrayLike);
```
通过for-of遍历对象，一种解决方法是，使用`Object.keys`方法将对象的键名生成一个数组，然后遍历这个数组。
```javascript
for (var key of Object.keys(someObject)) {
  console.log(key + ": " + someObject[key]);
}
```
另一个方法是使用Generator函数将对象重新包装一下。

# 函数
ECMAScript中最有意思的可能是函数了，函数实际上是对象。每个函数都是Function类型的实例，而且都与其他引用类型一样具有属性和方法。**由于函数是对象，因此函数名实际上也是一个指向函数对象的指针，不会与某个函数绑定**。

创建一个函数，在创建Funciton类型实例的同时还会创建一个原型对象，函数变量的prototype属性指向该原型对象。

## 函数声明和表达式
函数通常是使用函数声明语法定义的。
```javascript
function sum (num1, num2) {
  return num1 + num2;
}
```
下面是使用函数表达式定义函数的方式，和上面效果是一样的。
```javascript
var sum = function(num1, num2){
  return num1 + num2;
};
```
需要注意的下面这样声明函数，add只能在函数内部使用。
```javascript
var sum = function add(num1, num2){
  return num1 + num2;
};
```
最后一种定义函数的方式是使用Function构造函数。Function构造函数可以接收任意数量的参数，但最后一个参数始终都被看成是函数体，而前面的参数则枚举出了新函数的参数。
```javascript
var sum = new Function("num1", "num2", "return num1 + num2"); // 不推荐，因为这种语法会导致解析两次代码(第一次是解析常规 ECMAScript 代码,第二次是解析传入构造函数中的字符串)
```
在函数名后加圆括号就是调用函数，不加就只是一个函数指针。所以也可以像下面这样定义一个函数就直接调用。
```javascript
(function(){
})();
```
匿名函数被认为是表达式；因此为了可调用性，它们首先会被执行。

有一些其他的调用函数表达式的方法，比如下面的两种方式语法不同，但是效果一模一样。

```javascript
// 另外两种方式
+function(){}();
(function(){}());
```
这种立即执行的匿名函数可以用来解决只有一个全局作用域导致的常见错误是命名冲突。

## 没有重载
将函数名想象为指针，也有助于理解为什么 ECMAScript中没有函数重载的概念。在创建第二个同名函数时,实际上覆盖了引用第一个函数的函数名变量。

## 作为值的函数
因为 ECMAScript中的函数名本身就是变量，所以函数也可以作为值来使用。也就是说，不仅可以像传递参数一样把一个函数传递给另一个函数，而且可以将一个函数作为另一个函数的结果返回

## arguments
函数内部的arguments是一个类数组对象，包含着传入函数中的所有参数。虽然 arguments 的主要用途是保存函数参数，但是arguments存储的参数和形式参数存储的变量空间是独立的。arguments 对象为其内部属性以及函数形式参数创建 getter 和 setter 方法。因此，改变形参的值会影响到 arguments 对象的值，反之亦然。严格模式下不允许创建这些getter和setter，所以两者值互不影响。

```javascript
function test(num1, num2) {
    'use strict';
    num1 = 11;
    console.log(arguments[0]);
}
```

## this
函数内部的另一个特殊对象是 this ,其行为与 Java 中的 this 大致类似。this引用的是执行函数的环境对象（当在网页的全局作用域中调用函数时，this对象引用的就是window）。

全局范围内使用this，它指向全局对象
```javascript
this //浏览器里就是window
foo() //这种函数调用中的this也是全局对象，如果在严格模式下将是undefined
test.foo(); //this指向test对象
new foo();  //this指向新创建的对象
```
还可以显示设置this
```javascript
function foo(a, b, c) {}

var bar = {};
//在foo 函数内 this 被设置成了 bar。
foo.apply(bar, [1, 2, 3]); // 数组将会被扩展，如下所示
foo.call(bar, 1, 2, 3); // 传递到foo的参数是：a = 1, b = 2, c = 3
```
常见误解
```javascript
Foo.method = function() {
    function test() { //this将是全局对象，严格模式是undefined}
    test();
}
```
很容易认为test方法中的this是Foo，但是并不是，这里test符合的是函数调用的情况，this将是全局对象，严格模式是undefined

为什么内部函数（test）没有取得其包含作用域(或外部作用域)的 this 对象呢? 每个函数在被调用时都会自动取得两个特殊变量: this 和 arguments 。内部函数在搜索这两个变量时,只会搜索到其活动对象（当前函数test的作用域）为止,因此永远不可能直接访问外部函数中的这两个变量。不过,可以把外部作用域中的 this 对象保存在一个闭包能够访问到的变量里。像下面这样使用。
```javascript
Foo.method = function() {
    var that = this;
    function test() { //that}
    test();
}
```
另一个例子，test 就像一个普通的函数被调用；因此，函数内的 this 将不再被指向到 someObject 对象。
```javascript
var test = someObject.methodTest;
test();
```
虽然 this 的晚绑定特性似乎并不友好，但这确实是基于原型继承赖以生存的土壤。

```javascript
function Foo() {}
Foo.prototype.method = function() {};
function Bar() {}
Bar.prototype = Foo.prototype;
new Bar().method();
```
当 method 被调用时，this 将会指向 Bar 的实例对象。

## 返回值
没有return，或者return不带任何返回值，都会返回undefined值。

## 默认参数
ES6允许为函数的参数设置默认值，即直接写在参数定义的后面。

定义了默认值的参数，必须是函数的尾部参数，其后不能再有其他无默认值的参数。

甚至还可以设置双重默认值。
```javascript
function fetch(url, { method = 'GET' } = {}){
  console.log(method);
}
```
上面代码中，调用函数fetch时，如果不含第二个参数，则默认值为一个空对象；如果包含第二个参数，则它的method属性默认值为GET。

如果传入undefined，将触发该参数等于默认值，null则没有这个效果。

注意，参数默认值所处的作用域，不是全局作用域，而是函数作用域。
```javascript
var x = 1;
function foo(x, y = x) {
  console.log(y);
}
foo(2) // 2
```

## rest参数
rest参数之后不能再有其他参数（即只能是最后一个参数），否则会报错。

函数的length属性，不包括rest参数。
```javascript
(function(a, ...b) {}).length  // 1
```

## 扩展运算符
将一个数组（只要实现了Iterable接口的对象即可）转为用逗号分隔的参数序列，该运算符主要用于函数调用
```javascript
Math.max(...[14, 3, 77])
```

## 箭头函数
ES6允许使用“箭头”（=>）定义函数（和Java8中lambda表达式有点类似）
```javascript
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
```javascript
// 正常函数写法
[1,2,3].map(function (x) {
  return x * x;
});
// 箭头函数写法
[1,2,3].map(x => x * x);
```

箭头函数有几个使用注意点。
* 函数体内的this对象，绑定定义时所在的对象，而不是使用时所在的对象。
* 不可以当作构造函数，也就是说，不可以使用new命令，否则会抛出一个错误。
* 不可以使用arguments对象，该对象在函数体内不存在。
* 不可以使用yield命令，因此箭头函数不能用作Generator函数。

```javascript
var obj = {
  length: 1,
  doSomeThing(){
    console.log([1,2,3].map(x => x*this.length));
  }
}
obj.doSomeThing();//[1,2,3]
```
如果不是使用箭头函数，得到结果是不一样的，如下例，下面this就是window
```javascript
var obj = {
  length:1,
  doSomeThing(){
    console.log([1,2,3].map(function(x){
      return this.length * x;
    }));
  }
}
obj.doSomeThing();//[0,0,0]
```
箭头函数还有可以嵌套

## Generator 函数
Generator函数是ES6提供的一种异步编程解决方案，语法行为与传统函数完全不同。

Generator函数是一个普通函数，但是有几个特征。一是，function命令与函数名之间有一个星号；二是，可以像调用普通函数一样调用Generator函数，但是返回的结果并不是函数返回值，而是一个实现了Iterable和Iterator接口的对象（该对象的Symbol.iterator方法返回其自身）；三是，函数体内部使用yield语句，每调用Generator函数返回值的next方法，就会到达下一个yield语句，同时将yield语句后面的表达式求值后作为返回结果的value属性（yield语句在英语里的意思就是“产出”）；四是，函数体内也可以有`yield*`，其后面须是一个Iterable对象；五是，Generator函数返回值的next方法可以有参数，参数将作为函数体内上一个yield语句的值。

```javascript
function* gen(tree) {
  var x = yield 123+234;
  yield x;
  return 123;
}
var it = gen();
it[Symbol.iterator]() === it // true
it.next();
it.next('a');
it.next();
```
一个稍复杂的例子，取出嵌套数组的所有成员
```javascript
// 下面是二叉树的构造函数，三个参数分别是左树、当前节点和右树
function Tree(left, label, right) {
  this.left = left;
  this.label = label;
  this.right = right;
}

// 下面是中序（inorder）遍历函数。
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
result // ['a', 'b', 'c', 'd', 'e', 'f', 'g']
```
Generator函数还有一个特点，它可以在函数体外通过返回的Iterator对象的throw方法抛出错误，然后在函数体内捕获。

一个对象的属性可以是Generator函数
```javascript
var obj = { * gen(){} };
var obj = { gen: function* (){} };
```

## 尾调用优化
尾调用（Tail Call）是函数式编程的一个重要概念，就是指某个函数的最后一步是调用另一个函数。
```javascript
function f(x){
  return g(x);
}

//上面是尾调用，下面三种情况都不是尾调用
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
```javascript
function f(x){
  g(x);
  return undefined;
}
```
尾调用不一定出现在函数尾部，只要是最后一步操作即可。
```javascript
function f(x) {//函数m和n都属于尾调用
  if (x > 0) {
    return m(x)
  }
  return n(x);
}
```
我们知道，函数调用会在内存形成一个“调用记录”，又称“调用帧”（call frame），保存调用位置和内部变量等信息。如果在函数A的内部调用函数B，那么在A的调用帧上方，还会形成一个B的调用帧。等到B运行结束，将结果返回到A，B的调用帧才会消失。如果函数B内部还调用函数C，那就还有一个C的调用帧，以此类推。所有的调用帧，就形成一个“调用栈”（call stack）。

尾调用由于是函数的最后一步操作，所以不需要保留外层函数的调用帧，因为调用位置、内部变量等信息都不会再用到了，只要直接用内层函数的调用帧，取代外层函数的调用帧就可以了。

“尾调用优化”（Tail call optimization），即只保留内层函数的调用帧。如果所有函数都是尾调用，那么完全可以做到每次执行时，调用帧只有一项，这将大大节省内存。这就是“尾调用优化”的意义。

注意，只有不再用到外层函数的内部变量，内层函数的调用帧才会取代外层函数的调用帧，否则就无法进行“尾调用优化”。
```javascript
function addOne(a){
  var one = 1;
  function inner(b){
    return b + one;
  }
  return inner(a);
}
```
上面的函数不会进行尾调用优化，因为内层函数inner用到了，外层函数addOne的内部变量one。

尾递归的实现，往往需要改写递归函数，确保最后一步只调用自身。做到这一点的方法，就是把所有用到的内部变量改写成函数的参数。

## 作用域
标识符解析是沿着作用域链一级一级地搜索标识符的过程。搜索过程始终从作用域链的前端开始，然后逐级地向后回溯，直至找到标识符为止（如果找不到标识符，通常会导致错误发生）。

执行环境定义了变量或函数有权访问的其他数据，决定了它们各自的行为。每个执行环境都有一个与之关联的变量对象（variable object），环境中定义的所有变量和函数都保存在这个对象中。虽然我们编写的代码无法访问这个对象，但解析器在处理数据时会在后台使用它。 全局执行环境是最外围的一个执行环境。根据 ECMAScript实现所在的宿主环境不同，表示执行环境的对象也不一样。在Web浏览器中，全局执行环境被认为是 window 对象，因此所有全局变量和函数都是作为window对象的属性和方法创建的。某个执行环境中的所有代码执行完毕后，该环境被销毁，保存在其中的所有变量和函数定义也随之销毁（全局执行环境直到应用程序退出——例如关闭网页或浏览器——时才会被销毁）。 每个函数都有自己的执行环境。当执行流进入一个函数时，函数的环境就会被推入一个环境栈中。而在函数执行之后，栈将其环境弹出，把控制权返回给之前的执行环境。ECMAScript 程序中的执行流正是由这个方便的机制控制着。 当代码在一个环境中执行时，会创建变量对象的一个作用域链（scope chain）。作用域链的用途，是保证对执行环境有权访问的所有变量和函数的有序访问。作用域链的前端，始终都是当前执行的代码所在环境的变量对象。如果这个环境是函数，则将其活动对象（activation object）作为变量对象。活动对象在最开始时只包含一个变量，即arguments对象（这个对象在全局环境中是不存在的）。作用域链中的下一个变量对象来自包含（外部）环境，而再下一个变量对象则来自下一个包含环境。这样，一直延续到全局执行环境；全局执行环境的变量对象始终都是作用域链中的最后一个对象。

内部环境可以通过作用域链访问所有的外部环境，但外部环境不能访问内部环境中的任何变量和函数。这些环境之间的联系是线性、有次序的。每个环境都可以向上搜索作用域链，以查询变量和函数名；但任何环境都不能通过向下搜索作用域链而进入另一个执行环境。
```javascript
function compare(value1, value2){
    if (value1 < value2){
        return -1;
    } else if (value1 > value2){
        return 1;
    } else {
        return 0;
    }
}
var result = compare(5, 10);
```
当调用 compare() 时,会创建一个包含 arguments 、 value1 和 value2 的活动对象。全局执行环境的变量对象(包含 result和 compare )在 compare() 执行环境的作用域链中则处于第二位。

```
+----------------------+
|     compare          |
|  execution context   |<-------------------------------------------------+
+----------------------+    +------------+      +----------------------+  |
|(scope chain) |      -|--->|scope chain |  +-->|global variable object|  |
+----------------------+    +------------+  |   +----------------------+  |
                            |1     |    -|--+   |   compare |         -|--+
                            +------------+      +----------------------+
                            |0     |    -|--+   |   result  | undefined|
                            +------------+  |   +----------------------+
                                            |
                                            |   +----------------------+
                                            +-->|    compare()         |
                                                |  activation object   |
                                                +----------------------+
                                                | arguments |  [5,10]  |
                                                +----------------------+
                                                |   value1  |  5       |
                                                +----------------------+
                                                |   value2  |  10      |
                                                +----------------------+
```
每个执行环境都有一个表示变量的对象——变量对象。全局环境的变量对象始终存在,而像compare() 函数这样的局部环境的变量对象,则只在函数执行的过程中存在。在创建 compare() 函数时,会创建一个预先包含全局变量对象的作用域链,这个作用域链被保存在内部的 [[Scope]] 属性中。当调用 compare() 函数时,会为函数创建一个执行环境,然后通过复制函数的 [[Scope]] 属性中的对象构建起执行环境的作用域链。此后,又有一个活动对象(在此作为变量对象使用)被创建并被推入执行环境作用域链的前端。对于这个例子中 compare() 函数的执行环境而言,其作用域链中包含两个变量对象:本地活动对象和全局变量对象。显然,作用域链本质上是一个指向变量对象的指针列表,它只引用但不实际包含变量对象。

无论什么时候在函数中访问一个变量时,就会从作用域链中搜索具有相应名字的变量。一般来讲,当函数执行完毕后,局部活动对象就会被销毁,内存中仅保存全局作用域(全局执行环境的变量对象)。但是,下面要讲的闭包的情况又有所不同。

## 闭包
闭包是指有权访问另一个函数作用域中的变量的函数。创建闭包的常见方式,就是在一个函数内部创建另一个函数
```javascript
function fn(name) {
    return function(){
      return name;
    };
}
var f = fn("Howie");
f();
f = null;
```
即使这个内部函数被返回了,而且是在其他地方被调用了,但它仍然可以访问外部函数的变量 name。之所以还能够访问这个变量,是因为内部函数的作用域链中包含fn() 的作用域。

前面讲的有关如何创建作用域链以及作用域链有什么作用的细节,对彻底理解闭包至关重要。当某个函数被调用时,会创建一个执行环境(execution context)及相应的作用域链。然后,使用 arguments 和其他命名参数的值来初始化函数的活动对象(activation object)。但在作用域链中,外部函数的活动对象始终处于第二位,外部函数的外部函数的活动对象处于第三位,......直至作为作用域链终点的全局执行环境。

fn("Howie") 返回后其活动对象并没有被销毁，因为匿名函数（即被返回的f函数）的作用域链中有对其的引用。通过将 f设置为等于 null解除该函数的引用,就等于通知垃圾回收例程将其清除。随着匿名函数的作用域链被销毁,其他作用域(除了全局作用域)也都可以安全地销毁了。

过度使用闭包可能会导致内存占用过多，只在绝对必要时使用闭包。

作用域链的这种配置机制引出了一个值得注意的副作用,即闭包只能取得包含函数中任何变量的最后一个值。别忘了闭包所保存的是整个变量对象,而不是某个特殊的变量。

```javascript
function createFunctions(){
    var result = new Array();
    for (var i=0; i < 10; i++){
        result[i] = function(){
            return i;
        };
    }
    return result;
}
```

数组中每个函数都只会返回10，而不是0到9。i在createFunctions()的活动变量中，而每个匿名函数的作用域链第二个位置就是createFunctions()的活动变量，当createFunctions()返回后，i的值为10，此时每个函数都引用着保存变量 i 的同一个变量对象,所以在每个函数内部 i 的值都是 10。通过创建另一个匿名函数强制让闭包的行为符合预期

```javascript
function createFunctions(){
    var result = new Array();
    for (var i=0; i < 10; i++){
        result[i] = function(num){
            return function(){
                return num;
            };
        }(i);
    }
    return result;
}
```
ES6中我们还可以使用let关键字声明i，这样i仅在for循环中有效，可以得到同样预期的结果。
```javascript
function createFunctions(){
    var result = new Array();
    for (let i=0; i < 10; i++){
        result[i] = function(){
            return i;
        };
    }
    return result;
}
```

# 模块
ES6中模块功能由三个命令构成：export，import和module。export命令用于用户自定义模块，规定对外接口；import命令用于导入其他模块提供的功能，同时创造命名空间（namespace），防止函数名冲突；module用于整体输入其它模块的提供的功能。

类和模块的内部，默认就是严格模式，所以不需要使用`use strict`指定运行模式。只要你的代码写在类或模块之中，就只有严格模式可用。

```javascript
// profile.js
var name = 'Michael';
var year = 1958;
export {name, year};
// main.js
import {name as nickName, year} from 'profile';
console.log(nickName);
```
import花括号里面的变量名必须与导出的变量名相同，可以通过as起别名。下面是另一个示例
```javascript
export { es6 as default } from './someModule';

// 等同于
import { es6 } from './someModule';
export default es6;
```
如上，如果在一个模块之中，先输入后输出同一个模块，import语句可以与export语句写在一起。最后再看一个示例
```javascript
// circle.js
export var pi = 3.1415926;
// circleplus.js
export * from 'circle';
export var e = 2.71828182846;
export default function(x) {
    return Math.exp(x);
}
// main.js
module math from "circleplus"; //整体导入相当于 import * as math from "circleplus";
import exp from "circleplus"; //导入circleplus中导出的默认方法
console.log(exp(math.e));
```
`export default`命令用于指定模块的默认输出。显然，一个模块只能有一个默认输出，因此`export deault`命令只能使用一次。所以，import命令后面才不用加大括号，因为只可能对应一个方法。

# 错误处理
ECMA-262 定义了下列 7 种错误类型: Error,EvalError,RangeError,ReferenceError,SyntaxError,TypeError,URIError。可以通过继承这些类型自定义错误类型。

内置的Error对象具有两个标准属性name和message

* **name**：错误名称
* **message**：错误提示信息
* **stack**：错误的堆栈（非标准属性，但是大多数平台支持）

```javascript
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

必须要给 throw 操作符指定一个值,这个值是什么类型,没有要求。
```javascript
throw 12345;
throw "Hello world!";
throw true;
throw { name: "JavaScript"};
```

任何没有通过 try-catch 处理的错误都会触发 window 对象的 error 事件。

# 垃圾回收
JavaScript 中最常用的垃圾收集方式是标记清除（mark-and-sweep）。

另一种不太常见的垃圾收集策略叫做引用计数（reference counting）。IE中的COM对象的垃圾收集机制采用的就是引用计数策略，只要在IE中涉及COM对象，就会存在循环引用的问题

# 面向对象编程
## 对象
ECMA-262把对象定义为：“无序属性的集合，其属性可以包含基本值、对象或者函数。”严格来讲，这就相当于说对象是一组没有特定顺序的值。对象的每个属性或方法都有一个名字，而每个名字都映射到一个值。正因为这样（以及其他将要讨论的原因），我们可以把ECMAScript的对象想象成散列表：无非就是一组名值对，其中值可以是数据或函数
### 属性类型
ECMAScript 中有两种属性:数据属性和访问器属性。

1. 数据属性
    数据属性包含一个数据值的位置。在这个位置可以读取和写入值。数据属性有4个描述其行为的特性。
    * [[Configurable]]：表示能否通过 delete 删除属性从而重新定义属性，能否修改属性的特性，或者能否把属性修改为访问器属性。像前面例子中那样直接在对象上定义的属性，它们的这个特性默认值为true。
    * [[Enumerable]]：表示能否通过 for-in 循环返回属性。像前面例子中那样直接在对象上定义的属性，它们的这个特性默认值为true。
    * [[Writable]]：表示能否修改属性的值。像前面例子中那样直接在对象上定义的属性，它们的这个特性默认值为true。
    * [[Value]]：包含这个属性的数据值。读取属性值的时候，从这个位置读；写入属性值的时候，把新值保存在这个位置。这个特性的默认值为undefined。
2. 访问器属性
    访问器属性不包含数据值；它们包含一对儿getter和setter函数（不过，这两个函数都不是必需的）。在读取访问器属性时，会调用 getter函数，这个函数负责返回有效的值；在写入访问器属性时，会调用setter函数并传入新值，这个函数负责决定如何处理数据。访问器属性有如下4个特性。
    * [[Configurable]]：表示能否通过 delete 删除属性从而重新定义属性，能否修改属性的特性，或者能否把属性修改为数据属性。对于直接在对象上定义的属性，这个特性的默认值为true。
    * [[Enumerable]]：表示能否通过 for-in 循环返回属性。对于直接在对象上定义的属性，这个特性的默认值为true。
    * [[Get]]：在读取属性时调用的函数。默认值为undefined。
    * [[Set]]：在写入属性时调用的函数。默认值为undefined。

```javascript
Object.defineProperties(book, {
  _year: {
    value: 2004
  },
  edition: {
    value: 1
  },
  year: {
    get: function(){
      return this._year;
    },
    set: function(newValue){
      if (newValue > 2004) {
        this._year = newValue;
        this.edition += newValue - 2004;
      }
    }
  }
});
```
使用 ECMAScript 5的 Object.getOwnPropertyDescriptor()方法，可以取得给定属性的描述符。这个方法接收两个参数：属性所在的对象和要读取其描述符的属性名称。返回值是一个对象，如果是访问器属性，这个对象的属性有configurable、enumerable、get 和set；如果是数据属性，这个对象的属性有configurable、enumerable、writable和value

```javascript
var descriptor = Object.getOwnPropertyDescriptor(book, "_year");
alert(descriptor.value); //2004
```

### 对象使用和属性
一种方式是使用对象字面量表示法。属性名可以是字符串也可以是Symbol类型的数据（后者必须使用方括号包含）
```javascript
var person = {
  name : 'Howie',
  age : 26
};
```
另一种方法是通过构造函数
```javascript
function Person(){
  this.name = 'Howie';
  this.age = 26;
}
var person = new Person();
```
构造函数一般首字母大写，如果构造函数没有参数，使用new时后面的括号也可以省略。

ES6中可以简写
```javascript
var nickname = Symbol.for('nickname');
var type = 'cat';
var animal = { [nickname]:'mimi', type ,'come from':'shan xi'}
```
访问属性
```javascript
animal[nickname]
animal.type
animal['type']
animal['come from']
```
从上例可以看出属性名不是一个有效的变量名（比如属性名中包含空格，或者属性名是 JS 的关键词）

有很多变通方法可以让数字的字面值看起来像对象。
```javascript
2.toString();//出错
2..toString(); // 第二个点号可以正常解析
2 .toString(); // 注意点号前面的空格
(2).toString(); // 2先被计算
```

### 原型
JavaScript中每个函数都是Function类型的实例，每个函数都有一个 prototype（原型）属性，这个属性是一个指针，指向一个函数的原型对象，而这个对象的用途是包含可以由特定类型的**所有实例共享的属性和方法**。如果按照字面意思来理解，那么 prototype 就是通过调用构造函数而创建的那个对象实例的原型对象。使用原型对象的好处是可以让所有对象实例共享它所包含的属性和方法。换句话说，不必在构造函数中定义对象实例的信息，而是可以将这些信息直接添加到原型对象中。

默认情况下，每个原型对象都有一个constructor属性，这个属性指向 prototype 属性所在实例，也就是构造函数。创建了自定义的构造函数之后，其原型对象默认只会取得constructor属性；至于其他方法，则都是从Object继承而来的。每个对象都有[[Prototype]]属性（内部属性），虽然在脚本中没有标准的方式访问[[Prototype]]，但 Firefox、Safari 和 Chrome 在每个对象上都支持一个属性`__proto__`，通过它可以访问[[Prototype]]；这个属性指向了构造函数的原型对象，JavaScript中通过递归原型链来查找对象属性，同一个构造函数创建的对象都可以访问到其原型中的属性constructor。除了通过instanceof外也可以通过person.constructor === Person来判断是否是Person类型，但是instanceof更加可靠，因为prototype对象完全可以被覆盖，其属性constructor也就不一定是Person了。

ECMAScript 5增加了一个新方法，叫 Object.getPrototypeOf()，在所有支持的实现中，这个方法返回[[Prototype]]的值。

每当代码读取某个对象的某个属性时，都会执行一次搜索，目标是具有给定名字的属性。搜索首先从对象实例本身开始。如果在实例中找到了具有给定名字的属性，则返回该属性的值；如果没有找到，则继续搜索指针指向的原型对象，在原型对象中查找具有给定名字的属性。如果在原型对象中找到了这个属性，则返回该属性的值。

虽然可以通过对象实例访问保存在原型中的值，但却不能通过对象实例重写原型中的值。如果我们在实例中添加了一个属性，而该属性与实例原型中的一个属性同名，那我们就在实例中创建该属性，该属性将会屏蔽原型中的那个属性。`person1.name = "Greg";`将会覆盖原型中的name属性。

使用hasOwnProperty()方法可以检测一个属性是存在于实例中，还是存在于原型中。这个方法（不要忘了它是从Object继承来的）只在给定属性存在于对象实例中时，才会返回true。

有两种方式使用in操作符：单独使用和在for-in循环中使用。在单独使用时，in操作符会在通过对象能够访问给定属性时返回true，无论该属性存在于实例中还是原型中。`"name" in person`为true

在使用 for-in 循环时，返回的是所有能够通过对象访问的、可枚举的（enumerated）属性，其中既包括存在于实例中的属性，也包括存在于原型中的属性。屏蔽了原型中不可枚举属性（即将[[Enumerable]]标记为 false 的属性）的实例属性也会在 for-in 循环中返回，因为根据规定，所有开发人员定义的属性都是可枚举的——只有在IE8及更早版本中例外。

要取得对象上所有可枚举的实例属性，可以使用ECMAScript 5的Object.keys()方法。这个方法接收一个对象作为参数，返回一个包含所有可枚举属性的字符串数组。

```javascript
var keys = Object.keys(Person.prototype); //["name","age","jbo","sayName"]
var keys = Object.getOwnPropertyNames(Person.prototype); //["constructor","name","age","jbo","sayName"]
```
### 创建对象
工厂模式、寄生构造函数模式、稳妥构造函数模式都是构造函数（工厂模式中就是普通函数）内部创建一个对象然后返回，通常返回的对象和构造函数没有什么联系。后两者使用new创建对象，工厂模式是直接函数调用。第三种没有公共属性，而且也不引用this的对象。

组合使用构造函数模式和原型模式结合了两者的优点，每个实例都会有自己的一份实例属性的副本，但同时又共享着对方法的引用，最大限度地节省了内存。动态原型模式则在此基础上通过检查某个应该存在的方法是否有效，来决定是否需要初始化原型。

```javascript
function Person(name, age, job){
  this.name = name;
  this.age = age;
  this.job = job;
  //方法
  if (typeof this.sayName != "function"){
    Person.prototype.sayName = function(){
      alert(this.name);
    };
  }
}
```
需要在每个实例共享的属性应该在原型上定义，如方法，如果在this对象上定义，那么每个实例的相同函数名的函数实例实际是不同的，这样就会浪费空间。

### class
ES6提供了更接近传统语言的写法，引入了Class（类）这个概念，作为对象的模板。通过class关键字，可以定义类。基本上，ES6的class可以看作只是一个语法糖，它的绝大部分功能，ES5都可以做到，新的class写法只是让对象原型的写法更加清晰、更像面向对象编程的语法而已。

```javascript
class Person{
  constructor(name, age, job){
    this.name = name;
    this.age = age;
    this.job = job;
  }
  sayName(){
    alert(name);
  }
}
var friend = new Person("Nicholas", 29, "Software Engineer");
```
上面代码定义了一个“类”，可以看到里面有一个constructor方法，这就是构造方法，而this关键字则代表实例对象。注意，定义“类”的方法的时候，前面不需要加上function这个关键字，直接把函数定义放进去了就可以了。

如果对比前面的组合使用构造函数模式和原型模式，可以发现前面的Person构造函数对应现在Person类的构造方法constructor，前面Person原型上定义的sayName方法现在是类的内部方法。

一个类必须有constructor方法，如果没有显式定义，一个空的constructor方法会被默认添加。constructor方法默认返回实例对象（即this），完全可以指定返回另外一个对象。

与函数一样，Class也可以使用表达式的形式定义。

```javascript
const MyClass = class Me {
  getClassName() {
    return Me.name;
  }
};
```
Me只能在类内部使用

Class不存在变量提升
```javascript
new Foo(); // ReferenceError
class Foo {}
```

与ES5一样，在Class内部可以使用get和set关键字，定义访问器属性。

```javascript
class MyClass {
  constructor() {
    // ...
  }
  get prop() {
    return 'getter';
  }
  set prop(value) {
    console.log('setter: '+value);
  }
}
inst.prop = 123;
```

类相当于实例的原型，所有在类中定义的方法，都会被实例继承。如果在一个方法前，加上static关键字，就表示该方法不会被实例继承，而是直接通过类来调用，这就称为“静态方法”。
```javascript
class Foo {
  static classMethod() {
    return 'hello';
  }
}

Foo.classMethod() // 'hello'

var foo = new Foo();
foo.classMethod()
// TypeError: undefined is not a function
```javascript
父类的静态方法，可以被子类继承。

ES6为new命令引入了一个`new.target`属性，（在构造函数中）返回new命令作用于的那个构造函数。如果构造函数不是通过new命令调用的，`new.target`会返回undefined，因此这个属性可以用来确定构造函数是怎么调用的。

需要注意的是，子类继承父类时，`new.target`会返回子类。

利用这个特点，可以写出不能独立使用、必须继承后才能使用的类。
```javascript
class Shape {
  constructor() {
    if (new.target === Shape) {
      throw new Error('本类不能实例化');
    }
  }
}
```javascript
### 共享变量
在构造函数原型上定义的属性可以被所有实例共享。

### 静态变量
ES6加入了static关键字。

构造函数原型链上定义的变量或属性只能通过构造函数访问，也可以当做是静态的。

### 私有变量
严格来讲,JavaScript 中没有私有成员的概念;所有对象属性都是公有的。不过,倒是有一个私有变量的概念。任何在函数中定义的变量,都可以认为是私有变量,因为不能在函数的外部访问这些变量。私有变量包括函数的参数、局部变量和在函数内部定义的其他函数。

我们把有权访问私有变量和私有函数的公有方法称为特权方法(privileged method)。有两种在对象上创建特权方法的方式。第一种是在构造函数中定义特权方法
```javascript
function MyObject(){
    //私有变量和私有函数
    var privateVariable = 10;
    function privateFunction(){
        return false;
    }
    //特权方法
    this.publicMethod = function (){
        privateVariable++;
        return privateFunction();
    };
}
```

### 静态私有变量
```javascript
(function(){
    //私有变量和私有函数
    var privateVariable = 10;
    function privateFunction(){
        return false;
    }
    //构造函数
    MyObject = function(){
    };
    //公有/特权方法
    MyObject.prototype.publicMethod = function(){
        privateVariable++;
        return privateFunction();
    };
})();
```
注意,这个模式在定义构造函数时并没有使用函数声明,而是使用了函数表达式。函数声明只能创建局部函数,但那并不是我们想要的。出于同样的原因,我们也没有在声明 MyObject 时使用 var 关键字。但也要知道,在严格模式下给未经声明的变量赋值会导致错误。

### 模块模式
模块模式通过为单例添加私有变量和特权方法能够使其得到增强
```javascript
var singleton = function(){
    //私有变量和私有函数
    var privateVariable = 10;
    function privateFunction(){
        return false;
    }
    //特权/公有方法和属性
    return {
        publicProperty: true,
        publicMethod : function(){
            privateVariable++;
            return privateFunction();
        }
    };
}();
```

### 增强的模块模式
有人进一步改进了模块模式,即在返回对象之前加入对其增强的代码。这种增强的模块模式适合那些单例必须是某种类型的实例,同时还必须添加某些属性和(或)方法对其加以增强的情况。
```javascript
var singleton = function(){
    //私有变量和私有函数
    var privateVariable = 10;
    function privateFunction(){
        return false;
    }
    //创建对象
    var object = new CustomType();
    //添加特权/公有属性和方法
    object.publicProperty = true;
    object.publicMethod = function(){
        privateVariable++;
        return privateFunction();
    };
    //返回这个对象
    return object;
}();
```

## 继承
JavaScript 不包含传统的类继承模型，而是使用 prototype 原型模型。

### 原型链
其基本思想是利用原型让一个引用类型继承另一个引用类型的属性和方法。简单回顾一下构造函数、原型和实例的关系：每个构造函数都有一个原型对象，原型对象都包含一个指向构造函数的指针，而实例都包含一个指向原型对象的内部指针。那么，假如我们让原型对象等于另一个类型的实例，结果会怎么样呢？显然，此时的原型对象将包含一个指向另一个原型的指针，相应地，另一个原型中也包含着一个指向另一个构造函数的指针。假如另一个原型又是另一个类型的实例，那么上述关系依然成立，如此层层递进，就构成了实例与原型的链条。这就是所谓原型链的基本概念。

![JavaScript Object Layout](http://fh-1.qiniudn.com/jsobj.jpg "JavaScript Object Layout")

上面这张图将原型链关系描绘地非常清晰

### 继承方法
组合继承(combination inheritance) ,有时候也叫做伪经典继承,指的是将原型链和借用构造函数的技术组合到一块,从而发挥二者之长的一种继承模式。其背后的思路是使用原型链实现对原型属性和方法的继承,而通过借用构造函数来实现对实例属性的继承。
```javascript
function SuperType(name){
  this.name = name;
  this.colors = ["red", "blue", "green"];
}
SuperType.prototype.sayName = function(){
  alert(this.name);
};
function SubType(name, age){
  //继承属性
  SuperType.call(this, name); //第二次调用 SuperType()
  this.age = age;
}
//继承方法
SubType.prototype = new SuperType(); ///第一次调用 SuperType()
SubType.prototype.constructor = SubType;
SubType.prototype.sayAge = function(){
  alert(this.age);
};
var instance1 = new SubType("Nicholas", 29);
instance1.colors.push("black");
alert(instance1.colors); //"red,blue,green,black"
instance1.sayName(); //"Nicholas";
instance1.sayAge(); //29
var instance2 = new SubType("Greg", 27);
alert(instance2.colors); //"red,blue,green"
instance2.sayName(); //"Greg";
instance2.sayAge(); //27
```
如果知识用原型链继承，那么像colors这样的引用类型会被子类的所有实例共享，一个实例更改colors，所有都会更改，这不是我们想要的，而结合借用构造函数的继承方法，在构造函数内调用父类的构造方法，通过使用 apply() 和 call() 方法也可以在(将来)新创建的对象上执行构造函数，则解决了所有子类实例共享colors的问题。

组合继承是 JavaScript 最常用的继承模式;不过,它也有自己的不足。组合继承最大的问题就是无论什么情况下,都会调用两次超类型构造函数:一次是在创建子类型原型的时候,另一次是在子类型构造函数内部。没错,子类型最终会包含超类型对象的全部实例属性,但我们不得不在调用子类型构造函数时重写这些属性。

在第一次调用 SuperType 构造函数时, SubType.prototype 会得到两个属性: name 和 colors ;它们都是 SuperType 的实例属性,只不过现在位于 SubType 的原型中。当调用 SubType 构造函数时,又会调用一次 SuperType 构造函数,这一次又在新对象上创建了实例属性 name 和 colors 。

寄生组合式继承,即通过借用构造函数来继承属性,通过原型链的混成形式来继承方法。其背后的基本思路是:不必为了指定子类型的原型而调用超类型的构造函数,我们所需要的无非就是超类型原型的一个副本而已。本质上,就是使用寄生式继承来继承超类型的原型,然后再将结果指定给子类型的原型。

```javascript
function inheritPrototype(subType, superType){
  var prototype = Object.create(superType.prototype); //创建对象
  prototype.constructor = subType; //增强对象
  subType.prototype = prototype; //指定对象
}
```
在函数内部,第一步是创建超类型原型的一个副本。第二步是为创建的副本添加 constructor 属性,从而弥补因重写原型而失去的默认的 constructor 属性。最后一步,将新创建的对象(即副本)赋值给子类型的原型。

ECMAScript 5 新增 Object.create() 方法。这个方法接收两个参数:一个用作新对象原型的对象和(可选的)一个为新对象定义额外属性的对象。
```javascript
function SuperType(name){
  this.name = name;
  this.colors = ["red", "blue", "green"];
}
SuperType.prototype.sayName = function(){
  alert(this.name);
};
function SubType(name, age){
  SuperType.call(this, name);
  this.age = age;
}
inheritPrototype(SubType, SuperType);
SubType.prototype.sayAge = function(){
  alert(this.age);
};
```
YUI 的 YAHOO.lang.extend() 方法采用了寄生组合继承

### extends
Class之间可以通过extends关键字实现继承，这比ES5的通过修改原型链实现继承，要清晰和方便很多。

```javascript
class SuperType{
  constructor(name){
    this.name = name;
  }
  sayName(){
    alert(this.name);
  }
}
class SubType extends SuperType{
  constructor(name, age){
    super(name);
    this.age = age;
  }
  sayAge(){
    alert(this.age);
    super.sayName();
  }
}
```
子类必须在constructor方法中调用super方法，否则新建实例时会报错。这是因为子类没有自己的this对象，而是继承父类的this对象，然后对其进行加工。如果不调用super方法，子类就得不到this对象。

对比借用构造函数继承，实质是先创建子类的实例对象this，然后再将父类的属性添加到this上面（`Parent.apply(this)`）。ES6的继承机制则不同，实质是先创建父类的实例对象this（所以必须先调用super方法），然后再用子类的属性修改this。

如果子类没有定义constructor方法，这个方法会被默认添加，代码如下。也就是说，不管有没有显式定义，任何一个子类都有constructor方法。

另一个需要注意的地方是，在子类的构造函数中，只有调用super之后，才可以使用this关键字，否则会报错。这是因为子类实例的构建，是基于对父类实例加工，只有super方法才能返回父类实例。

大部分浏览器实现中，每一个对象都有`__proto__`属性，指向对应的构造函数的prototype属性。Class作为构造函数的语法糖，同时有prototype属性和`__proto__`属性，因此同时存在两条继承链。

1. 子类的`__proto__`属性，表示构造函数的继承，总是指向父类。
2. 子类prototype属性的`__proto__`属性，表示方法的继承，总是指向父类的prototype属性。

```javascript
SubType.__proto__ === SuperType // true
SubType.prototype.__proto__ === SuperType.prototype // true
```

下面，讨论三种特殊情况。

第一种特殊情况，子类继承Object类。
```javascript
class A extends Object {
}

A.__proto__ === Object // true
A.prototype.__proto__ === Object.prototype // true
```
第二种特殊情况，不存在任何继承。
```javascript
class A {
}

A.__proto__ === Function.prototype // true
A.prototype.__proto__ === Object.prototype // true
```
第三种特殊情况，子类继承null。
```javascript
class A extends null {
}

A.__proto__ === Function.prototype // true
A.prototype.__proto__ === undefined // true
```

Object.getPrototypeOf方法可以用来从子类上获取父类。

```javascript
Object.getPrototypeOf(SubType) === SuperType // true
```
因此，可以使用这个方法判断，一个类是否继承了另一个类。

原生构造函数是指语言内置的构造函数，通常用来生成数据结构，比如`Array()`。以前，这些原生构造函数是无法继承的，即不能自己定义一个Array的子类。

```javascript
function MyArray() {
  Array.apply(this, arguments);
}

MyArray.prototype = Object.create(Array.prototype, {
  constructor: {
    value: MyArray,
    writable: true,
    configurable: true,
    enumerable: true
  }
});
```

上面代码定义了一个继承Array的MyArray类。但是，这个类的行为与Array完全不一致。

```javascript
var colors = new MyArray();
colors[0] = "red";
colors.length  // 0

colors.length = 0;
colors[0]  // "red"
```

之所以会发生这种情况，是因为原生构造函数无法外部获取，通过`Array.apply()`或者分配给原型对象都不行。ES5是先新建子类的实例对象this，再将父类的属性添加到子类上，由于父类的属性无法获取，导致无法继承原生的构造函数。

ES6允许继承原生构造函数定义子类，因为ES6是先新建父类的实例对象this，然后再用子类的构造函数修饰this，使得父类的所有行为都可以继承。下面是一个继承Array的例子。

```javascript
class MyArray extends Array {
  constructor(...args) {
    super(...args);
  }
}

var arr = new MyArray();
arr[0] = 12;
arr.length // 1

arr.length = 0;
arr[0] // undefined
```

# 原生类型
## Object
JavaScript语言的所有对象都是由Object衍生的对象；所有对象都继承了Object.prototype的方法和属性，尽管它们可能被覆盖。

构建方法的参数为空，null或undefined将返回一个空对象，参数为String，Number,Boolean类型相当于使用其对应包装类型创建对象。对于其它类型的对象会返回原对象。

 函数                                        | 描述
---                                          | ---
Object.assign(target, ...sources)            | 把任意多个的源对象所拥有的自身可枚举属性拷贝给目标对象，然后返回目标对象。
Object.create(proto, [ propertiesObject ])   | 创建具有指定原型并可选择包含指定属性的对象。
Object.defineProperties(obj, props)          | 将一个或多个属性添加到对象，和/或修改现有属性的特性，并返回该对象。
Object.defineProperty(obj, prop, descriptor) | 将属性添加到对象，或修改现有属性的特性，并返回该对象。
Object.freeze(obj)                           | 冻结对象是指那些不能添加新的属性，不能修改已有属性的值，不能删除已有属性，以及不能修改已有属性的可枚举性、可配置性、可写性的对象。也就是说，这个对象永远是不可变的。该方法返回被冻结的对象。
Object.getOwnPropertyDescriptor(obj, prop)   | 返回指定对象上一个自有属性对应的属性描述符。（自有属性指的是直接赋予该对象的属性，不需要从原型链上进行查找的属性）
Object.getOwnPropertyNames(obj)              | 返回一个由指定对象的所有自身属性的属性名（包括不可枚举属性）组成的数组。
Object.getOwnPropertySymbols(obj)            | 返回一个数组，该数组包含了指定对象自身的（非继承的）所有 symbol 属性键。
Object.getPrototypeOf(object)                | 返回指定对象的原型（也就是该对象内部属性[[Prototype]]的值）。
Object.is(value1, value2)                    | 返回一个值，该值指示两个值是否相同。它与严格比较运算符（===）的行为基本一致，不同之处只有两个：一是+0不等于-0，二是NaN等于自身
Object.isExtensible(obj)                     | 返回指示是否可将新属性添加到对象的值。
Object.isFrozen(obj)                         | 判断一个对象是否被冻结（frozen）
Object.isSealed(obj)                         | 判断一个对象是否是密封的（sealed）
Object.keys(obj)                             | 返回一个由给定对象的所有可枚举自身属性的属性名组成的数组，数组中属性名的排列顺序和使用for-in循环遍历该对象时返回的顺序一致（两者的主要区别是 for-in 还会遍历出一个对象从其原型链上继承到的可枚举属性）。
Object.preventExtensions(obj)                | 让一个对象变的不可扩展，也就是永远不能再添加新的属性
Object.seal(obj)                             | 可以让一个对象密封，并返回被密封后的对象。密封对象是指那些不能添加新的属性，不能删除已有属性，以及不能修改已有属性的可枚举性、可配置性、可写性，但可能可以修改已有属性的值的对象。
Object.setPrototypeOf(object, prototype)     | 设置一个对象的原型(既对象的[[Prototype]]内部属性)。

Object原型属性
* Object.prototype.constructor： 返回一个指向创建了该对象原型的函数引用
* Object.prototype.__proto__：非标准，一个对象的__proto__ 属性和自己的内部属性[[Prototype]]指向一个相同的值 (通常称这个值为原型),原型的值可以是一个对象值也可以是null(比如说Object.prototype.__proto__的值就是null)

Object实例方法

方法                           | 描述
---                            | ---
obj.hasOwnProperty(prop)       | 用来判断某个对象是否含有指定的自身属性
prototype.isPrototypeOf(obj)   | 测试一个对象是否存在于另一个对象的原型链上
obj.propertyIsEnumerable(prop) | 返回一个布尔值，表明指定的属性名是否是当前对象可枚举的自身属性
obj.toLocaleString();          | 返回一个该对象的字符串表示。该方法主要用于被本地化相关对象覆盖。
obj.toString()                 | 返回一个代表该对象的字符串。
obj.valueOf()                  | 返回一个对象的值，默认情况下返回对象本身。

## Array
```javascript
new Array();
new Array(size);
new Array(...items);
```
如果只有一个参数并且是数值，那么这个参数将用于指定数组大小，否则创建包含这个参数的一个数组。

Array的函数

 函数                                     | 描述
 ---                                      | ---
Array.from(arrayLike[, mapFn[, thisArg]]) | 将一个类数组对象或可迭代对象转换成真实的数组。
Array.isArray(value)                      | 返回一个布尔值，该值指示对象是否为数组。
Array.of(...items)                        | 将它的任意多个参数放在一个数组里并返回。

Array 实例的属性
* length： 数组长度

Array 实例的方法

方法                                     | 描述
---                                      | ---
concat(...arguments)                     | 将传入的数组或非数组值与原数组合并,组成一个新的数组并返回.
copyWithin(target, start[, end])         | 复制数组从start位置到end位置的元素到target，end默认是数组长度
entries()                                | 返回包含数组的键/值对的迭代器
every(callbackfn[, thisArg])             | 测试数组的所有元素是否都通过了指定函数的测试
fill(value[, start[, end]])              | 将一个数组中指定区间的所有元素的值, 都替换成或者说填充成为某个固定的值 区间是[start,end)，start默认0，end默认数组长度
filter(callbackfn[, thisArg])            | 利用所有通过指定函数测试的元素创建一个新的数组，并返回
find(predicate[, thisArg])               | 返回数组中满足测试条件的一个元素，如果没有满足条件的元素，则返回undefined
findIndex(predicate[, thisArg])          | 用来查找数组中某指定元素的索引, 如果找不到指定的元素, 则返回 -1
forEach(callbackfn[, thisArg])           | 让数组的每一项都执行一次给定的函数
indexOf(searchElement[, fromIndex])      | 返回根据给定元素找到的第一个索引值，否则返回-1
keys()                                   | 返回包含数组的索引值的迭代器
lastIndexOf(searchElement[, fromIndex])  | 返回指定元素（也即有效的 JavaScript 值或变量）在数组中的最后一个的索引，如果不存在则返回 -1。从数组的后面向前查找，从 fromIndex 处开始
map(callbackfn[, thisArg])               | 返回一个由原数组中的每个元素调用一个指定方法后的返回值组成的新数组
pop()                                    | 从数组中移除最后一个元素并将该元素返回
push(...items)                           | 添加一个或多个元素到数组的末尾，并返回数组新的长度（length 属性值）
reduce(callbackfn[, initialValue])       | 通过对数组中的所有元素（从左到右）调用定义的回调函数来累积单个结果。 回调函数的返回值是累积的结果，并且作为对回调函数的下一个调用中的参数提供
reduceRight(callbackfn[, initialValue])  | 通过对数组中的所有元素调用定义的回调函数来按降序顺序（从右到左）累积单个结果。 回调函数的返回值是累积的结果，并且作为对回调函数的下一个调用中的参数提供
reverse()                                | 颠倒数组中元素的顺序
shift()                                  | 从数组中移除第一个元素并将返回该元素
slice(start, end)                        | 把数组中一部分的浅复制（shallow copy）存入一个新的数组对象中，并返回这个新的数组
some(callbackfn[, thisArg])              | 测试数组中的某些元素是否通过了指定函数的测试
sort(comparefn)                          | 对数组的元素做原地的排序，并返回这个数组。 sort 可能不是稳定的
splice(start, deleteCount, ...items)     | 用新元素替换旧元素，以此修改数组的内容
toLocaleString([reserved1[, reserved2]]) | 返回一个字符串表示数组中的元素。数组中的元素将使用各自的 toLocaleString 方法转成字符串，这些字符串将使用一个特定语言环境的字符串（例如一个逗号 ","）隔开
toString()                               | 返回一个字符串，表示指定的数组及其元素
unshift(...items)                        | 在数组的开头添加一个或者多个元素，并返回数组新的 length 值
values()                                 | 返回一个新的包含数组中每个索引的取值的 Array Iterator （数组迭代）对象
[@@iterator]()                           | 返回迭代器

## Date
```javascript
new Date()
new Date(dateVal)
new Date(year, month, date[, hours[, minutes[, seconds[,ms]]]])
```

Date 函数

 函数                                                           | 描述
---                                                             | ---
Date.now()                                                      | 返回 1970 年 1 月 1日与当前日期和时间之间的毫秒数。
Date.parse(string)                                              | 分析一个包含日期的字符串，并返回该日期与 1970 年 1 月 1 日午夜之间相差的毫秒数。
Date.UTC(year, month, date[, hours[, minutes[, seconds[,ms]]]]) | 返回协调通用时间 (UTC)（或 GMT）1970 年 1 月 1 日午夜与所提供的日期之间相差的毫秒数。

Date实例方法

方法                   | 说明
---                    | ---
getTime()              | 返回表示日期的毫秒数;与 valueOf() 方法返回的值相同
setTime(ms)            | 以毫秒数设置日期,会改变整个日期
getFullYear()          | 取得4位数的年份(如2007而非仅07)
getUTCFullYear()       | 返回UTC日期的4位数年份
setFullYear(year)      | 设置日期的年份。传入的年份值必须是4位数字(如2007而非仅07)
setUTCFullYear(year)   | 设置UTC日期的年份。传入的年份值必须是4位数字(如2007而非仅07)
getMonth()             | 返回日期中的月份,其中0表示一月,11表示十二月
getUTCMonth()          | 返回UTC日期中的月份,其中0表示一月,11表示十二月
setMonth(month)        | 设置日期的月份。传入的月份值必须大于0,超过11则增加年份
setUTCMonth(month)     | 设置UTC日期的月份。传入的月份值必须大于0,超过11则增加年份
getDate()              | 返回日期月份中的天数(1到31)
getUTCDate()           | 返回UTC日期月份中的天数(1到31)
setDate(date)          | 设置日期月份中的天数。如果传入的值超过了该月中应有的天数,则增加月份
setUTCDate(date)       | 设置UTC日期月份中的天数。如果传入的值超过了该月中应有的天数,则增加月份
getDay()               | 返回日期中星期的星期几(其中0表示星期日,6表示星期六)
getUTCDay()            | 返回UTC日期中星期的星期几(其中0表示星期日,6表示星期六)
getHours()             | 返回日期中的小时数(0到23)
getUTCHours()          | 返回UTC日期中的小时数(0到23)
setHours(hours)        | 设置日期中的小时数。传入的值超过了23则增加月份中的天数
setUTCHours(hours)     | 设置UTC日期中的小时数。传入的值超过了23则增加月份中的天数
getMinutes()           | 返回日期中的分钟数(0到59)
getUTCMinutes()        | 返回UTC日期中的分钟数(0到59)
setMinutes(minutes)    | 设置日期中的分钟数。传入的值超过59则增加小时数
setUTCMinutes(minutes) | 设置UTC日期中的分钟数。传入的值超过59则增加小时数
getSeconds()           | 返回日期中的秒数(0到59)
getUTCSeconds()        | 返回UTC日期中的秒数(0到59)
setSeconds(seconds)    | 设置日期中的秒数。传入的值超过了59会增加分钟数
setUTCSeconds(seconds) | 设置UTC日期中的秒数。传入的值超过了59会增加分钟数
getMilliseconds()      | 返回日期中的毫秒数
getUTCMilliseconds()   | 返回UTC日期中的毫秒数
setMilliseconds(ms)    | 设置日期中的毫秒数
setUTCMilliseconds(ms) | 设置UTC日期中的毫秒数
getTimezoneOffset()    | 返回本地时间与UTC时间相差的分钟数。例如,美国东部标准时间返回300。在某地进入夏令时的情况下,这个值会有所变化
toDateString()         | 以特定于实现的格式显示星期几、月、日和年；
toTimeString()         | 以特定于实现的格式显示时、分、秒和时区；
toLocaleDateString()   | 以特定于地区的格式显示星期几、月、日和年；
toLocaleTimeString()   | 以特定于实现的格式显示时、分、秒；
toUTCString()          | 以特定于实现的格式完整的UTC日期。
toJSON()               | 调用 toJSON() 返回一个 JSON 格式字符串 (使用 toISOString) ，表示该日期对象的值。默认情况下，这个方法常用于 JSON 序列化时序列化日期对象

## RegExp
```javascript
new RegExp(pattern[, flags])
/pattern/[flags]
```
使用构造函数，pattern可以是字符串，ES6中也可以是正则字面量，如果是正则字面量第二个参数会覆盖字面量中的标志。构造函数如果第一个是字符串需要注意所有元字符需要双重转义（`\\`字符串中就是`\\\\`）

模式中使用的所有元字符都必须转义。正则表达式中的元字符包括： `( [ { \ ^ $ | ) ? * + .]}`

正则表达式的匹配模式支持下列 5 个标志，后两个是ES6新增。
* g :表示全局(global)模式,即模式将被应用于所有字符串,而非在发现第一个匹配项时立即停止;
* i :表示不区分大小写(case-insensitive)模式,即在确定匹配项时忽略模式与字符串的大小写;
* m :表示多行(multiline)模式,即在到达一行文本末尾时还会继续查找下一行中是否存在与模式匹配的项。
* u :表示“Unicode模式”，用来正确处理大于\uFFFF的Unicode字符。也就是说，会正确处理四个字节的UTF-16编码。
* y :表示“粘连”（sticky）模式。y修饰符的作用与g修饰符类似，也是全局匹配，后一次匹配都从上一次匹配成功的下一个位置开始。不同之处在于，g修饰符只要剩余位置中存在匹配就可，而y修饰符确保匹配必须从剩余的第一个位置开始，这也就是“粘连”的涵义。如果同时使用g修饰符和y修饰符，则y修饰符覆盖g修饰符。

RegExp的每个实例都具有下列属性，通过这些属性可以取得有关模式的各种信息。
* global：布尔值，表示是否设置了g标志。
* ignoreCase：布尔值，表示是否设置了i标志。
* lastIndex：整数，表示开始搜索下一个匹配项的字符位置，从0算起。
* multiline：布尔值，表示是否设置了m标志。
* source：正则表达式的字符串表示，按照字面量形式而非传入构造函数中的字符串模式返回。
ES6新增属性
* sticky:布尔值，表示是否设置了y标志。
* flags: 字符串，表示正则表达式的标志

RegExp的实例方法

方法      | 说明
---       | ---
exec(str) | 为指定的一段字符串执行搜索匹配操作。它的返回值是一个数组或者 null。返回的数组虽然是Array 的实例，但包含两个额外的属性：index 和input。其中，index 表示匹配项在字符串中的位置，而 input 表示应用正则表达式的字符串。在数组中，第一项是与整个模式匹配的字符串，其他项是与模式中的捕获组匹配的字符串
test(str) | 执行一个检索，用来查看正则表达式与指定的字符串是否匹配。返回 true 或 false

RegExp实例继承的toLocaleString()和toString()方法都会返回正则表达式的字面量，与创建正则表达式的方式无关

正则表达式的valueOf()方法返回正则表达式本身。

RegExp 构造函数属性分别有一个长属性名和一个短属性名（Opera是例外，它不支持短属性名）。下表列出了RegExp构造函数的属性。

长属性名     | 短属性名 | 说明
---          | ---      | ---
input        | $_       | 最近一次要匹配的字符串。Opera未实现此属性
lastMatch    | $&       | 最近一次的匹配项。Opera未实现此属性
lastParen    | $+       | 最近一次匹配的捕获组。Opera未实现此属性
leftContext  | $`       | input字符串中lastMatch之前的文本
multiline    | $*       | 布尔值,表示是否所有表达式都使用多行模式。IE和Opera未实现此属性
rightContext | $'       | Input字符串中lastMatch之后的文本

## Function
```javascript
new Function(p1, p2, … , pn, body)
```
JavaScript中所有函数都是Function类型的实例。

Function实例属性
* name： 函数名
* length： 函数参数的个数
* prototype： 函数原型

Function实例方法

方法                     | 说明
---                      | ---
apply(thisArg, argArray) | 指定 this 值和参数（参数以数组或类数组对象的形式存在）的情况下调用某个函数。 和call方法的区别是call方法接受的是一个参数列表
bind(thisArg, ...args)   | 创建一个新函数，称为绑定函数，当调用这个绑定函数时，绑定函数会以创建它时传入 bind()方法的第一个参数作为 this，传入 bind() 方法的第二个以及以后的参数加上绑定函数运行时本身的参数按照顺序作为原函数的参数来调用原函数
call(thisArg, ...args)   | 在使用一个指定的this值和若干个指定的参数值的前提下调用某个函数或方法

```javascript
function list() {
  return Array.prototype.slice.call(arguments);
}
var list1 = list(1, 2, 3); // [1, 2, 3]
```

## Boolean
```javascript
new Boolean([value])
```
基本类型与引用类型的布尔值还有两个区别。首先，typeof操作符对基本类型返回"boolean"，而对引用类型返回"object"。其次，由于Boolean对象是Boolean类型的实例，所以使用instanceof操作符测试Boolean对象会返回true，而测试基本类型的布尔值则返回false。

## Number
```javascript
new Number([value])
```

Number属性
* Number.MAX_VALUE 能表示的最大正数。最大的负数是 -MAX_VALUE。
* Number.MIN_VALUE 能表示的最小正数 -- 即，最接近 0 的正数 (实际上不会变成 0)。最小的负数是 -MIN_VALUE。
* Number.MAX_SAFE_INTEGER 能表示的最大整数。(2^53−1).
* Number.MIN_SAFE_INTEGER 能表示的最小整数。 (−(2^53−1))
* Number.NaN 特殊的“非数字”值。
* Number.NEGATIVE_INFINITY 特殊的负无穷大值，在溢出时返回。
* Number.POSITIVE_INFINITY 特殊的正无穷大值，在溢出时返回。

Number函数

 函数                          | 描述
---                            | ---
Number.isFinite(number)        | 返回一个布尔值，该值指示值是否为有限数。
Number.isInteger(number)       | 返回一个布尔值，该值指示值是否为整数。
Number.isNaN(number)           | 返回一个布尔值，该值指示某个值是否为保留值 NaN（非数字）。
Number.isSafeInteger(number)   | 返回一个布尔值，该值指示值是否可在 JavaScript 中安全表示。
Number.parseFloat(string)      | 解析一个字符串并返回一个浮点数
Number.parseInt(string, radix) | 解析一个字符串并返回一个整数，第二参数指定进制

Number实例方法

 方法                                    | 描述
---                                      | ---
toExponential(fractionDigits)            | 返回一个字符串，其中包含一个以指数记数法表示的数字。
toFixed(fractionDigits)                  | 返回一个字符串，它表示定点表示法中的一个数字。
toLocaleString([reserved1[, reserved2]]) | 返回基于当前区域设置转换为字符串的对象。
toPrecision(precision)                   | 返回一个字符串，其中包含一个以指数或定点表示法表示且具有指定位数的数字。
toString(radix)                          | 返回对象的字符串表示形式。可以指定进制
valueOf()                                | 返回指定对象的基元值。

## String
```javascript
new String(value);
```
ES6提供了对Unicode辅助平面码点的支持

String 函数

函数                                   | 描述
---                                    | ---
String.fromCharCode(...codeUnits)      | 根据指定的一或多个 Unicode 字符编码来返回一个字符串。
String.fromCodePoint(...codePoints)    | 可以识别码点大于0xFFFF（辅助平面）的字符，弥补了String.fromCharCode方法的不足
String.raw(template, ...substitutions) | 模板字符串的标签函数，它的作用类似于 Python 中的字符串前缀 r 和 C# 中的字符串前缀 @，是用来获取一个模板字符串的原始字面量值的

String 实例的方法

 方法                                         | 描述
---                                           | ---
charAt(pos)                                   | 返回指定索引处的字符。
charCodeAt(pos)                               | 返回指定字符的 Unicode 编码。但是不支持辅助平面的码点
codePointAt(pos)                              | 返回一个 Unicode UTF-16 字符的码点。辅助平面的码点
concat(...args)                               | 返回由提供的两个字符串串联而成的字符串。
endsWith(searchString[,endPosition])          | 返回一个布尔值，该值指示字符串或子字符串是否以传入字符串结尾。
includes(searchString[, position])            | 返回一个布尔值，该值指示传入字符串是否包含在字符串对象中。
indexOf(searchString[, position])             | 返回字符串内第一次出现子字符串的字符位置。
lastIndexOf(searchString[, position])         | 返回字符串内子字符串的最后一个匹配项。
localeCompare(that[, reserved1[, reserved2]]) | 返回一个值，该值指示两个字符串在当前区域设置中是否相等。
match(regexp)                                 | 通过使用提供的正则表达式对象来搜索字符串并以数组形式返回结果。
normalize([form])                             | 按照指定的一种 Unicode 正规形式将当前字符串正规化。四种 Unicode 正规形式 "NFC", "NFD", "NFKC", 以及 "NFKD" 其中的一个, 默认值为 "NFC"
repeat(count)                                 | 返回一个新的字符串对象，它的值等于重复了指定次数的原始字符串。
replace(searchValue, replaceValue)            | 使用正则表达式替换字符串中的文本并返回结果。
search(regexp)                                | 返回正则表达式搜索中第一个子字符串匹配项的位置。
slice(start, end)                             | 返回字符串的片段。
split(separator, limit)                       | 返回一个字符串拆分为若干子字符串时所产生的字符串数组。
startsWith(searchString[, position])          | 返回一个布尔值，该值指示字符串或子字符串是否以传入字符串开头。
substr(start, end)                            | 返回一个从指定位置开始且具有指定长度的子字符串。
substring(start, end)                         | 返回 String 对象中指定位置处的子字符串。
toLocaleLowerCase([reserved1[, reserved2]])   | 返回一个字符串，其中所有字母字符都转换为小写形式，并将考虑主机环境的当前区域设置。
toLocaleUpperCase([reserved1[, reserved2]])   | 返回一个字符串，其中所有字母字符都转换为大写形式，并将考虑主机环境的当前区域设置。
toLowerCase()                                 | 返回一个字符串，其中所有字母字符都转换为小写形式。
toString()                                    | 返回字符串。
toUpperCase()                                 | 返回一个字符串，其中所有字母字符都转换为大写形式。
trim()                                        | 返回已移除前导空格、尾随空格和行终止符的字符串。
valueOf()                                     | 返回字符串
[@@iterator]()                                | 返回迭代器

ECMAScript还提供了三个基于子字符串创建新字符串的方法：slice()、substr()和substring()。这三个方法都会返回被操作字符串的一个子字符串，而且也都接受一或两个参数。第一个参数指定子字符串的开始位置，第二个参数（在指定的情况下）表示子字符串到哪里结束。具体来说，slice()和substring()的第二个参数指定的是子字符串最后一个字符后面的位置。而 substr() 的第二个参数指定的则是返回的字符个数。如果没有给这些方法传递第二个参数，则将字符串的长度作为结束位置。与concat()方法一样，slice()、substr()和 substring()也不会修改字符串本身的值——它们只是返回一个基本类型的字符串值，对原始字符串没有任何影响。

在传递给这些方法的参数是负值的情况下，它们的行为就不尽相同了。其中，slice()方法会将传入的负值与字符串的长度相加，substr()方法将负的第一个参数加上字符串的长度，而将负的第二个参数转换为0。最后，substring()方法会把所有负值参数都转换为0

## Global
Global对象可以说是ECMAScript中最特别的一个对象了，因为不管你从什么角度上看，这个对象都是不存在的。ECMAScript中的Global对象在某种意义上是作为一个终极的“兜底儿对象”来定义的。换句话说，不属于任何其他对象的属性和方法，最终都是它的属性和方法。事实上，没有全局变量或全局函数；所有在全局作用域中定义的属性和函数，都是Global对象的属性。诸如 isNaN() 、 isFinite() 、 parseInt() 以及 parseFloat() ,实际上全都是 Global 对象的方法。

* URI 编码方法
    对象的 encodeURI()和 encodeURIComponent()方法可以对 URI（Uniform Resource Identifiers，通用资源标识符）进行编码，以便发送给浏览器。有效的 URI 中不能包含某些字符，例如空格。而这两个URI编码方法就可以对URI进行编码，它们用特殊的UTF-8编码替换所有无效的字符，从而让浏览器能够接受和理解。 其中，encodeURI()主要用于整个URI（例如，`http://www.wrox.com/illegal value.htm`），而 encodeURIComponent()主要用于对URI中的某一段（例如前面URI中的illegal value.htm）进行编码。它们的主要区别在于，encodeURI()不会对本身属于 URI 的特殊字符进行编码，例如冒号、正斜杠、问号和井字号；而encodeURIComponent()则会对它发现的任何非标准字符进行编码。

    一般来说，我们使用 encodeURIComponent()方法的时候要比使用encodeURI()更多，因为在实践中更常见的是对查询字符串参数而不是对基础 URI进行编码。

    与 encodeURI()和 encodeURIComponent()方法对应的两个方法分别是 decodeURI()和decodeURIComponent()

* eval()方法
    eval()方法就像是一个完整的ECMAScript解析器，它只接受一个参数，即要执行的ECMAScript（或JavaScript）字符串。看例子： eval("alert('hi')"); 这行代码的作用等价于代码： alert("hi");

    当解析器发现代码中调用eval()方法时，它会将传入的参数当作实际的ECMAScript语句来解析，然后把执行结果插入到原位置。通过 eval() 执行的代码可以引用在包
含环境中定义的变量 `var msg = "hello world"; eval("alert(msg)");`

    在eval()中创建的任何变量或函数都不会被提升，因为在解析代码的时候，它们被包含在一个字符串中；它们只在eval()执行的时候创建。 严格模式下，在外部访问不到eval()中创建的任何变量或函数，在严格模式下,为 eval 赋值也会导致错误

* Global 对象的属性
    特殊的值undefined、NaN以及Infinity都是Global对象的属性。此外，所有原生引用类型的构造函数，像Object和Function，也都是Global对象的属性。下表列出了Global对象的所有属性。

isFinite(number)，isNaN(number)，parseFloat(string)，parseInt(string , radix)这几个函数功能和Number的类似

属性           | 说明
---            | ---
undefined      | 特殊值 undefined
NaN            | 特殊值 NaN
Infinity       | 特殊值 Infinity
Date           | 构造函数 Date
RegExp         | 构造函数 RegExp
Error          | 构造函数 Error
Object         | 构造函数 Object
Array          | 构造函数 Array
Function       | 构造函数 Function
Boolean        | 构造函数 Boolean
String         | 构造函数 String
Number         | 构造函数 Number
EvalError      | 构造函数 EvalError
RangeError     | 构造函数 RangeError
ReferenceError | 构造函数 ReferenceError
SyntaxError    | 构造函数 SyntaxError
TypeError      | 构造函数 TypeError
URIError       | 构造函数 URIError

ECMAScript 5明确禁止给undefined、NaN和Infinity赋值，这样做即使在非严格模式下也会导致错误。

## Math
* Math 对象的属性

属 性        | 说 明
---          | ---
Math.E       | 自然对数的底数，即常量e的值
Math.LN10    | 10的自然对数
Math.LN2     | 2的自然对数
Math.LOG2E   | 以2为底e的对数
Math.LOG10E  | 以10为底e的对数
Math.PI      | π的值
Math.SQRT1_2 | 1/2的平方根（即2的平方根的倒数）
Math.SQRT2   | 2的平方根

* min() 和 max() 方法
    这两个方法都可以接收任意多个数值参数，要查找数组中的最大值可以使用apply方法。
    {% codeblock %}
    Math.min(1,2,3,4);
    var values = [1, 2, 3, 4, 5, 6, 7, 8];
    var max = Math.max.apply(Math, values);
    {% endcodeblock %}

* 舍入方法
    * Math.ceil()执行向上舍入，即它总是将数值向上舍入为最接近的整数；
    * Math.floor()执行向下舍入，即它总是将数值向下舍入为最接近的整数；
    * Math.round()执行标准舍入，即它总是将数值四舍五入为最接近的整数

* random() 方法
    Math.random() 方法返回大于等于 0 小于 1 的一个随机数。套用下面的公式，就可以利用Math.random()从某个整数范围内随机选择一个值。 `值 = Math.floor(Math.random() * 可能值的总数 + 第一个可能的值)`

* 其他方法

方 法               | 说 明
---                 | ---
Math.abs(num)       | 返回num 的绝对值
Math.exp(num)       | 返回Math.E 的num 次幂
Math.log(num)       | 返回num 的自然对数
Math.pow(num,power) | 返回num 的power 次幂
Math.sqrt(num)      | 返回num 的平方根
Math.acos(x)        | 返回x 的反余弦值
Math.asin(x)        | 返回x 的反正弦值
Math.atan(x)        | 返回x 的反正切值
Math.atan2(y,x)     | 返回y/x 的反正切值
Math.cos(x)         | 返回x 的余弦值
Math.sin(x)         | 返回x 的正弦值
Math.tan(x)         | 返回x 的正切值

* ES6新增方法

方 法                | 说 明
---                  | ---
Math.trunc(num)      | 去除一个数的小数部分，返回整数部分，对于空值和无法截取整数的值，返回NaN
Math.sign(num)       | 判断一个数到底是正数、负数、还是零。参数为正数，返回+1； 参数为负数，返回-1； 参数为0，返回0； 参数为-0，返回-0; 其他值，返回NaN。
Math.cbrt(num)       | 计算一个数的立方根
Math.clz32(num)      | 返回一个数的32位无符号整数二进制形式表示有多少个前导0。对于小数，只考虑整数部分，对于其他值，先转为数值，再计算
Math.imul(num1,num2) | 回两个数以32位带符号整数形式相乘的结果，返回的也是一个32位的带符号整数。多数情况和`(a * b) | 0`效果相同，但JavaScript对于超过2的53次方的值无法精确表示，该方法可以得到正确值
Math.fround(num)     | Math.fround方法返回一个数的单精度浮点数形式。对于整数来说，Math.fround方法返回结果不会有任何不同，区别主要是那些无法用64个二进制位精确表示的小数。这时，Math.fround方法会返回最接近这个小数的单精度浮点数。
Math.hypot()         | 返回所有参数的平方和的平方根，如果参数不是数值，Math.hypot方法会将其转为数值。只要有一个参数无法转为数值，就会返回NaN
Math.expm1()         | 返回Math.exp(x) - 1
Math.log1p()         | 返回1 + x的自然对数。如果x小于-1，返回NaN
Math.log10()         | 返回以10为底的x的对数。如果x小于0，则返回NaN
Math.log2()          | 返回以2为底的x的对数。如果x小于0，则返回NaN
Math.sinh(x)         | 返回x的双曲正弦（hyperbolic sine）
Math.cosh(x)         | 返回x的双曲余弦（hyperbolic cosine）
Math.tanh(x)         | 返回x的双曲正切（hyperbolic tangent）
Math.asinh(x)        | 返回x的反双曲正弦（inverse hyperbolic sine）
Math.acosh(x)        | 返回x的反双曲余弦（inverse hyperbolic cosine）
Math.atanh(x)        | 返回x的反双曲正切（inverse hyperbolic tangent）

## Map
```javascript
new Map([iterable])
```

Map对象属性：size，映射中的元素数

Map对象方法

 方法                          | 描述
---                            | ---
clear()                        | 清除所有成员，没有返回值。
delete(key)                    | 删除某个键，返回true。如果删除失败，返回false。
forEach(callbackfn[, thisArg]) | 对映射中的每个元素执行指定操作。
get(key)                       | 读取key对应的键值，如果找不到key，返回undefined。
has(key)                       | 返回一个布尔值，表示某个键是否在Map数据结构中。
set(key,value)                 | 设置key所对应的键值，然后返回整个Map结构。如果key已经有值，则键值会被更新，否则就新生成该键。
entries()                      | 返回所有成员的Iterator对象。
keys()                         | 返回键名的Iterator对象。
values()                       | 返回键值的Iterator对象。

## WeakMap
```javascript
new WeakMap([iterable])
```
WeakMap结构与Map结构基本类似，唯一的区别是它只接受对象作为键名（null除外），不接受原始类型的值作为键名，而且键名所指向的对象，不计入垃圾回收机制。

WeakMap的设计目的在于，键名是对象的弱引用（垃圾回收机制不将该引用考虑在内），所以其所对应的对象可能会被自动回收。当对象被回收后，WeakMap自动移除对应的键值对。典型应用是，一个对应DOM元素的WeakMap结构，当某个DOM元素被清除，其所对应的WeakMap记录就会自动被移除。基本上，WeakMap的专用场合就是，它的键所对应的对象，可能会在将来消失。WeakMap结构有助于防止内存泄漏。

WeakMap只有四个方法可用：get()、set()、has()、delete()。

## Set
```javascript
new Set([iterable])
```
Set 实例属性size，返回元素个数

Set 实例方法

 方法                          | 描述
---                            | ---
clear()                        | 清除所有成员，没有返回值。
delete(value)                  | 删除某个键，返回true。如果删除失败，返回false。
forEach(callbackfn[, thisArg]) | 对映射中的每个元素执行指定操作。
has(value)                     | 返回一个布尔值，表示某个键是否在Set数据结构中。
add(value)                     | 设置key所对应的键值，然后返回整个Map结构。如果key已经有值，则键值会被更新，否则就新生成该键。
entries()                      | 返回所有成员的Iterator对象。
keys()                         | 返回键名的Iterator对象。
values()                       | 返回键值的Iterator对象。

entries，keys，values三个方法返回一样。

数组、Map、Set实例都有entries，keys，values这三个方法，都返回一个迭代器，实现了Iterable和Iterator接口。且其`Symbol.iterator`方法的返回值就是其本身

## WeakSet
```javascript
new WeakSet([iterable])
```
WeakSet结构与Set类似，也是不重复的值的集合。但是，它与Set有两个区别。

首先，WeakSet的成员只能是对象，而不能是其他类型的值。

其次，WeakSet中的对象都是弱引用，即垃圾回收机制不考虑WeakSet对该对象的引用，也就是说，如果其他对象都不再引用该对象，那么垃圾回收机制会自动回收该对象所占用的内存，不考虑该对象还存在于WeakSet之中。这个特点意味着，无法引用WeakSet的成员，因此WeakSet是不可遍历的。

实例只有add，delete，has三个方法。

## Proxy
```javascript
new Proxy(target, handler)
```
Proxy对象的所有用法，都是上面这种形式，不同的只是handler参数的写法。其中，`new Proxy()`表示生成一个Proxy实例，target参数表示所要拦截的目标对象，handler参数也是一个对象，用来定制拦截行为。

Proxy.revocable(target, handler)

 处理程序方法（陷阱）语法                                  | 用法示例
 ---                                                       | ---
apply: function(target, thisArg, args)                     | 函数调用陷阱。
construct: function(target, args)                          | 构造函数陷阱。
defineProperty: function(target, propertyName, descriptor) | Object.defineProperty 函数 (JavaScript) 陷阱。
deleteProperty: function(target, propertyName)             | delete 语句的陷阱。
enumerate: function(target)                                | for…in 语句、Object.getOwnPropertySymbols、Object.keys 函数和 JSON.stringify 的陷阱。
get: function(target, propertyName, receiver)              | 任何 getter 属性的陷阱。
getOwnPropertyDescriptor: function(target, propertyName)   | Object.getOwnPropertyDescriptor 函数 (JavaScript) 的陷阱。
getPrototypeOf: function(target)                           | Object.getPrototypeOf 函数 (JavaScript) 的陷阱。
has: function(target, propertyName)                        | in 运算符、hasOwnProperty 方法 (Object) (JavaScript) 和其他方法的陷阱。
isExtensible: function(target)                             | Object.isExtensible 函数 (JavaScript) 的陷阱。
ownKeys: function(target)                                  | Object.getOwnPropertyNames 函数 (JavaScript) 的陷阱。
preventExtensions: function(target)                        | Object.preventExtensions 函数 (JavaScript) 的陷阱。
set: function(target, propertyName, value, receiver)       | 任何 setter 属性的陷阱。
setPrototypeOf: function(target, prototype)                | Object.setPrototypeOf 的陷阱。

## Reflect
Reflect 方法通常与Proxy一起使用，因为后者允许你委托默认行为而无需在代码中实现该默认行为。

Reflect 提供与每个代理陷阱具有相同名称的静态方法

Reflect函数清单如下。

* Reflect.getOwnPropertyDescriptor(target,name)
* Reflect.defineProperty(target,name,desc)
* Reflect.getOwnPropertyNames(target)
* Reflect.getPrototypeOf(target) 读取对象的`__proto__`属性，等同于`Object.getPrototypeOf(obj)`。
* Reflect.setPrototypeOf(obj, newProto) 设置对象的`__proto__`属性，注意，Object对象没有对应这个方法的方法。
* Reflect.deleteProperty(target,name) 等同于`delete obj[name]`。
* Reflect.enumerate(target)
* Reflect.freeze(target)
* Reflect.seal(target)
* Reflect.preventExtensions(target)
* Reflect.isFrozen(target)
* Reflect.isSealed(target)
* Reflect.isExtensible(target)
* Reflect.has(target,name) 等同于`name in obj`。
* Reflect.hasOwn(target,name)
* Reflect.keys(target)
* Reflect.get(target,name,receiver) 查找并返回target对象的name属性，如果没有该属性，则返回undefined。如果name属性部署了读取函数，则读取函数的this绑定receiver。
* Reflect.set(target,name,value,receiver) 设置target对象的name属性等于value。如果name属性设置了赋值函数，则赋值函数的this绑定receiver。
* Reflect.apply(target,thisArg,args) 等同于`Function.prototype.apply.call(fun,thisArg,args)`。一般来说，如果要绑定一个函数的this对象，可以这样写`fn.apply(obj, args)`，但是如果函数定义了自己的apply方法，就只能写成`Function.prototype.apply.call(fn, obj, args)`，采用Reflect对象可以简化这种操作。
* Reflect.construct(target,args) 等同于`new target(...args)`，这提供了一种不使用new，来调用构造函数的方法。

## Promise
```javascript
new Promise(function(resolve, reject) { ... });
```
Promise必须完成（返回一个值）或者必须被拒绝（返回一个原因）。Promise完成或被拒绝时（无论哪一个先发生），Promise 对象的 then 方法都会运行。如果承诺成功完成，则将运行 then 方法的履行处理程序函数。如果承诺被拒绝，则将运行 then 方法（或 catch 方法）的错误处理程序函数。

Promise对象有以下两个特点。

1. 对象的状态不受外界影响。Promise对象代表一个异步操作，有三种状态：Pending（进行中）、Resolved（已完成，又称Fulfilled）和Rejected（已失败）。只有异步操作的结果，可以决定当前是哪一种状态，任何其他操作都无法改变这个状态。这也是Promise这个名字的由来，它的英语意思就是“承诺”，表示其他手段无法改变。
2. 一旦状态改变，就不会再变，任何时候都可以得到这个结果。Promise对象的状态改变，只有两种可能：从Pending变为Resolved和从Pending变为Rejected。只要这两种情况发生，状态就凝固了，不会再变了，会一直保持这个结果。就算改变已经发生了，你再对Promise对象添加回调函数，也会立即得到这个结果。这与事件（Event）完全不同，事件的特点是，如果你错过了它，再去监听，是得不到结果的。

Promise函数

函数                   | 描述
---                    | ---
Promise.all(iterable)  | 返回一个promise，该promise会在iterable参数内的所有promise都被解决后被解决。如果传入的可迭代数组中某项不是一个promise，该项会被用Promise.resolve转换为一个promise。如果任一传入的promise被拒绝了，all Promise立刻带着该promise的拒绝原因进入拒绝(rejected)状态，不再理会其它传入的promise是否被解决。
Promise.race(iterable) | 返回一个promise，这个promise在iterable中的任意一个promise被解决或拒绝后，立刻以相同的解决值被解决或以相同的拒绝原因被拒绝。
Promise.reject(reason) | 返回一个用reason拒绝的Promise
Promise.resolve(x)     | 返回一个以给定值resolve掉的Promise对象。但如果这个值是thenable的（就是说带有then方法），返回的promise会“追随”这个thenable的对象，接收它的最终状态（指resolved/rejected/pendding/settled）；否则这个被返回的promise对象会以这个值被fulfilled

Promise对象方法

方法                          | 描述
---                           | ---
then(onFulfilled, onRejected) | 返回一个Promise。它有两个参数，分别为Promise在 success 和 failure 情况下的回调函数
catch(onRejected)             | 只处理Promise被拒绝的情况，并返回一个Promise。该方法的行为和调用Promise.prototype.then(undefined, onRejected)相同

# 异步编程
异步编程对JavaScript语言很重要。JavaScript只有一个线程，如果没有异步编程，性能堪忧。

ES6之前，异步编程的方法，大概有下面四种。

* 回调函数
* 事件监听
* 发布/订阅
* Promise 对象

## 异步基本概念
所谓"异步"，简单说就好比把一个任务分成两段，先执行第一段，然后转而执行其他任务，等做好了准备，再回过头执行第二段。

比如，有一个任务是读取文件进行处理，任务的第一段是向操作系统发出请求，要求读取文件。然后，程序执行其他任务，等到操作系统返回文件，再接着执行任务的第二段（处理文件）。这种不连续的执行，就叫做异步。

相应地，连续的执行就叫做同步。由于是连续执行，不能插入其他任务，所以操作系统从硬盘读取文件的这段时间，程序只能干等着。

## 回调函数

```javascript
fs.readFile('/etc/passwd', function (err, data) {
  if (err) throw err;
  console.log(data);
});
```
上面代码中，readFile函数的第二个参数，就是回调函数，也就是任务的第二段。等到操作系统返回了`/etc/passwd`这个文件以后，回调函数才会执行。

## Promise
回调函数本身并没有问题，它的问题出现在多个回调函数嵌套。假定读取A文件之后，再读取B文件，代码如下。

```javascript
fs.readFile(fileA, function (err, data) {
  fs.readFile(fileB, function (err, data) {
    // ...
  });
});
```
上面回调函数会有多重嵌套，Promise允许将回调函数的横向加载，改成纵向加载。采用Promise，连续读取多个文件，写法如下。

```javascript
var readFile = require('fs-readfile-promise');

readFile(fileA)
.then(function(data){
  console.log(data.toString());
})
.then(function(){
  return readFile(fileB);
})
.then(function(data){
  console.log(data.toString());
})
.catch(function(err) {
  console.log(err);
});
```

Generator函数是协程在ES6的实现，最大特点就是可以交出函数的执行权（即暂停执行）。

整个Generator函数就是一个封装的异步任务，或者说是异步任务的容器。异步操作需要暂停的地方，都用yield语句注明。

可以看到，虽然 Generator 函数将异步操作表示得很简洁，但是流程管理却不方便（即何时执行第一阶段、何时执行第二阶段）。

Thunkify模块和co模块可以自动执行Generator函数

基于Promise对象的自动执行
```javascript
var fs = require('fs');

var readFile = function (fileName){
  return new Promise(function (resolve, reject){
    fs.readFile(fileName, function(error, data){
      if (error) reject(error);
      resolve(data);
    });
  });
};

var gen = function* (){
  var f1 = yield readFile('/etc/fstab');
  var f2 = yield readFile('/etc/shells');
  console.log(f1.toString());
  console.log(f2.toString());
};
```

然后，手动执行上面的Generator函数。
```javascript
var g = gen();

g.next().value.then(function(data){
  g.next(data).value.then(function(data){
    g.next(data);
  });
})
```
## async函数
async函数现在是ES7的一个提案。上面例子写成 async 函数，就是下面这样。

```javascript
var asyncReadFile = async function (){
  var f1 = await readFile('/etc/fstab');
  var f2 = await readFile('/etc/shells');
  console.log(f1.toString());
  console.log(f2.toString());
};
```
一比较就会发现，async函数就是将Generator函数的星号（`*`）替换成async，将yield替换成await，仅此而已。

参考：

[JavaScript秘密花园](http://bonsaiden.github.io/JavaScript-Garden/zh/)
