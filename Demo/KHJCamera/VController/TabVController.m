//
//  TabVController.m
//  KHJCamera
//
//  Created by hezewen on 2018/6/15.
//  Copyright © 2018年 khj. All rights reserved.
//

#import "DeTabVController.h"

@interface DeTabVController ()

@end

@implementation DeTabVController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSUserDefaults standardUserDefaults] setObject:0 forKey:@"didSelectItem"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    
    NSInteger inNum = [tabBar.items indexOfObject:item];
    CLog(@"item tag = %ld", inNum);

    [[NSUserDefaults standardUserDefaults] setInteger:inNum forKey:@"didSelectItem"];
    
}
- (BOOL)shouldAutorotate
{
    return [self.selectedViewController shouldAutorotate];
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.selectedViewController preferredInterfaceOrientationForPresentation];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.selectedViewController supportedInterfaceOrientations];

}


@end









