//
//  KHJUdpHelper.h
//  KHJCamera
//
//  Created by hezewen on 2018/12/24.
//  Copyright © 2018年 khj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KHJUdpHelper : UIView
+ (KHJUdpHelper*)getinstance;
- (void)openUDPServer;
- (void)closeUpdServer;
@end

NS_ASSUME_NONNULL_END
