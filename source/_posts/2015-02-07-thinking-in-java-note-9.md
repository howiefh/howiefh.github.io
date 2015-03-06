title: Java编程思想笔记九
date: 2015-02-07 20:51:16
tags: Thinking in Java
categories: Java
description: thinking in java; java编程思想; 图形化用户界面;
---


Swing中有一个非常令人称道的原则，称为“正交使用”。意思是，一旦你理解了库中的某个通用概念，你就可以把这个概念应用到其他地方。

## Swing 基础

Swing有它自己的专用线程来接收UI事件并更新屏幕，如果从其他线程着手对屏幕进行操作，那么就可能产生冲突和死锁。其他线程通过事件分发线程提交要执行的任务，可以通过将任务提交给SwingUtilities.invokeLater()来实现这种方式，这个方法会通过事件分发线程将任务放置到（最终将得到执行的）待执行事件队列中。程序中的所有代码都遵循这种通过SwingUtilities.invokeLater()来提交操作的方式。这包括启动程序自身，即main也不应该调用Swing方法，就像上面的程序一样，它应该向事件队列提交任务。

Java中设计和实现图形用户界面的工作主要有：
1. 创建组件（Component)：创建组成界面的各种元素，如按钮、文本框等。
2. 指定布局（Layout）：根据具体需要排列组件的位置关系。
3. 响应事件（Event）：定义图形用户界面的事件和各界面元素对不同事件的响应，从而实现图形用户界面与用户的交互功能。

<!-- more -->

### 组件

Swing GUI由顶层容器-中间容器-基本组件构成

* 顶层容器，这些组件在Swing GUI层次体系的顶层，主要包括JFrame，JApplet，JDialog等
* 通用容器，具有普遍应用场合，包括Jpanel，JScrollPane，JSplitPane，JTabbedPane, JToolBar等
* 特殊容器，在GUI中起特殊作用的中间层容器，包括JInternalFrame，JLayeredPane，JRootPane等
* 基本控制组件，这些基本组件主要用于接收用户输入，它们一般能够显示简单的状态，包括JButton，JComboBox，JList，JMemu，JSlider，JTestField等
* 不可编辑的信息显示组件，完全用来显示信息的组件，包括JLabel，JProgressBar等
* 可编辑的信息显示组件，这些组件用来显示可被用户编辑修改的格式化信息，包括JTable，JFileChooser，JTree等

Swing组件中，除了顶层容器组件，所有以J开头的组件都是JComponent类的子类，可以添加工具提示setToolTipText(String)

* 对话框
    * JOptionPane（简单标准的对话框）
    * ProgressMonitor（显示操作进程的对话框）
    * JColorChooser（标准对话框）
    * JFileChooser（标准对话框）
    * JDialog（可制定对话框）

* 按钮类组件
    * 包括JButton，JCheckBox,JRadioButton, JMenuItem, JCheckBoxMenuItem
    * AbstractButton是一个抽象类，它是JButton，JCheckBox,JRadioButton, JMenuItem, JCheckBoxMenuItem类的父类

* 文本组件
    * JTextField
    * JPasswordField
    * JTextArea
    * JEditorPane
    * JTextPane

* 标签JLable
* 列表JList
* 表格JTable
* 树JTree
* 选择框JComboBox
* 文件选择器JFileChooser
* 颜色选择器JColorChooser
* 进程条JProgressBar
* 滑动块Jslider
* 微调器JSpinner

### 布局管理

Java提供了下列布局管理器

1. FlowLayout 流式布局管理器(JPanel的默认布局)

    FlowLayout(int align, int hgap, int vgap)，组件按参数指定的对齐方式摆放，组件之间水平距离由hgap指定，垂直距离由vgap指定，aligh 默认居中，hgap，vgap默认5个像素。使用FlowLayout，所有组件将被压缩到它们的最小尺寸，如果重新调整视窗大小，那么布局管理器将随之重新流动所有组件。
    
