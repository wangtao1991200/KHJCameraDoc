//
//  SettingViewController.h
//
//
//
//
//

#import <UIKit/UIKit.h>
#import "DeviceInfo.h"

@class DeviceInfo;

@interface KHJSettingViewController : UIViewController

@property (nonatomic,copy)NSString *uuidStr;
@property (nonatomic,copy)NSString *deviceName;
@property (nonatomic,strong)DeviceInfo *myInfo;

@end
