//
//  KHJAllBaseManager.m
//  KHJCamera
//
//  Created by hezewen on 2018/11/24.
//  Copyright © 2018年 khj. All rights reserved.
//

#import "KHJAllBaseManager.h"

@interface KHJAllBaseManager()

@property(nonatomic, copy) NSMutableDictionary *cameraDic;

@end

@implementation KHJAllBaseManager

+ (KHJAllBaseManager *)sharedBaseManager
{
    static KHJAllBaseManager *instanceManager = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instanceManager = [[super allocWithZone:NULL] init] ;
    }) ;
    return instanceManager ;
}

+ (id) allocWithZone:(struct _NSZone *)zone
{
    return [KHJAllBaseManager sharedBaseManager] ;
}

- (id) copyWithZone:(struct _NSZone *)zone
{
    return [KHJAllBaseManager sharedBaseManager] ;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cameraDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return self;
}

- (int)KHJSingleCheckDeviceOnline:(NSString *)uidStr
{
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:uidStr];
    if (dDevice) {
        return [[[KHJAllBaseManager sharedBaseManager] searchForkey:uidStr].mDeviceManager checkDeviceStatus];
    }
    return -1;
}

- (KHJBaseDevice *)searchForkey:(NSString *)uidStr
{
    KHJBaseDevice *khjManager = [_cameraDic objectForKey:uidStr];
    return khjManager;
}

- (void)addKHJManager:(KHJBaseDevice *)khjManager andKey:(NSString *)uidStr
{
    [_cameraDic setObject:khjManager forKey:uidStr];
}

- (void)removeKHJManagerForKey:(NSString *)uidStr
{
    [_cameraDic removeObjectForKey:uidStr];
}

- (void)removeAllDevice
{
    NSArray *baseArr = [_cameraDic allValues];
    for (int i = 0;i < [baseArr count];i++) {
        KHJBaseDevice *bDevice = [baseArr objectAtIndex:i];
        [bDevice.mDeviceManager destroySelf];
    }
    [_cameraDic removeAllObjects];
}

@end