2. BorderLayout 边界布局管理器(JFrame,JWindow的默认布局)

    BorderLayout()：组件之间没有水平间隙与垂直间隙；BorderLayout(int hgap, int vgap)：指定组件之间的水平和垂直间隙

    BorderLayout布局管理器将容器分为5个区：East, West, South, North和Center。对于除Center以外的所有位置，加入的组件被沿着一个方向压缩到最小尺寸，同时在另一个方向上拉伸到最大尺寸。不过对于Center，组件将在两个方向上同时拉伸，以覆盖中央区域。
    
3. GridLayout网格布局管理器

    BorderLayout()：组件之间没有水平间隙与垂直间隙；BorderLayout(int hgap, int vgap)：指定组件之间的水平和垂直间隙；GridLayout(int rows, int cols, int hgap, int vgap)，容器划分为指定数目的网格，并制定组件间的水平垂直距离

4. GridBagLayout网格包布局管理器
    
    GridBagLayout所管理的每个组件都与一个GridBagConstraints类的对象相关。这个约束对象指定了组建的显示区域在网格中的位置，以及在其显示区域中应该如何摆放组件

    GridBagConstraints对象的定制是通过设置一个或者多个GridBagConstraints的变量来实现的：

    * gridx,gridy指定组件左上角在网格中的行与列
    * gridwidth, gridheight指定组件显示区域所占的列数与行数
    * fill指定组件填充网格的方式
    * ipadx,ipady指定组件显示区域的内部填充
    * insets指定组件显示区域的外部填充
    * anchor指定组件在显示区域的摆放位置
    * weightx, weighty用来指定在容器大小改变是，增加或减少的孔家如何在组件间进行分配  

5. BoxLayout箱式布局管理器
    
    箱式布局管理器将组件垂直摆放在一列或水平摆放的一行中，具体由BoxLayout.X_AXIS和BoxLayout.Y_AXIS指定

6. GroupLayout分组布局管理器
    
    GroupLayout 是一个 LayoutManager，它将组件按层次分组，以决定它们在 Container 中的位置。GroupLayout 主要供生成器使用，但也可以手工编码。分组由 Group 类的实例来完成。GroupLayout 支持两种组。串行组 (sequential group) 按顺序一个接一个地放置其子元素。并行组 (parallel group) 能够以四种方式对齐其子元素。

    每个组可以包含任意数量的元素，其中元素有 Group、Component 或间隙 (gap)。间隙可被视为一个具有最小大小、首选大小和最大大小的不可见组件。此外，GroupLayout 还支持其值取自 LayoutStyle 的首选间隙。

7. CardLayout卡片布局管理器

    CardLayout()，组件与左右上下界之间没有间隙， CardLayout(int hgap, int vgap)，参数hgap指定组件距离左右边界的间隙，参数vgap指定组件距离上下边界的间隙。

    CardLayout常用的方法：`public void first (Container parent)`，显示第一张卡片，`public void next (Container parent)`，显示下一张卡片(如果当前是最后一张，则显示第一张)，`public void previous (Container parent)`，显示前一张卡片，`public void last (Container parent)`，显示最后一张卡片，`public void show (Container parent, String name)`，显示指定名称的组件，

8. 无布局管理器

    使用setLayout(null)把容器的布局管理器设置为空。需要使用setLocation(), setSize(),setBounds()或者reshape()等方法手工设置组件大小和位置(这些方法会导致平台相关，不建议使用)

第三方：FormLayout、MigLayout，TableLayout

### 事件

事件处理模型中的3类对象

* 事件
    当用户在界面上执行一个操作，如敲键盘、拖动或者单击鼠标，都产生了事件
* 事件源
    产生事件的组件就是一个事件源。如在一个Button上单击鼠标时，将产生一个ActionEvent类型的事件，这个Button就是事件源
* 事件处理器
    事件处理器是一个方法，该方法接收一个事件对象，对其进行解释，并做出相应的处理

事件及其相应的监听器接口

