//
//  LANVController.h
//  KHJCamera
//
//  Created by hezewen on 2018/6/23.
//  Copyright © 2018年 khj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LANVController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *uidTextField;

- (IBAction)swipERClick:(UIButton *)sender;
- (IBAction)searchWifi:(UIButton *)sender;
- (IBAction)addDeviceClick:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIView *bgView;

@end



