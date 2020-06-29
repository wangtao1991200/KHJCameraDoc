//
//  DeCreateQRCodeViewController.m
//
//
//
//
//

#import "KHJCreateQRCodeViewController.h"
#import "CreateTwoCode.h"
#import "KHJCodeTipVController.h"

@interface KHJCreateQRCodeViewController ()
{
    UIImage *erImage;
}
- (IBAction)tipClick:(UIButton *)sender;

@end

@implementation KHJCreateQRCodeViewController
@synthesize ssidString;
@synthesize ssidPwd;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = KHJLocalizedString(@"scanQRcode", nil);
    self.view.backgroundColor = UIColor.lightGrayColor;
    [self createERCode];
    [self setbackBtn];
}

- (void)createERCode
{
    NSString *codeData = [NSString stringWithFormat:@"S=%@,P=%@",self.ssidString,self.ssidPwd];
    
    // 利用 "codeData" 创建一个二维码
    
    // Create a QR code using "codeData"
    
    erImage = [CreateTwoCode createTCode:codeData];
    
    // 显示二维码，提供给设备扫描，设备扫描成功后
    // 由设备自动添加到 "serverAddress" 服务器上
    
    // Display the QR code and provide it to the device for scanning. After the device is scanned successfully
    // Automatically added by the device to the "serverAddress" server
    
    self.erImageview = [self getErImageView];
    
    // 听到设备网络连接成功，表示设备已添加到服务器，从服务器重新获取设备列表即可!
    
    // Hearing that the network connection of the device is successful means that the device has been added to the server, and the device list can be obtained from the server again!

    [self.view addSubview:self.erImageview];
    self.erImageview.image = erImage;
}

- (void)setbackBtn
{
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    but.frame =CGRectMake(0,0, 66, 44);
    but.imageEdgeInsets = UIEdgeInsetsMake(0,-40, 0, 0);
    
    [but setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(popMainViewCtrl) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem  *barBut = [[UIBarButtonItem alloc]initWithCustomView:but];
    self.navigationItem.leftBarButtonItem = barBut;
}

- (void)popMainViewCtrl
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:needReloadList_Noti object:nil];;
}

- (UIImageView *)getErImageView
{
    if (_erImageview == nil) {
        _erImageview = [[UIImageView alloc] initWithFrame:CGRectMake(20,120, SCREENWIDTH-40, SCREENWIDTH-40)];
    }
    return _erImageview;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)listenSuccessBtn:(UIButton *)sender
{
    [self popMainViewCtrl];
}

- (IBAction)tipClick:(UIButton *)sender
{
    KHJCodeTipVController *cTipVC = [[KHJCodeTipVController alloc] init];
    [self.navigationController pushViewController:cTipVC animated:YES];
}
@end