事件类别          | 描述信息                 | 接口名                  | 方法
---               | ---                      | ---                     | ---
　ActionEvent     | 激活组件                 | 　　ActionListener      | 　actionPerformed(ActionEvent)
　ItemEvent       | 选择了某些项目           | 　　ItemListener        | 　itemStateChanged(ItemEvent)
　MouseEvent      | 鼠标移动                 | 　　MouseMotionListener | 　mouseDragged(MouseEvent) 　mouseMoved(MouseEvent)
  MouseEvent      | 鼠标点击等               | 　　MouseListener       | 　mousePressed(MouseEvent) 　mouseReleased(MouseEvent) 　mouseEntered(MouseEvent) 　mouseExited(MouseEvent) 　mouseClicked(MouseEvent)
　KeyEvent        | 键盘输入                 | 　　KeyListener         | 　keyPressed(KeyEvent) 　keyReleased(KeyEvent) 　keyTyped(KeyEvent)
　FocusEvent      | 组件收到或失去焦点       | 　　FocusListener       | 　focusGained(FocusEvent) 　focusLost(FocusEvent)
　AdjustmentEvent | 移动了滚动条等组件       | 　　AdjustmentListener  | 　adjustmentValueChanged(AdjustmentEvent)
　ComponentEvent  | 对象移动缩放显示隐藏等   | 　　ComponentListener   | 　componentMoved(ComponentEvent) 　componentHidden(ComponentEvent) 　componentResized(ComponentEvent) 　componentShown(ComponentEvent)
　WindowEvent     | 窗口收到窗口级事件       | 　　WindowListener      | 　windowClosing(WindowEvent) 　windowOpened(WindowEvent) 　windowIconified(WindowEvent) 　windowDeiconified(WindowEvent) 　windowClosed(WindowEvent) 　windowActivated(WindowEvent) 　windowDeactivated(WindowEvent)
　ContainerEvent  | 容器中增加删除了组件     | 　　ContainerListener   | 　componentAdded(ContainerEvent) componentRemoved(ContainerEvent)
　TextEvent       | 文本字段或文本区发生改变 | 　　TextListener        | 　textValueChanged(TextEvent)

事件适配器 

1. ComponentAdapter( 组件适配器) 
2. ContainerAdapter( 容器适配器) 
3. FocusAdapter( 焦点适配器) 
4. KeyAdapter( 键盘适配器) 
5. MouseAdapter( 鼠标适配器) 
6. MouseMotionAdapter( 鼠标运动适配器)
7. WindowAdapter( 窗口适配器) 

可以创建一个全局的监听器，不过有时写成内部类会更有用。这不仅是因为将监听器类放在它们所服务的用户接口类或者业务逻辑类的内部时，可以在逻辑上对其进行分组，而且还因为内部类对象含有一个对其外部类对象的引用，这就为跨越类和子类系统边界的调用提供了一种优雅的方式。

Swing支持键盘快捷键，可以用键盘而不是鼠标来选择任何从AbstractButton继承而来的组件：只要使用重载的构造器，使它的第二个参数接受快捷键的标识符即可。如果没有这样的构造器，可以通过setMnemonic()方法`btn.setMnemonic(KeyEvent.VK_B)`。

setActionCommand()的用法。

```
//先设置 
menuitem.setActionCommand("Open");
//在事件处理器中
JMenuItem target = (JMenuItem)e.getSource();
String actionCommand = target.getActionCommand();
if(actionCommand.equals("Open")){}
```

任何能够接受文本的组件都可以接受html文本，且能根据html的规则来重新格式化文本。必须使文本以`<html>`开始，然后就可以使用普通的html标记了，注意，不会强制要求你添加普通的结束标记。

选择外观
try {
    UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
} catch(Exception e) {
    throw new RuntimeException(e);
}
不过你要确保在创建任何可视组件之前先调用这些代码。

### 绘图

1. paint方法

    public void paint(Graphics g)       以画布为参数，在画布上执行画图方法 

2. repaint方法

    Applet重画时系统自动调用paint方法

3. update方法

    public void update(Graphics g)       更新容器，向repaint发出刷新小应用程序的信号，缺省的update方法清除Applet画图区并调用paint方法

