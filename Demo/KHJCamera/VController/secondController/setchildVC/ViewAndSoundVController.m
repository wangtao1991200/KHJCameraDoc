//
//  ViewAndSoundVController.m
//  KHJCamera
//
//  Created by hezewen on 2018/7/6.
//  Copyright © 2018年 khj. All rights reserved.
//

#import "ViewAndSoundVController.h"

@interface ViewAndSoundVController ()

@end

@implementation ViewAndSoundVController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"画面与声音";
    self.view.backgroundColor = bgVCcolor;
    
    [self setbackBtn];
    [self setMainView];
}
- (void)setbackBtn
{
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    but.frame =CGRectMake(0,0, 66, 44);
    but.imageEdgeInsets = UIEdgeInsetsMake(0,-40, 0, 0);//解决按钮不能靠左问题
    [but setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem  *barBut = [[UIBarButtonItem alloc]initWithCustomView:but];
    self.navigationItem.leftBarButtonItem = barBut;

}
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setMainView
{
    UIView *v1 = [[UIView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 44)];
    v1.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:v1];
    UIView *v2 = [[UIView alloc] initWithFrame:CGRectMake(0, v1.frame.size.height+v1.frame.origin.y+1, SCREEN_WIDTH, 80)];
    v2.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:v2];
    UIView *v3 = [[UIView alloc] initWithFrame:CGRectMake(0, v2.frame.size.height+v2.frame.origin.y+1, SCREEN_WIDTH, 80)];
    v3.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:v3];
    
    UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 150, 24)];
    lab1.text = @"画面质量";
    [v1 addSubview:lab1];
    UISwitch   *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-82, 8, 72, 44)];
    switchView.on = NO;//设置初始为ON的一边
    switchView.transform = CGAffineTransformMakeScale( 0.75, 0.75);//缩放
    switchView.layer.anchorPoint=CGPointMake(0,0.5);
    [switchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];   // 开关事件切换通知
    [v1 addSubview: switchView];
    
    UILabel *lab2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 30)];
    lab2.text = @"录像质量";
    [v2 addSubview:lab2];
    
    
    UILabel *lab3 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 30)];
    lab3.text = @"音量";
    [v3 addSubview:lab3];
    
    
    
}
- (void)switchAction:(UISwitch *)sw
{
    if (sw.on == YES) {
        
        sw.on = NO;
    }else{
        sw.on = YES;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end


























