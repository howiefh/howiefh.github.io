title: 使用substance美化java界面并解决乱码问题
date: 2014-02-07 18:08:42
categories: Java
tags: Java
---

使用java做界面，并不怎么美观，可以使用substance包来做美化。但是界面中的中文字符会出现乱码的现象，可以通过设置字体来解决这个问题。首先写使用substance外观的代码，然后在要使窗体显示的代码之前调用一个方法

<!-- more -->

```java
public static void main(String[] args) throws ClassNotFoundException {
	EventQueue.invokeLater(new Runnable() {
		public void run() {
			try {
				UIManager.setLookAndFeel(new SubstanceOfficeBlue2007LookAndFeel());
				//另外如果想让整体界面变得协调，最好设置容器窗体的DefaultLookAndFeelDecorated属性为true。
				JFrame.setDefaultLookAndFeelDecorated(true);
				
				//必须在窗体显示前调用
				InitGlobalFont(new Font("Dialog", Font.PLAIN, 14));  
				 
				MainFrame frame = new MainFrame();
				frame.setVisible(true);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	});
}

/**
 * 统一设置字体，父界面设置之后，所有由父界面进入的子界面都不需要再次设置字体
 */
@SuppressWarnings("unchecked")
public static void InitGlobalFont(Font font) {
	FontUIResource fontRes = new FontUIResource(font);
	for (Enumeration<Object> keys = UIManager.getDefaults().keys(); keys
			.hasMoreElements();) {
		Object key = keys.nextElement();
		Object value = UIManager.get(key);
		if (value instanceof FontUIResource) {
			UIManager.put(key, fontRes);
		}
	}
}  
```
这样，程序界面字体就不会乱码了。
