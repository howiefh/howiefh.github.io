title: Java编程思想笔记八
date: 2015-02-06 10:17:57
tags: Thinking in Java
categories: Java
description: thinking in java; java编程思想; 并发;
---

并发“具有可论证的正确性，但是实际上具有不可确定性”

## 并发的多样性

并发解决的问题大体上可以分为“速度”和“设计可管理性”两种。

<!-- more -->

### 更快的执行

并发通常是提高运行在单处理器上的程序的性能。如果程序中的一个任务阻塞了，其他任务可以继续执行，如果没有阻塞，那么单处理器上使用并发就没有任何意义，反而还增加了上下文切换的代价。使用并发就好像cpu可以同时位于两处一样，这仅仅是错觉，但是多处理器的话，就不只是错觉了。

提高单处理器系统性能的常见示例是事件驱动的编程。实际上，使用并发最吸引人的一个原因就是要产生具有可响应的用户界面。

实现并发最直接的方式是在操作系统级别使用进程，进程是运行在自己的地址空间内的自包容程序。

操作系统通常会将进程相互隔离，因此它们不会彼此干涉，这使得用进程编程相对容易一些。与此相反的是，向java所使用的这种并发系统会共享注入内存和I/O这样的资源，因此编写多线程程序最基本的困难在于在协调不同线程驱动的任务之间对这些资源的使用，以使得这些资源不会同时被多个任务访问。

某些编程语言被设计为可以将并发任务彼此隔离，通常被称为函数型语言，其中每个函数调用都不会产生任何副作用（并因此而不能干涉其他函数），并因此可以当作独立的任务来驱动。

### 改进代码设计

Java的线程机制是抢占式的，这表示调度机制会周期性的中断线程，将上下文切换到另一个线程，从而为每一个线程都提供时间片，使得每个线程都会分配到数量合理的时间去驱动任务。在协作式系统中，每个任务都会自动地放弃控制，这要求程序员要有意识的在每个任务中插入某种类型的让步语句。协作式系统的优势是双重的：上下文切换的开销通常比抢占式系统要低廉许多，并且对可以同时执行的线程数量在理论上没有任何限制。（注意：某些协作式系统并未设计为可以在多个处理器之前分布任务，这可能会非常受限）。

## 基本的线程机制

### 定义任务

线程可以驱动任务，因此你需要一种描述任务的方式，这可以由实现 Runnable 接口提供。

**对静态方法Thread.yield()的调用是对线程调度器（java线程机制的一部分，可以将CPU从一个线程转移给另一个线程）的一种建议，它在声明：“我已经执行完生命周期中最重要的部分了，此刻正是切换给其他任务执行一段时间的大好时机。”这完全是选择性的**。

### Thread类

Thread构造器只需要一个Runnable对象。调用start方法会迅速返回，run方法由其他线程“同时”执行。

**每个Thread都“注册”了它自己，因此确实有一个对它的引用，而且在它的任务退出其run并死亡之前，垃圾回收器无法清除它**。

### 使用Executor

Executor执行器将为你管理Thread对象，从而简化并发编程。

ExecutorService（具有服务生命周期的Executor，例如关闭）知道如何构建恰当的上下文来执行Runnable对象。

**Executor.newCachedThreadPool()将为每一个任务都创建一个线程，然后在他回收旧线程时停止创建新线程，因此它是合理的Executor首选。只有当这种方式会引发问题时，才需要切换到FixedThreadPool**。

常见的情况是，单个的Executor被用来创建和管理系统中所有的任务。

Executor.shutdown()方法的调用可以防止新任务被提交给Executor.

**Executor.newFixedThreadPool(int num)，可以一次性预先执行代价高昂的线程分配，因而也就可以限制线程的数量了。这可以节省时间，因为不用为每个任务都固定的付出创建线程的开销，在事件驱动的系统中，需要线程的事件处理器，通过直接从池中获取线程，如你所愿尽快的得到服务**。

在任何线程池中，现有线程在可能的情况下，都会被自动复用。

**Executor.newSingleThreadExecutor()就像是线程数量为1的FixedThreadPool，并提供了一种重要的并发保证，其他线程不会（即没有两个线程会）被并发调用，这会改变任务的加锁需求。SingleThreadExecutor会序列化所有提交给他的任务，并维护他自己（隐藏）的悬挂任务队列。每个任务都是按照他们被提交的顺序，并且是在下一个任务开始之前完成的**。

### 从任务中产生返回值

**可以通过实现Callable接口在任务结束时返回一个值。Callable是一个具有类型参数的泛型，其类型参数表示的是从方法call()返回的值，并且必须使用ExecutorService.submit()方法调用它**。

**submit()方法会产生Future对象，它用Callable返回结果的特定类型进行了参数化。可以通过isDone()方法查询Future是否完成。当任务完成时，它具有一个结果，可以调用get()方法获取该结果。也可以不用isDone()进行检查就直接调用get()，此时，get()将阻塞，直至结果准备就绪。还可以调用具有超时的get()**

### 休眠

对 sleep()的调用可能抛出 InterruptedException 异常（这是调用 Thread的 interrupt()方法），并且你可以看到，它在 run()中被捕获。**因为异常不能跨线程传播回 main，所以你必须在本地处理所有在任务内部产生的异常**。

sleep() VS TimeUnit.MILLISECONDS.sleep()。后者可阅读性更强。

### 优先级

Thread.currentThread()获取对驱动该任务的Thread对象的引用。优先级是在run方法的开头设定的。

getPriority来读取线程的优先级，setPriority设置线程的优先级。优先级在run()的开头部分设定。JDK有十个优先级，一般调用优先级的时候只使用Thread.MAX_PRIORITY、Thread.NORM_PRIORITY和Thread.MIN_PRIORITY。

### 让步

