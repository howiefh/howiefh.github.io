title: Android布局管理器
date: 2014-03-04 19:22:01
categories: android
tags: android
---
## 线性布局
线性布局由LinearLayout类来代表，它将容器里面的组件一个挨着一个地排列起来。LinearLayout不仅可以控制各组件横向排列（通过设置android:orientation属性控制），也可以控制各组件纵向排列。

LInearLayout不会换行，当组件一个挨着一个排列到头之后，剩下的组件将不会被显示。

<!-- more -->
LInearLayout常用XML属性及相关方法:
```
| Xml属性               | 相关方法                | 说明                                                                                                          |
|---------------------|---------------------|----------------------------------------------------------------------------------------------------------------------|
| android:gravity     | setGravity(int)     | 设置布局管理器内组件的对齐方式。支持top、bottom、left、right、center_vertical、fill_vertical、center_horizontal、fill_horizontal、center、fill、clip_vertical、clip_horizontal几个属性值。可以同时指定多种对齐方式，如left|center_vertical表示出现在屏幕左边，并且垂直居中。 |
| android:orientation | setOrientation(int) | 设置布局管理器内组件的排列方式，可设置为horizontal（水平排列）、vertical（垂直排列），但只能是其中之一。     |    

```
说明:android:gravity属性中的多个属性值之间用竖线隔开，但竖线前后千万不能出现空格

## 表格布局
表格布局有TableLayout代表，表格布局采用行、列的形式来管理UI组件。

每次向TableLayout中添加一个TableRow，该TableRow就是一个表格行，TableRow也是容器，因此它也可以添加其他组件，没增加一个子组件该表格就增加一列。

如果直接向TableLayout中添加组件，那么这个组件将直接占用一行。
表格布局中，列的宽度由该列中最宽的那个单元格决定，整个表格布局的宽度取决于父容器的宽度（默认总是占满父容器本身）。

TableLayout继承了LinearLayout，因此它完全可以支持LinearLayout所支持的全部XML属性，除此之外,TableLayout的常用XML属性及相关方法
```
| XML属性                   | 相关方法                            | 说  明                       |
|-------------------------|---------------------------------|----------------------------|
| android:collapseColumns | setColumnCollapsed(int,boolean) | 设置需要被隐藏的列的序列号。多个列序号之间用逗号隔开 |
| android:shrinkColumns   | setShrinkAllColumns(boolean)    | 设置允许被收缩的列的序列号。多个列序号之间用逗号隔开 |
| android:stretchColumns  | setStretchAllColumns(boolean)   | 设置允许被拉伸的列的序列号，多个列序号之间用逗号隔开 |
```

## 帧布局
帧布局由Framelayout所代表，FrameLayout直接继承了ViewGroup组件。

帧布局容器为每个加入其中的组件创建一个空白区域（称为一帧），多有每个子组件占据一帧，这些帧都会跟据gravity属性执行自动对齐。

FrameLayout的常用XML属性及相关方法:
```
| XML属性                     | 相关方法                     | 说  明               |
|---------------------------|--------------------------|--------------------|
| android:foreground        | setForeground(Drawable)  | 设置该帧布局容器的前景图像      |
| android:foregroundGravity | setForegroundGravty(int) | 定义绘制前景图像的gravity属性 |
```
 
## 相对布局
相对布局由RelativeLayout代表，相对布局内子组件的位置总是相对兄弟组件、父容器来决定。如果A组件的位置由B组件位置来决定，Android要先定义B组件，再定义A组件。

RelativeLayout的XML属性及相关方法:
```
| XML属性                | 相关方法                  | 说明                   |
|----------------------|-----------------------|----------------------|
| android:gravity      | setGraviy(int)        | 设置该布局容器内各子组件的对齐方式    |
| android:ignoreGravty | setIgnoreGravity(int) | 设置哪个组件不受gravity属性的影响 |
```

