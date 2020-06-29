//
//  VideoPlayViewController.h
//
//
//
//
//

#import <UIKit/UIKit.h>
#import "DeviceInfo.h"

@interface KHJVideoPlayViewController : UIViewController

// 是否可以分享
// Is it possible to share
@property(nonatomic, assign) BOOL isShare;
// 报警页面push过来的
// Pushed from the alarm page
@property(nonatomic, assign) BOOL isFromAlarm;
@property(nonatomic, strong)DeviceInfo *myInfo;

- (void)refreshData:(DeviceInfo *)alarmDevInfo;
- (void)noRefreshData:(DeviceInfo *)alarmDevInfo;

@end