run()方法的循环中的一次迭代过程中所需的工作，就可以给线程调度机制一个暗示：我的工作已经差不多了，可以让别的线程使用 CPU 了。这个暗示将通过调用 yield()方法来作出（不过这只是一个提示，没有任何机制保证它将会被采纳）。当调用 yield()时，其实是在建议线程调度器去调度具有相同优先级的其他线程工作。

**大体上，对于任何重要的控制或在调整应用时，都不能依赖 yield()。实际上，yied()经常被误用**。

### 后台线程

后台（daemon）线程，是指程序运行的时候在后台提供一种通用服务的线程，并且这种线程不属于程序中不可或缺的部分。**因此，当所有的非后台线程结束时，程序也就终止了，同时杀死进程中所有后台线程。这样意味着，并不能保证后台线程中的代码可以完全执行**。

必须在线程启动之前调用setDaemon()方法，才能把它设置为后台线程。

Daemon线程派生的子线程，即使没有显式的设置为后台线程，但确实是后台线程。

**应该意识到后台线程在不执行finally子句的情况下就会终止其run()方法**。

### 编码的变体

可以继承Thread类，重写run方法。

在构造器中启动线程可能会变得很有问题，因为另一个任务可能会在构造器结束之前开始任务，这意味着该任务能够访问处于不稳定状态的对象。这是优选Executor而不是显式地创建Thread对象的另一个原因。

### 术语

Thread类自身不执行任何操作，它只是驱动赋予它的任务。

在物理上创建线程可能会代价高昂，因此你必须保存并管理它们。这样，从实现的角度看，将任务从线程中分离出来是很有意义的。另外，java的线程机制基于来自C的低级的p线程方式，这是一种你必须深入研究，并且需要完全理解其所有事物的所有细节的方式。

### 加入一个线程

**如果某线程调用t线程的t.join()，则此线程将被挂起，直到t线程结束才恢复(即t.isAlive()返回为假)**。

**对join方法的调用可以被中断，做法是在调用线程上调用interrupt方法，上面的例子即调用t.interrupt()，调用此方法将给该线程设置一个标志，表明该线程已经被中断。然而，InterruptedException异常被捕获时将清理这个标志。可以用isInterrupted检测线程的中断状态**。

java.util.concurrent类库包含诸如CyclicBarrier这样的工具，它们可能比最初的线程库中join更加合适。

### 捕获异常

由于线程的本质特性，使得你不能捕获从线程中逃逸的异常，一旦异常逃出任务的run()方法，就会向外传播到控制台，除非采用特殊的步骤捕获这种异常。

**为了解决这个问题，需要修改Executor生产线程的方式。Thread.UncaughtExceptionHandler是Java SE5中的新接口，它允许在每个Thread对象上都附着一个异常处理器。Thread.UncaughtExceptionHandler.uncaughtException()会在线程因为捕获的异常而临近死亡时被调用**。

```
Thread t = new Thread(new Runnable(){public void run() {});
t.setUncaughtExceptionHandler(new Thread.UncaughtExceptionHandler(){public void uncaughtException(Thread t, Throwable e) {});
```

如果确定将要在代码中处处使用相同的异常处理器，那么更简单的方式是在Thread类中设置一个静态域，并将这个处理器设置为默认的未捕获异常处理器。

```
Thread.setDefaultUncaughtExceptionHandler(new Thread.UncaughtExceptionHandler(){public void uncaughtException(Thread t, Throwable e) {});
```

这个处理器只有在不存在线程专有的未捕获异常处理器的情况下才会被调用。系统会检查线程专有版本，如果没有发现，则检查线程组是否有其专有的uncaughtException()方法，如果没有，再调用defaultUncaughtExceptionHandler。

## 共享受限资源

### 解决共享资源竞争

基本上所有的并发模式在解决线程冲突问题的时候，都是采用序列化访问共享资源的方案。这意味着在给定时刻只允许一个任务访问共享资源。通常这是通过在代码前面加上一条锁语句来实现的，这种机制就是所谓的互斥量(mutex)。

**临界资源**：共享资源一般是以对象形式存在的内存片段，也可以是文件、输入/输出端口，或者是打印机之类的东西

**临界区**：有时，你只是希望防止多个线程同时访问方法内部的内部代码而不是整个方法，通过这种方式分离出来的代码段被称为临界区(critical section)，它也使用 synchronized 关键字建立。这里，synchronized 被用来指定某个对象，此对象的锁被用来对花括号内的代码进行同步控制。

**所有对象都自动含有单一的锁（也称为监视器）。当在对象上调用其任意synchronized方法的时候，此对象都被加锁，这时该对象上的其他synchronized方法只有等到前一个方法调用完毕并释放了锁之后才能被调用。所以，对于某个特定对象来说，其所有synchronized方法共享同一个锁，可以被用来防止多个任务同时访问被编码为对象内存**。

**注意，在使用并发时，将域设置为 private 是非常重要的，否则，synchronized 关键字就不能防止其他任务直接访问域，这样会产生冲突**。

**一个任务可以多次获得对象的锁。每当这个相同的任务在这个对象上获得锁时，计数都会递增。每当任务离开一个synchronized方法，计数递减，当计数为零的时候，锁被完全释放，此时别的任务就可以使用此资源**。

**针对每个类，也有一个锁（作为类的 Class 对象的一部分），所以 synchronized static 方法可以在类的范围内防止对 static 数据的并发访问**。

**每个访问临界共享资源的方法都必须被同步，否则它们就不会正常地工作**。

**Java SE5的 java.util.concurrent 类库还包含有定义在 java.util.concurrent.locks 中的显式的互斥机制。Lock 对象必须显式的创建、锁定和释放。因此，它与 synchronized 提供的锁机制相比，代码缺少优雅性。但是对于有些场景，使用 Lock 会更加灵活**。

