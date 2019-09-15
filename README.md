

# 看护家智能摄像机iOS SDK  接入指南



### 功能概述
看护家SDK 提供给 APP 与 硬件设备 和 看护家云通讯的接口封装，加速应用开发。主要包括了以下功能：

预览摄像机实时采集的影像。
播放摄像机SD卡中录制的影像。
手机端录制摄像机采集的影像。
播放摄像机传来的音频与摄像机设备通话。
下发与接收摄像机指令功能


### 快速集成

~~~go
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

说明文档：https://wangtao1991200.github.io/KHJCameraTest1/index.html

