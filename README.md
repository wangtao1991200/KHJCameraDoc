

# 看护家iOS SDK   



### 功能概述
看护家SDK 提供给 APP 与 硬件设备 和 看护家云通讯的接口封装，加速应用开发。


### 快速集成

~~~go
在 TARGETS => Build Phases => Link Binary With Librarie
~~~

1、添加 SDK 中的依赖库

![Snip20190904_44](/assets/Snip20190904_44.png)

2、添加系统依赖库

![Snip20190904_44](/assets/Snip20190904_44.png)


3、添加<font color=red>KHJCameraLib.framework</font>，包含5个头文件：

```
KHJCameraLib.h
KHJDeviceManager.h
KHJVideoModel.h
OpenGLView20.h
TimeInfo.h
```
