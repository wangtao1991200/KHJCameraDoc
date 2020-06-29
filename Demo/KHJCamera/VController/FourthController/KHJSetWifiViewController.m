//
//  CreTwoCodeViewController.m
//
//
//
//
//

#import <SystemConfiguration/CaptiveNetwork.h>
#import "KHJSetWifiViewController.h"
#import "KHJCreateQRCodeViewController.h"
#import "KHJAddHotVController.h"


@interface KHJSetWifiViewController ()
{
    NSString *SSIDStr;
    BOOL isSheild;
}

- (IBAction)clickbtn2:(UIButton *)sender;

@end

@implementation KHJSetWifiViewController

@synthesize vIndex;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = bgVCcolor;
    
    [self setbackBtn];
    [self setView];
    [self fetchSSIDInfo];
    [self addNoti];
}

- (void)addNoti
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(EnterForeground) name: UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)EnterForeground
{
    _isAP = NO;
    [self fetchSSIDInfo];
}

- (id)fetchSSIDInfo
{
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    CLog(@"ifs = %@",ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, info);
        NSString *SSIDString =[(NSDictionary *)info objectForKey:@"SSID"];
        [self saveSSID:SSIDString];
        if (info && [info count]) {
            break;
        }
    }
    return info;
}

- (void)saveSSID:(NSString *)ssid
{
    CLog(@"ssid == %@", ssid);
    SSIDStr = ssid;
    if (!_isAP) {
        if (ssid &&![ssid isEqualToString:@""]) {
            [self.wifiBtn setTitle:SSIDStr forState:UIControlStateNormal];
            NSString *wifiPwd = [[NSUserDefaults standardUserDefaults] objectForKey:SSIDStr];
            self.wifiPwd.text = wifiPwd;
        }
        else {
            [self showAlertTip];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 提示框

- (void)showAlertTip
{
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"kWifiTips", nil) message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *defult = [UIAlertAction actionWithTitle:KHJLocalizedString(@"commit", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertview addAction:cancel];
    [alertview addAction:defult];
    [self presentViewController:alertview animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.wifiPwd resignFirstResponder];
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

- (void)setView
{
    self.view1.layer.cornerRadius  = 4.f;
    self.view1.layer.borderWidth = 0.5;
    self.view1.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.view1.layer.masksToBounds = YES;
    self.view2.layer.cornerRadius  = 4.f;
    self.view2.layer.borderWidth = 0.5;
    self.view2.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.view2.layer.masksToBounds = YES;
    
    [self.wifiPwd setBorderStyle:UITextBorderStyleNone];
    self.wifiPwd.secureTextEntry = YES;
}

- (void)popMainViewCtrl
{
    NSInteger index = [[self.navigationController viewControllers] indexOfObject:self];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index - 3] animated:YES];
}

- (IBAction)sheild1:(UIButton *)sender
{
    if (!isSheild) {
        self.wifiPwd.secureTextEntry = NO;
        [sender setBackgroundImage:[UIImage imageNamed:@"pwd_eye_blue"] forState:UIControlStateNormal];
    }
    else {
        self.wifiPwd.secureTextEntry = YES;
        [sender setBackgroundImage:[UIImage imageNamed:@"pwd_eye_gray"] forState:UIControlStateNormal];
    }
    isSheild = !isSheild;
    [self.wifiPwd becomeFirstResponder];
}

- (IBAction)createTwoCode:(UIButton *)sender
{
    if (![self.wifiPwd.text isEqualToString:@""] && ![self.wifiBtn.titleLabel.text isEqualToString:@""]) {
        [[NSUserDefaults standardUserDefaults] setObject:self.wifiPwd.text forKey:self.wifiBtn.titleLabel.text];
    }
    if (vIndex == 0) {
        KHJCreateQRCodeViewController *twoCtrl = [[KHJCreateQRCodeViewController alloc] init];
        twoCtrl.ssidString = self.wifiBtn.titleLabel.text;
        twoCtrl.ssidPwd = self.wifiPwd.text;
        [self.navigationController pushViewController:twoCtrl animated:YES];    
    }
    else {
        KHJAddHotVController *hotVC = [[KHJAddHotVController alloc] init];
        if (!self.wifiBtn.titleLabel.text ||[self.wifiBtn.titleLabel.text isEqualToString:@""]) {
            [self showAlertTip];
        }
        else {
            hotVC.ssidName = self.wifiBtn.titleLabel.text;
            hotVC.ppPwd = self.wifiPwd.text;
            hotVC.isAP = NO;
            [self.navigationController pushViewController:hotVC animated:YES];
        }
    }
}

- (IBAction)clickbtn2:(UIButton *)sender
{
    [self showAlertTip];
}

@end