**Graphics类**

Graphics类提供画各种图形的方法，其中包括线、圆和椭圆、矩形和多边形、图像以及各种字体的文本等。这些方法具体如下：

public abstract void clipRect(int x, int y, int width, int height)        指定的区域切分
public abstract void drawLine(int x1, int y1, int x2, int y2) 使用当前颜色，在点(x1, y1) 和 (x2, y2) 之间画线
public abstract void drawOval(int x, int y, int width, int height) 画椭圆
public abstract void fillOval(int x, int y, int width, int height) 画实心椭圆
public abstract void drawPolygon(int[] xPoints, int[] yPoints, int nPoints) 画x和y坐标定义的多边形
public void drawRect(int x, int y, int width, int height) 画矩形
public void fillRect(int x, int y, int width, int height) 画实心矩形
public abstract void drawRoundRect(int x, int y, int width, int height, int arcWidth, int arcHeight) 画圆角矩形
public abstract void drawString(String str, int x, int y) 使用当前字体和颜色画字符串str
public abstract void setColor(Color c) 设置图形上下文的当前颜色
public abstract void setPaintMode() 设置画模式
public abstract boolean drawImage (Image img, int x, int y, ImageObserver observer) 画特定图
public abstract void setFont(Font font) 设置特定的font字体。使用时首先得到font对象的一个实例，Font类常用构造函数为：public Font(String name, int style, int size) 

Color类

`public Color(int red, int green, int blue)`
`public Color(int red, int green, int blue, int alpha)`       其中：前三个分量即RGB颜色模式中的参数，第四个alpha分量指透明的程度。当alpha分量为255时，表示完全不透明，正常显示；当alpha分量为0时，表示完全透明，前三个分量不起作用

Graphics2D类

Graphics2D类继承于Graphics类，提供几何学、坐标变换、颜色管理以及文本排列等的更高级控制。Graphics2D类是Java平台上渲染二维图形、文字、以及图片的基础类，提供较好的对绘制形状、填充形状、旋转形状、绘制文本、绘制图像以及定义颜色的支持。在AWT编程接口中，用户通过paint方法接收Graphics对象作为参数，若是使用Graphics2D类，就需要在Paint方法中进行强制转换。

```
public void paint(Graphics old){	Graphics2D new = (Graphics2D)old;}
```

Graphics2D提供以下两个方法进行形状的绘制：
public abstract void draw(Shape s)         根据Graphics2D的环境设置画出形状s。
public abstract void fill(Shape s)         画实心形状s。

Shape的实现类：Line2D（线）、Rectangle2D（矩形）、RoundRectangle2D（圆角矩形）、Ellipse2D（椭圆）、GeneralPath（几何路径）。

## Swing与并发

### 长期运行的任务

在专用线程中执行长时间 GUI 交互任务的抽象类。 

使用 Swing 编写多线程应用程序时，要记住两个约束条件：（有关详细信息，请参阅 How to Use Threads）： 

* 不应该在事件指派线程 上运行耗时任务。否则应用程序将无响应。 
* 只能在事件指派线程 上访问 Swing 组件。 

这些约束意味着需要时间密集计算操作的 GUI 应用程序至少需要以下两个线程：1) 执行长时间任务的线程； 2) 所有 GUI 相关活动的事件指派线程 （EDT）这涉及到难以实现的线程间通信。 

SwingWorker 设计用于需要在后台线程中运行长时间运行任务的情况，并可在完成后或者在处理过程中向 UI 提供更新。SwingWorker 的子类必须实现 doInBackground() 方法，以执行后台计算。 

工作流 

SwingWorker 的生命周期中包含三个线程： 

* 当前线程：在此线程上调用 execute() 方法。它调度 SwingWorker 以在 worker 线程上执行并立即返回。可以使用 get 方法等待 SwingWorker 完成。 
* Worker 线程：在此线程上调用 doInBackground() 方法。所有后台活动都应该在此线程上发生。要通知 PropertyChangeListeners 有关绑定 (bound) 属性的更改，请使用 firePropertyChange 和 getPropertyChangeSupport() 方法。默认情况下，有两个可用的绑定属性：state 和 progress。 
* 事件指派线程：所有与 Swing 有关的活动都在此线程上发生。SwingWorker 调用 process 和 done() 方法，并通知此线程的所有 PropertyChangeListener。 

