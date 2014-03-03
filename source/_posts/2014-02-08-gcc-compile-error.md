title: gcc编译问题
date: 2014-02-08 16:31:16
categories: c
tags: [c, gcc]
---
# 问题
(.rodata+0x0): multiple definition of   
在头文件中有如下代码:

```c
#ifndef LIB_HECA_DEF_H_
#define LIB_HECA_DEF_H_
struct dsm_config {
    int auto_unmap;
    int enable_copy_on_access;
};
const struct dsm_config DEFAULT_DSM_CONFIG = { AUTO_UNMAP, NO_ENABLE_COA };
#endif
```
编译的时候出现如下错误：
```
cc -g -Wall -pthread libheca.c dsm_init.c -DDEBUG    master.c   -o master
/tmp/cciBnGer.o:(.rodata+0x0): multiple definition of `DEFAULT_DSM_CONFIG'
/tmp/cckveWVO.o:(.rodata+0x0): first defined here
collect2: ld returned 1 exit status
make: *** [master] Error 1
```

<!-- more -->
# 解决
因为每个c文件中都包含了这个头文件。
```
const struct dsm_config DEFAULT_DSM_CONFIG = { AUTO_UNMAP, NO_ENABLE_COA };
```

所以每个c文件中都定义了变量dsm_config。如果想只保留一个变量dsm_config应该这样：
```
extern const struct dsm_config DEFAULT_DSM_CONFIG;
```
在一个c文件中做如下定义：
```
const struct dsm_config DEFAULT_DSM_CONFIG = { AUTO_UNMAP, NO_ENABLE_COA };
```

还有一个解决办法，但相比较上面的不是最佳的，可以在头文件中这样定义：
```
static const struct dsm_config DEFAULT_DSM_CONFIG = { AUTO_UNMAP, NO_ENABLE_COA };
```
这样在每个c文件中都有一个独立的dsm_config，对其他的是不可见的。
