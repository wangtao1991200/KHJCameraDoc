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


@property(nonatomic, assign) BOOL isShare;//是否可以分享
@property(nonatomic, assign) BOOL isFromAlarm;//报警页面push过来的
@property(nonatomic, strong)DeviceInfo *myInfo;



- (void)refreshData:(DeviceInfo *)alarmDevInfo;
- (void)noRefreshData:(DeviceInfo *)alarmDevInfo;

@end