RelativeLayout.LayoutParams里只能设为boolean值的属性如下:
```
| 属性                               | 说明                  |
|----------------------------------|---------------------|
| android:layout_centerHorizontal  | 控制该子组件是否位于布局容器的水平居中 |
| android:layout_centerVertical    | 控制该子组件是否位于布局容器的垂直居中 |
| android:layout_centerInParent    | 控制该子组件是否位于布局容器的中央位置 |
| android:layout_alignParentBottom | 控制该子组件是否与布局容器低端对齐   |
| android:layout_alignParentLeft   | 控制该子组件是否与布局容器左边对齐   |
| android:layout_alignParentRIght  | 控制该子组件是否与布局容器右边对齐   |
| android:layout_alignParentTop    | 控制该子组件是否与布局容器顶端对齐   |
```
RelativeLayout.LayoutParams里属性值为其它UI组件ID的XML属性如下:

```
| 属性                         | 说明                   |
|----------------------------|----------------------|
| android:layout_toRightOf   | 控制该子组件位于给出ID组件的右侧    |
| android:layout_toLeftOf    | 控制该子组件位于给出ID组件的左侧    |
| android:layout_above       | 控制该子组件位于给出ID组件的上方    |
| android:layout_below       | 控制该子组件位于给出ID组件的下方    |
| android:layout_alignTop    | 控制该子组件位于给出ID组件的上边界对齐 |
| android:layout_alignBotton | 控制该子组件位于给出ID组件的下边界对齐 |
| android:layout_alignLeft   | 控制该子组件位于给出ID组件的左边界对齐 |
| android:layout_alignRight  | 控制该子组件位于给出ID组件的右边界对齐 |
```

## 网格布局
网格布局时Android4.0版本才有的, 在低版本使用该布局需要导入对应支撑库;

GridLayout将整个容器划分成`rows*columns`个网格, 每个网格可以放置一个组件。还可以设置一个组件横跨多少列, 多少行。不存在一个网格放多个组件情况;

网格布局常用属性
```
| XML属性                        | 相关方法                             | 说明                 |
|------------------------------|----------------------------------|--------------------|
| android:alignmentMode        | setAlignmentMode(int)            | 设置该布局管理器采用的对齐方式    |
| android:columnCount          | setColumnCount(int)              | 设置该网格的列数量          |
| android:columnOrderPreserved | setColumnOrderPreserved(boolean) | 设置该网格容器是否保留列序号     |
| android:rowCount             | setRowCount(int)                 | 设置该网格的行数量          |
| android:rowOrderPreserved    | setRowOrderPreserved(boolean)    | 设置该网格容器是否保留行序号     |
| android:useDefaultMargins    | setUseDefaultMargins(boolen)     | 设置该布局管理器是否使用默认的页边距 |
```

GridLayout的LayoutParams属性
```
| XML属性                     | 相关方法           | 说明                      |
|---------------------------|----------------|-------------------------|
| android:layout_column     |                | 设置该子组件在GridLayout的第几列   |
| android:layout_columnSpan |                | 设置该子组件在GridLayout横向上跨几列 |
| android:layout_gravity    | setGrvity(int) | 设置该子组件采用何种方式占据该网格的空间    |
| android:layout_row        |                | 设置该子组件在GridLayout的第几行   |
| android:layout_rowSpan    |                | 设置该子组件在GridLayout纵向上跨几行 |
```

## 绝对布局
绝对布局由AbsoluteLayout代表。此布局不提供任何布局控制，而是由开发人员自己通过X、Y坐标来控制组件的位置，当使用AbsoluteLayout作为布局容器时，布局容器不在管理子组件的位置、大小--由开发人员自己控制。

使用绝对布局，每个子组件都可以指定如下两个XML属性:

* `layout_x`:指定该子组件的X坐标。
* `layout_y`:指定该子组件的Y坐标。

注意:大部分时候，使用绝对布局都不是一个好思路，因为手机千差万别，屏幕、分辨率可能存在较大差异，使用绝对布局很难兼顾不同屏幕大小、分表率问题。

Android中一般支持如下一些距离单位:

* px（像素）:每个px对应屏幕上的一个点。
* dip或dp（设备独立像素）:一种基于屏幕密度的抽象单位，在每英寸160点的显示器上，1dip=1px，但随着屏幕密度的改变，dip和px的换算也发生改变。
* sp（比例像素）:主要处理字体的大小，可以根据用户的字体大小首选项进行缩放。
* in（英寸）:标准长度单位。
* mm（毫米）:标准长度单位。
* pt（磅）:标准长度单位，1/72英寸。
