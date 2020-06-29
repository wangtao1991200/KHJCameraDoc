//
//  KHJBaseDevice.h

#import <Foundation/Foundation.h>
#import "DeviceInfo.h"
#import <KHJCameraLib/KHJCameraLib.h>

@interface KHJBaseDevice : NSObject

// 设备信息类
// Device information
@property(nonatomic,strong) DeviceInfo          *mDeviceInfo;
// 嵌入式管理类
// Embedded management
@property(nonatomic,strong) KHJDeviceManager    *mDeviceManager;

@end
