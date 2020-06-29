//
//  KHJAllBaseManager.h
//  全局管理类，管理所有camera对象
#import <Foundation/Foundation.h>
#import "KHJAllBaseManager.h"
#import "KHJBaseDevice.h"

@interface KHJAllBaseManager : NSObject

+ (KHJAllBaseManager *)sharedBaseManager;
- (int)KHJSingleCheckDeviceOnline:(NSString *)uidStr;
- (KHJBaseDevice *)searchForkey:(NSString *)uidStr;
- (void)addKHJManager:(KHJBaseDevice *)baseDevice andKey:(NSString *)uidStr;
- (void)removeKHJManagerForKey:(NSString *)uidStr;
- (void)removeAllDevice;

@end
