title: JavaScript 面向对象程序设计、函数表达式和异步编程
date: 2015-08-28 12:23:08
tags: JavaScript
categories: JavaScript
description: JavaScript 面向对象程序设计、函数表达式和异步编程，创建对象，继承，递归，闭包，块级作用域，私有变量，回调函数，Promise，Generator函数，async函数
---
[JavaScript 基本语法](2015/08/28/javascript-grammar/)，[JavaScript 引用类型](2015/08/28/javascript-reference-type/)，[JavaScript 面向对象程序设计、函数表达式和异步编程](2015/08/28/javascript-oop-function-expression-and-async/)三篇笔记是对《JavaScript 高级程序设计》和 [《ECMAScript 6入门》](https://github.com/ruanyf/es6tutorial/tree/5a5f9d8d492d0f925cbb6e09b10ebed9d2078d40)两本书的总结整理。

# 面向对象程序设计
ECMA-262把对象定义为：“无序属性的集合，其属性可以包含基本值、对象或者函数。”严格来讲，这就相当于说对象是一组没有特定顺序的值。对象的每个属性或方法都有一个名字，而每个名字都映射到一个值。正因为这样（以及其他将要讨论的原因），我们可以把ECMAScript的对象想象成散列表：无非就是一组名值对，其中值可以是数据或函数

<!-- more -->
### 属性类型
ECMAScript 中有两种属性:数据属性和访问器属性。

1. 数据属性
    数据属性包含一个数据值的位置。在这个位置可以读取和写入值。数据属性有4个描述其行为的特性。
    * [[Configurable]]：表示能否通过 delete 删除属性从而重新定义属性，能否修改属性的特性，或者能否把属性修改为访问器属性。像前面例子中那样直接在对象上定义的属性，它们的这个特性默认值为true。
    * [[Enumerable]]：表示能否通过 for-in 循环返回属性。像前面例子中那样直接在对象上定义的属性，它们的这个特性默认值为true。
    * [[Writable]]：表示能否修改属性的值。像前面例子中那样直接在对象上定义的属性，它们的这个特性默认值为true。
    * [[Value]]：包含这个属性的数据值。读取属性值的时候，从这个位置读；写入属性值的时候，把新值保存在这个位置。这个特性的默认值为undefined。

    像例子中那样直接在对象上定义的属性,它们的 [[Configurable]] 、 [[Enumerable]] 和 [[Writable]] 特性都被设置为 true ,而 [[Value]] 特性被设置为"Nicholas"。例如: `var person = { name: "Nicholas" };`

    要修改属性默认的特性，必须使用ECMAScript 5的Object.defineProperty()方法。这个方法接收三个参数：属性所在的对象、属性的名字和一个描述符对象。其中，描述符（descriptor）对象的属性必须是：configurable、enumerable、writable 和 value。设置其中的一或多个值，可以修改对应的特性值。

    {% codeblock %}
    var person = {};
    Object.defineProperty(person, "name", {
      writable: false,
      value: "Nicholas"
    });
    alert(person.name); //"Nicholas"
    person.name = "Greg";
    alert(person.name); //"Nicholas"
    {% endcodeblock %}

    name属性的值是不可修改的，如果尝试为它指定新值，则在非严格模式下，赋值操作将被忽略；在严格模式下，赋值操作将会导致抛出错误。

    把configurable设置为false，表示不能从对象中删除属性。如果对这个属性调用delete，则在非严格模式下什么也不会发生，而在严格模式下会导致错误。而且,一旦把属性定义为不可配置的,就不能再把它变回可配置了。此时,再调用 Object.defineProperty() 方法修改除 writable 之外的特性

    可以多次调用Object.defineProperty()方法修改同一个属性，但在把configurable特性设置为false之后就会有限制了。 在调用Object.defineProperty()方法时，如果不指定，configurable、enumerable和writable特性的默认值都是false。

2. 访问器属性
    访问器属性不包含数据值；它们包含一对儿getter和setter函数（不过，这两个函数都不是必需的）。在读取访问器属性时，会调用 getter函数，这个函数负责返回有效的值；在写入访问器属性时，会调用setter函数并传入新值，这个函数负责决定如何处理数据。访问器属性有如下4个特性。
    * [[Configurable]]：表示能否通过 delete 删除属性从而重新定义属性，能否修改属性的特性，或者能否把属性修改为数据属性。对于直接在对象上定义的属性，这个特性的默认值为true。
    * [[Enumerable]]：表示能否通过 for-in 循环返回属性。对于直接在对象上定义的属性，这个特性的默认值为true。
    * [[Get]]：在读取属性时调用的函数。默认值为undefined。
    * [[Set]]：在写入属性时调用的函数。默认值为undefined。

    访问器属性不能直接定义，必须使用Object.defineProperty()来定义。

    {% codeblock %}
    var book = {
      _year: 2004,
      edition: 1
    };
    Object.defineProperty(book, "year", {
      get: function(){
        return this._year;
      },
      set: function(newValue){
        if (newValue > 2004) {
          this._year = newValue;
          this.edition += newValue - 2004;
        }
      }
    });
    book.year = 2005;
    alert(book.edition); //2
    {% endcodeblock %}

    `_year`前面的下划线是一种常用的记号，用于表示只能通过对象方法访问的属性。

    不一定非要同时指定getter和setter。只指定getter意味着属性是不能写，尝试写入属性会被忽略。在严格模式下，尝试写入只指定了getter函数的属性会抛出错误。类似地，只指定setter函数的属性也不能读，否则在非严格模式下会返回undefined，而在严格模式下会抛出错误。

    {% codeblock %}
    book.__defineGetter__("year", function(){
      return this._year;
    });
    book.__defineSetter__("year", function(newValue){
      if (newValue > 2004) {
        this._year = newValue;
        this.edition += newValue - 2004;
      }
    });
    {% endcodeblock %}

    支持ECMAScript 5的这个方法的浏览器有IE9+（IE8只是部分实现）、Firefox 4+、Safari 5+、Opera 12+和Chrome。在这个方法之前，要创建访问器属性，一般都使用两个非标准的方法：__defineGetter__()和__defineSetter__()。
    在 不 支 持 Object.defineProperty() 方 法 的 浏 览 器 中 不 能 修 改 [[Configurable]] 和 [[Enumerable]] 。

### 定义多个属性
由于为对象定义多个属性的可能性很大，ECMAScript 5又定义了一个Object.defineProperties()方法。利用这个方法可以通过描述符一次定义多个属性。这个方法接收两个对象参数：第一个对象是要添加和修改其属性的对象，第二个对象的属性与第一个对象中要添加或修改的属性一一对应。

```
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

### 读取属性的特性
使用 ECMAScript 5的 Object.getOwnPropertyDescriptor()方法，可以取得给定属性的描述符。这个方法接收两个参数：属性所在的对象和要读取其描述符的属性名称。返回值是一个对象，如果是访问器属性，这个对象的属性有configurable、enumerable、get 和set；如果是数据属性，这个对象的属性有configurable、enumerable、writable和value

```
var descriptor = Object.getOwnPropertyDescriptor(book, "_year");
alert(descriptor.value); //2004
alert(descriptor.configurable); //false
```

## 创建对象
### 工厂模式
用函数来封装以特定接口创建对象的细节
```
function createPerson(name, age, job){
  var o = new Object();
  o.name = name;
  o.age = age;
  o.job = job;
  o.sayName = function(){
    alert(this.name);
  };
  return o;
}
var person1 = createPerson("Nicholas", 29, "Software Engineer");
var person2 = createPerson("Greg", 27, "Doctor");
```

函数createPerson()能够根据接受的参数来构建一个包含所有必要信息的Person对象。可以无数次地调用这个函数，而每次它都会返回一个包含三个属性一个方法的对象。工厂模式虽然解决了创建多个相似对象的问题，但却没有解决对象识别的问题（即怎样知道一个对象的类型）。

### 构造函数模式

```
function Person(name, age, job){
  this.name = name;
  this.age = age;
  this.job = job;
  this.sayName = function(){
    alert(this.name);
  };
}
var person1 = new Person("Nicholas", 29, "Software Engineer");
var person2 = new Person("Greg", 27, "Doctor");
```

在这个例子中，Person()函数取代了 createPerson()函数。我们注意到，Person()中的代码除了与createPerson()中相同的部分外，还存在以下不同之处：
* 没有显式地创建对象；
* 直接将属性和方法赋给了this对象；
* 没有return语句。

此外，还应该注意到函数名Person使用的是大写字母P。按照惯例，构造函数始终都应该以一个大写字母开头，而非构造函数则应该以一个小写字母开头。这个做法借鉴自其他OO语言，主要是为了区别于ECMAScript中的其他函数；本质上它和其它函数没有区别的，任何函数通过new调用就会被当做构造函数。 要创建 Person 的新实例，必须使用 new 操作符。以这种方式调用构造函数实际上会经历以下 4个步骤： (1) 创建一个新对象； (2) 将构造函数的作用域赋给新对象（因此this就指向了这个新对象）； (3) 执行构造函数中的代码（为这个新对象添加属性）； (4) 返回新对象。

1. 将构造函数当作函数
    构造函数本身就是一个普通的函数，所以我们不使用new关键字，可以看下调用Person会有什么结果
    {% codeblock %}
    // 作为普通函数调用，由于构造函数没有返回值，所以p将是undefined
    var p = Person("Greg", 27, "Doctor"); // 在全局作用域中调用一个函数时, this 对象总是指向 Global 对象，这里就是添加到 window
    window.sayName(); //"Greg"
    sayName(); //"Greg"
    // 在另一个对象的作用域中调用
    var o = new Object();
    Person.call(o, "Kristen", 25, "Nurse");
    o.sayName(); //"Kristen"
    {% endcodeblock %}

2. 构造函数的问题
    上面的声明函数等价于`this.sayName = new Function("alert(this.name)");`

    使用构造函数的主要问题，就是每个方法都要在每个实例上重新创建一遍。在前面的例子中，person1和person2都有一个名为sayName()的方法，但那两个方法不是同一个Function的实例。可以通过将函数声明在全局作用域，通过`this.sayName = sayName`赋值，但在全局作用域添加函数不是一种好的做法。这个问题可以通过原型模式解决

### 原型模式
我们创建的每个函数都有一个 prototype（原型）属性，这个属性是一个指针，指向一个对象，而这个对象的用途是包含可以由特定类型的所有实例共享的属性和方法。如果按照字面意思来理解，那么 prototype 就是通过调用构造函数而创建的那个对象实例的原型对象。使用原型对象的好处是可以让所有对象实例共享它所包含的属性和方法。换句话说，不必在构造函数中定义对象实例的信息，而是可以将这些信息直接添加到原型对象中

```
function Person(){
}
Person.prototype.name = "Nicholas";
Person.prototype.age = 29;
Person.prototype.job = "Software Engineer";
Person.prototype.sayName = function(){
  alert(this.name);
};
```

1. 理解原型对象
    JavaScript中函数都是Function类型的实例，把Person当做一个指针，它指向一个Function类型的对象，每个Function实例都有prototype属性，其指向一个函数的原型对象，通过Person.prototype就可以访问到这个对象。默认情况下，每个原型对象都有一个constructor属性，这个属性指向 prototype 属性所在函数也就是Person。创建了自定义的构造函数之后，其原型对象默认只会取得constructor属性；至于其他方法，则都是从Object继承而来的。每个对象都有[[Prototype]]属性（内部属性），虽然在脚本中没有标准的方式访问[[Prototype]]，但 Firefox、Safari 和 Chrome 在每个对象上都支持一个属性`__proto__`；而在其他实现中，这个属性对脚本则是完全不可见的。这个属性指向了构造函数的原型对象，也就是Person.prototype指向的对象。JavaScript中通过递归原型链来查找对象属性，因此person1和person2可以访问到其原型Person.prototype中的属性constructor。除了通过instanceof外也可以通过person1.constructor === Person来判断是否是Person类型，但是instanceof更加可靠，因为prototype对象完全可以被覆盖，其属性constructor也就不一定是Person了。

    {% codeblock %}
    +-------------------+ <------------------------------+
    |      Person       |                                |
    +-------------------+                                |
    |prototype|        -|--+-->+----------------------+  |
    +-------------------+  |   |     Person prototype |  |
                           |   +----------------------+  |
    +--------------------+ |   |constructor|         -|--+
    |      person1       | |   +----------------------+
    +--------------------+ |   |name       |"Nicholas"|
    |[[Prototype]]|     -|-+   +----------------------+
    +--------------------+ |   |age        |     29   |
                           |   +----------------------+
    +--------------------+ |   |job        |"Soft...."|
    |      person2       | |   +----------------------+
    +--------------------+ |   |sayName    |(function)|
    |[[Prototype]]|     -|-+   +----------------------+
    +--------------------+
    {% endcodeblock %}

    虽然在所有实现中都无法访问到[[Prototype]]，但可以通过 isPrototypeOf()方法来确定对象之间是否存在这种关系。从本质上讲，如果[[Prototype]]指向调用 isPrototypeOf()方法的对象（Person.prototype），那么这个方法就返回true

    ECMAScript 5增加了一个新方法，叫 Object.getPrototypeOf()，在所有支持的实现中，这个方法返回[[Prototype]]的值。

    每当代码读取某个对象的某个属性时，都会执行一次搜索，目标是具有给定名字的属性。搜索首先从对象实例本身开始。如果在实例中找到了具有给定名字的属性，则返回该属性的值；如果没有找到，则继续搜索指针指向的原型对象，在原型对象中查找具有给定名字的属性。如果在原型对象中找到了这个属性，则返回该属性的值。

    虽然可以通过对象实例访问保存在原型中的值，但却不能通过对象实例重写原型中的值。如果我们在实例中添加了一个属性，而该属性与实例原型中的一个属性同名，那我们就在实例中创建该属性，该属性将会屏蔽原型中的那个属性。`person1.name = "Greg";`将会覆盖原型中的name属性。

    不过，使用delete操作符则可以完全删除实例属性，从而让我们能够重新访问原型中的属性

    使用hasOwnProperty()方法可以检测一个属性是存在于实例中，还是存在于原型中。这个方法（不要忘了它是从Object继承来的）只在给定属性存在于对象实例中时，才会返回true。`person1.hasOwnProperty("name");person2.hasOwnProperty("name");`第一个返回true，第二个返回false

    ECMAScript 5 的 Object.getOwnPropertyDescriptor() 方法只能用于实例属性,要取得原型属性的描述符,必须直接在原型对象上调用 Object.getOwnPropertyDescriptor() 方法。

2. 原型与 in 操作符
    有两种方式使用in操作符：单独使用和在for-in循环中使用。在单独使用时，in操作符会在通过对象能够访问给定属性时返回true，无论该属性存在于实例中还是原型中。`"name" in person1`为true

    在使用 for-in 循环时，返回的是所有能够通过对象访问的、可枚举的（enumerated）属性，其中既包括存在于实例中的属性，也包括存在于原型中的属性。屏蔽了原型中不可枚举属性（即将[[Enumerable]]标记为 false 的属性）的实例属性也会在 for-in 循环中返回，因为根据规定，所有开发人员定义的属性都是可枚举的——只有在IE8及更早版本中例外。

    要取得对象上所有可枚举的实例属性，可以使用ECMAScript 5的Object.keys()方法。这个方法接收一个对象作为参数，返回一个包含所有可枚举属性的字符串数组。

    为减少不必要的输入，也为了从视觉上更好地封装原型的功能，更常见的做法是用一个包含所有属性和方法的对象字面量来重写整个原型对象，如下面的例子所示。

    {% codeblock %}
    var keys = Object.keys(Person.prototype); //["name","age","jbo","sayName"]
    var keys = Object.getOwnPropertyNames(Person.prototype); //["constructor","name","age","jbo","sayName"]
    {% endcodeblock %}

3. 更简单的原型语法
    如果你想要得到所有实例属性，无论它是否可枚举，都可以使用Object.getOwnPropertyNames()方法。

    {% codeblock %}
    function Person(){ }
    Person.prototype = {
        name : "Nicholas",
        age : 29,
        job: "Software Engineer",
        sayName : function () { alert(this.name); }
    };
    {% endcodeblock %}

    这时constructor 属性不再指向 Person 了。前面曾经介绍过，每创建一个函数，就会同时创建它的 prototype 对象，这个对象也会自动获得 constructor 属性。而我们在这里使用的语法，本质上完全重写了默认的 prototype 对象，因此 constructor 属性也就变成了新对象的constructor属性（指向Object构造函数），不再指向Person函数。如果constructor的值真的很重要，可以像下面这样特意将它设置回适当的值。

    {% codeblock %}
    function Person(){ }
    Person.prototype = {
        constructor : Person,
        name : "Nicholas",
        age : 29,
        job: "Software Engineer",
        sayName : function () { alert(this.name); }
    };
    {% endcodeblock %}

    注意，以这种方式重设 constructor 属性会导致它的[[Enumerable]]特性被设置为 true。默认情况下，原生的constructor属性是不可枚举的，因此如果你使用兼容ECMAScript 5的JavaScript引擎，可以试一试Object.defineProperty()。

4. 原型的动态性
    由于在原型中查找值的过程是一次搜索,因此我们对原型对象所做的任何修改都能够立即从实例上反映出来——即使是先创建了实例后修改原型也照样如此。
    {% codeblock %}
    var friend = new Person();
    Person.prototype.sayHi = function(){
      alert("hi");
    };
    friend.sayHi(); //"hi"(没有问题!)
    {% endcodeblock %}
    其原因可以归结为实例与原型之间的松散连接关系。当我们调用person.sayHi()时，首先会在实例中搜索名为 sayHi 的属性，在没找到的情况下，会继续搜索原型。因为实例与原型之间的连接只不过是一个指针，而非一个副本，因此就可以在原型中找到新的 sayHi 属性并返回保存在那里的函数。

    尽管可以随时为原型添加属性和方法，并且修改能够立即在所有对象实例中反映出来，但如果是重写整个原型对象，那么情况就不一样了。我们知道，调用构造函数时会为实例添加一个指向最初原型的[[Prototype]]指针，而把原型修改为另外一个对象就等于切断了构造函数与最初原型之间的联系。请记住：实例中的指针仅指向原型，而不指向构造函数

5. 原生对象的原型
    通过原生对象的原型，不仅可以取得所有默认方法的引用，而且也可以定义新方法。可以像修改自定义对象的原型一样修改原生对象的原型，因此可以随时添加方法。但是不推荐这么做。
6. 原型对象的问题
    原型中所有属性是被很多实例共享的，这种共享对于函数非常合适。对于那些包含基本值的属性倒也说得过去，毕竟（如前面的例子所示），通过在实例上添加一个同名属性，可以隐藏原型中的对应属性。然而，对于包含引用类型值的属性来说，问题就比较突出了。

### 组合使用构造函数模式和原型模式
构造函数模式用于定义实例属性，而原型模式用于定义方法和共享的属性。结果，每个实例都会有自己的一份实例属性的副本，但同时又共享着对方法的引用，最大限度地节省了内存。另外，这种混成模式还支持向构造函数传递参数；可谓是集两种模式之长。这是用来定义引用类型的一种默认模式。

```
function Person(name, age, job){
  this.name = name;
  this.age = age;
  this.job = job;
}
Person.prototype = {
  constructor : Person,
  sayName : function(){
    alert(this.name);
  }
}
```

### 动态原型模式
有其他 OO 语言经验的开发人员在看到独立的构造函数和原型时,很可能会感到非常困惑。动态原型模式正是致力于解决这个问题的一个方案，它把所有信息都封装在了构造函数中，而通过在构造函数中初始化原型（仅在必要的情况下），又保持了同时使用构造函数和原型的优点。换句话说，可以通过检查某个应该存在的方法是否有效，来决定是否需要初始化原型。
```
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

if中这段代码只会在初次调用构造函数时才会执行。

使用动态原型模式时,不能使用对象字面量重写原型。前面已经解释过了,如果在已经创建了实例的情况下重写原型,那么就会切断现有实例与新原型之间的联系。

### 寄生构造函数模式

```
function Person(name, age, job){
  var o = new Object();
  o.name = name;
  o.age = age;
  o.job = job;
  o.sayName = function(){
    alert(this.name);
  };
  return o;
}
var friend = new Person("Nicholas", 29, "Software Engineer");
```
除了使用new操作符并把使用的包装函数叫做构造函数之外，这个模式跟工厂模式其实是一模一样的。构造函数在不返回值的情况下，默认会返回新对象实例。添加return可以重写调用构造函数时返回的值。

关于寄生构造函数模式，有一点需要说明：首先，返回的对象与构造函数或者与构造函数的原型属性之间没有关系；也就是说，构造函数返回的对象与在构造函数外部创建的对象没有什么不同。为此，不能依赖instanceof操作符来确定对象类型。由于存在上述问题，我们建议在可以使用其他模式的情况下，不要使用这种模式。

### 稳妥构造函数模式
稳妥对象，指的是没有公共属性，而且其方法也不引用this的对象。稳妥对象最适合在一些安全的环境中（这些环境中会禁止使用this和new），或者在防止数据被其他应用程序（如Mashup程序）改动时使用。稳妥构造函数遵循与寄生构造函数类似的模式，但有两点不同：一是新创建对象的实例方法不引用this；二是不使用new 操作符调用构造函数
```
function Person(name, age, job){
  var o = new Object();
  //可以在这里定义私有变量和函数
  o.sayName = function(){
    alert(name);
  };
  return o;
}
var friend = new Person("Nicholas", 29, "Software Engineer");
```
除了调用 sayName() 方法外,没有别的方式可以访问其数据成员。

与寄生构造函数模式类似，使用稳妥构造函数模式创建的对象与构造函数之间也没有什么关系，因此instanceof操作符对这种对象也没有意义。

### Class
ES6提供了更接近传统语言的写法，引入了Class（类）这个概念，作为对象的模板。通过class关键字，可以定义类。基本上，ES6的class可以看作只是一个语法糖，它的绝大部分功能，ES5都可以做到，新的class写法只是让对象原型的写法更加清晰、更像面向对象编程的语法而已。

```
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

ES6的类，完全可以看作构造函数的另一种写法。
```
typeof Person // "function"
```

prototype对象的constructor属性，直接指向“类”的本身，这与ES5的行为是一致的。
```
Person.prototype.constructor === Person// true
```
另外，类的内部所有定义的方法，都是不可枚举的（enumerable）。
```
Object.keys(Person.prototype)
// []
Object.getOwnPropertyNames(Person.prototype)
// ["constructor","sayName"]
```

上面代码中，sayName方法是Person类内部定义的方法，它是不可枚举的。这一点与ES5的行为不一致。

#### constructor方法
constructor方法是类的默认方法，通过new命令生成对象实例时，自动调用该方法。一个类必须有constructor方法，如果没有显式定义，一个空的constructor方法会被默认添加。

constructor方法默认返回实例对象（即this），完全可以指定返回另外一个对象。

```
class Foo {
  constructor() {
    return Object.create(null);
  }
}

new Foo() instanceof Foo // false
```
上面代码中，constructor函数返回一个全新的对象，结果导致实例对象不是Foo类的实例。

#### 实例对象
生成实例对象的写法，与ES5完全一样，也是使用new命令。如果忘记加上new，像函数那样调用Class，将会报错。

与ES5一样，实例的属性除非显式定义在其本身（即定义在this对象上），否则都是定义在原型上（即定义在class上）。

与ES5一样，类的所有实例共享一个原型对象。

```
friend.__proto__ === Person.prototype  //true
```
#### name属性
由于本质上，ES6的Class只是ES5的构造函数的一层包装，所以函数的许多特性都被Class继承，包括name属性。
```
Person.name
```
#### class 表达式
与函数一样，Class也可以使用表达式的形式定义。

```
const MyClass = class Me {
  getClassName() {
    return Me.name;
  }
};
```

上面代码使用表达式定义了一个类。需要注意的是，这个类的名字是MyClass而不是Me，Me只在Class的内部代码可用，指代当前类。如果Class内部没用到的话，可以省略Me，也就是可以写成下面的形式。
```
const MyClass = class { /* ... */ };
```

采用Class表达式，可以写出立即执行的Class。

```
let person = new class {
  constructor(name) {
    this.name = name;
  }

  sayName() {
    console.log(this.name);
  }
}("张三");

person.sayName(); // "张三"
```

#### 不存在变量提升
Class不存在变量提升（hoist），这一点与ES5完全不同。

```
new Foo(); // ReferenceError
class Foo {}
```

上面代码中，Foo类使用在前，定义在后，这样会报错，因为ES6不会把变量声明提升到代码头部。这种规定的原因与下文要提到的继承有关，必须保证子类在父类之后定义。

```
{
  let Foo = class {};
  class Bar extends Foo {
  }
}
```

#### 严格模式
类和模块的内部，默认就是严格模式，所以不需要使用`use strict`指定运行模式。只要你的代码写在类或模块之中，就只有严格模式可用。

#### class的取值函数（getter）和存值函数（setter）
与ES5一样，在Class内部可以使用get和set关键字，对某个属性设置存值函数和取值函数，拦截该属性的存取行为。

```
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

let inst = new MyClass();

inst.prop = 123;
// setter: 123

inst.prop
// 'getter'
```

存值函数和取值函数是设置在属性的descriptor对象上的。

```
class CustomHTMLElement {
  constructor(element) {
    this.element = element;
  }

  get html() {
    return this.element.innerHTML;
  }

  set html(value) {
    this.element.innerHTML = value;
  }
}

var descriptor = Object.getOwnPropertyDescriptor(
  CustomHTMLElement.prototype, "html");
"get" in descriptor  // true
"set" in descriptor  // true
```

上面代码中，存值函数和取值函数是定义在html属性的描述对象上面，这与ES5完全一致。

下面的例子针对所有属性，设置存值函数和取值函数。

```
class Jedi {
  constructor(options = {}) {
    // ...
  }

  set(key, val) {
    this[key] = val;
  }

  get(key) {
    return this[key];
  }
}
```

上面代码中，Jedi实例所有属性的存取，都会通过存值函数和取值函数。

#### Class的Generator方法
如果某个方法之前加上星号（*），就表示该方法是一个Generator函数。

```
class Foo {
  constructor(...args) {
    this.args = args;
  }
  * [Symbol.iterator]() {
    for (let arg of this.args) {
      yield arg;
    }
  }
}

for (let x of new Foo('hello', 'world')) {
  console.log(x);
}
// hello
// world
```

上面代码中，Foo类的Symbol.iterator方法前有一个星号，表示该方法是一个Generator函数。Symbol.iterator方法返回一个Foo类的默认Iterator对象，for...of循环会自动调用这个方法。

#### Class的静态方法
类相当于实例的原型，所有在类中定义的方法，都会被实例继承。如果在一个方法前，加上static关键字，就表示该方法不会被实例继承，而是直接通过类来调用，这就称为“静态方法”。

```
class Foo {
  static classMethod() {
    return 'hello';
  }
}

Foo.classMethod() // 'hello'

var foo = new Foo();
foo.classMethod()
// TypeError: undefined is not a function
```

上面代码中，Foo类的classMethod方法前有static关键字，表明该方法是一个静态方法，可以直接在Foo类上调用（`Foo.classMethod()`），而不是在Foo类的实例上调用。如果在实例上调用静态方法，会抛出一个错误，表示不存在该方法。

父类的静态方法，可以被子类继承。

静态方法也是可以从super对象上调用的。

```
class Foo {
  static classMethod() {
    return 'hello';
  }
}

class Bar extends Foo {
  static classMethod() {
    return super.classMethod() + ', too';
  }
}

Bar.classMethod();
```

#### new.target属性
new是从构造函数生成实例的命令。ES6为new命令引入了一个`new.target`属性，（在构造函数中）返回new命令作用于的那个构造函数。如果构造函数不是通过new命令调用的，`new.target`会返回undefined，因此这个属性可以用来确定构造函数是怎么调用的。

```
function Person(name) {
  if (new.target !== undefined) {
    this.name = name;
  } else {
    throw new Error('必须使用new生成实例');
  }
}

// 另一种写法
function Person(name) {
  if (new.target === Person) {
    this.name = name;
  } else {
    throw new Error('必须使用new生成实例');
  }
}

var person = new Person('张三'); // 正确
var notAPerson = Person.call(person, '张三');  // 报错
```

上面代码确保构造函数只能通过new命令调用。

Class内部调用`new.target`，返回当前Class。

```
class Rectangle {
  constructor(length, width) {
    console.log(new.target === Rectangle);
    this.length = length;
    this.width = width;
  }
}

var obj = new Rectangle(3, 4); // 输出 true
```

需要注意的是，子类继承父类时，`new.target`会返回子类。

```
class Rectangle {
  constructor(length, width) {
    console.log(new.target === Rectangle);
    // ...
  }
}

class Square extends Rectangle {
  constructor(length) {
    super(length, length);
  }
}

var obj = new Square(3); // 输出 false
```

上面代码中，`new.target`会返回子类。

利用这个特点，可以写出不能独立使用、必须继承后才能使用的类。

```
class Shape {
  constructor() {
    if (new.target === Shape) {
      throw new Error('本类不能实例化');
    }
  }
}

class Rectangle extends Shape {
  constructor(length, width) {
    super();
    // ...
  }
}

var x = new Shape();  // 报错
var y = new Rectangle(3, 4);  // 正确
```

上面代码中，Shape类不能被实例化，只能用于继承。

注意，在函数外部，使用`new.target`会报错。

#### Mixin模式的实现
Mixin模式指的是，将多个类的接口“混入”（mix in）另一个类。它在ES6的实现如下。

```
function mix(...mixins) {
  class Mix {}

  for (let mixin of mixins) {
    copyProperties(Mix, mixin);
    copyProperties(Mix.prototype, mixin.prototype);
  }

  return Mix;
}

function copyProperties(target, source) {
  for (let key of Reflect.ownKeys(source)) {
    if ( key !== "constructor"
      && key !== "prototype"
      && key !== "name"
    ) {
      let desc = Object.getOwnPropertyDescriptor(source, key);
      Object.defineProperty(target, key, desc);
    }
  }
}
```

上面代码的mix函数，可以将多个对象合成为一个类。使用的时候，只要继承这个类即可。

```
class DistributedEdit extends mix(Loggable, Serializable) {
  // ...
}
```

## 继承
ECMAScript只支持实现继承，而且其实现继承主要是依靠原型链来实现的。

### 原型链
其基本思想是利用原型让一个引用类型继承另一个引用类型的属性和方法。简单回顾一下构造函数、原型和实例的关系：每个构造函数都有一个原型对象，原型对象都包含一个指向构造函数的指针，而实例都包含一个指向原型对象的内部指针。那么，假如我们让原型对象等于另一个类型的实例，结果会怎么样呢？显然，此时的原型对象将包含一个指向另一个原型的指针，相应地，另一个原型中也包含着一个指向另一个构造函数的指针。假如另一个原型又是另一个类型的实例，那么上述关系依然成立，如此层层递进，就构成了实例与原型的链条。这就是所谓原型链的基本概念。

```
function SuperType(){
    this.property = true;
}

SuperType.prototype.getSuperValue = function(){
    return this.property;
};

function SubType(){
    this.subproperty = false;
}

//inherit from SuperType
SubType.prototype = new SuperType();

SubType.prototype.getSubValue = function (){
    return this.subproperty;
};

var instance = new SubType();
alert(instance.getSuperValue());   //true

alert(instance instanceof Object);      //true
alert(instance instanceof SuperType);   //true
alert(instance instanceof SubType);     //true
alert(Object.prototype.isPrototypeOf(instance));    //true
alert(SuperType.prototype.isPrototypeOf(instance)); //true
alert(SubType.prototype.isPrototypeOf(instance));   //true
```
既然 SubType.prototype 现在是 SuperType的实例,那么 property 当然就位于该实例中了。此外,要注意 instance.constructor 现在指向的是 SuperType ,这是因为SubType 的原型指向了另一个对象—— SuperType 的原型,而这个原型对象的 constructor 属性指向的是 SuperType。
```
+-------------------+
|      SuperType    | <--------------------------------+
+-------------------+                                  |
|prototype|        -|----+>+------------------------+  |
+-------------------+    | |   SuperType prototype  |  |
                         | +------------------------+  |
+--------------------+   | |constructor  |         -|--+
|      SubType       |   | +------------------------+
+--------------------+   | |getSuperValue|(function)|
|  prototype  |     -|-+ | +------------------------+
+--------------------+ | +----------------------------+
                       |   +------------------------+ |
+--------------------+ |-->|    SubType prototype   | |
|      instance      | |   +------------------------+ |
+--------------------+ |   |[[Prototype]]|         -|-+
|[[Prototype]]|     -|-+   +------------------------+
+--------------------+     |property     |  true    |
|subproperty  | false|     +------------------------+
+--------------------+     |getSubValue  |(function)|
                           +------------------------+
```

通过实现原型链,本质上扩展了本章前面介绍的原型搜索机制。读者大概还记得,当以读取模式访问一个实例属性时,首先会在实例中搜索该属性。如果没有找到该属性,则会继续搜索实例的原型。在通过原型链实现继承的情况下,搜索过程就得以沿着原型链继续向上。就拿上面的例子来说,调用instance.getSuperValue() 会经历三个搜索步骤:1)搜索实例;2)搜索 SubType.prototype ; 3)搜索 SuperType.prototype ,最后一步才会找到该方法。在找不到属性或方法的情况下,搜索过程总是要一环一环地前行到原型链末端才会停下来。

1. 别忘记默认的原型
    事实上,前面例子中展示的原型链还少一环。我们知道,所有引用类型默认都继承了 Object ,而这个继承也是通过原型链实现的。大家要记住,所有函数的默认原型都是 Object 的实例,因此默认原型都会包含一个内部指针,指向 Object.prototype
2. 确定原型和实例的关系
    第一种方式是使用 instanceof 操作符,只要用这个操作符来测试实例与原型链中出现过的构造函数,结果就会返回 true。
    第二种方式是使用 isPrototypeOf() 方法。同样,只要是原型链中出现过的原型,都可以说是该原型链所派生的实例的原型,因此 isPrototypeOf() 方法也会返回 true
3. 谨慎地定义方法
    子类型有时候需要重写超类型中的某个方法,或者需要添加超类型中不存在的某个方法。但不管怎样,给原型添加方法的代码一定要放在替换原型的语句之后。
    {% codeblock %}
    //继承了 SuperType
    SubType.prototype = new SuperType();
    //添加新方法
    SubType.prototype.getSubValue = function (){
      return this.subproperty;
    };
    //重写超类型中的方法
    SubType.prototype.getSuperValue = function (){
      return false;
    };
    {% endcodeblock %}
    还有一点需要提醒读者,即在通过原型链实现继承时,不能使用对象字面量创建原型方法。因为这样做就会重写原型链
4. 原型链的问题
    原型链虽然很强大,可以用它来实现继承,但它也存在一些问题。其中,最主要的问题来自包含引用类型值的原型。

    在通过原型来实现继承时,原型实际上会变成另一个类型的实例。于是,原先的实例属性也就顺理成章地变成了现在的原型属性了。这些继承的属性会被子类实例共享。
    {% codeblock %}
    function SuperType(){
      this.colors = ["red", "blue", "green"];
    }
    function SubType(){
    }
    //继承了 SuperType
    SubType.prototype = new SuperType();
    var instance1 = new SubType();
    instance1.colors.push("black");
    alert(instance1.colors); //"red,blue,green,black"
    var instance2 = new SubType();
    alert(instance2.colors); //"red,blue,green,black"
    {% endcodeblock %}
    原型链的第二个问题是:在创建子类型的实例时,不能向超类型的构造函数中传递参数。基于这两点原因实践中很少单独使用原型链

### 借用构造函数
在解决原型中包含引用类型值所带来问题的过程中,开发人员开始使用一种叫做借用构造函数(constructor stealing)的技术(有时候也叫做伪造对象或经典继承)。这种技术的基本思想相当简单,即在子类型构造函数的内部调用超类型构造函数。别忘了,函数只不过是在特定环境中执行代码的对象,因此通过使用 apply() 和 call() 方法也可以在(将来)新创建的对象上执行构造函数

```
function SuperType(name){
  this.colors = ["red", "blue", "green"];
  this.name = name;
}
function SubType(){
  //继承了 SuperType 同时还传递了参数
  SuperType.call(this, "Nicholas");
  this.age = 29;
}
var instance1 = new SubType();
instance1.colors.push("black");
alert(instance1.colors); //"red,blue,green,black"
var instance2 = new SubType();
alert(instance2.colors); //"red,blue,green"
alert(instance2.name);
alert(instance2.age);
```

1. 传递参数
    这种方法解决了原型链的两个主要的问题，为了确保SuperType 构造函数不会重写子类型的属性,可以在调用超类型构造函数后,再添加应该在子类型中定义的属性。
2. 借用构造函数的问题
    如果仅仅是借用构造函数,那么也将无法避免构造函数模式存在的问题——方法都在构造函数中定义,因此函数复用就无从谈起了。而且,在超类型的原型中定义的方法,对子类型而言也是不可见的,结果所有类型都只能使用构造函数模式。考虑到这些问题,借用构造函数的技术也是很少单独使用的。

### 组合继承
组合继承(combination inheritance) ,有时候也叫做伪经典继承,指的是将原型链和借用构造函数的技术组合到一块,从而发挥二者之长的一种继承模式。其背后的思路是使用原型链实现对原型属性和方法的继承,而通过借用构造函数来实现对实例属性的继承。
```
function SuperType(name){
  this.name = name;
  this.colors = ["red", "blue", "green"];
}
SuperType.prototype.sayName = function(){
  alert(this.name);
};
function SubType(name, age){
  //继承属性
  SuperType.call(this, name);
  this.age = age;
}
//继承方法
SubType.prototype = new SuperType();
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

### 原型式继承
道格拉斯·克罗克福德在 2006 年写了一篇文章,题为 Prototypal Inheritance in JavaScript (JavaScript 中的原型式继承)。在这篇文章中,他介绍了一种实现继承的方法,这种方法并没有使用严格意义上的构造函数。他的想法是借助原型可以基于已有的对象创建新对象,同时还不必因此创建自定义类型。
```
function object(o){
  function F(){}
  F.prototype = o;
  return new F();
}
```
在 object() 函数内部,先创建了一个临时性的构造函数,然后将传入的对象作为这个构造函数的原型,最后返回了这个临时类型的一个新实例。从本质上讲, object() 对传入其中的对象执行了一次浅复制。

```
var person = {
  name: "Nicholas",
  friends: ["Shelby", "Court", "Van"]
};
//var anotherPerson = object(person);
var anotherPerson = Object.create(person);
anotherPerson.name = "Greg";
anotherPerson.friends.push("Rob");
//var yetAnotherPerson = object(person);
var yetAnotherPerson = Object.create(person);
yetAnotherPerson.name = "Linda";
yetAnotherPerson.friends.push("Barbie");
alert(person.friends); //"Shelby,Court,Van,Rob,Barbie"
```
原型式继承,要求你必须有一个对象可以作为另一个对象的基础。通过object()函数返回的对象实际上是person的副本，它们共享这引用类型属性。

ECMAScript 5 通过新增 Object.create() 方法规范化了原型式继承。这个方法接收两个参数:一个用作新对象原型的对象和(可选的)一个为新对象定义额外属性的对象。在传入一个参数的情况下,Object.create() 与 object() 方法的行为相同

Object.create() 方法的第二个参数与 Object.defineProperties() 方法的第二个参数格式相同:每个属性都是通过自己的描述符定义的。以这种方式指定的任何属性都会覆盖原型对象上的同名属性。

在没有必要兴师动众地创建构造函数,而只想让一个对象与另一个对象保持类似的情况下,原型式继承是完全可以胜任的。不过别忘了,包含引用类型值的属性始终都会共享相应的值,就像使用原型模式一样。

### 寄生式继承
寄生式(parasitic)继承是与原型式继承紧密相关的一种思路,并且同样也是由克罗克福德推而广之的。寄生式继承的思路与寄生构造函数和工厂模式类似,即创建一个仅用于封装继承过程的函数,该函数在内部以某种方式来增强对象,最后再像真地是它做了所有工作一样返回对象。

```
function createAnother(original){
  var clone = object(original); //通过调用函数创建一个新对象
  clone.sayHi = function(){  //以某种方式来增强这个对象
    alert("hi");
  };
  return clone;
}
```
在主要考虑对象而不是自定义类型和构造函数的情况下,寄生式继承也是一种有用的模式。前面示范继承模式时使用的 object() 函数不是必需的;任何能够返回新对象的函数都适用于此模式。

使用寄生式继承来为对象添加函数,会由于不能做到函数复用而降低效率;这一点与构造函数模式类似。

### 寄生组合式继承
组合继承是 JavaScript 最常用的继承模式;不过,它也有自己的不足。组合继承最大的问题就是无论什么情况下,都会调用两次超类型构造函数:一次是在创建子类型原型的时候,另一次是在子类型构造函数内部。没错,子类型最终会包含超类型对象的全部实例属性,但我们不得不在调用子类型构造函数时重写这些属性。

```
function SuperType(name){
  this.name = name;
  this.colors = ["red", "blue", "green"];
}
SuperType.prototype.sayName = function(){
  alert(this.name);
};
function SubType(name, age){
  SuperType.call(this, name);
  //第二次调用 SuperType()
  this.age = age;
}
SubType.prototype = new SuperType();
//第一次调用 SuperType()
SubType.prototype.constructor = SubType;
SubType.prototype.sayAge = function(){
  alert(this.age);
};
```
在第一次调用 SuperType 构造函数时, SubType.prototype 会得到两个属性: name 和 colors ;它们都是 SuperType 的实例属性,只不过现在位于 SubType 的原型中。当调用 SubType 构造函数时,又会调用一次 SuperType 构造函数,这一次又在新对象上创建了实例属性 name 和 colors 。

所谓寄生组合式继承,即通过借用构造函数来继承属性,通过原型链的混成形式来继承方法。其背后的基本思路是:不必为了指定子类型的原型而调用超类型的构造函数,我们所需要的无非就是超类型原型的一个副本而已。本质上,就是使用寄生式继承来继承超类型的原型,然后再将结果指定给子类型的原型。

```
function inheritPrototype(subType, superType){
  var prototype = object(superType.prototype); //创建对象
  prototype.constructor = subType; //增强对象
  subType.prototype = prototype; //指定对象
}
```
在函数内部,第一步是创建超类型原型的一个副本。第二步是为创建的副本添加 constructor 属性,从而弥补因重写原型而失去的默认的 constructor 属性。最后一步,将新创建的对象(即副本)赋值给子类型的原型。
```
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

### Class的继承
#### 基本用法
Class之间可以通过extends关键字实现继承，这比ES5的通过修改原型链实现继承，要清晰和方便很多。

```
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
SubType类通过extends关键字，继承了SuperType类的所有属性和方法，并且扩展了属性和方法。super关键字，它指代父类的实例（即父类的this对象）。

子类必须在constructor方法中调用super方法，否则新建实例时会报错。这是因为子类没有自己的this对象，而是继承父类的this对象，然后对其进行加工。如果不调用super方法，子类就得不到this对象。

```
class SuperType { /* ... */ }
class SubType extends SuperType {
  constructor() {
  }
}

let cp = new SubType(); // ReferenceError
```

对比前面的借用构造函数继承，实质是先创建子类的实例对象this，然后再将父类的属性添加到this上面（`Parent.apply(this)`）。ES6的继承机制则不同，实质是先创建父类的实例对象this（所以必须先调用super方法），然后再用子类的属性修改this。

如果子类没有定义constructor方法，这个方法会被默认添加，代码如下。也就是说，不管有没有显式定义，任何一个子类都有constructor方法。

```
constructor(...args) {
  super(...args);
}
```

另一个需要注意的地方是，在子类的构造函数中，只有调用super之后，才可以使用this关键字，否则会报错。这是因为子类实例的构建，是基于对父类实例加工，只有super方法才能返回父类实例。

```
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
    this.age = age; // ReferenceError
    super(name);
  }
}
```

```
let st = new SubType("Howie", 26);
st instanceof SubType // true
st instanceof SuperType // true
```
上面代码中，实例对象st同时是SubType和SuperType两个类的实例，这与ES5的行为完全一致。

#### 类的prototype属性和`__proto__`属性
在ES5中，每一个对象都有`__proto__`属性，指向对应的构造函数的prototype属性。Class作为构造函数的语法糖，同时有prototype属性和`__proto__`属性，因此同时存在两条继承链。

1. 子类的`__proto__`属性，表示构造函数的继承，总是指向父类。
2. 子类prototype属性的`__proto__`属性，表示方法的继承，总是指向父类的prototype属性。

```
SubType.__proto__ === SuperType // true
SubType.prototype.__proto__ === SuperType.prototype // true
```

这样的结果是因为，类的继承是按照下面的模式实现的。

```
class SuperType { }
class SubType { }

// B的实例继承A的实例
Object.setPrototypeOf(SubType.prototype, SuperType.prototype);

// B继承A的静态属性
Object.setPrototypeOf(SubType, SuperType);
//而setPrototypeOf实现如下
Object.setPrototypeOf = function (obj, proto) {
  obj.__proto__ = proto;
  return obj;
}
```

这两条继承链，可以这样理解：作为一个对象，子类的原型（`__proto__`属性）是父类；作为一个构造函数，子类的原型（prototype属性）是父类的实例。

```
SubType.prototype = new SuperType();
// 等同于
SubType.prototype.__proto__ = SuperType.prototype;
```

#### Extends 的继承目标
extends关键字后面可以跟多种类型的值。

```
class SubType extends SuperType{
}
```

上面代码的SuperType，只要是一个有prototype属性的函数，就能被SubType继承。由于函数都有prototype属性，因此SuperType可以是任意函数。

下面，讨论三种特殊情况。

第一种特殊情况，子类继承Object类。

```
class A extends Object {
}

A.__proto__ === Object // true
A.prototype.__proto__ === Object.prototype // true
```

这种情况下，A其实就是构造函数Object的复制，A的实例就是Object的实例。

第二种特殊情况，不存在任何继承。

```
class A {
}

A.__proto__ === Function.prototype // true
A.prototype.__proto__ === Object.prototype // true
```

这种情况下，A作为一个基类（即不存在任何继承），就是一个普通函数，所以直接继承`Funciton.prototype`。但是，A调用后返回一个空对象（即Object实例），所以`A.prototype.__proto__`指向构造函数（Object）的prototype属性。

第三种特殊情况，子类继承null。

```
class A extends null {
}

A.__proto__ === Function.prototype // true
A.prototype.__proto__ === undefined // true
```

这种情况与第二种情况非常像。A也是一个普通函数，所以直接继承`Funciton.prototype`。但是，A调用后返回的对象不继承任何方法，所以它的`__proto__`指向`Function.prototype`，即实质上执行了下面的代码。

```
class A extends null {
  constructor() { return Object.create(null); }
}
```

#### Object.getPrototypeOf()
Object.getPrototypeOf方法可以用来从子类上获取父类。

```
Object.getPrototypeOf(SubType) === SuperType // true
```
因此，可以使用这个方法判断，一个类是否继承了另一个类。

#### super关键字
上面讲过，在子类中，super关键字代表父类实例。

```
class SubType extends SuperType {
  get m() {
    return this._p * super._p;
  }
  set m() {
    throw new Error('该属性只读');
  }
}
```
上面代码中，子类通过super关键字，调用父类的实例。

由于，对象总是继承其他对象的，所以可以在任意一个对象中，使用super关键字。

```
var obj = {
  toString() {
    return "MyObject: " + super.toString();
  }
}

obj.toString(); // MyObject: [object Object]
```

#### 实例的`__proto__`属性
子类实例的`__proto__`属性的`__proto__`属性，指向父类实例的`__proto__`属性。也就是说，子类的原型的原型，是父类的原型。

```
let s1 = new SuperType("Howie");
let s2 = new SubType("Howie", 26);

s2.__proto__ === s1.__proto // false
s2.__proto__.__proto__ === s1.__proto__ // true
```

因此，通过子类实例的`__proto__.__proto__`属性，可以修改父类实例的行为。

### 原生构造函数的继承
原生构造函数是指语言内置的构造函数，通常用来生成数据结构，比如`Array()`。以前，这些原生构造函数是无法继承的，即不能自己定义一个Array的子类。

```
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

```
var colors = new MyArray();
colors[0] = "red";
colors.length  // 0

colors.length = 0;
colors[0]  // "red"
```

之所以会发生这种情况，是因为原生构造函数无法外部获取，通过`Array.apply()`或者分配给原型对象都不行。ES5是先新建子类的实例对象this，再将父类的属性添加到子类上，由于父类的属性无法获取，导致无法继承原生的构造函数。

ES6允许继承原生构造函数定义子类，因为ES6是先新建父类的实例对象this，然后再用子类的构造函数修饰this，使得父类的所有行为都可以继承。下面是一个继承Array的例子。

```
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

上面代码定义了一个MyArray类，继承了Array构造函数，因此就可以从MyArray生成数组的实例。这意味着，ES6可以自定义原生数据结构（比如Array、String等）的子类，这是ES5无法做到的。

上面这个例子也说明，extends关键字不仅可以用来继承类，还可以用来继承原生的构造函数。因此可以在原生数据结构的基础上，定义自己的数据结构。下面就是定义了一个带版本功能的数组。

```
class VersionedArray extends Array {
  constructor() {
    super();
    this.history = [[]];
  }
  commit() {
    this.history.push(this.slice());
  }
  revert() {
    this.splice(0, this.length, this.history[this.history.length - 1]);
  }
}
```

上面代码中，VersionedArray结构会通过commit方法，将自己的上一个版本存入history属性，然后通过revert方法，可以撤销当前版本，回到上一个版本。除此之外，VersionedArray依然是一个数组，所有原生的数组方法都可以在它上面调用。

下面是一个自定义Error子类的例子。

```
class ExtendableError extends Error {
  constructor(message) {
    super();
    this.message = message;
    this.stack = (new Error()).stack;
    this.name = this.constructor.name;
  }
}

class MyError extends ExtendableError {
  constructor(m) {
    super(m);
  }
}

var myerror = new MyError('ll');
myerror.message // "ll"
myerror instanceof Error // true
myerror.name // "MyError"
myerror.stack
// Error
//     at MyError.ExtendableError
//     ...
```

# 函数表达式
之前已经讲过函数声明和函数表达式区别了。

Firefox、Safari、Chrome 和 Opera 都给函数定义了一个非标准的 name 属性（ES6已经正式加入name属性）,通过这个属性可以访问到给函数指定的名字。这个属性的值永远等于跟在 function 关键字后面的标识符。

关于函数声明,它的一个重要特征就是函数声明提升(function declaration hoisting) ,意思是在执行代码之前会先读取函数声明。这就意味着可以把函数声明放在调用它的语句后面。

```
sayHi();
function sayHi(){
  alert("Hi!");
}
```

函数表达式创建的函数叫做匿名函数(anonymous function),因为 function 关键字后面没有标识符。(匿名函数有时候也叫拉姆达函数)匿名函数的 name 属性是空字符串。

理解函数提升的关键,就是理解函数声明与函数表达式之间的区别。例如,执行以下代码的结果可能会让人意想不到。
```
//不要这样做!
if(condition){
  function sayHi(){
    alert("Hi!");
  }
} else {
  function sayHi(){
    alert("Yo!");
  }
}
```

实际上,这在 ECMAScript 中属于无效语法,JavaScript 引擎会尝试修正错误,将其转换为合理的状态。但问题是浏览器尝试修正错误的做法并不一致。大多数浏览器会返回第二个声明,忽略condition ;Firefox 会在 condition 为 true 时返回第一个声明。因此这种使用方式很危险,不应该出现在你的代码中。不过,如果是使用函数表达式,那就没有什么问题了。

```
//可以这样做
var sayHi;
if(condition){
  sayHi = function(){
    alert("Hi!");
  };
} else {
  sayHi = function(){
    alert("Yo!");
  };
}
```

## 递归

之前说过可以递归时可以使用arguments.callee，但在严格模式下,不能通过脚本访问 arguments.callee ,访问这个属性会导致错误。不过,可以使用命名函数表达式来达成相同的结果。
```
var factorial = (function f(num){
  if (num <= 1){
    return 1;
  } else {
    return num * f(num-1);
  }
});
```
以上代码创建了一个名为 f() 的命名函数表达式,然后将它赋值给变量 factorial 。即便把函数赋值给了另一个变量,函数的名字 f 仍然有效,所以递归调用照样能正确完成。这种方式在严格模式和非严格模式下都行得通

## 闭包
闭包是指有权访问另一个函数作用域中的变量的函数。创建闭包的常见方式,就是在一个函数内部创建另一个函数

```
function createComparisonFunction(propertyName) {
    return function(object1, object2){
        var value1 = object1[propertyName];
        var value2 = object2[propertyName];
        if (value1 < value2){
            return -1;
        } else if (value1 > value2){
            return 1;
        } else {
            return 0;
        }
    };
}
```

即使这个内部函数被返回了,而且是在其他地方被调用了,但它仍然可以访问外部函数的变量 propertyName。之所以还能够访问这个变量,是因为内部函数的作用域链中包含createComparisonFunction() 的作用域。

前面讲的有关如何创建作用域链以及作用域链有什么作用的细节,对彻底理解闭包至关重要。当某个函数被调用时,会创建一个执行环境(execution context)及相应的作用域链。然后,使用 arguments 和其他命名参数的值来初始化函数的活动对象(activation object)。但在作用域链中,外部函数的活动对象始终处于第二位,外部函数的外部函数的活动对象处于第三位,......直至作为作用域链终点的全局执行环境。

```
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

后台的每个执行环境都有一个表示变量的对象——变量对象。全局环境的变量对象始终存在,而像compare() 函数这样的局部环境的变量对象,则只在函数执行的过程中存在。在创建 compare() 函数时,会创建一个预先包含全局变量对象的作用域链,这个作用域链被保存在内部的 [[Scope]] 属性中。当调用 compare() 函数时,会为函数创建一个执行环境,然后通过复制函数的 [[Scope]] 属性中的对象构建起执行环境的作用域链。此后,又有一个活动对象(在此作为变量对象使用)被创建并被推入执行环境作用域链的前端。对于这个例子中 compare() 函数的执行环境而言,其作用域链中包含两个变量对象:本地活动对象和全局变量对象。显然,作用域链本质上是一个指向变量对象的指针列表,它只引用但不实际包含变量对象。

无论什么时候在函数中访问一个变量时,就会从作用域链中搜索具有相应名字的变量。一般来讲,当函数执行完毕后,局部活动对象就会被销毁,内存中仅保存全局作用域(全局执行环境的变量对象)。但是,闭包的情况又有所不同。

在另一个函数内部定义的函数会将外部函数的活动对象添加到它的作用域链中。因此,在 createComparisonFunction() 函数内部定义的匿名函数的作用域链中,实际上将会包含外部函数 createComparisonFunction() 的活动对象。

```
//创建函数
var compareNames = createComparisonFunction("name");
//调用函数
var result = compareNames({ name: "Nicholas" }, { name: "Greg" });
//解除对匿名函数的引用(以便释放内存)
compareNames = null;
```
createComparisonFunction("name") 返回后其活动对象并没有被销毁，因为匿名函数（即被返回的比较函数）的作用域链中有对其的引用。通过将 compareNames 设置为等于 null解除该函数的引用,就等于通知垃圾回收例程将其清除。随着匿名函数的作用域链被销毁,其他作用域(除了全局作用域)也都可以安全地销毁了。

```
+----------------------+
|  anonymous function  |
|  execution context   |
+----------------------+ +------------+
|(scope chain) |      -|>| scope chain|
+----------------------+ +------------+
                         |2     |    -|-->全局变量对象
                         +------------+
                         |1     |    -|-->createComparisonFunction()的活动对象
                         +------------+
                         |0     |    -|-->闭包的活动对象
                         +------------+
```
过度使用闭包可能会导致内存占用过多，只在绝对必要时使用闭包。

### 闭包与变量

作用域链的这种配置机制引出了一个值得注意的副作用,即闭包只能取得包含函数中任何变量的最后一个值。别忘了闭包所保存的是整个变量对象,而不是某个特殊的变量。

```
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

```
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
我们没有直接把闭包赋值给数组,而是定义了一个匿名函数,并将立即执行该匿名函数的结果赋给数组。这里的匿名函数有一个参数 num ,也就是最终的函数要返回的值。每个函数都有自己num变量的一个副本。

ECMASctipt6中你可以直接使用let声明i，这样i仅在for循环中有效，可以得到同样预期的结果。
```
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

### 关于 this 对象
在闭包中使用 this 对象也可能会导致一些问题。我们知道, this 对象是在运行时基于函数的执行环境绑定的:在全局函数中, this 等于 window ,而当函数被作为某个对象的方法调用时, this 等于那个对象。不过,匿名函数的执行环境具有全局性,因此其 this 对象通常指向 window。当然,在通过 call() 或 apply() 改变函数执行环境的情况下, this 就会指向其他对象。

```
var key = "The Window";
var object = {
    key : "My Object",
    getKeyFunc : function(){
        return function(){
            return this.key;
        };
    }
};
alert(object.getKeyFunc()()); //"The Window"(在非严格模式下)
```
为什么匿名函数没有取得其包含作用域(或外部作用域)的 this 对象呢? 前面曾经提到过,每个函数在被调用时都会自动取得两个特殊变量: this 和 arguments 。内部函数在搜索这两个变量时,只会搜索到其活动对象为止,因此永远不可能直接访问外部函数中的这两个变量。不过,可以把外部作用域中的 this 对象保存在一个闭包能够访问到的变量里。
```
var key = "The Window";
var object = {
    key : "My Object",
    getKeyFunc : function(){
        var that = this;
        return function(){
            return that.key;
        };
    }
};
alert(object.getKeyFunc()()); //"The Window"(在非严格模式下)
```
arguments 也存在同样的问题。如果想访问作用域中的 arguments 对象,必须将对该对象的引用保存到另一个闭包能够访问的变量中。

```
var name = "The Window";
var object = {
    name : "My Object",
    getName: function(){
        return this.name;
    }
};
object.getName(); //"My Object"
(object.getName)(); //"My Object"
(object.getName = object.getName)(); //"The Window",在非严格模式下
```

### 内存泄露
由于 IE9 之前的版本对 JScript 对象和 COM 对象使用引用计数器来回收垃圾。而闭包中存在对外部函数的活动对象的引用，有可能导致对象不能被正常回收。

```
function assignHandler(){
    var element = document.getElementById("someElement");
    element.onclick = function(){
        alert(element.id);
    };
}
```
由于匿名函数保存了一个对 assignHandler() 的活动对象的引用,因此就会导致无法减少 element 的引用数。只要匿名函数存在, element 的引用数至少也是 1,因此它所占用的内存就永远不会被回收。不过,这个问题可以通过稍微改写一下代码来解决
```
function assignHandler(){
    var element = document.getElementById("someElement");
    var id = element.id;//通过把 element.id 的一个副本保存在一个变量中,并且在闭包中引用该变量消除了循环引用
    element.onclick = function(){
        alert(id);
    };
    element = null;//解除对 DOM 对象的引用,顺利地减少其引用数,确保正常回收其占用的内存
}
```

## 模仿块级作用域
如前所述,JavaScript 没有块级作用域的概念。

用作块级作用域(通常称为私有作用域)的匿名函数的语法如下所示。
```
(function(){
//这里是块级作用域
})();
```
以上代码定义并立即调用了一个匿名函数。将函数声明包含在一对圆括号中,表示它实际上是一个函数表达式。而紧随其后的另一对圆括号会立即调用这个函数。

```
function(){
//这里是块级作用域
}(); //出错!
```
这段代码会导致语法错误,是因为 JavaScript 将 function 关键字当作一个函数声明的开始,而函数声明后面不能跟圆括号。然而,函数表达式的后面可以跟圆括号。要将函数声明转换成函数表达式,只要给它加上一对圆括号即可。在下面的情况下可以不加圆括号。
```
var v = function(i){return i;}(1);
```
这种技术经常在全局作用域中被用在函数外部,从而限制向全局作用域中添加过多的变量和函数。一般来说,我们都应该尽量少向全局作用域中添加变量和函数。在一个由很多开发人员共同参与的大型应用程序中,过多的全局变量和函数很容易导致命名冲突。而通过创建私有作用域,每个开发人员既可以使用自己的变量,又不必担心搞乱全局作用域。

这种做法可以减少闭包占用的内存问题,因为没有指向匿名函数的引用。只要函数执行完毕,就可以立即销毁其作用域链了。

ECMASctipt6中支持块级作用域，所以ES6中可以不再使用上面的执行匿名函数（IIFE）。

## 私有变量
严格来讲,JavaScript 中没有私有成员的概念;所有对象属性都是公有的。不过,倒是有一个私有变量的概念。任何在函数中定义的变量,都可以认为是私有变量,因为不能在函数的外部访问这些变量。私有变量包括函数的参数、局部变量和在函数内部定义的其他函数。

我们把有权访问私有变量和私有函数的公有方法称为特权方法(privileged method)。有两种在对象上创建特权方法的方式。第一种是在构造函数中定义特权方法
```
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
创建 MyObject 的实例后,除了使用 publicMethod() 这一个途径外,没有任何办法可以直接访问 privateVariable 和 privateFunction() 。

在构造函数中定义特权方法也有一个缺点,那就是你必须使用构造函数模式来达到这个目的。

### 静态私有变量
通过在私有作用域中定义私有变量或函数,同样也可以创建特权方法

```
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
前面的模式是用于为自定义类型创建私有变量和特权方法的。而道格拉斯所说的模块模式(module pattern)则是为单例创建私有变量和特权方法。所谓单例(singleton),指的就是只有一个实例的对象。按照惯例,JavaScript 是以对象字面量的方式来创建单例对象的。
```
var singleton = {
    name : value,
    method : function () {
    //这里是方法的代码
    }
};
```
模块模式通过为单例添加私有变量和特权方法能够使其得到增强
```
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
```
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

# 异步操作
异步编程对JavaScript语言很重要。JavaScript只有一个线程，如果没有异步编程，根本没法用，非卡死不可。

ES6诞生以前，异步编程的方法，大概有下面四种。

* 回调函数
* 事件监听
* 发布/订阅
* Promise 对象

ES6将JavaScript异步编程带入了一个全新的阶段。

## 异步基本概念
所谓"异步"，简单说就好比把一个任务分成两段，先执行第一段，然后转而执行其他任务，等做好了准备，再回过头执行第二段。

比如，有一个任务是读取文件进行处理，任务的第一段是向操作系统发出请求，要求读取文件。然后，程序执行其他任务，等到操作系统返回文件，再接着执行任务的第二段（处理文件）。这种不连续的执行，就叫做异步。

相应地，连续的执行就叫做同步。由于是连续执行，不能插入其他任务，所以操作系统从硬盘读取文件的这段时间，程序只能干等着。

## 回调函数
JavaScript语言对异步编程的实现，就是回调函数。所谓回调函数，就是把任务的第二段单独写在一个函数里面，等到重新执行这个任务的时候，就直接调用这个函数。它的英语名字callback，直译过来就是"重新调用"。

读取文件进行处理，是这样写的。

```
fs.readFile('/etc/passwd', function (err, data) {
  if (err) throw err;
  console.log(data);
});
```
上面代码中，readFile函数的第二个参数，就是回调函数，也就是任务的第二段。等到操作系统返回了`/etc/passwd`这个文件以后，回调函数才会执行。

一个有趣的问题是，为什么Node.js约定，回调函数的第一个参数，必须是错误对象err（如果没有错误，该参数就是null）？原因是执行分成两段，在这两段之间抛出的错误，程序无法捕捉，只能当作参数，传入第二段。

## Promise
回调函数本身并没有问题，它的问题出现在多个回调函数嵌套。假定读取A文件之后，再读取B文件，代码如下。

```
fs.readFile(fileA, function (err, data) {
  fs.readFile(fileB, function (err, data) {
    // ...
  });
});
```
不难想象，如果依次读取多个文件，就会出现多重嵌套。代码不是纵向发展，而是横向发展，很快就会乱成一团，无法管理。这种情况就称为“回调函数噩梦”（callback hell）。

Promise就是为了解决这个问题而提出的。它不是新的语法功能，而是一种新的写法，允许将回调函数的横向加载，改成纵向加载。采用Promise，连续读取多个文件，写法如下。

```
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
上面代码中，使用了fs-readfile-promise模块，它的作用就是返回一个Promise版本的readFile函数。Promise提供then方法加载回调函数，catch方法捕捉执行过程中抛出的错误。

可以看到，Promise 的写法只是回调函数的改进，使用then方法以后，异步任务的两段执行看得更清楚了，除此以外，并无新意。

Promise 的最大问题是代码冗余，原来的任务被Promise 包装了一下，不管什么操作，一眼看去都是一堆 then，原来的语义变得很不清楚。

## Generator函数
### 协程
传统的编程语言，早有异步编程的解决方案（其实是多任务的解决方案）。其中有一种叫做"协程"（coroutine），意思是多个线程互相协作，完成异步任务。

协程的运行流程大致如下。

* 协程A开始执行。
* 协程A执行到一半，进入暂停，执行权转移到协程B。
* （一段时间后）协程B交还执行权。
* 协程A恢复执行。

上面流程的协程A，就是异步任务，因为它分成两段（或多段）执行。

举例来说，读取文件的协程写法如下。

```
function asnycJob() {
  // ...其他代码
  var f = yield readFile(fileA);
  // ...其他代码
}
```
上面代码的函数asyncJob是一个协程，它的奥妙就在其中的yield命令。它表示执行到此处，执行权将交给其他协程。也就是说，yield命令是异步两个阶段的分界线。

协程遇到 yield 命令就暂停，等到执行权返回，再从暂停的地方继续往后执行。它的最大优点，就是代码的写法非常像同步操作，如果去除yield命令，简直一模一样。

### Generator函数的概念
Generator函数是协程在ES6的实现，最大特点就是可以交出函数的执行权（即暂停执行）。

整个Generator函数就是一个封装的异步任务，或者说是异步任务的容器。异步操作需要暂停的地方，都用yield语句注明。Generator函数的执行方法如下。

```
function* gen(x){
  var y = yield x + 2;
  return y;
}

var g = gen(1);
g.next() // { value: 3, done: false }
g.next() // { value: undefined, done: true }
```
Generator函数和普通函数最大不同就是会返回一个Iterator对象，调用该对象的next方法，会分阶段执行Generator函数，这种阶段由yield关键字划分。上例第一个next就是执行到第一个yield出现的位置。next 方法返回IteratorResult对象，含有value和done两个属性。前者是yield语句后面的值，后者表示Generator函数是否执行完毕。

### Generator函数的数据交换和错误处理
Generator函数可以暂停执行和恢复执行，这是它能封装异步任务的根本原因。除此之外，它还有两个特性，使它可以作为异步编程的完整解决方案：函数体内外的数据交换和错误处理机制。

next方法返回值的value属性，是Generator函数向外输出数据；next方法还可以接受参数，这是向Generator函数体内输入数据。

```
function* gen(x){
  var y = yield x + 2;
  return y;
}

var g = gen(1);
g.next() // { value: 3, done: false }
g.next(2) // { value: 2, done: true }
```

上面代码中，第一个next方法的value属性，返回表达式`x + 2`的值（3）。第二个next方法带有参数2，这个参数可以传入 Generator 函数，作为上个阶段异步任务的返回结果，被函数体内的变量y接收。因此，这一步的 value 属性，返回的就是2（变量y的值）。

Generator 函数内部还可以部署错误处理代码，捕获函数体外抛出的错误。

```
function* gen(x){
  try {
    var y = yield x + 2;
  } catch (e){
    console.log(e);
  }
  return y;
}

var g = gen(1);
g.next();
g.throw（'出错了'）;
// 出错了
```

上面代码的最后一行，Generator函数体外，使用指针对象的throw方法抛出的错误，可以被函数体内的try ...catch代码块捕获。这意味着，出错的代码与处理错误的代码，实现了时间和空间上的分离，这对于异步编程无疑是很重要的。

### 异步任务的封装
下面看看如何使用 Generator 函数，执行一个真实的异步任务。

```
var fetch = require('node-fetch');

function* gen(){
  var url = 'https://api.github.com/users/github';
  var result = yield fetch(url);
  console.log(result.bio);
}
```
上面代码中，Generator函数封装了一个异步操作，该操作先读取一个远程接口，然后从JSON格式的数据解析信息。就像前面说过的，这段代码非常像同步操作，除了加上了yield命令。

执行这段代码的方法如下。

```
var g = gen();
var result = g.next();

result.value.then(function(data){
  return data.json();
}).then(function(data){
  g.next(data);
});
```

上面代码中，首先执行Generator函数，获取Iterator对象，然后使用next 方法（第二行），执行异步任务的第一阶段。由于Fetch模块返回的是一个Promise对象，因此要用then方法调用下一个next 方法。

可以看到，虽然 Generator 函数将异步操作表示得很简洁，但是流程管理却不方便（即何时执行第一阶段、何时执行第二阶段）。

### Thunk函数
#### 参数的求值策略
Thunk函数早在上个世纪60年代就诞生了。

那时，编程语言刚刚起步，计算机学家还在研究，编译器怎么写比较好。一个争论的焦点是"求值策略"，即函数的参数到底应该何时求值。

```
var x = 1;

function f(m){
  return m * 2;
}

f(x + 5)
```

上面代码先定义函数f，然后向它传入表达式`x + 5`。这个表达式应该何时求值？

一种意见是"传值调用"（call by value），即在进入函数体之前，就计算`x + 5`的值（等于6），再将这个值传入函数f 。C语言就采用这种策略。

另一种意见是"传名调用"（call by name），即直接将表达式`x + 5`传入函数体，只在用到它的时候求值。Hskell语言采用这种策略。

传值调用和传名调用，哪一种比较好？回答是各有利弊。传值调用比较简单，但是对参数求值的时候，实际上还没用到这个参数，有可能造成性能损失。

#### Thunk函数的含义
编译器的"传名调用"实现，往往是将参数放到一个临时函数之中，再将这个临时函数传入函数体。这个临时函数就叫做Thunk函数。

```
function f(m){
  return m * 2;
}

f(x + 5);

// 等同于
var thunk = function () {
  return x + 5;
};

function f(thunk){
  return thunk() * 2;
}
```

上面代码中，函数f的参数`x + 5`被一个函数替换了。凡是用到原参数的地方，对`Thunk`函数求值即可。

这就是Thunk函数的定义，它是"传名调用"的一种实现策略，用来替换某个表达式。

#### JavaScript语言的Thunk函数
JavaScript语言是传值调用，它的Thunk函数含义有所不同。在JavaScript语言中，Thunk函数替换的不是表达式，而是多参数函数，将其替换成单参数的版本，且只接受回调函数作为参数。

```
// 正常版本的readFile（多参数版本）
fs.readFile(fileName, callback);

// Thunk版本的readFile（单参数版本）
var readFileThunk = Thunk(fileName);
readFileThunk(callback);

var Thunk = function (fileName){
  return function (callback){
    return fs.readFile(fileName, callback);
  };
};
```

上面代码中，fs模块的readFile方法是一个多参数函数，两个参数分别为文件名和回调函数。经过转换器处理，它变成了一个单参数函数，只接受回调函数作为参数。这个单参数版本，就叫做Thunk函数。

任何函数，只要参数有回调函数，就能写成Thunk函数的形式。下面是一个简单的Thunk函数转换器。

```
var Thunk = function(fn){
  return function (){
    var args = Array.prototype.slice.call(arguments);
    return function (callback){
      args.push(callback);
      return fn.apply(this, args);
    }
  };
};
```

使用上面的转换器，生成`fs.readFile`的Thunk函数。

```
var readFileThunk = Thunk(fs.readFile);
readFileThunk(fileA)(callback);
```

#### Thunkify模块
生产环境的转换器，建议使用Thunkify模块。

安装。
```
$ npm install thunkify
```

使用方式。
```
var thunkify = require('thunkify');
var fs = require('fs');

var read = thunkify(fs.readFile);
read('package.json')(function(err, str){
  // ...
});
```

Thunkify的源码与前面那个简单的转换器非常像。主要多了一个检查机制，变量called确保回调函数只运行一次。这样的设计与下文的Generator函数相关。请看下面的例子。

```
function f(a, b, callback){
  var sum = a + b;
  callback(sum);
  callback(sum);
}

var ft = thunkify(f);
ft(1, 2)(console.log); // 3
```
由于thunkify只允许回调函数执行一次，所以只输出一行结果。

#### Generator 函数的流程管理
你可能会问， Thunk函数有什么用？回答是以前确实没什么用，但是ES6有了Generator函数，Thunk函数现在可以用于Generator函数的自动流程管理。

以读取文件为例。下面的Generator函数封装了两个异步操作。

```
var fs = require('fs');
var thunkify = require('thunkify');
var readFile = thunkify(fs.readFile);

var gen = function* (){
  var r1 = yield readFile('/etc/fstab');
  console.log(r1.toString());
  var r2 = yield readFile('/etc/shells');
  console.log(r2.toString());
};
```

上面代码中，yield命令用于将程序的执行权移出Generator函数，那么就需要一种方法，将执行权再交还给Generator函数。

这种方法就是Thunk函数，因为它可以在回调函数里，将执行权交还给Generator函数。为了便于理解，我们先看如何手动执行上面这个Generator函数。

```
var g = gen();

var r1 = g.next();
r1.value(function(err, data){
  if (err) throw err;
  var r2 = g.next(data);
  r2.value(function(err, data){
    if (err) throw err;
    g.next(data);
  });
});
```

仔细查看上面的代码，可以发现Generator函数的执行过程，其实是将同一个回调函数，反复传入next方法的value属性。这使得我们可以用递归来自动完成这个过程。

#### Thunk函数的自动流程管理
Thunk函数真正的威力，在于可以自动执行Generator函数。下面就是一个基于Thunk函数的Generator执行器。

```
function run(fn) {
  var gen = fn();

  function next(err, data) {
    var result = gen.next(data);
    if (result.done) return;
    result.value(next);
  }

  next();
}

run(gen);
```
上面代码的run函数，就是一个Generator函数的自动执行器。内部的next函数就是Thunk的回调函数。next函数先将指针移到Generator函数的下一步（gen.next方法），然后判断Generator函数是否结束（result.done 属性），如果没结束，就将next函数再传入Thunk函数（result.value属性），否则就直接退出。前面的gen函数可以有更多读取文件操作，只要执行run函数，这些操作就会自动完成。

有了这个执行器，执行Generator函数方便多了。不管有多少个异步操作，直接传入run函数即可。当然，前提是每一个异步操作，都要是Thunk函数，也就是说，跟在yield命令后面的必须是Thunk函数。

Thunk函数并不是Generator函数自动执行的唯一方案。因为自动执行的关键是，必须有一种机制，自动控制Generator函数的流程，接收和交还程序的执行权。回调函数可以做到这一点，Promise 对象也可以做到这一点。

### co模块
#### 基本用法
[co模块](https://github.com/tj/co)是著名程序员TJ Holowaychuk于2013年6月发布的一个小工具，用于Generator函数的自动执行。

co模块可以让你不用编写Generator函数的执行器。

```
var co = require('co');
co(gen);
```
上面代码中，gen函数是前面定义的，Generator函数只要传入co函数，就会自动执行。

co函数返回一个Promise对象，因此可以用then方法添加回调函数。

```
co(gen).then(function (){
  console.log('Generator 函数执行完成');
})
```

上面代码中，等到Generator函数执行结束，就会输出一行提示。

#### co模块的原理
为什么co可以自动执行Generator函数？

前面说过，Generator就是一个异步操作的容器。它的自动执行需要一种机制，当异步操作有了结果，能够自动交回执行权。

两种方法可以做到这一点。

1. 回调函数。将异步操作包装成Thunk函数，在回调函数里面交回执行权。
2. Promise 对象。将异步操作包装成Promise对象，用then方法交回执行权。

co模块其实就是将两种自动执行器（Thunk函数和Promise对象），包装成一个模块。使用co的前提条件是，Generator函数的yield命令后面，只能是Thunk函数或Promise对象。

已经介绍了基于Thunk函数的自动执行器。下面来看，基于Promise对象的自动执行器。这是理解co模块必须的。

#### 基于Promise对象的自动执行
还是沿用上面的例子。首先，把fs模块的readFile方法包装成一个Promise对象。

```
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

```
var g = gen();

g.next().value.then(function(data){
  g.next(data).value.then(function(data){
    g.next(data);
  });
})
```

手动执行其实就是用then方法，层层添加回调函数。理解了这一点，就可以写出一个自动执行器。

```
function run(gen){
  var g = gen();

  function next(data){
    var result = g.next(data);
    if (result.done) return result.value;
    result.value.then(function(data){
      next(data);
    });
  }

  next();
}

run(gen);
```

上面代码中，只要Generator函数还没执行到最后一步，next函数就调用自身，以此实现自动执行。

co就是上面那个自动执行器的扩展，它的源码只有几十行，非常简单。增加了一些类型检查的操作。

#### 处理并发的异步操作
co支持并发的异步操作，即允许某些操作同时进行，等到它们全部完成，才进行下一步。

这时，要把并发的操作都放在数组或对象里面，跟在yield语句后面。

```
// 数组的写法
co(function* () {
  var res = yield [
    Promise.resolve(1),
    Promise.resolve(2)
  ];
  console.log(res);
}).catch(onerror);

// 对象的写法
co(function* () {
  var res = yield {
    1: Promise.resolve(1),
    2: Promise.resolve(2),
  };
  console.log(res);
}).catch(onerror);
```

下面是另一个例子。

```
co(function* () {
  var values = [n1, n2, n3];
  yield values.map(somethingAsync);
});

function* somethingAsync(x) {
  // do something async
  return y
}
```

上面的代码允许并发三个somethingAsync异步操作，等到它们全部完成，才会进行下一步。

## async函数
### 含义
async 函数是什么？一句话，async函数就是Generator函数的语法糖。

前文有一个Generator函数，依次读取两个文件。

```
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

写成 async 函数，就是下面这样。

```
var asyncReadFile = async function (){
  var f1 = await readFile('/etc/fstab');
  var f2 = await readFile('/etc/shells');
  console.log(f1.toString());
  console.log(f2.toString());
};
```

一比较就会发现，async函数就是将Generator函数的星号（*）替换成async，将yield替换成await，仅此而已。

async 函数对 Generator 函数的改进，体现在以下三点。

1. 内置执行器。Generator函数的执行必须靠执行器，所以才有了co模块，而async 函数自带执行器。也就是说，async函数的执行，与普通函数一模一样，只要一行。 `var result = asyncReadFile();`
2. 更好的语义。async和await，比起星号和yield，语义更清楚了。async表示函数里有异步操作，await 表示紧跟在后面的表达式需要等待结果。
3. 更广的适用性。 co模块约定，yield命令后面只能是Thunk函数或Promise对象，而async函数的await命令后面，可以跟Promise对象和原始类型的值（数值、字符串和布尔值，但这时等同于同步操作）。

### async函数的实现
async 函数的实现，就是将 Generator 函数和自动执行器，包装在一个函数里。

```
async function fn(args){
  // ...
}

// 等同于
function fn(args){
  return spawn(function*() {
    // ...
  });
}
```

所有的 async 函数都可以写成上面的第二种形式，其中的 spawn 函数就是自动执行器。

下面给出 spawn 函数的实现，基本就是前文自动执行器的翻版。

```
function spawn(genF) {
  return new Promise(function(resolve, reject) {
    var gen = genF();
    function step(nextF) {
      try {
        var next = nextF();
      } catch(e) {
        return reject(e);
      }
      if(next.done) {
        return resolve(next.value);
      }
      Promise.resolve(next.value).then(function(v) {
        step(function() { return gen.next(v); });
      }, function(e) {
        step(function() { return gen.throw(e); });
      });
    }
    step(function() { return gen.next(undefined); });
  });
}
```

async 函数是非常新的语法功能，新到都不属于 ES6，而是属于 ES7。目前，它仍处于提案阶段，但是转码器 Babel 和 regenerator 都已经支持，转码后就能使用。

### async 函数的用法
同Generator函数一样，async函数返回一个Promise对象，可以使用then方法添加回调函数。当函数执行的时候，一旦遇到 await 就会先返回，等到触发的异步操作完成，再接着执行函数体内后面的语句。

下面是一个例子。

```
async function getStockPriceByName(name) {
  var symbol = await getStockSymbol(name);
  var stockPrice = await getStockPrice(symbol);
  return stockPrice;
}

getStockPriceByName('goog').then(function (result){
  console.log(result);
});
```

上面代码是一个获取股票报价的函数，函数前面的async关键字，表明该函数内部有异步操作。调用该函数时，会立即返回一个Promise对象。

下面的例子，指定多少毫秒后输出一个值。

```
function timeout(ms) {
  return new Promise((resolve, reject) => {
    setTimeout(resolve, ms);
  });
}

async function asyncPrint(value, ms) {
  await timeout(ms);
  console.log(value)
}

asyncPrint('hello world', 50);
```

### 注意点
await命令后面的Promise对象，运行结果可能是rejected，所以最好把await命令放在try...catch代码块中。

```
async function myFunction() {
  try {
    await somethingThatReturnsAPromise();
  } catch (err) {
    console.log(err);
  }
}

// 另一种写法
async function myFunction() {
  await somethingThatReturnsAPromise().catch(function (err){
    console.log(err);
  };
}
```

await命令只能用在async函数之中，如果用在普通函数，就会报错。

```
async function dbFuc(db) {
  let docs = [{}, {}, {}];

  // 报错
  docs.forEach(function (doc) {
    await db.post(doc);
  });
}
```

```
async function dbFuc(db) {
  let docs = [{}, {}, {}];

  // 可能得到错误结果
  docs.forEach(async function (doc) {
    await db.post(doc);
  });
}
```

上面代码可能不会正常工作，原因是这时三个`db.post`操作将是并发执行，也就是同时执行，而不是继发执行。正确的写法是采用for循环。

```
async function dbFuc(db) {
  let docs = [{}, {}, {}];

  for (let doc of docs) {
    await db.post(doc);
  }
}
```

如果确实希望多个请求并发执行，可以使用 Promise.all 方法。

```
async function dbFuc(db) {
  let docs = [{}, {}, {}];
  let promises = docs.map((doc) => db.post(doc));

  let results = await Promise.all(promises);
  console.log(results);
}

// 或者使用下面的写法

async function dbFuc(db) {
  let docs = [{}, {}, {}];
  let promises = docs.map((doc) => db.post(doc));

  let results = [];
  for (let promise of promises) {
    results.push(await promise);
  }
  console.log(results);
}
```

ES6将await增加为保留字。使用这个词作为标识符，在ES5是合法的，在ES6将抛出SyntaxError。

### 与Promise、Generator的比较
我们通过一个例子，来看Async函数与Promise、Generator函数的区别。

假定某个DOM元素上面，部署了一系列的动画，前一个动画结束，才能开始后一个。如果当中有一个动画出错，就不再往下执行，返回上一个成功执行的动画的返回值。

首先是Promise的写法。

```
function chainAnimationsPromise(elem, animations) {

  // 变量ret用来保存上一个动画的返回值
  var ret = null;

  // 新建一个空的Promise
  var p = Promise.resolve();

  // 使用then方法，添加所有动画
  for(var anim in animations) {
    p = p.then(function(val) {
      ret = val;
      return anim(elem);
    })
  }

  // 返回一个部署了错误捕捉机制的Promise
  return p.catch(function(e) {
    /* 忽略错误，继续执行 */
  }).then(function() {
    return ret;
  });

}
```

虽然Promise的写法比回调函数的写法大大改进，但是一眼看上去，代码完全都是Promise的API（then、catch等等），操作本身的语义反而不容易看出来。

接着是Generator函数的写法。

```
function chainAnimationsGenerator(elem, animations) {

  return spawn(function*() {
    var ret = null;
    try {
      for(var anim of animations) {
        ret = yield anim(elem);
      }
    } catch(e) {
      /* 忽略错误，继续执行 */
    }
      return ret;
  });

}
```

上面代码使用Generator函数遍历了每个动画，语义比Promise写法更清晰，用户定义的操作全部都出现在spawn函数的内部。这个写法的问题在于，必须有一个任务运行器，自动执行Generator函数，上面代码的spawn函数就是自动执行器，它返回一个Promise对象，而且必须保证yield语句后面的表达式，必须返回一个Promise。

最后是Async函数的写法。

```
async function chainAnimationsAsync(elem, animations) {
  var ret = null;
  try {
    for(var anim of animations) {
      ret = await anim(elem);
    }
  } catch(e) {
    /* 忽略错误，继续执行 */
  }
  return ret;
}
```

可以看到Async函数的实现最简洁，最符合语义，几乎没有语义不相关的代码。它将Generator写法中的自动执行器，改在语言层面提供，不暴露给用户，因此代码量最少。如果使用Generator写法，自动执行器需要用户自己提供。
