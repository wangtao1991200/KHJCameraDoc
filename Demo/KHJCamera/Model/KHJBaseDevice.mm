//
//  KHJBaseDevice.m

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
