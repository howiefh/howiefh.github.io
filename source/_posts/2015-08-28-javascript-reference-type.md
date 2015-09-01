title: JavaScript 引用类型
date: 2015-08-28 12:18:03
tags: JavaScript
categories: JavaScript
description: JavaScript 引用类型，Object，Array，Date，RegExp，Function，Number，Boolean，String，Global，Math，Map，Set，WeakMap，WeakSet，Proxy，Reflect，Promise，Iterator
---
[JavaScript 基本语法](2015/08/28/javascript-grammar/)，[JavaScript 引用类型](2015/08/28/javascript-reference-type/)，[JavaScript 面向对象程序设计、函数表达式和异步编程](2015/08/28/javascript-oop-function-expression-and-async/)三篇笔记是对《JavaScript 高级程序设计》和 [《ECMAScript 6入门》](https://github.com/ruanyf/es6tutorial/tree/5a5f9d8d492d0f925cbb6e09b10ebed9d2078d40)两本书的总结整理。

# 引用类型
引用类型是一种数据结构，用于将数据和功能组织在一起。它也常被称为类，但这种称呼并不妥当。尽管 ECMAScript从技术上讲是一门面向对象的语言，但它不具备传统的面向对象语言所支持的类和接口等基本结构。引用类型有时候也被称为对象定义，因为它们描述的是一类对象所具有的属性和方法。

<!-- more -->
## Object类型
创建Object实例有两种方式，第一种是使用new操作符后跟Object构造函数，如下所示：
```
var person = new Object();
person.name = "Nicholas";
person.age = 29;
```

新对象是使用new操作符后跟一个构造函数来创建的。构造函数本身就是一个函数，只不过该函数是出于创建新对象的目的而定义的。

另一种方式是使用对象字面量表示法。
```
var person = {
  name : 'Nicholas',
  age : 9
};
```
在最后一个属性后面添加逗号，会在IE7及更早版本和Opera中导致错误。 在使用对象字面量语法时，属性名也可以使用字符串

```
var person = {
  'name' : 'Nicholas',
  'age' : 9,
  5 : true
};
```
这里5会被转换为字符串。

使用对象字面量语法时，如果留空其花括号，则可以定义只包含默认属性和方法的对象

```
var person = {}; //与 new Object()相同
person.name = "Nicholas";
person.age = 29;
```
开发人员更青睐对象字面量语法，因为这种语法要求的代码量少，而且能够给人封装数据的感觉。实际上，对象字面量也是向函数传递大量可选参数的首选方式。最好的做法是对那些必需值使用命名参数，而使用对象字面量来封装多个可选参数。

在通过对象字面量定义对象时，实际上不会调用Object构造函数

ES6允许直接写入变量和函数，作为对象的属性和方法。这样的书写更加简洁。
```
var v = 'world';
var obj = {
  v,
  method() {
    return 'Hello!';
  }
};
```
这种写法用于函数的返回值，将会非常方便。

在 JavaScript也可以使用方括号表示法来访问对象的属性。在使用方括号语法时，应该将要访问的属性以字符串的形式放在方括号中。方括号语法的主要优点是可以通过变量来访问属性，例如：
```
var propertyName = "name";
alert(person[propertyName]); //"Nicholas"
```

如果属性名中包含会导致语法错误的字符，或者属性名使用的是关键字或保留字，也可以使用方括号表示法。例如： `person["first name"] = "Nicholas";`

除非必须使用方括号，否则建议使用点表示法。

ES6允许字面量定义对象时，把表达式放在方括号内作为属性名。

```
var lastWord = 'last word';

var a = {
  'first word': 'hello',
  [lastWord]: 'world',
  ['h'+'ello']() {
    return 'hi';
  }
};

a['first word'] // "hello"
a[lastWord] // "world"
a['last word'] // "world"
a.hello(); //hi
```

函数的name属性，返回函数名。ES6为对象方法也添加了name属性。
```
var person = {
  sayName: function() {
    console.log(this.name);
  },
  get firstName() {
    return "Nicholas"
  }
}
person.sayName.name   // "sayName"
person.firstName.name // "get firstName"
```
上面代码中，方法的name属性返回函数名（即方法名）。如果使用了取值函数，则会在方法名前加上get。如果是存值函数，方法名的前面会加上set。

有两种特殊情况：bind方法创造的函数，name属性返回“bound”加上原函数的名字；Function构造函数创造的函数，name属性返回“anonymous”。
```
(new Function()).name // "anonymous"
var doSomething = function() {
  // ...
};
doSomething.bind().name // "bound doSomething"
```

**Object.is()**用来比较两个值是否严格相等。它与严格比较运算符（===）的行为基本一致，不同之处只有两个：一是+0不等于-0，二是NaN等于自身。
```
+0 === -0 //true
NaN === NaN // false
Object.is(+0, -0) // false
Object.is(NaN, NaN) // true
```

**Object.assign方法**用来将源对象（source）的所有可枚举属性，复制到目标对象（target）。它至少需要两个对象作为参数，第一个参数是目标对象，后面的参数都是源对象。只要有一个参数不是对象，就会抛出TypeError错误。
```
var target = { a: 1 };
var source1 = { b: 2 };
var source2 = { c: 3 };
Object.assign(target, source1, source2);
target // {a:1, b:2, c:3}
```
注意，如果目标对象与源对象有同名属性，或多个源对象有同名属性，则后面的属性会覆盖前面的属性。

assign方法有很多用处。

**1）为对象添加属性**
```
class Point {
  constructor(x, y) {
    Object.assign(this, {x, y});
  }
}
```

**2）为对象添加方法**
```
Object.assign(SomeClass.prototype, {
  someMethod(arg1, arg2) { ··· },
  anotherMethod() { ··· }
});
```

**3）克隆对象**
```
function clone(origin) {
  return Object.assign({}, origin);
}
```
不过，采用这种方法克隆，只能克隆原始对象自身的值，不能克隆它继承的值。如果想要保持继承链，可以采用下面的代码。
```
function clone(origin) {
  let originProto = Object.getPrototypeOf(origin);
  return Object.assign(Object.create(originProto), origin);
}
```

**4）合并多个对象**

将多个对象合并到某个对象。
```
const merge =
  (target, ...sources) => Object.assign(target, ...sources);
```

**5）为属性指定默认值**
```
const DEFAULTS = {
  logLevel: 0,
  outputFormat: 'html'
};

function processContent(options) {
  //用户自定义参数options和默认配置会合并
  let options = Object.assign({}, DEFAULTS, options);
}
```

`__proto__属性` ，用来读取或设置当前对象的prototype对象。该属性一度被正式写入ES6草案，但后来又被移除。目前，所有浏览器（包括IE11）都部署了这个属性。
```
var obj = {
  __proto__: someOtherObj,
  method: function() { ... }
}

// es5的写法
var obj = Object.create(someOtherObj);
obj.method = function() { ... }
```

**Object.setPrototypeOf()**方法的作用与`__proto__`相同，用来设置一个对象的prototype对象。它是ES6正式推荐的设置原型对象的方法。

```
// 格式
Object.setPrototypeOf(object, prototype)

// 用法
var o = Object.setPrototypeOf({}, null);
```

**Object.getPrototypeOf()**方法与setPrototypeOf方法配套，用于读取一个对象的prototype对象。

```
Object.getPrototypeOf(obj);
```

注意，Object.observe和Object.unobserve这两个方法不属于ES6，而是属于ES7的一部分。不过，Chrome浏览器从33版起就已经支持。

**Object.observe**方法用来监听对象（以及数组）的变化。一旦监听对象发生变化，就会触发回调函数。

```
var user = {};
Object.observe(user, function(changes){
  changes.forEach(function(change) {
    user.fullName = user.firstName+" "+user.lastName;
  });
});

user.firstName = 'Michael';
user.lastName = 'Jackson';
user.fullName // 'Michael Jackson'
```

上面代码中，Object.observer方法监听user对象。一旦该对象发生变化，就自动生成fullName属性。

一般情况下，Object.observe方法接受两个参数，第一个参数是监听的对象，第二个函数是一个回调函数。一旦监听对象发生变化（比如新增或删除一个属性），就会触发这个回调函数。很明显，利用这个方法可以做很多事情，比如自动更新DOM。

```
var div = $("#foo");

Object.observe(user, function(changes){
  changes.forEach(function(change) {
    var fullName = user.firstName+" "+user.lastName;
    div.text(fullName);
  });
});
```
上面代码中，只要user对象发生变化，就会自动更新DOM。如果配合jQuery的change方法，就可以实现数据对象与DOM对象的双向自动绑定。

回调函数的changes参数是一个数组，代表对象发生的变化。下面是一个更完整的例子。

```
var o = {};

function observer(changes){
  changes.forEach(function(change) {
    console.log('发生变动的属性：' + change.name);
    console.log('变动前的值：' + change.oldValue);
    console.log('变动后的值：' + change.object[change.name]);
    console.log('变动类型：' + change.type);
  });
}

Object.observe(o, observer);
```
参照上面代码，Object.observe方法指定的回调函数，接受一个数组（changes）作为参数。该数组的成员与对象的变化一一对应，也就是说，对象发生多少个变化，该数组就有多少个成员。每个成员是一个对象（change），它的name属性表示发生变化源对象的属性名，oldValue属性表示发生变化前的值，object属性指向变动后的源对象，type属性表示变化的种类。基本上，change对象是下面的样子。

Object.observe方法目前共支持监听六种变化。

* add：添加属性
* update：属性值的变化
* delete：删除属性
* setPrototype：设置原型
* reconfigure：属性的attributes对象发生变化
* preventExtensions：对象被禁止扩展（当一个对象变得不可扩展时，也就不必再监听了）

Object.observe方法还可以接受第三个参数，用来指定监听的事件种类。

```
Object.observe(o, observer, ['delete']);
```
上面的代码表示，只在发生delete事件时，才会调用回调函数。

**Object.unobserve**方法用来取消监听。

```
Object.unobserve(o, observer);
```

目前，ES7有一个[提案](https://github.com/sebmarkbage/ecmascript-rest-spread)，将rest参数/扩展运算符（...）引入对象。Babel转码器已经支持这项功能。

**1）Rest参数**

Rest参数用于从一个对象取值，相当于将所有可遍历的、但尚未被读取的属性，分配到指定的对象上面。所有的键和它们的值，都会拷贝到新对象上面。

```
let { x, y, ...z } = { x: 1, y: 2, a: 3, b: 4 };
x // 1
y // 2
z // { a: 3, b: 4 }
```
上面代码中，变量z是Rest参数所在的对象。它获取等号右边的所有尚未读取的键（a和b），将它们和它们的值拷贝过来。

注意，Rest参数的拷贝是浅拷贝，即如果一个键的值是复合类型的值（数组、对象、函数）、那么Rest参数拷贝的是这个值的引用，而不是这个值的副本。

另外，Rest参数不会拷贝继承自原型对象的属性。

```
let o1 = { a: 1 };
let o2 = { b: 2 };
o2.__proto__ = o1;
let o3 = { ...o2 };
o3 // { b: 2 }
```
上面代码中，对象o3是o2的复制，但是只复制了o2自身的属性，没有复制它的原型对象o1的属性。

**2）扩展运算符**

扩展运算符用于取出参数对象的所有可遍历属性，拷贝到当前对象之中。

```
let z = { a: 3, b: 4 };
let n = { ...z };
n // { a: 3, b: 4 }
```

这等同于使用`Object.assign`方法。

扩展运算符的参数对象之中，如果有取值函数`get`，这个函数是会执行的。

```
// 并不会抛出错误，因为x属性只是被定义，但没执行
let aWithXGetter = {
  ...a,
  get x() {
    throws new Error('not thrown yet');
  }
};

// 会抛出错误，因为x属性被执行了
let runtimeError = {
  ...a,
  ...{
    get x() {
      throws new Error('thrown now');
    }
  }
};
```

如果扩展运算符的参数是null或undefined，这个两个值会被忽略，不会报错。

```
let emptyObject = { ...null, ...undefined }; // 不报错
```
## Array 类型
ECMAScript 数组的每一项可以保存任何类型的数据

创建数组的基本方式有两种。第一种是使用 Array 构造函数。
```
var colors = new Array();
```
如果预先知道数组要保存的项目数量，也可以给构造函数传递该数量，而该数量会自动变成length属性的值。例如，下面的代码将创建length值为20的数组。
```
var colors = new Array(20);
```
也可以向Array构造函数传递数组中应该包含的项。以下代码创建了一个包含3个字符串值的数组：
```
var colors = new Array("red", "blue", "green");
```
当然，给构造函数传递一个值也可以创建数组。但这时候问题就复杂一点了，因为如果传递的是数值，则会按照该数值创建包含给定项数的数组；而如果传递的是其他类型的参数，则会创建包含那个值的只有一项的数组。下面就两个例子：
```
var colors = new Array(3); // 创建一个包含3 项的数组
var names = new Array("Greg"); // 创建一个包含1 项，即字符串"Greg"的数组
```
另外,在使用 Array 构造函数时也可以省略 new 操作符。
```
var colors = Array(3); // 创建一个包含3 项的数组
var names = Array("Greg"); // 创建一个包含1 项，即字符串"Greg"的数组
```

创建数组的第二种基本方式是使用数组字面量表示法。数组字面量由一对包含数组项的方括号表示，多个数组项之间以逗号隔开，如下所示：
```
var colors = ["red", "blue", "green"]; // 创建一个包含3 个字符串的数组
var names = []; // 创建一个空数组
var values = [1,2,]; // 不要这样！这样会创建一个包含2 或3 项的数组，对于IE早期版本(<=8)这里将会是三项，最后一项是undefined，下面同理
var options = [,,,,,]; // 不要这样！这样会创建一个包含5 或6 项的数组
```

ECMAScript数组的大小是可以动态调整的，即可以随着数据的添加自动增长以容纳新增数据。

与对象一样，在使用数组字面量表示法时，也不会调用Array构造函数

数组的length属性很有特点——它不是只读的。因此，通过设置这个属性，可以从数组的末尾移除项或向数组中添加新项。请看下面的例子：
```
var colors = ["red", "blue", "green"]; // 创建一个包含3 个字符串的数组
colors.length = 2;
alert(colors[2]); //undefined
```

当把一个值放在超出当前数组大小的位置上时,数组就会重新计算其长度值,即长度值
等于最后一项的索引加 1:
```
var colors = ["red", "blue", "green"];
colors[99] = "black";
alert(colors.length); // 100
```

位置3到位置98实际上都是不存在的，所以访问它们都将返回undefined。

数组最多可以包含4 294 967 295个项，这几乎已经能够满足任何编程需求了。如果想添加的项数超过这个上限值，就会发生异常。而创建一个初始大小与这个上限值接近的数组，则可能会导致运行时间超长的脚本错误。

### 检测数组
instanceof 操作符的问题在于,它假定只有一个全局执行环境。如果网页中包含多个框架,那实际上就存在两个以上不同的全局执行环境,从而存在两个以上不同版本的 Array 构造函数。如果你从一个框架向另一个框架传入一个数组,那么传入的数组与在第二个框架中原生创建的数组分别具有各自不同的构造函数。

ECMAScript 5新增了Array.isArray()方法。这个方法的目的是最终确定某个值到底是不是数组，而不管它是在哪个全局执行环境中创建的

### 转换方法
数组的toString()方法会返回由数组中每个值的字符串形式拼接而成的一个以逗号分隔的字符串。为了创建这个字符串会调用数组每一项的 toString() 方法。toLocaleString()与toString()有些类似，只不过是调用每项的toLocaleString()。而调用 valueOf()返回的还是数组。

如果使用 join() 方法,则可以使用不同的分隔符来构建这个字符串。 join() 方法只接收一个参数,即用作分隔符的字符串,然后返回包含所有数组项的字符串。如果不给 join() 方法传入任何值,或者给它传入 undefined ,则使用逗号作为分隔符。IE7 及更早版本会错误的使用字符串 "undefined" 作为分隔符。

```
var colors = ["red", "green", "blue"];
alert(colors.join()); //red,green,blue
alert(colors.join("||")); //red||green||blue
```
如果数组中的某一项的值是 null 或者 undefined，那么该值在 join()、toLocaleString()、toString() 和 valueOf() 方法返回的结果中以空字符串表示。

### 栈方法
ECMAScript为数组专门提供了push()和pop()方法，以便实现类似栈的行为。这两个方法会改变length的值
```
var colors = new Array();// 创建一个数组
var count = colors.push("red", "green"); // 推入两项
alert(count); //2
var item = colors.pop();// 取得最后一项
alert(item); //"black"
alert(colors.length); //1
```
### 队列方法
shift() 能够移除数组中的第一个项并返回该项,同时将数组长度减 1。结合使用 shift() 和 push() 方法,可以像使用队列一样使用数组。

unshift()与shift()的用途相反：它能在数组前端添加任意个项并返回新数组的长度。因此，同时使用unshift()和pop()方法，可以从相反的方向来模拟队列，即在数组的前端添加项，从数组末端移除项

### 重排序方法
数组中已经存在两个可以直接用来重排序的方法：reverse()和 sort()

sort()方法会调用每个数组项的 toString()转型方法，然后比较得到的字符串，以确定如何排序。即使数组中的每一项都是数值，sort()方法比较的也是字符串

sort()方法可以接收一个比较函数作为参数，以便我们指定哪个值位于哪个值的前面。比较函数接收两个参数，如果第一个参数应该位于第二个之前则返回一个负数，如果两个参数相等则返回0，如果第一个参数应该位于第二个之后则返回一个正数

```
function compare(value1, value2) {
  if (value1 < value2) {
    return -1;
  } else if (value1 > value2) {
    return 1;
  } else {
    return 0;
  }
}
var values = [0, 1, 5, 10, 15];
values.sort(compare);
alert(values); //0,1,5,10,15
values.sort();
alert(values); //0,1,10,15,5
```
对于数值类型或者其 valueOf() 方法会返回数值类型的对象类型,可以使用一个更简单的比较函数。这个函数只要用第二个值减第一个值即可。正数减负数可能溢出
```
function compare(value1, value2){
  return value2 - value1;
}
```
### 操作方法
concat()方法可以基于当前数组中的所有项创建一个新数组。具体来说，这个方法会先创建当前数组一个副本，然后将接收到的参数添加到这个副本的末尾，最后返回新构建的数组。在没有给concat()方法传递参数的情况下，它只是复制当前数组并返回副本。

slice()能够基于当前数组中的一或多个项创建一个新数组。slice()方法可以接受一或两个参数，即要返回项的起始和结束位置。在只有一个参数的情况下, slice() 方法返回从该参数指定位置开始到当前数组末尾的所有项。如果有两个参数,该方法返回起始和结束位置之间的项——但不包括结束位置的项。注意, slice() 方法不会影响原始数组。注意, slice() 方法不会影响原始数组。

```
var colors = ["red", "green", "blue", "yellow", "purple"];
var colors2 = colors.slice(1);
var colors3 = colors.slice(1,4);
alert(colors2); //green,blue,yellow,purple
alert(colors3); //green,blue,yellow
```
如果slice()方法的参数中有一个负数，则用数组长度加上该数来确定相应的位置。例如，在一个包含5项的数组上调用slice(-2,-1)与调用slice(3,4)得到的结果相同。如果结束位置小于起始位置，则返回空数组。

splice()方法，这个方法恐怕要算是最强大的数组方法了，它有很多种用法。splice()的主要用途是向数组的中部插入项，但使用这种方法的方式则有如下3种。
* 删除：可以删除任意数量的项，只需指定 2 个参数：要删除的第一项的位置和要删除的项数。例如，splice(0,2)会删除数组中的前两项。
* 插入：可以向指定位置插入任意数量的项，只需提供3个参数：起始位置、0（要删除的项数）和要插入的项。如果要插入多个项，可以再传入第四、第五，以至任意多个项。例如，splice(2,0,"red","green")会从当前数组的位置2开始插入字符串"red"和"green"。
* 替换：可以向指定位置插入任意数量的项，且同时删除任意数量的项，只需指定 3 个参数：起始位置、要删除的项数和要插入的任意数量的项。插入的项数不必与删除的项数相等。例如，splice (2,1,"red","green")会删除当前数组位置 2 的项，然后再从位置 2 开始插入字符串"red"和"green"。

splice()方法始终都会返回一个数组，该数组中包含从原始数组中删除的项（如果没有删除任何项，则返回一个空数组）。

### 位置方法
ECMAScript 5为数组实例添加了两个位置方法：indexOf()和lastIndexOf()。这两个方法都接收两个参数：要查找的项和（可选的）表示查找起点位置的索引。其中，indexOf()方法从数组的开头（位置0）开始向后查找，lastIndexOf()方法则从数组的末尾开始向前查找。

这两个方法都返回要查找的项在数组中的位置，或者在没找到的情况下返回-1。在比较第一个参数与数组中的每一项时，会使用全等操作符；也就是说，要求查找的项必须严格相等（就像使用===一样）。

### 迭代方法
ECMAScript 5为数组定义了5个迭代方法。每个方法都接收两个参数：要在每一项上运行的函数和（可选的）运行该函数的作用域对象——影响 this 的值。传入这些方法中的函数会接收三个参数：数组项的值、该项在数组中的位置和数组对象本身。根据使用的方法不同，这个函数执行后的返回值可能会也可能不会影响方法的返回值。以下是这5个迭代方法的作用。
* every()：对数组中的每一项运行给定函数，如果该函数对每一项都返回true，则返回 true。
* filter()：对数组中的每一项运行给定函数，返回该函数会返回true的项组成的数组。
* forEach()：对数组中的每一项运行给定函数。这个方法没有返回值。
* map()：对数组中的每一项运行给定函数，返回每次函数调用的结果组成的数组。
* some()：对数组中的每一项运行给定函数，如果该函数对任一项返回true，则返回true。

以上方法都不会修改数组中的包含的值。

### 归并方法
ECMAScript 5还新增了两个归并数组的方法：reduce()和 reduceRight()。这两个方法都会迭代数组的所有项，然后构建一个最终返回的值。其中，reduce()方法从数组的第一项开始，逐个遍历到最后。而reduceRight()则从数组的最后一项开始，向前遍历到第一项。

这两个方法都接收两个参数：一个在每一项上调用的函数和（可选的）作为归并基础的初始值。传给 reduce()和 reduceRight()的函数接收 4个参数：前一个值、当前值、项的索引和数组对象。这个函数返回的任何值都会作为第一个参数自动传给下一项。第一次迭代发生在数组的第二项上，因此第一个参数是数组的第一项，第二个参数就是数组的第二项。

```
var values = [1,2,3,4,5];
var sum = values.reduce(function(prev, cur, index, array){
  return prev + cur;
});
alert(sum); //15
var values = [1,2,3,4,5];
```
第一次执行回调函数, prev 是 1, cur 是 2。第二次, prev 是 3(1 加 2 的结果), cur 是 3(数组的第三项)。这个过程会持续到把数组中的每一项都访问一遍,最后返回结果。

### ES6 新增方法

* Array.from()
    用于将两类对象转为真正的数组：类似数组的对象（array-like object）和可遍历（iterable）的对象（包括ES6新增的数据结构Set和Map）

    Array.from方法可以将函数的arguments对象，转为数组。

    任何有length属性的对象，都可以通过Array.from方法转为数组。

    Array.from()还可以接受第二个参数，作用类似于数组的map方法，用来对每个元素进行处理。`Array.from(arrayLike, x => x * x);`等同于`Array.from(arrayLike).map(x => x * x);`

    Array.from()的一个应用是，将字符串转为数组，然后返回字符串的长度。这样可以避免JavaScript将大于\uFFFF的Unicode字符，算作两个字符的bug。
* Array.of()
    用于将一组值，转换为数组。这个方法的主要目的，是弥补数组构造函数Array()的不足。因为参数个数的不同，会导致Array()的行为有差异。`Array(3) // [undefined, undefined, undefined]`
* 数组实例的find()和findIndex()
    数组实例的find方法，用于找出第一个符合条件的数组成员。它的参数是一个回调函数，所有数组成员依次执行该回调函数，直到找出第一个返回值为true的成员，然后返回该成员。如果没有符合条件的成员，则返回undefined。`var found = [1, 4, -5, 10].find((n) => n < 0);`

    find方法的回调函数可以接受三个参数，依次为当前的值、当前的位置和原数组。

    数组实例的findIndex方法的用法与find方法非常类似，返回第一个符合条件的数组成员的位置，如果所有成员都不符合条件，则返回-1。

    这两个方法都可以接受第二个参数，用来绑定回调函数的this对象。
* 数组实例的fill()
    使用给定值，填充一个数组。fill()还可以接受第二个和第三个参数，用于指定填充的起始位置和结束位置。
* 数组实例的entries()，keys()和values()
    ES6提供三个新的方法——entries()，keys()和values()——用于遍历数组。它们都返回一个既实现了Iterable又实现了Iterator接口的对象，且该对象`Symbol.iterator`方法返回其自身，可以用for...of循环进行遍历，唯一的区别是keys()是对键名的遍历、values()是对键值的遍历，entries()是对键值对的遍历。

    {% codeblock %}
    for (let [index, elem] of ['a', 'b'].entries()) {
      console.log(index, elem);
    }
    {% endcodeblock %}

### ES7 将加入的方法

* 数组实例的includes()
    返回一个布尔值，表示某个数组是否包含给定的值。该方法属于ES7。该方法的第二个参数表示搜索的起始位置，默认为0。
* Array.observe()，Array.unobserve()
    这两个方法用于监听（取消监听）数组的变化，指定回调函数。

    它们的用法与Object.observe和Object.unobserve方法完全一致，也属于ES7的一部分，唯一的区别是，对象可监听的变化一共有六种，而数组只有四种：add、update、delete、splice（数组的length属性发生变化）

此外ES7将加入数组推导（array comprehension），以提供简洁写法，允许直接通过现有数组生成新数组。
```
var a1 = [1, 2, 3, 4];
var a2 = [for (i of a1) i * 2];
a2 // [2, 4, 6, 8]
```
上面代码表示，通过for...of结构，数组a2直接在a1的基础上生成。

注意，数组推导中，for...of结构总是写在最前面，返回的表达式写在最后面。

for...of后面还可以附加if语句，用来设定循环的限制条件。

需要注意的是，数组推导的方括号构成了一个单独的作用域，在这个方括号中声明的变量类似于使用let语句声明的变量。

## Date 类型
ECMAScript 中的 Date 类型是在早期 Java 中的 java.util.Date 类基础上构建的。

在调用Date 构造函数而不传递参数的情况下，新创建的对象自动获得当前日期和时间。如果想根据特定的日期和时间创建日期对象,必须传入表示该日期的毫秒数(即从 UTC 时间 1970 年 1 月 1 日午夜起至该日期止经过的毫秒数)。为了简化这一计算过程,ECMAScript 提供了两个方法: Date.parse()和 Date.UTC() 。

Date.parse()方法接收一个表示日期的字符串参数，然后尝试根据这个字符串返回相应日期的毫秒数。ECMA-262没有定义Date.parse()应该支持哪种日期格式，因此这个方法的行为因实现而异，而且通常是因地区而异。

如果传入Date.parse()方法的字符串不能表示日期，那么它会返回NaN。实际上，如果直接将表示日期的字符串传递给Date构造函数，也会在后台调用Date.parse()

Date.UTC()方法同样也返回表示日期的毫秒数，但它与 Date.parse()在构建值时使用不同的信息。Date.UTC()的参数分别是年份、基于 0的月份（一月是 0，二月是 1，以此类推）、月中的哪一天（1到 31）、小时数（0到 23）、分钟、秒以及毫秒数。在这些参数中，只有前两个参数（年和月）是必需的。如果没有提供月中的天数，则假设天数为 1；如果省略其他参数，则统统假设为 0。

Date 构造函数会模仿 Date.parse()和 Date.UTC()，但模仿后者有一点明显不同：日期和时间都基于本地时区而非GMT来创建。不过，Date 构造函数接收的参数仍然与Date.UTC()相同。

```
var y2k1 = new Date(Date.UTC(2000, 0));
var y2k2 = new Date(2000, 0);
var someDate1 = new Date(Date.parse("May 25, 2004"));
var someDate2 = new Date("May 25, 2004");
```

ECMAScript 5添加了Data.now()方法，返回表示调用这个方法时的日期和时间的毫秒数。这个方法简化了使用Data对象分析代码的工作。

使用+操作符把Data对象转换成数值，也可以达到同样的目的。

```
//取得开始时间 和Date.now()等效
var start = +new Date();
```

### 继承的方法
Date类型的toLocaleString()方法会按照与浏览器设置的地区相适应的格式返回日期和时间。这大致意味着时间格式中会包含AM或PM，但不会包含时区信息（当然，具体的格式会因浏览器而异）。而toString()方法则通常返回带有时区信息的日期和时间，其中时间一般以军用时间（即小时的范围是0到23）表示。

至于Date类型的valueOf()方法，则根本不返回字符串，而是返回日期的毫秒表示。

### 日期格式化方法
Date类型还有一些专门用于将日期格式化为字符串的方法，这些方法如下。
* toDateString()——以特定于实现的格式显示星期几、月、日和年；
* toTimeString()——以特定于实现的格式显示时、分、秒和时区；
* toLocaleDateString()——以特定于地区的格式显示星期几、月、日和年；
* toLocaleTimeString()——以特定于实现的格式显示时、分、秒；
* toUTCString()——以特定于实现的格式完整的UTC日期。

与toLocaleString()和toString()方法一样，以上这些字符串格式方法的输出也是因浏览器而异的，因此没有哪一个方法能够用来在用户界面中显示一致的日期信息。

除了前面介绍的方法之外,还有一个名叫 toGMTString() 的方法,这是一个与toUTCString() 等价的方法,其存在目的在于确保向后兼容。不过,ECMAScript 推荐现在编写的代码一律使用 toUTCString() 方法。

### 日期/时间组件方法
剩下还未介绍的Date类型的方法（如下表所示），都是直接取得和设置日期值中特定部分的方法了。需要注意的是，UTC日期指的是在没有时区偏差的情况下（将日期转换为GMT时间）的日期值。

方法                       | 说明
---                        | ---
getTime()                  | 返回表示日期的毫秒数;与 valueOf() 方法返回的值相同
setTime( 毫秒 )            | 以毫秒数设置日期,会改变整个日期
getFullYear()              | 取得4位数的年份(如2007而非仅07)
getUTCFullYear()           | 返回UTC日期的4位数年份
setFullYear( 年 )          | 设置日期的年份。传入的年份值必须是4位数字(如2007而非仅07)
setUTCFullYear( 年 )       | 设置UTC日期的年份。传入的年份值必须是4位数字(如2007而非仅07)
getMonth()                 | 返回日期中的月份,其中0表示一月,11表示十二月
getUTCMonth()              | 返回UTC日期中的月份,其中0表示一月,11表示十二月
setMonth( 月 )             | 设置日期的月份。传入的月份值必须大于0,超过11则增加年份
setUTCMonth( 月 )          | 设置UTC日期的月份。传入的月份值必须大于0,超过11则增加年份
getDate()                  | 返回日期月份中的天数(1到31)
getUTCDate()               | 返回UTC日期月份中的天数(1到31)
setDate( 日 )              | 设置日期月份中的天数。如果传入的值超过了该月中应有的天数,则增加月份
setUTCDate( 日 )           | 设置UTC日期月份中的天数。如果传入的值超过了该月中应有的天数,则增加月份
getDay()                   | 返回日期中星期的星期几(其中0表示星期日,6表示星期六)
getUTCDay()                | 返回UTC日期中星期的星期几(其中0表示星期日,6表示星期六)
getHours()                 | 返回日期中的小时数(0到23)
getUTCHours()              | 返回UTC日期中的小时数(0到23)
setHours( 时 )             | 设置日期中的小时数。传入的值超过了23则增加月份中的天数
setUTCHours( 时 )          | 设置UTC日期中的小时数。传入的值超过了23则增加月份中的天数
getMinutes()               | 返回日期中的分钟数(0到59)
getUTCMinutes()            | 返回UTC日期中的分钟数(0到59)
setMinutes( 分 )           | 设置日期中的分钟数。传入的值超过59则增加小时数
setUTCMinutes( 分 )        | 设置UTC日期中的分钟数。传入的值超过59则增加小时数
getSeconds()               | 返回日期中的秒数(0到59)
getUTCSeconds()            | 返回UTC日期中的秒数(0到59)
setSeconds( 秒 )           | 设置日期中的秒数。传入的值超过了59会增加分钟数
setUTCSeconds( 秒 )        | 设置UTC日期中的秒数。传入的值超过了59会增加分钟数
getMilliseconds()          | 返回日期中的毫秒数
getUTCMilliseconds()       | 返回UTC日期中的毫秒数
setMilliseconds( 毫秒 )    | 设置日期中的毫秒数
setUTCMilliseconds( 毫秒 ) | 设置UTC日期中的毫秒数
getTimezoneOffset()        | 返回本地时间与UTC时间相差的分钟数。例如,美国东部标准时间返回300。在某地进入夏令时的情况下,这个值会有所变化

## RegExp 类型

使用下面类似 Perl 的语法,就可以创建一个正则表达式。
```
var expression = / pattern / flags ;
```
其中的模式(pattern)部分可以是任何简单或复杂的正则表达式,可以包含字符类、限定符、分组、向前查找以及反向引用。每个正则表达式都可带有一或多个标志(flags),用以标明正则表达式的行为。正则表达式的匹配模式支持下列 3 个标志。
* g :表示全局(global)模式,即模式将被应用于所有字符串,而非在发现第一个匹配项时立即停止;
* i :表示不区分大小写(case-insensitive)模式,即在确定匹配项时忽略模式与字符串的大小写;
* m :表示多行(multiline)模式,即在到达一行文本末尾时还会继续查找下一行中是否存在与模式匹配的项。
ES6中新增两个标志
* u :表示“Unicode模式”，用来正确处理大于\uFFFF的Unicode字符。也就是说，会正确处理四个字节的UTF-16编码。
* y :表示“粘连”（sticky）模式。y修饰符的作用与g修饰符类似，也是全局匹配，后一次匹配都从上一次匹配成功的下一个位置开始。不同之处在于，g修饰符只要剩余位置中存在匹配就可，而y修饰符确保匹配必须从剩余的第一个位置开始，这也就是“粘连”的涵义。

```
var s = "𠮷";
//如果不添加u修饰符，正则表达式就会认为字符串为两个字符，从而匹配失败。
/^.$/.test(s) // false
/^.$/u.test(s) // true
//如果不加u修饰符，正则表达式无法识别\u{61}这种表示法，只会认为这匹配61个连续的u。
/\u{61}/u.test('a') // true
/\u{20BB7}/u.test('𠮷') // true
//使用u修饰符后，所有量词都会正确识别大于码点大于0xFFFF的Unicode字符。
/𠮷{2}/.test('𠮷𠮷') // false
/𠮷{2}/u.test('𠮷𠮷') // true
//u修饰符也影响到预定义模式，能否正确识别码点大于0xFFFF的Unicode字符。\S是预定义模式
/^\S$/.test('𠮷') // false
/^\S$/u.test('𠮷') // true
//有些Unicode字符的编码不同，但是字型很相近，比如，\u004B与\u212A都是大写的K。
/[a-z]/i.test('\u212A') // false
/[a-z]/iu.test('\u212A') // true
```
y修饰符号隐含了头部匹配的标志`ˆ`。y修饰符的设计本意，就是让头部匹配的标志ˆ在全局匹配中都有效。
```
var s = "aaa_aa_a";
var r1 = /a+/g;
var r2 = /a+/y;
r1.exec(s) // ["aaa"]
r2.exec(s) // ["aaa"]
r1.exec(s) // ["aa"]
//和g一样都是从_aa_a开始，但是y标志要求必须以a开头，所以返回null
r2.exec(s) // null
```
如果同时使用g修饰符和y修饰符，则y修饰符覆盖g修饰符。

模式中使用的所有元字符都必须转义。正则表达式中的元字符包括： `( [ { \ ^ $ | ) ? * + .]}`

```
// 匹配所有以"at"结尾的 3 个字符的组合,不区分大小写
var pattern3 = /.at/gi;
// 匹配所有".at",不区分大小写
var pattern4 = /\.at/gi;
```

这些例子都是以字面量形式来定义的正则表达式。另一种创建正则表达式的方式是使用RegExp 构造函数,它接收两个参数:一个是要匹配的字符串模式,另一个是可选的标志字符串。可以使用字面量定义的任何表达式,都可以使用构造函数来定义,如下面的例子所示。
```
// 匹配第一个"bat"或"cat",不区分大小写
var pattern1 = /[bc]at/i;
// 与 pattern1 相同,只不过是使用构造函数创建的
var pattern2 = new RegExp("[bc]at", "i");
```
要注意的是，传递给RegExp构造函数的两个参数都是字符串（ES5不能把正则表达式字面量传递给RegExp构造函数，ES6支持传递正则表达式字面量，如果同时有第二个标识参数，将覆盖字面量中的标识）。由于RegExp构造函数的模式参数是字符串，所以在某些情况下要对字符进行双重转义。所有元字符都必须双重转义，那些已经转义过的字符也是如此，例如`\n`（字符`\`在字符串中通常被转义为`\\`，而在正则表达式字符串中就会变成`\\\\`）。
```
// ES6中
new RegExp(/abc/ig, 'i').flags; //"i"
```

使用正则表达式字面量和使用 RegExp 构造函数创建的正则表达式不一样。在ECMAScript 3中，正则表达式字面量始终会共享同一个RegExp实例，而使用构造函数创建的每一个新RegExp实例都是一个新实例。
```
var re = null, i;
for (i=0; i < 10; i++){
  re = /cat/g;
  re.test("catastrophe");
}
```
循环中,即使是循环体中指定的,但实际上只为 /cat/ 创建了一个 RegExp 实例。由于实例属性(下一节介绍实例属性)不会重置,所以在循环中再次调用 test() 方法会失败。这是因为第一次调用 test() 找到了 "cat" ,但第二次调用是从索引为 3 的字符(上一次匹配的末尾)开始的,所以就找不到它了。由于会测试到字符串末尾,所以下一次再调用 test() 就又从开头开始了。

ECMAScript 5明确规定，使用正则表达式字面量必须像直接调用RegExp构造函数一样，每次都创建新的RegExp实例

### RegExp 实例属性
RegExp的每个实例都具有下列属性，通过这些属性可以取得有关模式的各种信息。
* global：布尔值，表示是否设置了g标志。
* ignoreCase：布尔值，表示是否设置了i标志。
* lastIndex：整数，表示开始搜索下一个匹配项的字符位置，从0算起。
* multiline：布尔值，表示是否设置了m标志。
* source：正则表达式的字符串表示，按照字面量形式而非传入构造函数中的字符串模式返回。
ES6新增属性
* sticky:布尔值，表示是否设置了y标志。
* flags: 字符串，表示正则表达式的标志

通过这些属性可以获知一个正则表达式的各方面信息，但却没有多大用处，因为这些信息全都包含在模式声明中。

### RegExp 实例方法

RegExp对象的主要方法是exec()，该方法是专门为捕获组而设计的。exec()接受一个参数，即要应用模式的字符串，然后返回包含第一个匹配项信息的数组；或者在没有匹配项的情况下返回null。返回的数组虽然是Array 的实例，但包含两个额外的属性：index 和input。其中，index 表示匹配项在字符串中的位置，而 input 表示应用正则表达式的字符串。在数组中，第一项是与整个模式匹配的字符串，其他项是与模式中的捕获组匹配的字符串（如果模式中没有捕获组，则该数组只包含一项）。

```
var text = "mom and dad and baby";
var pattern = /mom( and dad( and baby)?)?/gi;
var matches = pattern.exec(text);
alert(matches.index); // 0
alert(matches.input); // "mom and dad and baby"
alert(matches[0]); // "mom and dad and baby"
alert(matches[1]); // " and dad and baby"
alert(matches[2]); // " and baby"
```

对于 exec()方法而言，即使在模式中设置了全局标志（g），它每次也只会返回一个匹配项。在不设置全局标志的情况下，在同一个字符串上多次调用 exec()将始终返回第一个匹配项的信息。而在设置全局标志的情况下，每次调用exec()则都会在字符串中继续查找新匹配项

IE 的 JavaScript 实现在 lastIndex 属性上存在偏差，即使在非全局模式下，lastIndex属性每次也会变化。

正则表达式的第二个方法是 test()，它接受一个字符串参数。在模式与该参数匹配的情况下返回true；否则，返回 false。在只想知道目标字符串与某个模式是否匹配，但不需要知道其文本内容的情况下，使用这个方法非常方便

RegExp实例继承的toLocaleString()和toString()方法都会返回正则表达式的字面量，与创建正则表达式的方式无关

正则表达式的valueOf()方法返回正则表达式本身。

### RegExp 构造函数属性

RegExp 构造函数属性分别有一个长属性名和一个短属性名（Opera是例外，它不支持短属性名）。下表列出了RegExp构造函数的属性。

长属性名     | 短属性名 | 说明
---          | ---      | ---
input        | $_       | 最近一次要匹配的字符串。Opera未实现此属性
lastMatch    | $&       | 最近一次的匹配项。Opera未实现此属性
lastParen    | $+       | 最近一次匹配的捕获组。Opera未实现此属性
leftContext  | $`       | input字符串中lastMatch之前的文本
multiline    | $*       | 布尔值,表示是否所有表达式都使用多行模式。IE和Opera未实现此属性
rightContext | $'       | Input字符串中lastMatch之后的文本

```
var text = "this has been a short summer";
var pattern = /(.)hort/g;

if (pattern.test(text)){
  alert(RegExp.input); // this has been a short summer
  alert(RegExp.leftContext); // this has been a
  alert(RegExp.rightContext); // summer
  alert(RegExp.lastMatch); // short
  alert(RegExp.lastParen); // s
  alert(RegExp.multiline); // false
}
```

RegExp构造函数的各个属性返回了下列值：
* input属性返回了原始字符串；
* leftContext属性返回了单词short之前的字符串，而rightContext属性则返回了short之后的字符串；
* lastMatch属性返回最近一次与整个正则表达式匹配的字符串，即short；
* lastParen 属性返回最近一次匹配的捕获组,即例子中的s

由于短属性名大都不是有效的ECMAScript标识符，因此必须通过方括号语法来访问它们

除了上面介绍的几个属性之外，还有多达9个用于存储捕获组的构造函数属性。访问这些属性的语法是 RegExp.$1、RegExp.$2…RegExp.$9，分别用于存储第一、第二……第九个匹配的捕获组。在调用exec()或test()方法时，这些属性会被自动填充。

```
var text = "this has been a short summer";
var pattern = /(..)or(.)/g;
if (pattern.test(text)){
  alert(RegExp.$1);
  alert(RegExp.$2);
}
```

字符串必须转义，才能作为正则模式。有人提议作为RegExp对象的静态方法RegExp.escape()，放入ES7。该方法用于将字符串转义，但是最终这个方法没有被加入。

目前，该方法可以用下面的escapeRegExp函数或者垫片模块[regexp.escape](https://github.com/ljharb/regexp.escape)实现。
```
function escapeRegExp(str) {
  return str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
}
let str = '/path/to/resource.html?search=query';
escapeRegExp(str)
// "\/path\/to\/resource\.html\?search=query"
```

### 模式的局限性
ECMAScript 正则表达式不支持的特性(要了解更多相关信息。

* 匹配字符串开始和结尾的 \A 和 \Z 锚，但支持以插入符号(^)和美元符号($)来匹配字符串的开始和结尾。
* 向后查找(lookbehind),但完全支持向前查找(lookahead)
。
* 并集和交集类
* 原子组(atomic grouping)
* Unicode 支持(单个字符除外,如 \uFFFF )
* 命名的捕获组，但支持编号的捕获组。
* s (single,单行)和 x (free-spacing,无间隔)匹配模式
* 条件匹配
* 正则表达式注释

## Function 类型
说起来 ECMAScript中什么最有意思，我想那莫过于函数了——而有意思的根源，则在于函数实际上是对象。每个函数都是Function类型的实例，而且都与其他引用类型一样具有属性和方法。**由于函数是对象，因此函数名实际上也是一个指向函数对象的指针，不会与某个函数绑定**。

函数通常是使用函数声明语法定义的。
```
function sum (num1, num2) {
  return num1 + num2;
}
```
下面是使用函数表达式定义函数的方式，和上面效果是一样的。
```
var sum = function(num1, num2){
  return num1 + num2;
};
```
在使用函数表达式定义函数时，没有必要使用函数名——通过变量sum即可以引用函数。另外，还要注意函数末尾有一个分号，就像声明其他变量时一样。

最后一种定义函数的方式是使用Function构造函数。Function构造函数可以接收任意数量的参数，但最后一个参数始终都被看成是函数体，而前面的参数则枚举出了新函数的参数。
```
var sum = new Function("num1", "num2", "return num1 + num2"); // 不推荐，因为这种语法会导致解析两次代码(第一次是解析常规 ECMAScript 代码,第二次是解析传入构造函数中的字符串)
```

```
function sum(num1, num2){
  return num1 + num2;
}
alert(sum(10,10)); //20
var anotherSum = sum;
alert(anotherSum(10,10)); //20
```
**使用不带圆括号的函数名是访问函数指针，而非调用函数**

### 没有重载
将函数名想象为指针，也有助于理解为什么 ECMAScript中没有函数重载的概念。在创建第二个同名函数时,实际上覆盖了引用第一个函数的函数名变量。

### 函数声明与函数表达式
解析器会率先读取函数声明，并使其在执行任何代码之前可用（可以访问）；至于函数表达式，则必须等到解析器执行到它所在的代码行，才会真正被解释执行

在代码开始执行之前，解析器就已经通过一个名为函数声明提升（function declaration hoisting）的过程，读取并将函数声明添加到执行环境中。对代码求值时，JavaScript引擎在第一遍会声明函数并将它们放到源代码树的顶部

```
alert(sum(10,10));
function sum(num1, num2){
  return num1 + num2;
}
```
上面的例子可以正常运行，但是下面的运行时会抛出错误
```
alert(sum(10,10));
var sum = function(num1, num2){
  return num1 + num2;
}
```

也可以同时使用函数声明和函数表达式，例如var sum = function sum(){}。不过，这种语法在Safari中会导致错误。

### 作为值的函数
因为 ECMAScript中的函数名本身就是变量，所以函数也可以作为值来使用。也就是说，不仅可以像传递参数一样把一个函数传递给另一个函数，而且可以将一个函数作为另一个函数的结果返回（将函数返回这是一种很有用的技巧）

```
function callSomeFunction(someFunction, someArgument){ //someFunction是一个函数
  return someFunction(someArgument);
}
```

### 函数内部属性
在函数内部，有两个特殊的对象：arguments和this。arguments是一个类数组对象，包含着传入函数中的所有参数。虽然 arguments 的主要用途是保存函数参数，但这个对象还有一个名叫callee的属性，该属性是一个指针，指向拥有这个arguments对象的函数。
```
function factorial(num){
  if (num <=1) {
    return 1;
  } else {
    // return num * factorial(num - 1); 和下面效果相同，但是如果引用函数的变量名不是factorial而是var a = factorial，同时factorial被指向另一个函数，通过a调用该方法，那么这样就会有问题了
    return num * arguments.callee(num-1); //通过这种方法，消除了和函数名的耦合
  }
}
```

函数内部的另一个特殊对象是 this ,其行为与 Java 和 C#中的 this 大致类似。this引用的是函数据以执行的环境对象——或者也可以说是this值（当在网页的全局作用域中调用函数时，this对象引用的就是window）。

一定要牢记，函数的名字仅仅是一个包含指针的变量而已。

ECMAScript 5也规范化了另一个函数对象的属性：caller。除了 Opera的早期版本不支持，其他浏览器都支持这个 ECMAScript 3并没有定义的属性。这个属性中保存着调用当前函数的函数的引用，如果是在全局作用域中调用当前函数，它的值为null。

同样，为了实现更松散的耦合，可以通过arguments.callee.caller访问调用当前函数的函数的引用

```
function outer(){
  inner();
}
function inner(){
  alert(arguments.callee.caller);
}
outer();
```

当函数在严格模式下运行时，访问 arguments.callee 会导致错误。ECMAScript 5 还定义了arguments.caller属性，但在严格模式下访问它也会导致错误，而在非严格模式下这个属性始终是undefined。定义这个属性是为了分清arguments.caller 和函数的caller 属性。以上变化都是为了加强这门语言的安全性，这样第三方代码就不能在相同的环境里窥视其他代码了。 严格模式还有一个限制：不能为函数的caller属性赋值，否则会导致错误。

### 函数属性和方法
ECMAScript 中的函数是对象，因此函数也有属性和方法。每个函数都包含两个属性：length 和prototype。其中，length 属性表示函数希望接收的命名参数（形参）的个数

对于ECMAScript中的引用类型而言，prototype是保存它们所有实例方法的真正所在。换句话说，诸如toString()和valueOf()等方法实际上都保存在prototype名下，只不过是通过各自对象的实例访问罢了。在创建自定义引用类型以及实现继承时，prototype属性的作用是极为重要的（第6章将详细介绍）。在ECMAScript 5中，prototype属性是不可枚举的，因此使用for-in无法发现。

每个函数都包含两个非继承而来的方法：apply()和 call()。这两个方法的用途都是在特定的作用域中调用函数，实际上等于设置函数体内this对象的值。首先，apply()方法接收两个参数：一个是在其中运行函数的作用域，另一个是参数数组。其中，第二个参数可以是 Array 的实例，也可以是arguments对象

下例中，因为是在全局作用域中调用的,所以传入的就是 window 对象
```
function sum(num1, num2){
  return num1 + num2;
}
function callSum1(num1, num2){
  return sum.apply(this, arguments); // 传入 arguments 对象
}
function callSum2(num1, num2){
  return sum.apply(this, [num1, num2]); // 传入数组
}
alert(callSum1(10,10)); //20
alert(callSum2(10,10)); //20
```

在严格模式下，未指定环境对象而调用函数，则 this 值不会转型为 window。除非明确把函数添加到某个对象或者调用 apply()或 call()，否则 this 值将是undefined

call() 方法与 apply()方法的作用相同，它们的区别仅在于接收参数的方式不同。对于 call()方法而言，第一个参数是this值没有变化，变化的是其余参数都直接传递给函数。换句话说，在使用call()方法时,传递给函数的参数必须逐个列举出来

传递参数并非apply()和call()真正的用武之地；它们真正强大的地方是能够扩充函数赖以运行的作用域。

```
window.color = "red";
var o = { color: "blue" };
function sayColor(){
  alert(this.color);
}
sayColor(); //red
sayColor.call(this);//red
sayColor.call(window); //red
sayColor.call(o); //blue
```

使用call()（或apply()）来扩充作用域的最大好处，就是对象不需要与方法有任何耦合关系。如上sayColor方法就没有和具体对象耦合

ECMAScript 5还定义了一个方法：bind()。这个方法会创建一个函数的实例，其 this 值会被绑定到传给bind()函数的值

```
window.color = "red";
var o = { color: "blue" };
function sayColor(){
  alert(this.color);
}
var objectSayColor = sayColor.bind(o);
objectSayColor(); //blue
```

每个函数继承的 toLocaleString()和 toString()方法始终都返回函数的代码

另外一个继承的valueOf()方法同样也只返回函数代码。

### 默认参数
ES6允许为函数的参数设置默认值，即直接写在参数定义的后面。
```
function log(x, y = 'World') {
  console.log(x, y);
}
log('Hello') // Hello World
```

默认值的写法非常灵活，下面是一个为对象属性设置默认值的例子。
```
function fetch(url, { body = '', method = 'GET', headers = {} }){
  console.log(method);
}
```
上面代码中，传入函数fetch的第二个参数是一个对象，调用的时候可以为它的三个属性设置默认值。

甚至还可以设置双重默认值。
```
function fetch(url, { method = 'GET' } = {}){
  console.log(method);
}
```
上面代码中，调用函数fetch时，如果不含第二个参数，则默认值为一个空对象；如果包含第二个参数，则它的method属性默认值为GET。

定义了默认值的参数，必须是函数的尾部参数，其后不能再有其他无默认值的参数。

如果传入undefined，将触发该参数等于默认值，null则没有这个效果。

指定了默认值以后，函数的length属性，将返回没有指定默认值的参数个数。
```
(function(a, b, c = 5){}).length // 2
```

利用参数默认值，可以指定某一个参数不得省略，如果省略就抛出一个错误。
````
function throwIfMissing() {
  throw new Error('Missing parameter');
}

function foo(mustBeProvided = throwIfMissing()) {
  return mustBeProvided;
}

foo()
// Error: Missing parameter
```
上面代码的foo函数，如果调用的时候没有参数，就会调用默认值throwIfMissing函数，从而抛出一个错误。

从上面代码还可以看到，参数mustBeProvided的默认值等于throwIfMissing函数的运行结果（即函数名之后有一对圆括号），这表明参数的默认值不是在定义时执行，而是在运行时执行（即如果参数已经赋值，默认值中的函数就不会运行），这与python语言不一样。

另一个需要注意的地方是，参数默认值所处的作用域，不是全局作用域，而是函数作用域。
```
var x = 1;
function foo(x, y = x) {
  console.log(y);
}
foo(2) // 2
```
上面代码中，参数y的默认值等于x，由于处在函数作用域，所以y等于参数x，而不是全局变量x。

参数默认值可以与解构赋值，联合起来使用。
```
function foo({x, y = 5}) {
  console.log(x, y);
}

foo({}) // undefined, 5
foo({x: 1}) // 1, 5
foo({x: 1, y: 2}) // 1, 2
```
上面代码中，foo函数的参数是一个对象，变量x和y用于解构赋值，y有默认值5。

### rest参数
ES6引入rest参数（形式为“...变量名”），用于获取函数的多余参数，这样就不需要使用arguments对象了。rest参数搭配的变量是一个数组，该变量将多余的参数放入数组中。（和Java的变长参数类似）

注意，rest参数之后不能再有其他参数（即只能是最后一个参数），否则会报错。

函数的length属性，不包括rest参数。
```
(function(a, ...b) {}).length  // 1
```
### 扩展运算符
扩展运算符（spread）是三个点（...）。它好比rest参数的逆运算，将一个数组转为用逗号分隔的参数序列。该运算符主要用于函数调用。
```
//下面max,push 方法不接受数组
// ES6的写法
Math.max(...[14, 3, 77])
// 等同于
Math.max(14, 3, 77);

// ES5的写法
var arr1 = [0, 1, 2];
var arr2 = [3, 4, 5];
Array.prototype.push.apply(arr1, arr2);
// ES6的写法
var arr1 = [0, 1, 2];
var arr2 = [3, 4, 5];
arr1.push(...arr2);

var a = [1];
var b = [2, 3, 4];
var c = [6, 7];
var d = [0, ...a, ...b, 5, ...c];
```
上面代码其实也提供了，将一个数组拷贝进另一个数组的便捷方法。
```
const arr2 = [...arr1];
```

扩展运算符也可以与解构赋值结合起来，用于生成数组。
```
const [first, ...rest] = [1, 2, 3, 4, 5];
const [...butLast, last] = [1, 2, 3, 4, 5]; // 报错
```
如果将扩展运算符用于数组赋值，只能放在参数的最后一位，否则会报错。

任何类似数组的对象，都可以用扩展运算符转为真正的数组。
```
var nodeList = document.querySelectorAll('div');
var array = [...nodeList];
```
上面代码中，querySelectorAll方法返回的是一个nodeList对象，扩展运算符可以将其转为真正的数组。

扩展运算符内部调用的是数据结构的Iterable接口，因此只要具有Iterable接口的对象，都可以使用扩展运算符，比如Map结构。
```
let map = new Map([
  [1, 'one'],
  [2, 'two'],
  [3, 'three'],
]);

let arr = [...map.keys()]; // [1, 2, 3]
```
Generator函数运行后，返回一个同时实现了Iterator和Iterable接口的对象，因此也可以使用扩展运算符。
```
var go = function*(){
  yield 1;
  yield 2;
  yield 3;
};

[...go()] // [1, 2, 3]
```
上面代码中，变量go是一个Generator函数，执行后返回的是一个Iterable对象，对这个对象执行扩展运算符，就会将内部遍历得到的值，转为一个数组。

## 基本包装类型
为了便于操作基本类型值，ECMAScript提供了3个特殊的引用类型：Boolean、Number和String。实际上，每当读取一个基本类型值的时候，后台就会创建一个对应的基本包装类型的对象，从而让我们能够调用一些方法来操作这些数据。

```
var i = 1 .toString(); //注意空格，否则会被当浮点数解析，然后抛错，还可以写为(1).toString()  1..toString()
```
上例中实际执行了三步：1. 创建Number类型的一个实例 2. 在实例上调用指定方法 3. 销毁这个实例

引用类型与基本包装类型的主要区别就是对象的生存期。使用new操作符创建的引用类型的实例，在执行流离开当前作用域之前都一直保存在内存中。而自动创建的基本包装类型的对象，则只存在于一行代码的执行瞬间，然后立即被销毁。这意味着我们不能在运行时为基本类型值添加属性和方法
```
var s1 = "some text";
s1.color = "red";
alert(s1.color); //undefined
```
在此,第二行代码试图为字符串 s1 添加一个 color 属性。但是,当第三行代码再次访问 s1 时, 其 color 属性不见了。问题的原因就是第二行创建的 String 对象在执行第三行代码时已经被销毁了。第三行代码又创建自己的 String 对象,而该对象没有 color 属性。

Object构造函数也会像工厂方法一样，根据传入值的类型返回相应基本包装类型的实例。
```
var obj = new Object("some text");
alert(obj instanceof String); //true
```

要注意的是，使用new调用基本包装类型的构造函数，与直接调用同名的转型函数是不一样的。 例如：
```
var value = "25";
var number = Number(value); //转型函数
alert(typeof number); //"number"
var obj = new Number(value); //构造函数
alert(typeof obj); //"object"
```

### Boolean 类型
Boolean 对象在 ECMAScript 中的用处不大,因为它经常会造成人们的误解。所以不推荐使用。
```
var falseObject = new Boolean(false);
var result = falseObject && true;
alert(result); //这里返回的是true 布尔表达式中的所有对象都会被转换为true
```
基本类型与引用类型的布尔值还有两个区别。首先，typeof操作符对基本类型返回"boolean"，而对引用类型返回"object"。其次，由于Boolean对象是Boolean类型的实例，所以使用instanceof操作符测试Boolean对象会返回true，而测试基本类型的布尔值则返回false。

### Number 类型
和Boolean类型类似，不推荐直接创建Number类型的实例，而应该使用基本类型。

toFixed()方法会按照指定的小数位返回数值的字符串表示。J如果数值本身包含的小数位比指定的还多，那么接近指定的最大小数位的值就会舍入
```
alert((10).toFixed(2)); //"10.00"
alert((10.005).toFixed(2)); //"10.01"
```

toFixed() 方法可以表示带有 0 到 20 个小数位的数值。但这只是标准实现的范围,有些浏览器也可能支持更多位数。

另外可用于格式化数值的方法是toExponential()，该方法返回以指数表示法（也称e表示法）表示的数值的字符串形式。与toFixed()一样，toExponential()也接收一个参数，而且该参数同样也是指定输出结果中的小数位数
```
alert((10).toExponential(1)); //"1.0e+1"
```

如果你想得到表示某个数值的最合适的格式,就应该使用 toPrecision() 方法。对于一个数值来说，toPrecision()方法可能会返回固定大小（fixed）格式，也可能返回指数（exponential）格式；具体规则是看哪种格式最合适。这个方法接收一个参数，即表示数值的所有数字的位数（不包括指数部分）。
```
var num = 99;
alert(num.toPrecision(1)); //"1e+2"
alert(num.toPrecision(2)); //"99"
alert(num.toPrecision(3)); //"99.0"
```

ES6提供了二进制和八进制数值的新的写法，分别用前缀0b和0o表示。
```
0b111110111 === 503 // true
0o767 === 503 // true
```

八进制不再允许使用前缀0表示，而改为使用前缀0o。

ES6在Number对象上，新提供了Number.isFinite()和Number.isNaN()两个方法，用来检查无穷（infinity）和NaN这两个特殊值。它们与传统的全局方法isFinite()和isNaN()的区别在于，传统方法先调用Number()将非数值的值转为数值，再进行判断，而这两个新方法只对数值有效，非数值一律返回false。

ES6将全局方法parseInt()和parseFloat()，移植到Number对象上面，行为完全保持不变。

Number.isInteger()用来判断一个值是否为整数。需要注意的是，在JavaScript内部，整数和浮点数是同样的储存方法，所以3和3.0被视为同一个值。`Number.isInteger(25.0) // true`

JavaScript能够准确表示的整数范围在-2ˆ53 and 2ˆ53之间。ES6引入了`Number.MAX_SAFE_INTEGER`和`Number.MIN_SAFE_INTEGER`这两个常量，用来表示这个范围的上下限。Number.isSafeInteger()则是用来判断一个整数是否落在这个范围之内。

### String 类型
和Java中的String有点类似，String类型的方法只是返回一个新的字符串，不会改变原字符串。

String类型的每个实例都有一个length属性，表示字符串中包含多个字符。应该注意的是，即使字符串中包含双字节字符（不是占一个字节的ASCII字符），每个字符也仍然算一个字符。

两个用于访问字符串中特定字符的方法是：charAt()和 charCodeAt()。这两个方法都接收一个参数，即基于 0 的字符位置。其中，charAt()方法以单字符字符串的形式返回给定位置的那个字符

如果你想得到的不是字符而是字符编码，那么就要像下面这样使用charCodeAt()了。
```
var stringValue = "hello world"; alert(stringValue.charCodeAt(1)); //输出"101"
```
ECMAScript 5还定义了另一个访问个别字符的方法。在支持此方法的浏览器中，可以使用方括号加数字索引来访问字符串中的特定字符

concat()，用于将一或多个字符串拼接起来，返回拼接得到的新字符串。应用更多的还是加号操作符。

ECMAScript还提供了三个基于子字符串创建新字符串的方法：slice()、substr()和substring()。这三个方法都会返回被操作字符串的一个子字符串，而且也都接受一或两个参数。第一个参数指定子字符串的开始位置，第二个参数（在指定的情况下）表示子字符串到哪里结束。具体来说，slice()和substring()的第二个参数指定的是子字符串最后一个字符后面的位置。而 substr() 的第二个参数指定的则是返回的字符个数。如果没有给这些方法传递第二个参数，则将字符串的长度作为结束位置。与concat()方法一样，slice()、substr()和 substring()也不会修改字符串本身的值——它们只是返回一个基本类型的字符串值，对原始字符串没有任何影响。

在传递给这些方法的参数是负值的情况下，它们的行为就不尽相同了。其中，slice()方法会将传入的负值与字符串的长度相加，substr()方法将负的第一个参数加上字符串的长度，而将负的第二个参数转换为0。最后，substring()方法会把所有负值参数都转换为0
```
var stringValue = "hello world";
alert(stringValue.slice(-3)); //"rld" slice(8)
alert(stringValue.substring(-3)); //"hello world" substring(0)
alert(stringValue.substr(-3)); //"rld" substr(8)
alert(stringValue.slice(3, -4)); //"lo w" slice(3, 7)
alert(stringValue.substring(3, -4)); //"hel" substring(3,0) 而由于这个方法会将较小的数作为开始位置,将较大的数作为结束位置, 因此最终相当于调用了 substring(0,3)
alert(stringValue.substr(3, -4)); //""(空字符串) substr(3,0)
```

有两个可以从字符串中查找子字符串的方法：indexOf()和lastIndexOf()。这两个方法都是从一个字符串中搜索给定的子字符串，然后返子字符串的位置（如果没有找到该子字符串，则返回-1）。这两个方法都可以接收可选的第二个参数，表示从字符串中的哪个位置开始搜索

trim()方法。这个方法会创建一个字符串的副本，删除前置及后缀的所有空格，然后返回结果。Firefox 3.5+、Safari 5+和Chrome 8+还支持非标准的trimLeft()和trimRight()方法，分别用于删除字符串开头和末尾的空格。

接下来我们要介绍的是一组与大小写转换有关的方法。ECMAScript 中涉及字符串大小写转换的方法有4个：toLowerCase()、toLocaleLowerCase()、toUpperCase()和toLocaleUpperCase()。

String类型定义了几个用于在字符串中匹配模式的方法。第一个方法就是match()，在字符串上调用这个方法，本质上与调用 RegExp 的 exec()方法相同。match()方法只接受一个参数，要么是一个正则表达式，要么是一个RegExp对象

另一个用于查找模式的方法是search()。这个方法的唯一参数与match()方法的参数相同：由字符串或 RegExp 对象指定的一个正则表达式。search()方法返回字符串中第一个匹配项的索引；如果没有找到匹配项，则返回-1。

为了简化替换子字符串的操作，ECMAScript提供了replace()方法。这个方法接受两个参数：第一个参数可以是一个 RegExp 对象或者一个字符串（这个字符串不会被转换成正则表达式），第二个参数可以是一个字符串或者一个函数。如果第一个参数是字符串，那么只会替换第一个子字符串。要想替换所有子字符串，唯一的办法就是提供一个正则表达式，而且要指定全局（g）标志

如果第二个参数是字符串,那么还可以使用一些特殊的字符序列,将正则表达式操作得到的值插入到结果字符串中。下表列出了ECMAScript提供的这些特殊的字符序列。

字符序列 | 替换文本
---      | ---
$$       | $
$&       | 匹配整个模式的子字符串。与 RegExp.lastMatch 的值相同
$'       | 匹配的子字符串之前的子字符串。与 RegExp.leftContext 的值相同
$`       | 匹配的子字符串之后的子字符串。与 RegExp.rightContext 的值相同
$n       | 匹配第n个捕获组的子字符串,其中n等于0~9。例如, $1 是匹配第一个捕获组的子字符串, $2 是匹配第二个捕获组的子字符串,以此类推。如果正则表达式中没有定义捕获组,则使用空字符串
$nn      | 匹配第nn个捕获组的子字符串,其中nn等于01~99。例如, $01 是匹配第一个捕获组的子字符串, $02是匹配第二个捕获组的子字符串,以此类推。如果正则表达式中没有定义捕获组,则使用空字符串

replace()方法的第二个参数也可以是一个函数。在只有一个匹配项（即与模式匹配的字符串）的情况下，会向这个函数传递3个参数：模式的匹配项、模式匹配项在字符串中的位置和原始字符串。在正则表达式中定义了多个捕获组的情况下，传递给函数的参数依次是模式的匹配项、第一个捕获组的匹配项、第二个捕获组的匹配项……，但最后两个参数仍然分别是模式的匹配项在字符串中的位置和原始字符串。这个函数应该返回一个字符串，表示应该被替换的匹配项使用函数作为 replace()方法的第二个参数可以实现更加精细的替换操作

最后一个与模式匹配有关的方法是split()，这个方法可以基于指定的分隔符将一个字符串分割成多个子字符串，并将结果放在一个数组中。分隔符可以是字符串，也可以是一个RegExp对象（这个方法不会将字符串看成正则表达式）。split()方法可以接受可选的第二个参数，用于指定数组的大小，以便确保返回的数组不会超过既定大小。

对 split() 中正则表达式的支持因浏览器而异。尽管对于简单的模式没有什么差别,但对于未发现匹配项以及带有捕获组的模式,匹配的行为就不大相同了。以下是几种常见的差别。
* IE8 及之前版本会忽略捕获组。ECMA-262 规定应该把捕获组拼接到结果数组中。IE9 能正确地在结果中包含捕获组。
* Firefox 3.6 及之前版本在捕获组未找到匹配项时,会在结果数组中包含空字符串;ECMA-262 规定没有匹配项的捕获组在结果数组中应该用 undefined 表示。

ES6将match()、replace()、search()和split()这4个方法，在语言内部全部调用RegExp的实例方法，从而做到所有与正则相关的方法，全都定义在RegExp对象上。

* String.prototype.match 调用 RegExp.prototype[Symbol.match]
* String.prototype.replace 调用 RegExp.prototype[Symbol.replace]
* String.prototype.search 调用 RegExp.prototype[Symbol.search]
* String.prototype.split 调用 RegExp.prototype[Symbol.split]

与操作字符串有关的最后一个方法是localeCompare()，这个方法比较两个字符串，并返回下列值中的一个：
* 如果字符串在字母表中应该排在字符串参数之前，则返回一个负数（大多数情况下是-1，具体的值要视实现而定）；
* 如果字符串等于字符串参数，则返回0；
* 如果字符串在字母表中应该排在字符串参数之后，则返回一个正数（大多数情况下是1，具体的值同样要视实现而定）。

另外，String 构造函数本身还有一个静态方法：fromCharCode()。这个方法的任务是接收一或多个字符编码，然后将它们转换成一个字符串

一些被浏览器扩展的方法，应该尽量不使用这些方法,因为它们创建的标记通常无法表达语义。

方法             | 输出结果
---              | ---
anchor(name)     | `<a name= "name">string</a>`
big()            | `<big>string</big>`
bold()           | `<b>string</b>`
fixed()          | `<tt>string</tt>`
fontcolor(color) | `<font color="color">string</font>`
fontsize(size)   | `<font size="size">string</font>`
italics()        | `<i>string</i>`
link(url)        | `<a href="url">string</a>`
small()          | `<small>string</small>`
strike()         | `<strike>string</strike>`
sub()            | `<sub>string</sub>`
sup()            | `<sup>string</sup>`

ECMAScript6中对String进行了扩展。

对于Unicode字符，之前`\u20BB7`会被解析为`\u20BB+7`。由于\u20BB是一个不可打印字符，所以只会显示一个空格，后面跟着一个7。ES6对这一点做出了改进，只要将码点放入大括号，就能正确解读该字符。`\u{20BB7}`

ES6提供了String.fromCodePoint方法，可以识别码点大于0xFFFF（辅助平面）的字符，弥补了String.fromCharCode方法的不足。在作用上，正好与codePointAt方法相反。
```
String.fromCharCode(0x20BB7);// "ஷ"
String.fromCodePoint(0x20BB7);// "𠮷"
```
注意，fromCodePoint方法定义在String对象上，而codePointAt方法定义在字符串的实例对象上。

ES6提供了String.codePointAt方法，能够正确处理4个字节储存的字符，返回一个字符的码点。
```
var s = "𠮷a";

s.codePointAt(0) // 134071
s.codePointAt(1) // 57271

s.charCodeAt(0) // 55362
s.charCodeAt(1) // 57271
s.charCodeAt(2) // 97
```
上面代码中，汉字“𠮷”的码点是0x20BB7，UTF-16编码为0xD842 0xDFB7（十进制为55362 57271），需要4个字节储存。对于这种4个字节的字符，JavaScript不能正确处理，字符串长度会误判为2，而且charAt方法无法读取字符，charCodeAt方法只能分别返回前两个字节和后两个字节的值。

codePointAt方法的参数，是字符在字符串中的位置（从0开始）。上面代码中，JavaScript将“𠮷a”视为三个字符，codePointAt方法在第一个字符上，正确地识别了“𠮷”，返回了它的十进制码点134071（即十六进制的20BB7）。在第二个字符（即“𠮷”的后两个字节）和第三个字符“a”上，codePointAt方法的结果与charCodeAt方法相同。

ES5对字符串对象提供charAt方法，返回字符串给定位置的字符。该方法不能识别码点大于0xFFFF的字符。

ES7提供了字符串实例的at方法，可以识别Unicode编号大于0xFFFF的字符，返回正确的字符。Chrome浏览器已经支持该方法。
```
'𠮷'.charAt(0) // "\uD842"

'abc'.at(0) // "a"
'𠮷'.at(0) // "𠮷"
```

为了表示语调和重音符号，Unicode提供了两种方法。一种是直接提供带重音符号的字符，比如Ǒ（\u01D1）。另一种是提供合成符号（combining character），即原字符与重音符号的合成，两个字符合成一个字符，比如O（\u004F）和ˇ（\u030C）合成Ǒ（\u004F\u030C）。

这两种表示方法，在视觉和语义上都等价，但是JavaScript不能识别。
```
'\u01D1'.normalize() === '\u004F\u030C'.normalize(); // true
```

normalize方法可以接受四个参数。

* NFC，默认参数，表示“标准等价合成”（Normalization Form Canonical Composition），返回多个简单字符的合成字符。所谓“标准等价”指的是视觉和语义上的等价。
* NFD，表示“标准等价分解”（Normalization Form Canonical Decomposition），即在标准等价的前提下，返回合成字符分解的多个简单字符。
* NFKC，表示“兼容等价合成”（Normalization Form Compatibility Composition），返回合成字符。所谓“兼容等价”指的是语义上存在等价，但视觉上不等价，比如“囍”和“喜喜”。
* NFKD，表示“兼容等价分解”（Normalization Form Compatibility Decomposition），即在兼容等价的前提下，返回合成字符分解的多个简单字符。

不过，normalize方法目前不能识别三个或三个以上字符的合成。这种情况下，还是只能使用正则表达式，通过Unicode编号区间判断。

传统上，JavaScript只有indexOf方法，可以用来确定一个字符串是否包含在另一个字符串中。ES6又提供了三种新方法。
* includes()：返回布尔值，表示是否找到了参数字符串。
* startsWith()：返回布尔值，表示参数字符串是否在源字符串的头部。
* endsWith()：返回布尔值，表示参数字符串是否在源字符串的尾部。

这三个方法都支持第二个参数，表示开始搜索的位置。使用第二个参数n时，endsWith的行为与其他两个方法有所不同。它针对前n个字符，而其他两个方法针对从第n个位置直到字符串结束。

repeat()返回一个新字符串，表示将原字符串重复n次。
```
"hello".repeat(3) // "hellohellohello"
```

模板字符串（template string）是增强版的字符串，用反引号（\`）标识。它可以当作普通字符串使用，也可以用来定义多行字符串，或者在字符串中嵌入变量。模板字符串中嵌入变量，需要将变量名写在`${}`之中。

```
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
如果在模板字符串中需要使用反引号，则前面要用反斜杠转义。

大括号内部可以放入任意的JavaScript表达式，可以进行运算，以及引用对象属性。模板字符串之中还能调用函数

如果使用模板字符串表示多行字符串，所有的空格和缩进都会被保留在输出之中。

如果大括号中的值不是字符串，将按照一般的规则转为字符串。比如，大括号中是一个对象，将默认调用对象的toString方法。

如果模板字符串中的变量没有声明，将报错。

标签模板

模板字符串的功能，不仅仅是上面这些。它可以紧跟在一个函数名后面，该函数将被调用来处理这个模板字符串。这被称为“标签模板”功能（tagged template）。
```
var a = 5;
var b = 10;
tag`Hello ${ a + b } world ${ a * b }`;
```

上面代码中，模板字符串前面有一个标识名tag，它是一个函数。整个表达式的返回值，就是tag函数处理模板字符串后的返回值。

函数tag依次会接收到多个参数。
```
function tag(stringArr, value1, value2){ // ...  }
// 等同于
function tag(stringArr, ...values){ // ...  }
```

tag函数的第一个参数是一个数组，该数组的成员是模板字符串中那些没有变量替换的部分，也就是说，变量替换只发生在数组的第一个成员与第二个成员之间、第二个成员与第三个成员之间，以此类推。

tag函数的其他参数，都是模板字符串各个变量被替换后的值。由于本例中，模板字符串含有两个变量，因此tag会接受到value1和value2两个参数。

tag函数所有参数的实际值如下。

* 第一个参数：['Hello ', ' world ', '']
* 第二个参数: 15
* 第三个参数：50

```
var a = 5;
var b = 10;

function tag(s, v1, v2) {
  console.log(s[0]);
  console.log(s[1]);
  console.log(s[2]);
  console.log(v1);
  console.log(v2);
  return "OK";
}

tag`Hello ${ a + b } world ${ a * b}`;
// "Hello "
// " world "
// ""
// 15
// 50
// "OK"
```
“标签模板”的一个重要应用，就是过滤HTML字符串，防止用户输入恶意内容。
```
var message =
  SaferHTML`<p>${sender} has sent you a message.</p>`;

function SaferHTML(templateData) {
  var s = templateData[0];
  for (var i = 1; i < arguments.length; i++) {
    var arg = String(arguments[i]);

    // Escape special characters in the substitution.
    s += arg.replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;");

    // Don't escape special characters in the template.
    s += templateData[i];
  }
  return s;
}
```
标签模板的另一个应用，就是多语言转换（国际化处理）。

模板字符串本身并不能取代Mustache之类的模板库，因为没有条件判断和循环处理功能，但是通过标签函数，你可以自己添加这些功能。

模板处理函数的第一个参数（模板字符串数组），还有一个raw属性。
```
tag`First line\nSecond line`

function tag(strings) {
  console.log(strings.raw[0]);
  // "First line\\nSecond line"
}
```
上面代码中，tag函数的第一个参数strings，有一个raw属性，也指向一个数组。该数组的成员与strings数组完全一致。比如，strings数组是`["First line\nSecond line"]`，那么strings.raw数组就是`["First line\\nSecond line"]`。两者唯一的区别，就是字符串里面的斜杠都被转义了。比如，strings.raw数组会将`\n`视为`\`和`n`两个字符，而不是换行符。这是为了方便取得转义之前的原始模板而设计的。

ES6还为原生的String对象，提供了一个raw方法。String.raw方法，往往用来充当模板字符串的处理函数，返回一个斜杠都被转义（即斜杠前面再加一个斜杠）的字符串，对应于替换变量后的模板字符串。

```
String.raw`Hi\n${2+3}!`;
// "Hi\\n5!"

String.raw`Hi\u000A!`;
// 'Hi\\u000A!'
```

String.raw方法可以作为处理模板字符串的基本方法，它会将所有变量替换，而且对斜杠进行转义，方便下一步作为字符串来使用。

String.raw方法也可以作为正常的函数使用。这时，它的第一个参数，应该是一个具有raw属性的对象，且raw属性的值应该是一个数组。

```
String.raw({ raw: 'test' }, 0, 1, 2); // 't0e1s2t'

// 等同于
String.raw({ raw: ['t','e','s','t'] }, 0, 1, 2);
```

## 单体内置对象
### Global对象
Global（全局）对象可以说是ECMAScript中最特别的一个对象了，因为不管你从什么角度上看，这个对象都是不存在的。ECMAScript中的Global对象在某种意义上是作为一个终极的“兜底儿对象”来定义的。换句话说，不属于任何其他对象的属性和方法，最终都是它的属性和方法。事实上，没有全局变量或全局函数；所有在全局作用域中定义的属性和函数，都是Global对象的属性。诸如 isNaN() 、 isFinite() 、 parseInt() 以及 parseFloat() ,实际上全都是 Global 对象的方法。

* URI 编码方法
    对象的 encodeURI()和 encodeURIComponent()方法可以对 URI（Uniform Resource Identifiers，通用资源标识符）进行编码，以便发送给浏览器。有效的 URI 中不能包含某些字符，例如空格。而这两个URI编码方法就可以对URI进行编码，它们用特殊的UTF-8编码替换所有无效的字符，从而让浏览器能够接受和理解。 其中，encodeURI()主要用于整个URI（例如，`http://www.wrox.com/illegal value.htm`），而 encodeURIComponent()主要用于对URI中的某一段（例如前面URI中的illegal value.htm）进行编码。它们的主要区别在于，encodeURI()不会对本身属于 URI 的特殊字符进行编码，例如冒号、正斜杠、问号和井字号；而encodeURIComponent()则会对它发现的任何非标准字符进行编码。

    一般来说，我们使用 encodeURIComponent()方法的时候要比使用encodeURI()更多，因为在实践中更常见的是对查询字符串参数而不是对基础 URI进行编码。

    与 encodeURI()和 encodeURIComponent()方法对应的两个方法分别是 decodeURI()和decodeURIComponent()

* eval()方法
    现在，我们介绍最后一个——大概也是整个ECMAScript语言中最强大的一个方法：eval()。eval()方法就像是一个完整的ECMAScript解析器，它只接受一个参数，即要执行的ECMAScript（或JavaScript）字符串。看例子： eval("alert('hi')"); 这行代码的作用等价于代码： alert("hi");

    当解析器发现代码中调用eval()方法时，它会将传入的参数当作实际的ECMAScript语句来解析，然后把执行结果插入到原位置。通过 eval() 执行的代码可以引用在包
含环境中定义的变量 `var msg = "hello world"; eval("alert(msg)");`

    在eval()中创建的任何变量或函数都不会被提升，因为在解析代码的时候，它们被包含在一个字符串中；它们只在eval()执行的时候创建。 严格模式下，在外部访问不到eval()中创建的任何变量或函数，在严格模式下,为 eval 赋值也会导致错误

* Global 对象的属性
    特殊的值undefined、NaN以及Infinity都是Global对象的属性。此外，所有原生引用类型的构造函数，像Object和Function，也都是Global对象的属性。下表列出了Global对象的所有属性。

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

* window 对象
    ECMAScript 虽然没有指出如何直接访问 Global 对象，但 Web 浏览器都是将这个全局对象作为window对象的一部分加以实现的。因此，在全局作用域中声明的所有变量和函数，就都成为了window对象的属性。

### Math 对象
Math对象包含的属性大都是数学计算中可能会用到的一些特殊值。下表列出了这些属性。

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

    * Math.trunc(num)：去除一个数的小数部分，返回整数部分，对于空值和无法截取整数的值，返回NaN
    * Math.sign(num)：判断一个数到底是正数、负数、还是零。参数为正数，返回+1； 参数为负数，返回-1； 参数为0，返回0； 参数为-0，返回-0; 其他值，返回NaN。
    * Math.cbrt(num)：计算一个数的立方根
    * Math.clz32(num)：返回一个数的32位无符号整数二进制形式表示有多少个前导0。对于小数，只考虑整数部分，对于其他值，先转为数值，再计算
    * Math.imul(num1,num2)：回两个数以32位带符号整数形式相乘的结果，返回的也是一个32位的带符号整数。多数情况和`(a * b)|0`效果相同，但JavaScript对于超过2的53次方的值无法精确表示，该方法可以得到正确值
    * Math.fround(num)：Math.fround方法返回一个数的单精度浮点数形式。对于整数来说，Math.fround方法返回结果不会有任何不同，区别主要是那些无法用64个二进制位精确表示的小数。这时，Math.fround方法会返回最接近这个小数的单精度浮点数。
    * Math.hypot()：返回所有参数的平方和的平方根，如果参数不是数值，Math.hypot方法会将其转为数值。只要有一个参数无法转为数值，就会返回NaN
    * Math.expm1()：返回Math.exp(x) - 1
    * Math.log1p()：返回1 + x的自然对数。如果x小于-1，返回NaN
    * Math.log10()：返回以10为底的x的对数。如果x小于0，则返回NaN
    * Math.log2()：返回以2为底的x的对数。如果x小于0，则返回NaN
    * Math.sinh(x)：返回x的双曲正弦（hyperbolic sine）
    * Math.cosh(x)：返回x的双曲余弦（hyperbolic cosine）
    * Math.tanh(x)：返回x的双曲正切（hyperbolic tangent）
    * Math.asinh(x)：返回x的反双曲正弦（inverse hyperbolic sine）
    * Math.acosh(x)：返回x的反双曲余弦（inverse hyperbolic cosine）
    * Math.atanh(x)：返回x的反双曲正切（inverse hyperbolic tangent）

## 键集合类型
### Map 类型
#### 基本用法

JavaScript的对象（Object），本质上是键值对的集合（Hash结构），但是只能用字符串当作键。这给它的使用带来了很大的限制。

```
var data = {};
var element = document.getElementById("myDiv");

data[element] = metadata;
data["[Object HTMLDivElement]"] // metadata
```

上面代码原意是将一个DOM节点作为对象data的键，但是由于对象只接受字符串作为键名，所以element被自动转为字符串`[Object HTMLDivElement]`。

为了解决这个问题，ES6提供了Map数据结构。它类似于对象，也是键值对的集合，但是“键”的范围不限于字符串，各种类型的值（包括对象）都可以当作键。也就是说，Object结构提供了“字符串—值”的对应，Map结构提供了“值—值”的对应，是一种更完善的Hash结构实现。如果你需要“键值对”的数据结构，Map比Object更合适。

作为构造函数，Map可以接受一个数组作为参数。该数组的成员是一个个表示键值对的数组。

```
var map = new Map([ ["name", "张三"], ["title", "Author"]]);

map.size // 2
map.has("name") // true
map.get("name") // "张三"
map.has("title") // true
map.get("title") // "Author"
```
如果对同一个键多次赋值，后面的值将覆盖前面的值。

如果读取一个未知的键，则返回undefined。

```
new Map().get('asfddfsasadf') // undefined
```
注意，只有对同一个对象的引用，Map结构才将其视为同一个键。这一点要非常小心。

```
var map = new Map();

map.set(['a'], 555);
map.get(['a']) // undefined
```

同理，同样的值的两个实例，在Map结构中被视为两个键。
```
var map = new Map();

var k1 = ['a'];
var k2 = ['a'];

map.set(k1, 111);
map.set(k2, 222);

map.get(k1) // 111
map.get(k2) // 222
```

由上可知，Map的键实际上是跟内存地址绑定的，只要内存地址不一样，就视为两个键。这就解决了同名属性碰撞（clash）的问题，

如果Map的键是一个简单类型的值（数字、字符串、布尔值），则只要两个值严格相等，Map将其视为一个键，包括0和-0。另外，虽然NaN不严格相等于自身，但Map将其视为同一个键。

#### 实例的属性和操作方法

Map结构的实例有以下属性和操作方法。

* size：返回成员总数。
* set(key, value)：设置key所对应的键值，然后返回整个Map结构。如果key已经有值，则键值会被更新，否则就新生成该键。
* get(key)：读取key对应的键值，如果找不到key，返回undefined。
* has(key)：返回一个布尔值，表示某个键是否在Map数据结构中。
* delete(key)：删除某个键，返回true。如果删除失败，返回false。
* clear()：清除所有成员，没有返回值。

set()方法返回的是Map本身，因此可以采用链式写法。

#### 遍历方法

Map原生提供三个Iterable对象，这三个对象同样实现了Iterator接口。

* keys()：返回键名的Iterable对象。
* values()：返回键值的Iterable对象。
* entries()：返回所有成员的Iterable对象。

下面是使用实例。

```
for (let [key, value] of map.entries()) {
  console.log(key, value);
}

// 等同于使用map.entries()
for (let [key, value] of map) {
  console.log(key, value);
}
```
上面代码最后的那个例子，表示Map结构的Symbol.iterator属性，就是entries方法。

```
map[Symbol.iterator] === map.entries // true
```

Map结构转为数组结构，比较快速的方法是结合使用扩展运算符（...）。

```
let map = new Map([
  [1, 'one'],
  [2, 'two'],
  [3, 'three'],
]);

[...map.keys()]
// [1, 2, 3]
[...map.values()]
// ['one', 'two', 'three']
[...map.entries()]
// [[1,'one'], [2, 'two'], [3, 'three']]
[...map]
// [[1,'one'], [2, 'two'], [3, 'three']]
```

结合数组的map方法、filter方法，可以实现Map的遍历和过滤（Map本身没有map和filter方法）。

```
let map0 = new Map()
  .set(1, 'a')
  .set(2, 'b')
  .set(3, 'c');

let map1 = new Map(
  [...map0].filter(([k, v]) => k < 3)
);
// 产生Map结构 {1 => 'a', 2 => 'b'}
let map2 = new Map(
  [...map0].map(([k, v]) => [k * 2, '_' + v])
    );
// 产生Map结构 {2 => '_a', 4 => '_b', 6 => '_c'}
```

此外，Map还有一个forEach方法，与数组的forEach方法类似，也可以实现遍历。

```
map.forEach(function(value, key, map)) {
  console.log("Key: %s, Value: %s", key, value);
};
```

forEach方法还可以接受第二个参数，用来绑定this。
```
var reporter = {
  report: function(key, value) {
    console.log("Key: %s, Value: %s", key, value);
  }
};
map.forEach(function(value, key, map) {
  this.report(key, value);
}, reporter);
```
上面代码中，forEach方法的回调函数的this，就指向reporter。

#### 与其他数据结构的互相转换

1. **Map转为数组**

    前面已经提过，Map转为数组最方便的方法，就是使用扩展运算符（...）。

2. **数组转为Map**

    将数组转入Map构造函数，就可以转为Map。

3. **Map转为对象**

    如果所有Map的键都是字符串，通过遍历，它可以转为对象。

4. **对象转为Map**

   通过遍历Object.keys(obj)，调用map.set方法添加键值对

5. **Map转为JSON**

    Map转为JSON要区分两种情况。一种情况是，Map的键名都是字符串，这时可以选择转为对象JSON。JSON.stringify(strMapToObj(strMap));

    另一种情况是，Map的键名有非字符串，这时可以选择转为数组JSON。 JSON.stringify([...map]);

6. **JSON转为Map**

    JSON转为Map，正常情况下，所有键名都是字符串。JSON.parse(jsonStr)先转为对象，再把对象转为Map

    但是，有一种特殊情况，整个JSON就是一个数组，且每个数组成员本身，又是一个有两个成员的数组。这时，它可以一一对应地转为Map。这往往是数组转为JSON的逆操作。new Map(JSON.parse(jsonStr));

### WeakMap 类型

WeakMap结构与Map结构基本类似，唯一的区别是它只接受对象作为键名（null除外），不接受原始类型的值作为键名，而且键名所指向的对象，不计入垃圾回收机制。

WeakMap的设计目的在于，键名是对象的弱引用（垃圾回收机制不将该引用考虑在内），所以其所对应的对象可能会被自动回收。当对象被回收后，WeakMap自动移除对应的键值对。典型应用是，一个对应DOM元素的WeakMap结构，当某个DOM元素被清除，其所对应的WeakMap记录就会自动被移除。基本上，WeakMap的专用场合就是，它的键所对应的对象，可能会在将来消失。WeakMap结构有助于防止内存泄漏。

下面是WeakMap结构的一个例子，可以看到用法上与Map几乎一样。
```
var wm = new WeakMap();
var element = document.querySelector(".element");

wm.set(element, "Original");
wm.get(element) // "Original"

element.parentNode.removeChild(element);
element = null;
wm.get(element) // undefined
```
上面代码中，变量wm是一个WeakMap实例，我们将一个DOM节点element作为键名，然后销毁这个节点，element对应的键就自动消失了，再引用这个键名就返回undefined。

WeakMap与Map在API上的区别主要是两个，一是没有遍历操作（即没有key()、values()和entries()方法），也没有size属性；二是无法清空，即不支持clear方法。这与WeakMap的键不被计入引用、被垃圾回收机制忽略有关。因此，WeakMap只有四个方法可用：get()、set()、has()、delete()。

WeakMap的另一个用处是部署私有属性。

```
let _counter = new WeakMap();
let _action = new WeakMap();

class Countdown {
  constructor(counter, action) {
    _counter.set(this, counter);
    _action.set(this, action);
  }
  dec() {
    let counter = _counter.get(this);
    if (counter < 1) return;
    counter--;
    _counter.set(this, counter);
    if (counter === 0) {
      _action.get(this)();
    }
  }
}

let c = new Countdown(2, () => console.log('DONE'));

c.dec()
c.dec()
// DONE
```
上面代码中，Countdown类的两个内部属性`_counter`和`_action`，是实例的弱引用，所以如果删除实例，它们也就随之消失，不会造成内存泄漏。

### Set 类型
#### 基本用法
ES6提供了新的数据结构Set。它类似于数组，但是成员的值都是唯一的，没有重复的值。

```
var s = new Set();
[2,3,5,4,5,2,2].map(x => s.add(x))
s// Set [ 2, 3, 5, 4 ]
```

Set函数可以接受一个数组作为参数，用来初始化。
```
var items = new Set([1,2,3,4,5,5,5,5]);
items.size // 5
```

向Set加入值的时候，不会发生类型转换，所以5和“5”是两个不同的值。Set内部判断两个值是否不同，使用的算法类似于精确相等运算符（===），这意味着，两个对象总是不相等的。唯一的例外是NaN等于自身（精确相等运算符认为NaN不等于自身）。

```
let set = new Set();
set.add({})
set.size // 1
set.add({})
set.size // 2
```
上面代码表示，由于两个空对象不是精确相等，所以它们被视为两个值。

#### Set实例的属性和方法

Set结构的实例有以下属性。

* Set.prototype.constructor：构造函数，默认就是Set函数。
* Set.prototype.size：返回Set实例的成员总数。

Set实例的方法分为两大类：操作方法（用于操作数据）和遍历方法（用于遍历成员）。下面先介绍四个操作方法。

* add(value)：添加某个值，返回Set结构本身。
* delete(value)：删除某个值，返回一个布尔值，表示删除是否成功。
* has(value)：返回一个布尔值，表示该值是否为Set的成员。
* clear()：清除所有成员，没有返回值。

Array.from方法可以将Set结构转为数组。

```
var items = new Set([1, 2, 3, 4, 5]);
var array = Array.from(items);
```

这就提供了一种去除数组的重复元素的方法。

```
function dedupe(array) {
  return Array.from(new Set(array));
}
dedupe([1,1,2,3]) // [1, 2, 3]
```

**遍历操作**

Set结构的实例有四个遍历方法，可以用于遍历成员。

* keys()：返回一个键名的Iterable对象
* values()：返回一个键值的Iterable对象
* entries()：返回一个键值对的Iterable对象
* forEach()：使用回调函数遍历每个成员

key方法、value方法、entries方法返回的都是Iterable对象，该对象同样实现了Iterator接口。由于Set结构没有键名，只有键值（或者说键名和键值是同一个值），所以key方法和value方法的行为完全一致。

```
let set = new Set(['red', 'green', 'blue']);
for ( let item of set.entries() ){
  console.log(item);
}
// ["red", "red"]
// ["green", "green"]
// ["blue", "blue"]
```

Set结构的实例默认可遍历，它的默认Symbol.iterator方法就是它的values方法。
```
Set.prototype[Symbol.iterator] === Set.prototype.values
// true
```

这意味着，可以省略values方法，直接用for...of循环遍历Set。
```
let set = new Set(['red', 'green', 'blue']);

for (let x of set) {
  console.log(x);
}
```

由于扩展运算符（...）内部使用for...of循环，所以也可以用于Set结构。

```
let set = new Set(['red', 'green', 'blue']);
let arr = [...set];
// ['red', 'green', 'blue']
```

这就提供了另一种便捷的去除数组重复元素的方法。
```
let arr = [3, 5, 2, 2, 5, 5];
let unique = [...new Set(arr)];
// [3, 5, 2]
```

而且，通过扩展运算符，数组的map和filter方法也可以用于Set了。
```
let set = new Set([1, 2, 3]);
set = new Set([...set].map(x => x * 2));
// 返回Set结构：{2, 4, 6}
let set = new Set([1, 2, 3, 4, 5]);
set = new Set([...set].filter(x => (x % 2) == 0));
// 返回Set结构：{2, 4}
```

因此使用Set，可以很容易地实现并集（Union）和交集（Intersect）。
```
let a = new Set([1, 2, 3]);
let b = new Set([4, 3, 2]);
let union = new Set([...a, ...b]);
// [1, 2, 3, 4]
let intersect = new Set([...a].filter(x => b.has(x)));
// [2, 3]
```

Set结构的实例的forEach方法，用于对每个成员执行某种操作，没有返回值。
```
let set = new Set([1, 2, 3]);
set.forEach((value, key) => console.log(value * 2) )
// 2
// 4
// 6
```

上面代码说明，forEach方法的参数就是一个处理函数。该函数的参数依次为键值、键名、集合本身（上例省略了该参数）。另外，forEach方法还可以有第二个参数，表示绑定的this对象。

如果想在遍历操作中，同步改变原来的Set结构，目前没有直接的方法，但有两种变通方法。一种是利用原Set结构映射出一个新的结构，然后赋值给原来的Set结构；另一种是利用Array.from方法。
```
// 方法一
let set = new Set([1, 2, 3]);
set = new Set([...set].map(val => val * 2));
// set的值是2, 4, 6
// 方法二
let set = new Set([1, 2, 3]);
set = new Set(Array.from(set, val => val * 2));
// set的值是2, 4, 6
```
上面代码提供了两种方法，直接在遍历操作中改变原来的Set结构。

### WeakSet 类型

WeakSet结构与Set类似，也是不重复的值的集合。但是，它与Set有两个区别。

首先，WeakSet的成员只能是对象，而不能是其他类型的值。

其次，WeakSet中的对象都是弱引用，即垃圾回收机制不考虑WeakSet对该对象的引用，也就是说，如果其他对象都不再引用该对象，那么垃圾回收机制会自动回收该对象所占用的内存，不考虑该对象还存在于WeakSet之中。这个特点意味着，无法引用WeakSet的成员，因此WeakSet是不可遍历的。

```
var ws = new WeakSet();
ws.add(1)
// TypeError: Invalid value used in weak set
```

作为构造函数，WeakSet可以接受一个数组或类似数组的对象作为参数。（实际上，任何具有iterable接口的对象，都可以作为WeakSet的对象。）该数组的所有成员，都会自动成为WeakSet实例对象的成员。

```
var a = [[1,2], [3,4]];
var ws = new WeakSet(a);
```

上面代码中，a是一个数组，它有两个成员，也都是数组。将a作为WeakSet构造函数的参数，a的成员会自动成为WeakSet的成员。

WeakSet结构有以下三个方法。

* **WeakSet.prototype.add(value)**：向WeakSet实例添加一个新成员。
* **WeakSet.prototype.delete(value)**：清除WeakSet实例的指定成员。
* **WeakSet.prototype.has(value)**：返回一个布尔值，表示某个值是否在WeakSet实例之中。

WeakSet没有size属性，没有办法遍历它的成员。

WeakSet不能遍历，是因为成员都是弱引用，随时可能消失，遍历机制无法保存成员的存在，很可能刚刚遍历结束，成员就取不到了。WeakSet的一个用处，是储存DOM节点，而不用担心这些节点从文档移除时，会引发内存泄漏。

## 反射类型
### Proxy
Proxy用于修改某些操作的默认行为，等同于在语言层面做出修改，所以属于一种“元编程”（meta programming），即对编程语言进行编程。

Proxy可以理解成，在目标对象之前架设一层“拦截”，外界对该对象的访问，都必须先通过这层拦截，因此提供了一种机制，可以对外界的访问进行过滤和改写。Proxy这个词的原意是代理，用在这里表示由它来“代理”某些操作，可以译为“代理器”。（与Java中动态代理类似）

```
var proxy = new Proxy(target, handler)
```
Proxy对象的所有用法，都是上面这种形式，不同的只是handler参数的写法。其中，`new Proxy()`表示生成一个Proxy实例，target参数表示所要拦截的目标对象，handler参数也是一个对象，用来定制拦截行为。

```
var proxy = new Proxy({}, {
  get: function(target, property) {
    return 35;
  }
});

proxy.time // 35
proxy.name // 35
proxy.title // 35
```
注意，要使得Proxy起作用，必须针对Proxy实例（上例是proxy对象）进行操作，而不是针对目标对象（上例是空对象）进行操作。

一个技巧是将Proxy对象，设置到`object.proxy`属性，从而可以在object对象上调用。

```
var object = { proxy: new Proxy(target, handler) }
```

Proxy实例也可以作为其他对象的原型对象。

```
var proxy = new Proxy({}, {
  get: function(target, property) {
    return 35;
  }
});

let obj = Object.create(proxy);
obj.time // 35
```
上面代码中，proxy对象是obj对象的原型，obj对象本身并没有time属性，所有根据原型链，会在proxy对象上读取该属性，导致被拦截。

下面是Proxy支持的拦截操作一览。

对于可以设置、但没有设置拦截的操作，则直接落在目标对象上，按照原先的方式产生结果。

1. **get(target, propKey, receiver)**

    拦截对象属性的读取，比如`proxy.foo`和`proxy['foo']`，返回类型不限。最后一个参数receiver可选，当target对象设置了propKey属性的get函数时，receiver对象会绑定get函数的this对象。

2. **set(target, propKey, value, receiver)**

    拦截对象属性的设置，比如`proxy.foo = v`或`proxy['foo'] = v`，返回一个布尔值。

3. **has(target, propKey)**

    拦截`propKey in proxy`的操作，返回一个布尔值。

4. **deleteProperty(target, propKey)**

    拦截`delete proxy[propKey]`的操作，返回一个布尔值。

5. **enumerate(target)**

    拦截`for (var x in proxy)`，返回一个Iterable对象。

6. **hasOwn(target, propKey)**

    拦截`proxy.hasOwnProperty('foo')`，返回一个布尔值。

7. **ownKeys(target)**

    拦截`Object.getOwnPropertyNames(proxy)`、`Object.getOwnPropertySymbols(proxy)`、`Object.keys(proxy)`，返回一个数组。该方法返回对象所有自身的属性，而`Object.keys()`仅返回对象可遍历的属性。

8. **getOwnPropertyDescriptor(target, propKey)**

    拦截`Object.getOwnPropertyDescriptor(proxy, propKey)`，返回属性的描述对象。

9. **defineProperty(target, propKey, propDesc)**

    拦截`Object.defineProperty(proxy, propKey, propDesc）`、`Object.defineProperties(proxy, propDescs)`，返回一个布尔值。

10. **preventExtensions(target)**

    拦截`Object.preventExtensions(proxy)`，返回一个布尔值。

11. **getPrototypeOf(target)**

    拦截`Object.getPrototypeOf(proxy)`，返回一个对象。

12. **isExtensible(target)**

    拦截`Object.isExtensible(proxy)`，返回一个布尔值。

13. **setPrototypeOf(target, proto)**

    拦截`Object.setPrototypeOf(proxy, proto)`，返回一个布尔值。

如果目标对象是函数，那么还有两种额外操作可以拦截。

1. **apply(target, object, args)**

    拦截Proxy实例作为函数调用的操作，比如`proxy(...args)`、`proxy.call(object, ...args)`、`proxy.apply(...)`。

2. **construct(target, args, proxy)**

    拦截Proxy实例作为构造函数调用的操作，比如new proxy(...args)。

```
//get
var person = {
  name: "张三"
};

var proxy = new Proxy(person, {
  get: function(target, property) {
    if (property in target) {
      return target[property];
    } else {
      throw new ReferenceError("Property \"" + property + "\" does not exist.");
    }
  }
});

proxy.name // "张三"
proxy.age // 抛出一个错误

//apply
var target = function () { return 'I am the target'; };
var handler = {
  apply: function (receiver, ...args) {
    return 'I am the proxy';
  }
};

var p = new Proxy(target, handler);

p() === 'I am the proxy'; // true
```

### Reflect
Reflect对象与Proxy对象一样，也是ES6为了操作对象而提供的新API。Reflect对象的设计目的有这样几个。

1. 将Object对象的一些明显属于语言层面的方法，放到Reflect对象上。现阶段，某些方法同时在Object和Reflect对象上部署，未来的新方法将只部署在Reflect对象上。
2. 修改某些Object方法的返回结果，让其变得更合理。比如，`Object.defineProperty(obj, name, desc)`在无法定义属性时，会抛出一个错误，而`Reflect.defineProperty(obj, name, desc)`则会返回false。
3. 让Object操作都变成函数行为。某些Object操作是命令式，比如`name in obj`和`delete obj[name]`，而`Reflect.has(obj, name)`和`Reflect.deleteProperty(obj, name)`让它们变成了函数行为。
4. Reflect对象的方法与Proxy对象的方法一一对应，只要是Proxy对象的方法，就能在Reflect对象上找到对应的方法。这就让Proxy对象可以方便地调用对应的Reflect方法，完成默认行为，作为修改行为的基础。

```
Proxy(target, {
  set: function(target, name, value, receiver) {
    var success = Reflect.set(target,name, value, receiver);
    if (success) {
      log('property '+name+' on '+target+' set to '+value);
    }
    return success;
  }
});
```
Reflect对象的方法清单如下。

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

注意，Reflect.set()、Reflect.defineProperty()、Reflect.freeze()、Reflect.seal()和Reflect.preventExtensions()返回一个布尔值，表示操作是否成功。它们对应的Object方法，失败时都会抛出错误。

## 控制抽象类型
### Iteration 接口
ECMAScript 中一个接口是一组键值对属性，这些属性的键所对应的值符合特定的规范。如果一个对象提供了一个接口描述的所有属性，那么这个对象就实现了这个接口。一个接口并不是被单独的一个对象表示。可能有很多单独的对象实现符合某个接口，一个单独的对象可能实现多个接口。

通过统一的接口机制，可以使用for-of来遍历不同的数据结构。

#### Iterable 接口
这个接口只有一个属性，即Symbol.iterator，它是一个函数，这个函数返回一个实现了Iterator接口的对象。

在ES6中，有些数据结构原生实现了这个接口（比如数组），不用任何处理，就可以被for...of循环遍历，有些就不行（比如对象）。原因在于，这些数据结构原生部署了Symbol.iterator属性（详见下文），另外一些数据结构没有。凡是部署了Symbol.iterator属性的数据结构，就称为实现了Iterable接口。调用这个接口，就会返回一个Iterator对象。

#### Iterator 接口
这个接口有一个属性，next，这个属性是一个函数，它返回一个实现了IteratorResult接口的对象。如果上一步调用next返回的对象的done属性已经是true了，那么之后调用next函数也要返回一个done属性为true的IteratorResult对象。这个要求并不是强制的。

该接口还有两个可选的属性return 和 throw。这两个属性都是方法，并且方法返回值都是IteratorResult对象。

done为true，即遍历结束时，如果存在return方法，value的值会被设置为return方法。这并不是强制要求的。

#### IteratorResult 接口

包含value和done两个属性的对象。其中，value属性是当前成员的值，如果iterator提供了return方法的花，done为true时，这个value应该是iterator的return属性的值即return函数，否则done为true时value就是undefined，这种情况下可以没有value属性；done属性是一个布尔值，表示遍历是否结束，如果不存在done，就认为done属性为false。

#### 实例
如果使用TypeScript的写法，可以描述如下。

```
interface Iterable {
  [Symbol.iterator]() : Iterator,
}

interface Iterator {
  next(value?: any) : IterationResult,
}

interface IterationResult {
  value: any,
  done: boolean,
}
```
下面看一个例子
```
function Obj(value){
  this.value = value;
  this.next = null;
}

Obj.prototype[Symbol.iterator] = function(){

  var iterator = {
    next: next,
    return: returnFn
  };

  var current = this;

  function next(){
    if (current){
      var value = current.value;
      var done = current === null;
      current = current.next;
      return {
        done: done,
        value: value
      }
    } else {
      return {
        value: iterator.return,
        done: true
      }
    }
  }
  function returnFn(){
    return {
      done: true,
      value: 'return'
    }
  }

  return iterator;
}

var one = new Obj(1);
var two = new Obj(2);
var three = new Obj(3);

one.next = two;
two.next = three;

var it = one[Symbol.iterator]();
it.next();
it.next();
it.next();
it.next().value();

for(let a of one){
  console.log(a);
}
```
上面代码首先在构造函数的原型链上部署Symbol.iterator方法，调用该方法会返回遍Iterator对象，调用该对象的next方法，在返回一个值的同时，自动将内部指针移到下一个实例。

#### 默认实现Iterable接口的数据结构

Iterable接口的目的，就是为所有数据结构，提供了一种统一的访问机制，即for...of循环（详见下文）。当使用for...of循环遍历某种数据结构时，该循环会自动去寻找Iterable接口。

ES6规定，默认的Iterator接口部署在数据结构的`Symbol.iterator`属性，或者一个数据结构只要具有`Symbol.iterator`属性，就可以认为是“可遍历的”（iterable）。也就是说，调用`Symbol.iterator`方法，就会得到当前数据结构的默认Iterator对象。`Symbol.iterator`本身是一个表达式，返回Symbol对象的iterator属性，这是一个预定义好的、类型为Symbol的特殊值，所以要放在方括号内。

在ES6中，有三类数据结构原生具备Iterable接口：数组、某些类似数组的对象、Set和Map结构。

```
let arr = ['a', 'b', 'c'];
let iter = arr[Symbol.iterator]();

iter.next() // { value: 'a', done: false }
iter.next() // { value: 'b', done: false }
iter.next() // { value: 'c', done: false }
iter.next() // { value: undefined, done: true }
```

上面代码中，变量arr是一个数组，原生就具有Iterable接口，部署在arr的Symbol.iterator属性上面。所以，调用这个属性，就得到Iterator对象。

上面提到，原生就部署Iterable接口的数据结构有三类，对于这三类数据结构，for...of循环会自动遍历它们。除此之外，其他数据结构（主要是对象）的Iterable接口，都需要自己在Symbol.iterator属性上面部署，这样才会被for...of循环遍历。

对象（Object）之所以没有默认部署Iterable接口，是因为对象的哪个属性先遍历，哪个属性后遍历是不确定的，需要开发者手动指定。本质上，遍历是一种线性处理，对于任何非线性的数据结构，部署Iterable接口，就等于部署一种线性转换。不过，严格地说，对象部署Iterable接口并不是很必要，因为这时对象实际上被当作Map结构使用，ES5没有Map结构，而ES6原生提供了。

一个对象如果要有可被for...of循环调用的Iterable接口，就必须有Symbol.iterator方法（原型链上的对象具有该方法也可）。

```
class RangeIterator {
  constructor(start, stop) {
    this.value = start;
    this.stop = stop;
  }

  [Symbol.iterator]() { return this; }

  next() {
    var value = this.value;
    if (value < this.stop) {
      this.value++;
      return {done: false, value: value};
    } else {
      return {done: true, value: undefined};
    }
  }
}

function range(start, stop) {
  return new RangeIterator(start, stop);
}

for (var value of range(0, 3)) {
  console.log(value);
}
```


下面是另一个为对象添加Iterator接口的例子。
```
let obj = {
  data: [ 'hello', 'world' ],
  [Symbol.iterator]() {
    const self = this;
    let index = 0;
    return {
      next() {
        if (index < self.data.length) {
          return {
            value: self.data[index++],
            done: false
          };
        } else {
          return { value: undefined, done: true };
        }
      }
    };
  }
};
```

对于类似数组的对象（存在数值键名和length属性），部署Iterable接口，有一个简便方法，就是`Symbol.iterator`方法直接引用数组的Iterable接口。

```
NodeList.prototype[Symbol.iterator] = Array.prototype[Symbol.iterator];
// 或者
NodeList.prototype[Symbol.iterator] = [][Symbol.iterator];
[...document.querySelectorAll('div')] // 可以执行了
```

如果Symbol.iterator方法返回的不是Iterator对象，解释引擎将会报错。

```
var obj = {};

obj[Symbol.iterator] = () => 1;

[...obj] // TypeError: [] is not a function
```

有了Iterable接口，数据结构就可以用for...of循环遍历，也可以使用while循环遍历。

```
var $iterator = ITERABLE[Symbol.iterator]();
var $result = $iterator.next();
while (!$result.done) {
  var x = $result.value;
  // ...
  $result = $iterator.next();
}
```

上面代码中，ITERABLE代表某种可遍历的数据结构

#### Iterable接口默认的应用场合

有一些场合会默认使用Iterable接口（即调用Symbol.iterator方法），除了for...of循环，还有几个别的场合。

**解构赋值**

```
let set = new Set().add('a').add('b').add('c');

let [x,y] = set;
// x='a'; y='b'

let [first, ...rest] = set; // first='a'; rest=['b','c'];
```

**扩展运算符**

```
// 例一
var str = 'hello';
[...str] //  ['h','e','l','l','o']

// 例二
let arr = ['b', 'c'];
['a', ...arr, 'd']
// ['a', 'b', 'c', 'd']
```

实际上，这提供了一种简便机制，可以将任何实现了Iterable接口的数据结构，转为数组。也就是说，只要某个数据结构实现了Iterable接口，就可以对它使用扩展运算符，将其转为数组。

```
let arr = [...iterable];
```

**`yield*`**

`yield*`后面跟的是一个实现了Iterable的对象，它会调用该对象的Symbol.iterator方法。

```
let generator = function* () {
  yield 1;
  yield* [2,3,4]; //use an iterable, is looped, and added as yields
  yield 5;
};

var iterator = generator();

iterator.next() // { value: 1, done: false }
iterator.next() // { value: 2, done: false }
iterator.next() // { value: 3, done: false }
iterator.next() // { value: 4, done: false }
iterator.next() // { value: 5, done: false }
iterator.next() // { value: undefined, done: true }
```

**其他场合**

由于数组的遍历会调用Symbol.iterator方法，所以任何接受数组作为参数的场合，其实都调用了Symbol.iterator。下面是一些例子。

* Array.from()
* Map(), Set(), WeakMap(), WeakSet()（比如`new Map([['a',1],['b',2]])`）
* Promise.all()
* Promise.race()

#### 原生具备Iterable接口的数据结构

ES6对数组提供entries()、keys()和values()三个方法，就是返回三个Iterable对象。

```
var arr = [1, 5, 7];
var arrEntries = arr.entries();

arrEntries.toString() // "[object Array Iterator]"

arrEntries === arrEntries[Symbol.iterator]() // true
```

上面代码中，entries方法返回的是一个Iterator对象，本质上就是调用了`Symbol.iterator`方法。

字符串是一个类似数组的对象，也原生具有Iterable接口。

```
var someString = "hi";
typeof someString[Symbol.iterator]
// "function"

var iterator = someString[Symbol.iterator]();

iterator.next()  // { value: "h", done: false }
iterator.next()  // { value: "i", done: false }
iterator.next()  // { value: undefined, done: true }
```

可以覆盖原生的`Symbol.iterator`方法，达到修改Iterator对象行为的目的。

```
var str = new String("hi");

[...str] // ["h", "i"]

str[Symbol.iterator] = function() {
  return {
    next: function() {
      if (this._first) {
        this._first = false;
        return { value: "bye", done: false };
      } else {
        return { done: true };
      }
    },
    _first: true
  };
};

[...str] // ["bye"]
str // "hi"
```

上面代码中，字符串str的`Symbol.iterator`方法被修改了，所以扩展运算符（...）返回的值变成了bye，而字符串本身还是hi。

#### Iterable接口与Generator函数

`Symbol.iterator`方法的最简单实现，还是使用后面要介绍的Generator函数。

```
var myIterable = {};

myIterable[Symbol.iterator] = function* () {
  yield 1;
  yield 2;
  yield 3;
};
[...myIterable] // [1, 2, 3]

// 或者采用下面的简洁写法

let obj = {
  * [Symbol.iterator]() {
    yield 'hello';
    yield 'world';
  }
};

for (let x of obj) {
  console.log(x);
}
// hello
// world
```
上面代码中，`Symbol.iterator`方法几乎不用部署任何代码，只要用yield命令给出每一步的返回值即可。

### Promise 类型
#### Promise的含义
Promise在JavaScript语言早有实现，ES6将其写进了语言标准，统一了用法，原生提供了Promise对象。

所谓Promise，就是一个对象，用来传递异步操作的消息。它代表了某个未来才会知道结果的事件（通常是一个异步操作），并且这个事件提供统一的API，可供进一步处理。

Promise对象有以下两个特点。

1. 对象的状态不受外界影响。Promise对象代表一个异步操作，有三种状态：Pending（进行中）、Resolved（已完成，又称Fulfilled）和Rejected（已失败）。只有异步操作的结果，可以决定当前是哪一种状态，任何其他操作都无法改变这个状态。这也是Promise这个名字的由来，它的英语意思就是“承诺”，表示其他手段无法改变。
2. 一旦状态改变，就不会再变，任何时候都可以得到这个结果。Promise对象的状态改变，只有两种可能：从Pending变为Resolved和从Pending变为Rejected。只要这两种情况发生，状态就凝固了，不会再变了，会一直保持这个结果。就算改变已经发生了，你再对Promise对象添加回调函数，也会立即得到这个结果。这与事件（Event）完全不同，事件的特点是，如果你错过了它，再去监听，是得不到结果的。

有了Promise对象，就可以将异步操作以同步操作的流程表达出来，避免了层层嵌套的回调函数。此外，Promise对象提供统一的接口，使得控制异步操作更加容易。

Promise也有一些缺点。首先，无法取消Promise，一旦新建它就会立即执行，无法中途取消。其次，如果不设置回调函数，Promise内部抛出的错误，不会反应到外部。第三，当处于Pending状态时，无法得知目前进展到哪一个阶段（刚刚开始还是即将完成）。

如果某些事件不断地反复发生，一般来说，使用stream模式是比部署Promise更好的选择。

#### 基本用法

ES6规定，Promise对象是一个构造函数，用来生成Promise实例。

下面代码创造了一个Promise实例。

```
var promise = new Promise(function(resolve, reject) {
  // ... some code
  if (/* 异步操作成功 */){
    resolve(value);
  } else {
    reject(error);
  }
});
```
Promise构造函数接受一个函数作为参数，该函数的两个参数分别是resolve和reject。它们是两个函数，由JavaScript引擎提供，不用自己部署。

resolve函数的作用是，将Promise对象的状态从“未完成”变为“成功”（即从Pending变为Resolved），在异步操作成功时调用，并将异步操作的结果，作为参数传递出去；reject函数的作用是，将Promise对象的状态从“未完成”变为“失败”（即从Pending变为Rejected），在异步操作失败时调用，并将异步操作报出的错误，作为参数传递出去。

Promise实例生成以后，可以用then方法分别指定Resolved状态和Reject状态的回调函数。

```
promise.then(function(value) {
  // success
}, function(value) {
  // failure
});
```
then方法可以接受两个回调函数作为参数。第一个回调函数是Promise对象的状态变为Resolved时调用，第二个回调函数是Promise对象的状态变为Reject时调用。其中，第二个函数是可选的，不一定要提供。这两个函数都接受Promise对象传出的值作为参数。

下面是一个Promise对象的简单例子。

```
function timeout(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms, 'done');
  });
}
var to = timeout(8000);
to.then((value) => {
  console.log(value);
});
//没有输出done前命令行查看to，输出后再查看，两次状态不同
```
上面代码中，timeout方法返回一个Promise实例，表示一段时间以后才会发生的结果。过了指定的时间（ms参数）以后，Promise实例的状态变为Resolved，就会触发then方法绑定的回调函数。

下面是一个用Promise对象实现的Ajax操作的例子。

```
var getJSON = function(url) {
  var promise = new Promise(function(resolve, reject){
    var client = new XMLHttpRequest();
    client.open("GET", url);
    client.onreadystatechange = handler;
    client.responseType = "json";
    client.setRequestHeader("Accept", "application/json");
    client.send();

    function handler() {
      if (this.status === 200) {
        resolve(this.response);
      } else {
        reject(new Error(this.statusText));
      }
    };
  });

  return promise;
};

getJSON("/posts.json").then(function(json) {
  console.log('Contents: ' + json);
}, function(error) {
  console.error('出错了', error);
});
```
上面代码中，getJSON是对XMLHttpRequest对象的封装，用于发出一个针对JSON数据的HTTP请求，并且返回一个Promise对象。需要注意的是，在getJSON内部，resolve函数和reject函数调用时，都带有参数。

如果调用resolve函数和reject函数时带有参数，那么它们的参数会被传递给回调函数。reject函数的参数通常是Error对象的实例，表示抛出的错误；resolve函数的参数除了正常的值以外，还可能是另一个Promise实例，表示异步操作的结果有可能是一个值，也有可能是另一个异步操作，比如像下面这样。

```
var p1 = new Promise(function(resolve, reject){
  //可以在这里加resolve或reject方法，观察p1和p2的状态
});

var p2 = new Promise(function(resolve, reject){
  // ...
  resolve(p1);
})
```
上面代码中，p1和p2都是Promise的实例，但是p2的resolve方法将p1作为参数，即一个异步操作的结果是返回另一个异步操作。

注意，这时p1的状态就会传递给p2，也就是说，p1的状态决定了p2的状态。如果p1的状态是Pending，那么p2的回调函数就会等待p1的状态改变；如果p1的状态已经是Resolved或者Rejected，那么p2的回调函数将会立刻执行。

#### Promise.prototype.then()
then方法是定义在原型对象Promise.prototype上的。它的作用是为Promise实例添加状态改变时的回调函数。前面说过，then方法的第一个参数是Resolved状态的回调函数，第二个参数（可选）是Rejected状态的回调函数。

then方法返回的是一个新的Promise实例（注意，不是原来那个Promise实例）。因此可以采用链式写法，即then方法后面再调用另一个then方法。

```
getJSON("/posts.json").then(function(json) {
  return json.post;
}).then(function(post) {
  // ...
});
```
上面的代码使用then方法，依次指定了两个回调函数。第一个then方法的回调函数完成以后，会将返回结果作为参数，传入第二个then方法的回调函数。

采用链式的then，可以指定一组按照次序调用的回调函数。这时，前一个回调函数，有可能返回的还是一个Promise对象（即有异步操作），这时后一个回调函数，就会等待该Promise对象的状态发生变化，才会被调用。

```
getJSON("/post/1.json").then(function(post) {
  return getJSON(post.commentURL);
}).then(function funcA(comments) {
  console.log("Resolved: ", comments);
}, function funcB(err){
  console.log("Rejected: ", err);
});
```

上面代码中，第一个then方法指定的回调函数，返回的是另一个Promise对象。这时，第二个then方法指定的回调函数，就会等待这个新的Promise对象状态发生变化。如果变为Resolved，就调用funcA，如果状态变为Rejected，就调用funcB。

#### Promise.prototype.catch()
Promise.prototype.catch方法是`.then(null, rejection)`的别名，用于指定发生错误时的回调函数。

```
getJSON("/posts.json").then(function(posts) {
  // ...
}).catch(function(error) {
  // 处理前一个回调函数运行时发生的错误
  console.log('发生错误！', error);
});
```
上面代码中，getJSON方法返回一个Promise对象，如果该对象状态变为Resolved，则会调用then方法指定的回调函数；如果异步操作抛出错误，状态就会变为Rejected，就会调用catch方法指定的回调函数，处理这个错误。

下面是一个例子。

```
var promise = new Promise(function(resolve, reject) {
  throw new Error('test')
});
promise.catch(function(error) { console.log(error) });
// Error: test
```
如果Promise状态已经变成resolved，再抛出错误是无效的。
```
var promise = new Promise(function(resolve, reject) {
  resolve("ok");
  throw new Error('test');
});
promise
  .then(function(value) { console.log(value) })
  .catch(function(error) { console.log(error) });
// ok
```

Promise对象的错误具有“冒泡”性质，会一直向后传递，直到被捕获为止。也就是说，错误总是会被下一个catch语句捕获。

```
getJSON("/post/1.json").then(function(post) {
  return getJSON(post.commentURL);
}).then(function(comments) {
  // some code
}).catch(function(error) {
  // 处理前面三个Promise产生的错误
});
```

上面代码中，一共有三个Promise对象：一个由getJSON产生，两个由then产生。它们之中任何一个抛出的错误，都会被最后一个catch捕获。

跟传统的try/catch代码块不同的是，如果没有使用catch方法指定错误处理的回调函数，Promise对象抛出的错误不会传递到外层代码，即不会有任何反应。

```
var someAsyncThing = function() {
  return new Promise(function(resolve, reject) {
    // 下面一行会报错，因为x没有声明
    resolve(x + 2);
  });
};

someAsyncThing().then(function() {
  console.log('everything is great');
});
```
上面代码中，someAsyncThing函数产生的Promise对象会报错，但是由于没有调用catch方法，这个错误不会被捕获，也不会传递到外层代码，导致运行后没有任何输出。

```
var promise = new Promise(function(resolve, reject) {
  resolve("ok");
  setTimeout(function() { throw new Error('test') }, 0)
});
promise.then(function(value) { console.log(value) });
// ok
// Uncaught Error: test
```
上面代码中，Promise指定在下一轮“事件循环”再抛出错误，结果由于没有指定try-catch语句，就冒泡到最外层，成了未捕获的错误。

Node.js有一个unhandledRejection事件，专门监听未捕获的reject错误。

```
process.on('unhandledRejection', function (err, p) {
  console.error(err.stack)
});
```
上面代码中，unhandledRejection事件的监听函数有两个参数，第一个是错误对象，第二个是报错的Promise实例，它可以用来了解发生错误的环境信息。。

需要注意的是，catch方法返回的还是一个Promise对象，因此后面还可以接着调用then方法。

```
var someAsyncThing = function() {
  return new Promise(function(resolve, reject) {
    // 下面一行会报错，因为x没有声明
    resolve(x + 2);
  });
};

someAsyncThing().then(function() {
  return someOtherAsyncThing();
}).catch(function(error) {
  console.log('oh no', error);
}).then(function() {
  console.log('carry on');
});
// oh no [ReferenceError: x is not defined]
// carry on
```

catch方法之中，还能再抛出错误。

```
var someAsyncThing = function() {
  return new Promise(function(resolve, reject) {
    // 下面一行会报错，因为x没有声明
    resolve(x + 2);
  });
};

someAsyncThing().then(function() {
  return someOtherAsyncThing();
}).catch(function(error) {
  console.log('oh no', error);
  // 下面一行会报错，因为y没有声明
  y + 2;
}).then(function() {
  console.log('carry on');
});
// oh no [ReferenceError: x is not defined]
```

上面代码中，catch方法抛出一个错误，因为后面没有别的catch方法了，导致这个错误不会被捕获，也不会传递到外层。如果改写一下，结果就不一样了。

```
someAsyncThing().then(function() {
  return someOtherAsyncThing();
}).catch(function(error) {
  console.log('oh no', error);
  // 下面一行会报错，因为y没有声明
  y + 2;
}).catch(function(error) {
  console.log('carry on', error);
});
// oh no [ReferenceError: x is not defined]
// carry on [ReferenceError: y is not defined]
```

#### Promise.all()
Promise.all方法用于将多个Promise实例，包装成一个新的Promise实例。

```
var p = Promise.all([p1,p2,p3]);
```

上面代码中，Promise.all方法接受一个数组作为参数，p1、p2、p3都是Promise对象的实例。（Promise.all方法的参数不一定是数组，但是必须具有Iterable接口，且返回的每个成员都是Promise实例。）

p的状态由p1、p2、p3决定，分成两种情况。

1. 只有p1、p2、p3的状态都变成fulfilled，p的状态才会变成fulfilled，此时p1、p2、p3的返回值组成一个数组，传递给p的回调函数。
2. 只要p1、p2、p3之中有一个被rejected，p的状态就变成rejected，此时第一个被reject的实例的返回值，会传递给p的回调函数。

```
// 生成一个Promise对象的数组
var promises = [2, 3, 5, 7, 11, 13].map(function(id){
  return getJSON("/post/" + id + ".json");
});

Promise.all(promises).then(function(posts) {
  // ...
}).catch(function(reason){
  // ...
});
```
#### Promise.race()
Promise.race方法同样是将多个Promise实例，包装成一个新的Promise实例。

```
var p = Promise.race([p1,p2,p3]);
```

上面代码中，只要p1、p2、p3之中有一个实例率先改变状态，p的状态就跟着改变。那个率先改变的Promise实例的返回值，就传递给p的回调函数。

如果Promise.all方法和Promise.race方法的参数，不是Promise实例，就会先调用下面讲到的Promise.resolve方法，将参数转为Promise实例，再进一步处理。

#### Promise.resolve()
有时需要将现有对象转为Promise对象，Promise.resolve方法就起到这个作用。

```
var jsPromise = Promise.resolve($.ajax('/whatever.json'));
```

上面代码将jQuery生成deferred对象，转为一个新的Promise对象。

如果Promise.resolve方法的参数，不是具有then方法的对象（又称thenable对象），则返回一个新的Promise对象，且它的状态为Resolved。

```
var p = Promise.resolve('Hello');

p.then(function (s){
  console.log(s)
});
// Hello
```

上面代码生成一个新的Promise对象的实例p。由于字符串Hello不属于异步操作（判断方法是它不是具有then方法的对象），返回Promise实例的状态从一生成就是Resolved，所以回调函数会立即执行。Promise.resolve方法的参数，会同时传给回调函数。

Promise.resolve方法允许调用时不带参数。所以，如果希望得到一个Promise对象，比较方便的方法就是直接调用Promise.resolve方法。

```
var p = Promise.resolve();

p.then(function () {
  // ...
});
```

如果Promise.resolve方法的参数是一个Promise实例，则会被原封不动地返回。

#### Promise.reject()
Promise.reject(reason)方法也会返回一个新的Promise实例，该实例的状态为rejected。Promise.reject方法的参数reason，会被传递给实例的回调函数。

```
var p = Promise.reject('出错了');

p.then(null, function (s){
  console.log(s)
});
// 出错了

```
上面代码生成一个Promise对象的实例p，状态为rejected，回调函数会立即执行。

#### Generator函数与Promise的结合
使用Generator函数管理流程，遇到异步操作的时候，通常返回一个Promise对象。

```
function getFoo() {
  return new Promise(function (resolve, reject){
    resolve('foo');
  });
}

var g = function*() {
  try {
    var foo = yield getFoo();
    console.log(foo);
  } catch (e) {
    console.log(e);
  }
};

function run(generator) {
  var it = generator();

  function go(result) {
    if (result.done) return result.value;

    return result.value.then(function (value) {
      return go(it.next(value));
    }, function (error) {
      return go(it.throw(value));
    });
  }

  go(it.next());
}

run(g);
```

#### async函数
async函数与Promise、Generator函数一样，是用来取代回调函数、解决异步操作的一种方法。它本质上是Generator函数的语法糖。async函数并不属于ES6，而是被列入了ES7，但是traceur、Babel.js、regenerator等转码器已经支持这个功能，转码后立刻就能使用。