通常只有在解决特殊问题时，才使用显式的Lock对象。例如，用synchronized关键字不能尝试这获取锁且最终获取锁会失败，或者尝试着获取锁一段时间，然后释放它。

显式的 Lock 对象在加锁和释放锁方面，相对于内建的 synchronized 锁来说，还赋予了你更细粒度的控制力。这对于实现专有同步结构是很有用的，例如用于遍历链接列表中的节点的节节传递的加锁机制（也称为锁耦合），这种遍历代码必须在释放当前节点的锁之前捕获下一个节点的锁。如果使用 synchronized 是做不到的。

### 原子性和易变性

原子操作是不能被线程调度机制中断的操作；一旦操作开始，那么它一定可以在可能发生的“上下文切换”之前执行完毕。原子性可以应用于除long和double之外的所有基本类型之上的简单操作。JVM可以将64位（long和double变量）的读取和写入当作两个分离的32位操作来执行，这有时被称为字撕裂。**但，当定义long和double变量时，如果使用volatile关键字，就会获得（简单的赋值与返回操作的）原子性**。

原子操作可由线程机制保证其不可中断，专家级程序员可以利用这一点编写无锁的代码，这些代码不需要被同步。即使如此，它也是一种过于简化的机制。不要尝试！

在多处理器系统上，相对于单处理器系统而言，可视性问题远比原子性问题多得多。一个任务做出的修改，即使在不中断的意义上讲是原子性的，对其他任务也可能是不可视的，（例如，修改只是暂时性地存储在本地处理器的缓存中），因此不同的任务对应用的状态有不同的视图。另一方面，同步机制强制在处理器系统中，一个任务做出的修改必须在应用中是可视的。

**volatile关键字还确保了应用中的可视性。同步也会导致向主存中刷新，因此如果一个域完全由synchronized方法或语句块来防护，那就不必将其设置为是volatile。volatile还可以禁止指令重排序优化**。

**当一个域的值依赖于它之前的值时（例如递增一个计数器），volatile就无法工作了。如果一个域的值受到其他域的值的限制，那么volatile也无法工作**，例如Range类的lower和upper边界就必须遵循lower<=upper的限制。使用volatile而不是synchronized的唯一安全的情况是类中只有一个可变的域。第一选择应该是使用synchronized关键字，这是最安全的方式。

**Java中，对于除了long和double的基本类型的赋值和返回操作都是原子性的。i++ 不具有原子性，这与C++不同**。

总结：除了long和double的基本类型的赋值和返回操作都是原子性的。使用volatile关键字可以使long和double的这两个操作也具有原子性。即使除了long和double的基本类型的赋值和返回操作都是原子性的，但是并不能保证它们是可视的（如果修改只是暂时保存在本地处理器中，不同任务对应用的状态就有不同的视图，这就不是可视的）。即使volatile可以保证可视性，但是并不能保证像i++这样的操作的原子性。因此，大多数情况使用synchronized更安全。

### 原子类

Java SE5引入了 AtomicInteger、AtomicLong、AtomicReference 等原子类(应该强调的是，Atomic 类被设计用来构建 java.util.concurrent 中的类，因此只有在特殊情况下才在自己的代码中使用它们，即便使用了也不能认为万无一失。通常依赖于锁会更安全)。它们提供下面形式的更新操作：

```
boolean compareAndSet(expectedValue, updateValue);
```

### 临界区

防止多个线程同时访问方法内部的部分代码而不是防止访问整个方法，此代码段被称为临界区，也使用synchronized关键字。

```
synchronized(syncObject) {
//This code can be accessd
//by only one task at a time
}
```

这也被称为同步控制块，在进入这段代码前，必须获得 syncObject 对象的锁，如果其他线程已经得到这个锁，那么就得等到锁释放以后，才能进入临界区。

**synchronized块必须给定一个在其上进行同步的对象，并且最合理的方式是，使用其方法正在被调用的当前对象：synchronized(this)，这种方式中，如果获得了synchronized块上的锁，那么该对象的其他synchronized方法和临界区就不能被调用了，因此，如果在this上同步，临界区的效果就会直接缩小在同步的防范内**。

有时，必须在另一个对象上同步，但是如果这么做，必须保证所有相关的任务都是在同一个对象上同步的。

可以看出synchronized方法，相当于synchronized(this)整个方法中的代码段。

### 线程本地存储

防止任务在共享资源上产生冲突的第二种方式是根除对变量的共享。线程本地存储是一种自动化机制，可以为使用相同变量的每个不同的线程创建不同的存储。ThreadLocal对象通常当作静态域存储。在创建ThreadLocal时，你只能通过get()和set()方法来访问该对象的内容。

**synchronized 很简单，就是每个对象访问共享资源时，会检查对象头中的锁状态，然后进行串行访问共享资源；volatile 也很简单，它在使用中保证对变量的访问均在主内存进行，不存在对象副本，所以每个线程要使用的时候，都必须强制从主内存刷新，但是如果操作不具有原子性，也会导致共享资源的污染，所以 volatile 的使用场景要非常小心，在《深入理解 Java 虚拟机》中有详细的分析，这里就不细谈了；然后 ThreadLocal，其实 ThreadLocal 跟共享资源没关系，因为都是线程内部的，所以根本不存在共享这一说法**