通常，当前 线程就是事件指派线程。 

在 worker 线程上调用 doInBackground 方法之前，SwingWorker 通知所有 PropertyChangeListener 有关对 StateValue.STARTED 的 state 属性更改。doInBackground 方法完成后，执行 done 方法。然后 SwingWorker 通知所有 PropertyChangeListener 有关对 StateValue.DONE 的 state 属性更改。 

SwingWorker 被设计为只执行一次。多次执行 SwingWorker 将不会调用两次 doInBackground 方法。 

示例用法 

下例说明了最简单的使用范例：在后台完成某些处理，并在处理完成后更新 Swing 组件。 

假定想找到“Meaning of Life”并在 JLabel 中显示结果。 

```
final JLabel label;
class MeaningOfLifeFinder extends SwingWorker<String, Object> {
  @Override
  public String doInBackground() {
    return findTheMeaningOfLife();
  }
  @Override
  protected void done() {
    try { 
      label.setText(get());
    } catch (Exception ignore) {
    }
  }
}
 
(new MeaningOfLifeFinder()).execute();
```

### 可视化线程机制

调用repaint时，并未强制在这一时刻立即进行绘制，而只是设置了一个“脏标识”，表示当下一次事件分发线程准备好重绘时，这个区域是重绘的备选元素之一。

当事件分发线程实际执行paint时，首先调用paintComponent，然后是paintBorder和paintChildren。如果需要在导出组件中覆盖paint，就必须牢记调用基类版本的paint，以使得它仍旧可以执行正确的行为。

## 可视化编程与JavaBean

### 什么是JavaBean

JavaBean 只是一个命名规则

1. 对于一个名称为xxx的属性，通常你要写两个方法；getXxx()和setXxx()。任何浏览这些方法的工具，都会把get或sett后面的第一个字母自动转换为小写，以产生属性名，get方法返回的类型要与set方法里参数的类型相同属性的名称与set和get所依据的类型毫无关系
2. 对于布尔型属性可以使用以上get和set的方式，不过也可以把get替换成is
3. Bean的普通方法不必遵循以上命名规则，不过它们必须是public的。
4. 对于事件，要使用Swing中处理监听器的方式。这与前面所见到的完全相同addBounceListener( BounceListener)和 removeBounceListener (BounceListener)用来处理BounceEvent事件。大多数情况下，内置的事件和监听器就能够满足需求了，不过也可以自己编写事件和监听器接口。

### 使用Introspector抽取BeanInfo

Introspector（内省器），这个类最重要的就是静态的getBeanInfo方法。向这个方法传递一个Class对象引用，它能够完全侦测这个类，然后返回一个BeanInfo对象，可以通过这个对象得到Bean的属性、方法和事件。

