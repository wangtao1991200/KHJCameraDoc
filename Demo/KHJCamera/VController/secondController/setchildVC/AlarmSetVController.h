//
//  AlarmSetVController.h

#import <UIKit/UIKit.h>
#import "DeviceInfo.h"

@class DeviceInfo;

@interface AlarmSetVController : UIViewController

@property (nonatomic,copy) NSString *uuidStr;
@property (nonatomic,assign) BOOL isNeedUpdate;
@property (nonatomic,strong) DeviceInfo *myInfo;

@end