这是一种对共享资源安全使用的方法，但是和 synchronized 有区别，它为每个线程都分配一个变量的内存空间，根除了线程对共享变量的竞争。但是因为每个线程，所以这个变量在不同线程之间是“透明的”、“无法感知的”，这就意味着各个线程的这个变量不能有联系，它只和当前的线程相关联。参考 [理解ThreadLocal](http://github.thinkingbar.com/threadlocal/)

## 终结任务

### 在阻塞时终结

**线程的状态**
新建：当线程被创建时，它只会短暂的处于这种状态。此时它分配了必须的系统资源，并执行了初始化。此刻线程已经有资格获取 CPU 时间了。之后就靠调度器来调度
就绪：调度器分配时间片了就可以运行，不分配时间片就等待(不是阻塞！)。
阻塞：线程能够运行，但有某个条件阻止它的运行。当线程处于阻塞状态，调度器将忽略该线程，不会分配时间片，直到线程重新进入就绪状态
死亡：处于死亡状态的线程是不能再被调度的，并且再也不会得到时间片

**进入阻塞状态**
**调用了 sleep()方法使任务进入休眠状态**
**调用了 wait()使线程挂起，直到线程得到了 notify()或者 notifyAll()消息（或者在 Java SE5中的 java.lang.util.concurrent 类库中等价的 signal()或 signalAll()消息），线程才会进入就绪状态**
**任务等待某个输入/输出**
**任务试图在某个对象上调用其他同步控制方法，但是对象锁不可用，因为另一个任务已经获取了这个锁**

有时希望能中终止处于阻塞状态的任务。因为对处于阻塞状态的任务，你不能等待其到达代码中可以检查其状态值的某一点，进而决定让它主动终止，那么唯一的做法就是强制这个任务跳出阻塞状态。

### 中断

当打断被阻塞的任务时，可能需要清理资源。正因为这一点，在任务的run()方法中间打断，更像是抛出的异常，因此在 Java 线程中的这种类型的异常中断中用到了异常（这会滑向对异常的不恰当使用，因为这意味着你需要用异常来控制正常的代码逻辑）。为了在阻塞中终止任务，返回一个良好的状态，就必须仔细考虑 catch 子句以正确的清理所有事物。

**当抛出该异常或者该任务调用Thread.interrupted()时，中断状态将被复位。Thread.interrupted()提供了离开run()循环而不抛出异常的第二种方式**。

**调用 shutdownNow()将发送一个 interrupt()调用给它启动的所有线程**

**如果只想中断特定的任务，就要使用 submit()方法而不是 execute()来启动任务，前面说过 Runnable 的 run 是 void 的，而 Callable 的 run 会返回一个 Future<?>。也就是说通过 submit（）调用会持有任务的上下文。因为这里仅仅是为了调用 cancel()而不会调用 get()，所以可以用来中断任务。做法就是将 true 传递给 cancel()**

**能够中断对 sleep()的调用（或者任何要求抛出 InterruptedException 的调用）**
**不能中断正在试图获取 Synchronized 锁的线程**
**不能中断正在试图执行 I/O 操作的线程**

只要任务以不可中断的方式被阻塞，那么都有潜在的会锁住程序的可能。

对于io阻塞，有一个略显笨拙但是有时确实行之有效的解决方案，即关闭任务在其上发生阻塞的底层资源。nio类提供了更人性化的io中断，被阻塞的nio通道会自动地响应中断。

被互斥所阻塞

Java SE5并发类库中添加了一个特性，即在ReentrantLock上阻塞的任务具备可以被中断的能力。如果使用ReentrantLock而不是synchronized就可以调用interrupt方法打断被互斥所阻塞的调用。

### 检查中断

中断发生的唯一时刻是在任务要进入到阻塞操作中，或者已经在阻塞操作内部时。

可以通过调用interrupted()来检查中断状态，这不仅可以告诉你interrupt()是否被调用过，而且还可以清除中断状态。

**清除中断状态可以确保并发结构不会就某个任务被中断这个问题通知你两次，你可以经由单一的InterruptedException或单一的成功的Thread.interrupted()测试来得到这种通知**。

被设计用来响应 interrput()的类必须建立一种策略，来确保它将保持一致的状态。这通常意味着所有需要清理的对象创建操作的后面，都必须紧跟 try-catch-finally子句，从而使得无论 run()循环如何退出，清理都会发生。

## 线程之间的协作

当你使用线程来同时运行多个任务时，可以通过使用锁（互斥）来同步两个任务的行为，从而使得一个任务不会干涉另一个任务的资源。

现在的问题不是彼此之间的干涉，而是彼此之间的协调，因为在这类问题中，某些部分必须在其他部分被解决之前解决。当任务协作时，关键问题是这些任务之间的握手。为了实现这种握手，我们使用了相同的基础特性：互斥。在这种情况下，互斥能够确保只有一个任务可以响应某个信号，这样就可以根除任何可能的竞争条件。在互斥之上，我们为任务添加了一种途径，可以将其自身挂起，直至某些外部条件发生变化。

### wait()与notifyAll()

**调用sleep()和yield()时，锁并没有被释放。而调用wait()时，线程的执行被挂起，对象上的锁被释放。wait()表示无限期等待下去，直到notify或notifyAll，它也可以传入参数表示时间到期后恢复。当wait恢复时，会首先重新获取进入wait时释放的锁，在这个锁变为可用之前，是不会被唤醒的**。

**只能在同步控制方法或者同步控制块里调用wait(), notify()和notifyAll()（因为不用操作锁，所以sleep()可以在非同步控制方法里调用）**。否则虽然能够编译通过，但运行时将报异常：IllegalMonitorStateException。如果不这样做，就没有锁，就可能导致“错失的信号”。

**错失的信号**

当两个线程协作时，要特别注意可能会错过某个信号，例如下例T1通知T2，但是有可能T2收不到这个信号：

T1:
```
synchronized(shareMonitor) {
     //<setup condition for T2>
     shareMonitor.notify();
}
```

T2:
```
while(someCondition) {
     //Point 1
     synchronized(shareMonitor) {
          shareMonitor.wait();
     }
}
```
以上代码运行到Point1时，如果调度到了T1，则T2收不到通知，就会永远在那里等待。T2正确的做法是：

```
synchronized(shareMonitor) {
     while(someCondition) {
          shareMonitor.wait();
     }
}
```

### notify()与notifyAll()

两者的不同之处在于，前者只唤醒一个线程，而后者唤醒同一锁定的所有线程。当有多个等待线程时，notify唤醒哪一个线程由调度决定。**notifyAll唤醒多个线程后，它们将先为锁而战，先取得锁的线程先执行**。

**什么情况下使用notify或者notifyAll？在多个等待的线程中，如果它们都在等同一个条件，并且当条件变为真时，只有一个线程从中受益，那么用notify比notifyAll更好，因为它避免浪费CPU循环。 notify()只唤醒其中一个。因此当你使用notify时要确保只唤醒正确的那个**。

notifyAll并不是唤醒所有等待线程，而是等待某个特定锁的所有线程。

**使用显式的Lock和Condition对象**

除了wait()、notify()和notifyAll()方法用于同步方法或者同步代码块外，也可以使用Lock、Condition、await()、signal()和signalAll()方法。示例如下：

可以通过在Condition上调用await()来挂起一个任务。当外部条件发生变化，意味着某个任务应该继续执行时，你可以通过调用signal()来通知这个任务，从而唤醒一个任务，或者调用signalAll()来唤醒所有在这个Condition上被其自身挂起的任务（与使用notifyAll()相比，signalAll()是更安全的方式）。

```
class Car {
    private Lock lock = new ReentrantLock();
    private Condition condition = lock.newCondition();
    private boolean waxOn = false;
    public void waxed() {
        lock.lock();
        try {
            waxOn = true;
            condition.signalAll();
        } finally {
            lock.unlock();
        }
    }
    
    public void waitForWaxing() throws InterruptedException {
        lock.lock();
        try {
            while (waxOn == false) 
                condition.await();
        } finally {
            lock.unlock();
        }
    }
    
    //...
}
```

注意，每个lock()的调用都必须紧跟一个try-finally子句，以保证所有情况都可以释放锁。在await()、signal()或signalAll()之前，必须拥有这个锁。

### 生产者-消费者与队列

**使用wait()和notifyAll()这样的方法来解决任务互操作的问题比较复杂。在典型的生产者-消费者实现中，常使用先进先出队列来存储被生产和消费的对象。BlockingQueue接口提供了这样的同步队列，该接口有多种实现，常见的是LinkedBlockingQueue(无界队列)和ArrayBlockingQueue(固定尺寸)**。

如果消费者试图从队列中获取对象，而此时该队列为空，那么消费者将挂起，直到队列中有可消费的内容。阻塞队列可以解决很多问题，比wait()和notifyAll()相比，要简单得多，也更加可靠。示例如下：

```
class LiftOffRunner implements Runnable {
    private BlockingQueue<LiftOff> rockets;
    public LiftOffRunner(BlockingQueue<LiftOff> queue) {
        rockets = queue;
    }
    
    public void add(LiftOff lo) {
        try {
            rockets.put(lo);
        } catch(InterruptedException e) {
            print("Interrupted during put");
        }
    }
    
    public void run() {
        try {
            while(! Thread.interrupted)) {
                LiftOff rocket = rockets.take(); //阻塞直至rockets中有东西
                rocket.run();
            }
        } catch(InterruptedException e) {
            print("Exiting LiftOffRunner");
        }
    }
}
```

其它线程可以往rockets中添加内容，无需同步方法或者锁。

### 任务间使用管道进行输入/输出

通过输入/输出在线程间进行通信也很有用。这种管道在Java IO库中的对应物就是PipedWriter类和PipedReader类。这也是“生产者-消费者”的变体。示例如下：

```
class Sender implements Runnable {
    private PipedWriter out = new PipedWriter();
    public PipedWriter getWriter() { return out;}
    public void run() {
        try {
            while (true) {
                for(char c = 'A'; c <= 'z'; c++) {
                    out.write(c);
                    TimeUnit.MILLISECONDS.sleep(rand.nextInt(500));
                }
            }
        } catch(IOException e) {
            //...
        } catch(InterruptedException e ) {
            //...
        }
    }
}
class Receiver implements Runnable {
    private PipedReader in;
    public Receiver(Sender sender) {
        in = new PipedReader(sender.getWriter());
    }
    
    public void run() {
        try {
            while (true) {
                print("read: " + (char) in.read());
            }
        } catch (IOException e) {
            //...
        }
    }
}
```

与普通I/O不能interrupt不同，PipedReader是可以中断的。
相比之下，BlockingQueue使用起来更加健壮而容易。

## 死锁

某个任务在等待另一个任务，而后者又等待别的任务，这样一直下去，知道这个链条上的任务又在等待第一个任务释放锁。这得到了一个任务之间相互等待的连续循环，没有哪个线程能继续。这被称为死锁。

当以下四个条件同时满足时，就会发生死锁：

* **互斥条件。任务使用的资源中至少有一个是不能共享的**。
* **至少有一个任务必须持有一个资源且正在等待获取一个当前被别的任务持有的资源**。
* **资源不能被任务抢占，任务必须把资源释放当作普通事件**。
* **必须有循环等待。A等待B持有的资源，B又等待C持有的资源，这样一直下去之后，直到X在等待A所持有的资源**。
要防止死锁，只需破坏上述四条中的任意一条。破坏第4条是最容易的。

## 新类库中的构件

java.util.concurrent引入的新类库，有助于编写更简单和健壮的并发程序。

### CountDownLatch

用于同步一个或多个任务，强制它们等待由其他任务执行的一组操作完成。可以向CountDownLatch对象设置一初始值，任务在这个对象上调用await()方法都将阻塞，直到计数值为0。其它任务结束工作时，可以调用countDown()来减少这个计数值。

```
public class LatchDemo {
    private static class Latch implements Runnable {
        private CountDownLatch latch;
        Latch(CountDownLatch latch) {
            this.latch = latch;
        }

        @Override
        public void run() {
            try {
                doSomething();
                System.out.println("Latch runing...");
                TimeUnit.SECONDS.sleep(3);
                System.out.println("Latch sleeped 3 seconds.");
                //2. 当完成后，调用countDown()，将计数减1
                latch.countDown();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }

        private void doSomething() {}
    }
    
    private static class LatchWaiter implements Runnable {
        private CountDownLatch latch;
        LatchWaiter(CountDownLatch latch) {
            this.latch = latch;
        }

        @Override
        public void run() {
            try {
                System.out.println("LatchWaiter waiting...");
                //3. 一直等到latch的计数变为0
                latch.await();
                System.out.println("LatchWaiter exit wait...");
            } catch (InterruptedException e) {
                //todo
            }
        }

        private void doOtherthing() {}
    }

    public static void main(String[] args) {
        //1. 先赋一个值，例如1
        CountDownLatch latch = new CountDownLatch(1);
        ExecutorService exec = Executors.newCachedThreadPool();
        exec.execute(new Latch(latch));
        exec.execute(new LatchWaiter(latch));
        exec.shutdown();
    }
}
```
注意：CountDownLatch只会触发一次，计数值不能重置。

### CyclicBarrier

CyclicBarrier适用于有一组任务，它们并行工作，直到它们全部完成后，才一起向前移动。与CountDownLatch只会触发一次不同，CyclicBarrier可以多次重用。

```
public class CyclicBarrierDemo {
    private static class Horse implements Runnable {
        private CyclicBarrier barrier;
        private String id;
        private int stepCount = 0;
        private static Random rand = new Random(5000);

        Horse(String id, CyclicBarrier barrier) {
            this.id = id;
            this.barrier = barrier;
        }

        @Override
        public void run() {
            doSomething();
            try {
                while (!Thread.interrupted()) {
                    synchronized (this) {
                        System.out.println(String.format("Thread %s is doing.",
                                id));
                        stepCount++;
                        TimeUnit.MILLISECONDS.sleep(rand.nextInt(5000));
                        System.out.println(String.format("Thread %s has done.",
                                id));
                    }
                    // await：待所有线程都在这一步调用await方法。
                    barrier.await();
                }
            } catch (InterruptedException e) {
                // ...
            } catch (BrokenBarrierException e) {
                // ...
            }
        }

        private void doSomething() {
        }

        private int getStepCount() {
            return stepCount;
        }
    }

    public static void main(String[] args) {
        final ExecutorService exec = Executors.newCachedThreadPool();
        int threadCount = 3;
        final Counter cycleCount = new Counter();

        // 注意构造方法的参数
        CyclicBarrier barrier = new CyclicBarrier(threadCount, new Runnable() {
            @Override
            public void run() {
                // 当所有threadCount线程结束时，执行到这里。
                System.out.println("All Thread has done." + cycleCount.count);
                cycleCount.count++;
                if (cycleCount.count == 2) {
                    exec.shutdownNow();
                }
            }
        });
        for (int i = 0; i < threadCount; i++) {
            exec.execute(new Horse(String.valueOf(i), barrier));
        }
    }

    private static class Counter {
        int count = 0;
    }
}
```

### DelayQueue

**DelayQueue是一个无界的BlockingQueue，用于放置实现了Delayed接口的对象，其中的对象只能在其到期时才能从队列中取走。队列是有序的，延迟时间最长的对象最先取出。如果没有任何延迟到期，那么就不会有任何头元素，并且poll()将会返回null（正因为这样，你不能将null放置到这种队列中）。可以使用多种获取方法：poll(取出并从队列删除，不等待), take(取出并从队列删除，如果队列中还没有则等待), peek(取出但不从队列删除，不等待，可能会返回未过期的)**，详细区别见JavaDoc。

**DelayQueue适合的场景包括**：

关闭空闲连接。服务器中，有很多客户端的连接，空闲一段时间之后需要关闭之。
缓存。缓存中的对象，超过了空闲时间，需要从缓存中移出。
任务超时处理。在网络协议滑动窗口请求应答式交互时，处理超时未响应的请求。

### PriorityBlockingQueue

**这是一个很基础的优先级队列，具有可阻塞的读取操作。放入该队列的对象实现Comparable接口就可以轻松实现优先级调度了，优先级越小则优先级越高**。代码示例：

```
PriorityBlockingQueue<Runnable> queue = 
        new PriorityBlockingQueue<Runnable>();
ExecutorService exec = Executors.newCachedThreadPool();
exec.execute(new Producer(queue, exec));
exec.execute(new Consumer(queue));
```

### ScheduledExecutor

通过使用ScheduledExecutor.schedule()（运行一次任务）或者scheduleAtFixedRate()（每隔规则的时间重复执行任务），你可以将Runnable对象设置为在将来的某个时刻执行。代码示例：

```
public class SheduledThreadDemo {
    ScheduledThreadPoolExecutor scheduler = new ScheduledThreadPoolExecutor(10);
    
    public void repeat(Runnable event, long initialDelay, long period) {
        scheduler.scheduleAtFixedRate(event, initialDelay, period, TimeUnit.SECONDS);
    }
    
    public void schedule(Runnable event, long delay) {
        scheduler.schedule(event, delay, TimeUnit.SECONDS);
    }
}
```

通过java.util.Collections实用工具synchronizedList()创建的List的所有方法都是synchronized的。

### Semaphore

普通的锁（concurrent.locks或synchronized锁）在任何时刻都只允许一个任务访问一项资源，而计数信号量允许n个任务同时访问这个资源。作为一个示例，Pool是一个对象池，管理者数量有限的对象，要使用对象可以先签出，用完后再签入。

**Semaphore 可以很轻松完成信号量控制，Semaphore可以控制某个资源可被同时访问的个数，通过 acquire() 获取一个许可，如果没有就等待，而 release() 释放一个许可**。比如在Windows下可以设置共享文件的最大客户端访问个数。

Semaphore实现的功能就类似厕所有5个坑，假如有10个人要上厕所，那么同时只能有多少个人去上厕所呢？同时只能有5个人能够占用，当5个人中 的任何一个人让开后，其中等待的另外5个人中又有一个人可以占用了。另外等待的5个人中可以是随机获得优先机会，也可以是按照先来后到的顺序获得机会，这取决于构造Semaphore对象时传入的参数选项。单个信号量的Semaphore对象可以实现互斥锁的功能，并且可以是由一个线程获得了“锁”，再由另一个线程释放“锁”，这可应用于死锁恢复的一些场合。

```
public class Pool<T> {
    private int size;
    private List<T> items = new ArrayList<T>();
    private volatile boolean[] checkedOut; //跟踪被签出的对象
    private Semaphore available;
    
    public Pool(Class<T> classObject, int size) {
        this.size = size;
        checkedOut = new boolean[size];
        available = new Semaphore(size, true); //size个许可，先进先出:true
        for(int i = 0; i < size; ++i) {
            try {
                //Assums a default constructor
                items.add(classObject.newInstance());
            } catch(Exception e) {
                throw new RuntimeException(e);
            }
        }
    }
    
    public T checkOut() throws InterruptedException {
        available.acquire(); //从Semaphore获取一个许可，如果没有将阻塞
        return getItem();
    }
    
    public void checkIn(T x) {
        if (releaseItem(x))
            //释放一个permit，返回到Semaphore， 可用许可加1
            available.release();
    }
    
    private synchronized T getItem() {
        for(int i=0; i < size; ++i) {
            if (! checkedOut[i]) {
                checkedOut[i] = true;
                return items.get(i);
            }
        }
        
        return null;
    }
    
    private synchronized boolean releaseItem(T item) {
        int index = items.indexOf(item);
        if (index == -1) return false;
        if (checkedOut[index]) {
            checkedOut[index] = false;
            return true;
        }
        
        return false;
    }
}
```

### Exchanger

Exchanger用于实现两个人之间的数据交换，每个人在完成一定的事物后想与对方交换数据，第一个先拿出数据的人将一直等待第二个人拿着数据到来时，才能彼此交换数据。

```
public class ExchangerTest {
    public static void main(String[] args) {
        ExecutorService service = Executors.newCachedThreadPool();
        final Exchanger<String> exchanger = new Exchanger<String>();
        service.execute(new Runnable() {
            public void run() {
                try {
                    String data1 = "money";
                    System.out.println("线程"
                            + Thread.currentThread().getName() 
                            + "正在把数据" + data1 + "换出去");
                    Thread.sleep((long) (Math.random() * 10000));
                    String data2 = (String) exchanger.exchange(data1);
                    System.out.println("线程"
                            + Thread.currentThread().getName() 
                            + "换回数据为" + data2);
                } catch (InterruptedException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
            }
        });
        service.execute(new Runnable() {
            public void run() {
                try {
                    String data1 = "drug";
                    System.out.println("线程"
                            + Thread.currentThread().getName() + "正在把数据"
                            + data1 + "换出去");
                    Thread.sleep((long) (Math.random() * 10000));
                    String data2 = (String) exchanger.exchange(data1);
                    System.out.println("线程"
                            + Thread.currentThread().getName() + "换回数据为"
                            + data2);
                } catch (InterruptedException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
            }
        });
    }
}
```

## 性能调优

### 比较各种互斥技术

从书中的测试中，可以看出性能从好到差：Atomic -> Lock -> BaseLine -> synchronized。但是这个结果跟特定的机器平台还有关系。

安全的做法：以传统的互斥方式入手，只有性能方面的需求能够明确指示时，再替换为Atomic.

### 免锁容器

早期像Vector和Hashtable容器具有许多synchronized方法。用于非多线程的应用程序中时，便会导致不可接受的开销。

Java1.2中，新的容器类库是不同步的，并且Collections类提供了各种static的同步的装饰方法，从而来同步不同类型的容器。

Java SE5添加的新容器，通过更灵活的技术来消除加锁，从而提高性能。

这些免锁容器背后的通用策略是：**对容器的修改可以与读取操作同时发生，只要读取者只能看到完成修改的结果即可。修改是在容器数据结构的某个部分的一个单独的副本（有时是整个数据结构的副本）上执行的，并且这个副本在修改过程中是不可视的。只有当修改完成时，被修改的结构才会自动地与主数据结构进行交换，之后读取者就可以看到这个修改了**。

* 在CopyOnWriteArrayList中，写入将导致创建整个底层数组的副本，而源数组将保留在原地，使得复制的数组在被修改时，读取操作可以安全地执行。当修改完成时，一个原子性的操作将把新的数组换入，使得新的读取操作可以看到这个新的修改。CopyOnWriteArrayList的好处之一是当多个迭代器同时遍历和修改这个列表时，不会抛出ConcurrentModificationException

* 乐观锁：CopyOnWriteArrayList可以替代Collections.synchronizedList(new ArrayList());synchronized ArrayList无论读取者和写入者的数量是多少，都具有大致相同的性能--读取者与其他读取者竞争锁的方式与写入者相同。但是，CopyOnWriteArrayList在没有写入者时，速度会快许多。

* 比较各种Map实现：ConcurrentHashMap 可以替代Collections.synchronizedMap(new HashMap());

### 乐观加锁

Atomic对象将执行像decrementAndGet()这样的原子性操作，但是某些Atomic类还允许你执行所谓的“乐观加锁”。这意味着当你执行某项计算时，实际上没有使用互斥，但是在这项计算完成，并且你准备更新这个Atomic对象时，你需要使用一个称为compareAndSet的方法。你将旧值和新值一起提交给这个方法，如果旧值与它在Atomic对象中发现的值不一致，那么这个操作就失败--这意味着某个其他的任务已经于此操作执行期间修改了这个对象。记住，我们在正常情况下将使用互斥来防止多个任务同时修改一个对象，但是这里我们是“乐观的“，因为我们保持数据为未锁定状态，并希望没有其他任务插入修改它。

### ReadWriteLock

ReadWriteLock对向数据结构相对不频繁地写入，但是有多个任务要经常读取这个数据结构的这类情况进行了优化。ReadWriteLock使得你可以同时有多个读取者，只要它们都不试图写入即可。如果写锁已经被其他任务持有，那么任何读取者都不能访问，直至这个写锁被释放为止。

只有当你在搜索可以提高性能的方法时，才应该想到用它。你的程序的第一个草案应该使用更直观的同步，并且只有在必需时再引入ReadWriteLock

## 活动对象

java的线程机制看起来非常复杂，每个细节都很重要，你有责任处理所有事物，并且没有任何编译器检查形式的安全防护措施。这种机制来自过程型编程世界。可能还存在着另一种不同的并发模型，它更加适合面向对象编程。

有一种可替换的方式称为活动对象或行动者。之所以称这些对象是”活动的“，是因为每个对象都维护着它自己的工作线程和消息队列，并且所有对这种对象的请求都将进入队列排队，任何时刻都只能运行其中的一个。因此，有了活动对象，我们就可以串行化消息而不是方法，这意味着不再需要防备一个任务在其循环的中间被中断这种问题了。

```
public class ActiveObjectDemo {
  private ExecutorService ex =
    Executors.newSingleThreadExecutor();
  private Random rand = new Random(47);
  // Insert a random delay to produce the effect
  // of a calculation time:
  private void pause(int factor) {
    try {
      TimeUnit.MILLISECONDS.sleep(
        100 + rand.nextInt(factor));
    } catch(InterruptedException e) {
      print("sleep() interrupted");
    }
  }
  public Future<Integer>
  calculateInt(final int x, final int y) {
    return ex.submit(new Callable<Integer>() {
      public Integer call() {
        print("starting " + x + " + " + y);
        pause(500);
        return x + y;
      }
    });
  }
  public Future<Float>
  calculateFloat(final float x, final float y) {
    return ex.submit(new Callable<Float>() {
      public Float call() {
        print("starting " + x + " + " + y);
        pause(2000);
        return x + y;
      }
    });
  }
  public void shutdown() { ex.shutdown(); }
  public static void main(String[] args) {
    ActiveObjectDemo d1 = new ActiveObjectDemo();
    // Prevents ConcurrentModificationException:
    List<Future<?>> results =
      new CopyOnWriteArrayList<Future<?>>();
    for(float f = 0.0f; f < 1.0f; f += 0.2f)
      results.add(d1.calculateFloat(f, f));
    for(int i = 0; i < 5; i++)
      results.add(d1.calculateInt(i, i));
    print("All asynch calls made");
    while(results.size() > 0) {
      for(Future<?> f : results)
        if(f.isDone()) {
          try {
            print(f.get());
          } catch(Exception e) {
            throw new RuntimeException(e);
          }
          results.remove(f);
        }
    }
    d1.shutdown();
  }
}
```

由对Executors.newSingleThreadExecutor()的调用产生的单线程执行器维护着它自己的无界阻塞队列，并且只有—个线程从该队列中取走任务并执行它们直至完成，我们需要在calculateInt()和caculateFloat()中做的就是用submit()提交个新的Callable对象，以响应对这些方法的调用，这样就可以把方法调用转变为消息，而submit()的方法体包含在匿名内部类的call()方法中。注意，每个活动对象方法的返回值都是一个具有泛型参数的Future，而这个泛型参数就是该方法中实际的返回类型。通过这种方式，方法调用几乎可以立即返回，调用者可以使用Future来发现何时任务完成，并收集实际的返回值，这样可以处理最复杂的情况，但是如果调用没有任何返回值，那么这个过程将被简化。

注意使用CopyOnWriteArrayList可以移除为了防止ConcurrentModificationException而复制List时的这种需求。

为了能够在不经意间就可以方止线程之间的耦合，任何传递给活动对象方法调用的参数都必须是只读的其他活动对象，即没有连接任何其他任务的对象（这一点很难强制保障，因为没有任何语言支持它。有了活动对象

1. 每个对象都可以拥有自己的工作器线程：些普通的类
2. 每个对象都将维护对它自己的域的全部控制权（这比普通的类要更严苛一些，普通的类只是拥有防护它们的域的选择权）  
3. 所有在活动对象之间的通信都将以在这些对象之间的消息形式发生 
4. 活动对象之间的所有消息都要排队。

这些结果很吸引人，由于从一个活动对象到另一个活动对象的消息只能被排队时的延迟所阻塞，并且因为这个延迟总是非常短且独立于任何其他对象，所以发送消息实际上不是不可阻塞的（最坏情况也只是很短的延迟）。由于一个适动只经由消息来通信，所以两个对象在竞争调用另一个对象上的方法时，是不会被阻塞的，而这意味着不会发生死锁。因为在活动对象中的工作器线程在任何时刻只执行一个消息，所以不存在任何资源竞争，而你也不必操心应该如何同步方法。

活动对象、行动者或代理的信息，C.A.R. Hoare的通信顺序进程理论（Theory of Communicating Sequential Processes, CSP）
