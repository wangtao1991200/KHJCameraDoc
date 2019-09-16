# 集成SDK	



### 快速集成

~~~
在 TARGETS => Build Phases => Link Binary With Librarie
~~~

1、添加 SDK 中的依赖库

![Snip20190904_44](/localmd/assets/Snip20190904_44.png)

2、添加系统依赖库

![Snip20190904_44](/localmd/assets/Snip20190904_44.png)

3、添加<font color=red>KHJCameraLib.framework</font>，包含5个头文件：

```
KHJCameraLib.h
KHJDeviceManager.h
KHJVideoModel.h
OpenGLView20.h
TimeInfo.h
```