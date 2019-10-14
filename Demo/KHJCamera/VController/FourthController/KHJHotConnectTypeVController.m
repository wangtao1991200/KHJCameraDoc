//
//  SelectAPVController.m
//
//
//
//
//

#import "KHJHotConnectTypeVController.h"
#import "KHJAddHotVController.h"
#import "KHJSetWifiViewController.h"

@interface KHJHotConnectTypeVController ()

- (IBAction)apConnectClick:(UIButton *)sender;
- (IBAction)hotSetWifiClick:(UIButton *)sender;
@end

@implementation KHJHotConnectTypeVController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = KHJLocalizedString(@"modeSeclect", nil);
    self.view.backgroundColor = bgVCcolor;
    [self setbackBtn];
}

- (void)setbackBtn
{
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    but.frame = CGRectMake(0,0, 66, 44);
    but.imageEdgeInsets = UIEdgeInsetsMake(0,-40, 0, 0);//解决按钮不能靠左问题
    
    [but setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(popMainViewCtrl) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem  *barBut = [[UIBarButtonItem alloc]initWithCustomView:but];
    self.navigationItem.leftBarButtonItem = barBut;
}

- (void)popMainViewCtrl
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)apConnectClick:(UIButton *)sender
{
    /** 设备直连 */
    [self hotPoint];
}

- (IBAction)hotSetWifiClick:(UIButton *)sender
{
    /** 设备热点入网 */
    [self hotPoint_inNet];
}

/**
 热点直连
 手机 + 设备 ：无需网络，本地查看
 */
- (void)hotPoint
{
    KHJAddHotVController *adHotVC = [[KHJAddHotVController alloc] init];
    adHotVC.isAP = YES;
    [[NSUserDefaults standardUserDefaults] setValue:@"888888" forKey:@"APConnectPWD"];
    [self.navigationController pushViewController:adHotVC animated:YES];
}

/**
 设备热点入网
 手机 + 设备 + 路由
 设备热点入网逻辑：
 步骤1、保存可用的wifi账号 + wifi密码
 步骤2、连接设备热点网络后，返回APP
 步骤3、APP将 "wifi账号 + wifi密码" 传给设备
 步骤4、设备自动联网，并在服务器上注册
 */
- (void)hotPoint_inNet
{
    KHJSetWifiViewController *twCodeVC = [[KHJSetWifiViewController alloc] init];
    twCodeVC.vIndex = 1;
    [self.navigationController pushViewController:twCodeVC animated:YES];
}

@end
