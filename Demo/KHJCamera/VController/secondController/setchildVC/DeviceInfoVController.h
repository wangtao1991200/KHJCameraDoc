//
//  DeviceInfoVController.h

#import <UIKit/UIKit.h>
#import "DeviceInfo.h"

@class DeviceInfo;

@interface DeviceInfoVController : UIViewController

@property (nonatomic, copy) NSString *uuidStr;
@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, retain) DeviceInfo *myInfo;

@end
