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

还可以自定义一个标题栏，如下面代码所示，然后在创建MainFrame对象之后调用`TitlePane.editTitleBar(frame, "标题");`即可。
```java
import java.awt.Image;
import javax.swing.Icon;
import javax.swing.ImageIcon;
import javax.swing.JComponent;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JRootPane;
import org.pushingpixels.substance.api.SubstanceLookAndFeel;
import org.pushingpixels.substance.internal.ui.SubstanceRootPaneUI;
import org.pushingpixels.substance.internal.utils.SubstanceTitlePane;

public class TitlePane extends SubstanceTitlePane {

    private static final long serialVersionUID = 1L;

    public TitlePane(JRootPane root, SubstanceRootPaneUI ui) {
        super(root, ui);
    }

    public static void editTitleBar(JFrame frame, String titleText ) {
        JComponent title = SubstanceLookAndFeel.getTitlePaneComponent(frame);
        JLabel titleLabel = new JLabel("<html><font style=\"font-size:12px;\">"+titleText+"</font></html>");
        //磅值大小是基于排字磅值 的，大约为 1/72 英寸
        //以常见1024像素对比: 1024像素=3.413英寸=8.67厘米         (300像素/英寸dpi     每像素≈0.003333英寸)
        //所以1024像素的厘米尺寸就是:1024*0.003333*2.54
        //1024像素=14.222英寸=36.12厘米         (72像素/英寸dpi     每像素≈0.013889英寸)
        int size = (int)(titleLabel.getFont().getSize2D() / 72 * 300);
        titleLabel.setBounds(32, 0, size * titleText.length(),23);
        titleLabel.putClientProperty(
                "substancelaf.internal.titlePane.extraComponentKind",
                ExtraComponentKind.TRAILING);
        title.add(titleLabel, 0);
    }

    public static void editTitleBar(JFrame frame, Icon icon) {
        JComponent title = SubstanceLookAndFeel.getTitlePaneComponent(frame);
        ((ImageIcon)icon).getImage().getScaledInstance(24,24,Image.SCALE_DEFAULT);
        JLabel titleLabel = new JLabel(icon);
        titleLabel.setBounds(32, 0, 24,24);
        titleLabel.putClientProperty(
                "substancelaf.internal.titlePane.extraComponentKind",
                ExtraComponentKind.TRAILING);
        title.add(titleLabel, -1);
    }

    public static void editTitleBar(JFrame frame, JComponent component) {
        JComponent title = SubstanceLookAndFeel.getTitlePaneComponent(frame);
        component.putClientProperty(
                "substancelaf.internal.titlePane.extraComponentKind",
                ExtraComponentKind.TRAILING);
        title.add(component, 0);
    }
}
```