```
public class BeanDumper extends JFrame {  
    private JTextField query = new JTextField(20);  
    private JTextArea results = new JTextArea();  
  
    public void print(String s) {  
        results.append(s + " \n");  
    }  
  
    public void dump(Class<?> bean) {  
        results.setText("");  
        BeanInfo bi = null;  
  
        try {  
            bi = Introspector.getBeanInfo(bean, Object.class);  
        } catch (IntrospectionException e) {  
            System.out.println("Couldn 't introspect" + bean.getName());  
            return;  
        }  
        // 获取 bean属性 方法  
        for (PropertyDescriptor d : bi.getPropertyDescriptors()) {  
            Class<?> p = d.getPropertyType();  
            if (p == null)  
                continue;  
            System.out.println("Property type:\n" + p.getName());  
            Method m = d.getReadMethod();  
            if (m != null)  
                System.out.println("read method:+\n" + m.getName());  
            Method rm = d.getWriteMethod();  
            if (rm != null)  
                System.out.println("write method:+\n" + rm.getName());  
            System.out.println("====================================");  
        }  
        System.out.println("public methods:");  
        for (MethodDescriptor ms : bi.getMethodDescriptors()) {  
            System.out.println("ms:" + ms.getMethod().toString());  
        }  
        System.out.println("====================================");  
        System.out.println("envent support:");  
        for (EventSetDescriptor e : bi.getEventSetDescriptors()) {  
            System.out.println("listener type:\n"  
                    + e.getListenerType().getName());  
            for (Method lm : e.getListenerMethods())  
                System.out.println("listener method:\n" + lm.getName());  
  
            for (MethodDescriptor lmd : e.getListenerMethodDescriptors())  
                System.out.println("listener methodDescriptor:\n"  
                        + lmd.getName());  
            //  
            Method addListener = e.getAddListenerMethod();  
            System.out.println("add listener method:\n" + addListener);  
            Method removeListener = e.getRemoveListenerMethod();  
            System.out.println("Remove Listener Method:\n" + removeListener);  
            System.out.println("===========================================");  
        }  
    }  
  
    // ------------------------------------------------  
    class Dumper implements ActionListener {  
  
        @Override  
        public void actionPerformed(ActionEvent e) {  
            String name = query.getText();  
            System.out.println("name=========>"+name);  
            Class<?> c = null;  
            try {  
                c = Class.forName(name);  
            } catch (ClassNotFoundException e1) {  
                results.setText("couldn 't find " + name);  
                e1.printStackTrace();  
                return;  
            }  
            dump(c);  
        }  
    }  
  
    public BeanDumper() {  
        JPanel p = new JPanel();  
        p.setLayout(new FlowLayout());  
        p.add(new JLabel("qualifeied bean name:"));  
        p.add(query);  
        add(BorderLayout.NORTH, p);  
        add(new JScrollPane(results));  
        Dumper dmpr = new Dumper();  
        query.addActionListener(dmpr);  
        query.setText("org.rui.swing.bean.Frog");  
        dmpr.actionPerformed(new ActionEvent(dmpr, 0, ""));  
    }  
  
    public static void main(String[] args) {  
        //工具类  
        SwingConsole.run(new BeanDumper(), 600, 500);  
    }  
}  
```

### JavaBean与同步

1. 尽可能地让Bean中的所有公共方法都是synchronized的。
2. 当一个多路事件触发了一组对该事件感兴趣的监听器时，你必须假定，在你遍历列表进行通知的同时，监听器可能会被添加或移除。
    可以通过忽略synchronized关键字并使用单路事件处理方式，回避并发问题。 

```
// 这是这是一个单播侦听器  
// 最简单形式的侦听器管理  
public void addActionListener(ActionListener l)  
        throws TooManyListenersException {  
    if (actionListener != null) {  
        throw new TooManyListenersException();  
    }  
    actionListener = l;  
}  
```

判断方法是否被同步需要考虑的问题

1. 这个方法会修改对象中“关键”变量的状态吗？要弄清楚变量是否“关键”，必须判断它们是否被程序中的其他线程读写。
2. 这个方法依赖于那些“关键”变量吗？如果有某个同步方法会修改此方法所使用的变量，那么你应该把这个方法也同步。要是觉得问题不大，这种改变只起瞬时作用，你就可以做出不同步的决定，以避免同步方法调用所产生的开销。
3. 第三个线索是查看基类版本的paintComponent是否同步，这只是一个线索。注意，同步不会继承，也就是说，基类方法是同步的，派生类中覆盖后的版本并非自动同步。
4. 方法执行必须尽可能快。要尽可能把处理的开销移到方法外面。

### 对Bean更高级的支持

前面的例子只演示了单一属性，但也可以使用数组来表示多重属性。这称为索引属性。
属性可以被绑定，即它们能通过PropertyChangeEvent事件通知其他对象
属性可以被约束，即如果属性的改变是不可接受的，其他对象可以否决这个改变。

Swing的可替代选择flex，SWT
