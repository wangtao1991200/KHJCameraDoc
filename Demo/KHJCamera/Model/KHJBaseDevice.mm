//
//  KHJBaseDevice.m
//  包裹 服务端数据类和设备端camera类

#import "KHJBaseDevice.h"

@implementation KHJBaseDevice

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mDeviceManager = [[KHJDeviceManager alloc] init];
    }
    return self;
}

@end
