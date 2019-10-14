//
//  NAVVController.m
//  KHJCamera
//
//  Created by hezewen on 2018/6/15.
//  Copyright © 2018年 khj. All rights reserved.
//

#import "DeBaseNaviController.h"

@interface DeBaseNaviController ()

@end

@implementation DeBaseNaviController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UINavigationBar *navBar = self.navigationBar;
    UIImage *image = [UIImage imageNamed:@"bgN"];
    [navBar setTranslucent:false];
    [navBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [navBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];
    [self setNavigationBarHidden:NO animated:YES];
}



- (BOOL)shouldAutorotate
{
    return [self.topViewController shouldAutorotate];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];

}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}
@end
