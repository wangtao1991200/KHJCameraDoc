//
//  AddHotVController.m
//
//
//
//
//

#import "KHJAddHotVController.h"
#import <KHJCameraLib/KHJCameraLib.h>

#import "KHJAddSuerVController.h"
#import <SystemConfiguration/CaptiveNetwork.h>

#import "KHJAllBaseManager.h"
#import "DeviceInfo.h"

#define PWIDTH (314)

@interface KHJAddHotVController ()
{
//    UITableView *hTable;
    UIImageView *playImageV;
    NSTimer *pTimer;
    int pCount;
    UIButton *Surebtn;
}
@end

@implementation KHJAddHotVController
@synthesize ssidName;
@synthesize ppPwd;

- (void)viewDidLoad
{
    [super viewDidLoad];
    pCount = 2;
    self.title  = KHJLocalizedString(@"procedure", nil);
    self.view.backgroundColor = bgVCcolor;
    [self setbackBtn];
    [self setLabel];
    [self setTable];
    [self setMainView];
}

- (void)setLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT/2.0, SCREENWIDTH, 30)];
    label.textColor = [UIColor redColor];
    label.text = @"请连接\"camera_xxx\"开头的热点";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
}

- (void)setMainView
{
    playImageV = [self getPlayImgV];
    [self.view addSubview:playImageV];
    //定时播放
    pTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(playView) userInfo:nil repeats:YES];
    
    Surebtn = [[UIButton alloc] initWithFrame:CGRectMake(10, SCREENHEIGHT-64-64, SCREENWIDTH-20, 44)];
    [Surebtn setTitle:KHJLocalizedString(@"ensureConnSucc", nil) forState:UIControlStateNormal];
    [Surebtn setBackgroundImage:[UIImage imageNamed:@"bgN"] forState:UIControlStateNormal];
    [Surebtn addTarget:self action:@selector(clickSure:) forControlEvents:UIControlEventTouchUpInside];
    Surebtn.clipsToBounds = YES;
    Surebtn.layer.cornerRadius = 8;
    [self.view addSubview:Surebtn];
}

- (void)clickSure:(UIButton *)btn
{
    [self fetchSSIDInfo];
}

- (id)fetchSSIDInfo
{
    //mima:12356790
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
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

- (void)saveSSID:(NSString *)str
{
    //获取设备UUID
    if ([str hasPrefix:@"camera_"]) {
        NSArray *tArr = [str componentsSeparatedByString:@"_"];
        NSString *devUid = [tArr lastObject];
        if (self.isAP) {
            KHJBaseDevice *bdevice = [[KHJBaseDevice alloc] init];
            bdevice.mDeviceManager = [[KHJDeviceManager alloc] init];
            
            // KHJ
            [bdevice.mDeviceManager creatKHJCameraBase:devUid];
            // MAEVIA
//            [bdevice.mDeviceManager creatMAEVIACameraBase:devUid];
            DeviceInfo *dInfo = [[DeviceInfo alloc] init];
            dInfo.deviceUid = devUid;
            dInfo.deviceRealPwd = @"888888";
            dInfo.isOpen = YES;
            dInfo.isAPMode = NO;
            bdevice.mDeviceInfo = dInfo;
            [[KHJAllBaseManager sharedBaseManager] addKHJManager:bdevice andKey:devUid];
            WeakSelf
            [bdevice.mDeviceManager reConnect:@"888888" withUid:devUid flag:0 successCallBack:^(NSString *uidString, NSInteger isSuccess) {
                [weakSelf connectDevice:(int)isSuccess withUid:uidString];
            } offLineCallBack:^{
                NSLog(@"offLineCallBackoffLineCallBackoffLineCallBack");
            }];
        }
        else {
            KHJAddSuerVController *adSure = [[KHJAddSuerVController alloc] init];
            adSure.devUid = devUid;
            adSure.ssidName = self.ssidName;
            adSure.ppPwd = self.ppPwd;
            [self.navigationController pushViewController:adSure animated:YES];
        }
    }
    else {
        [[KHJToast share] showToastActionWithToastType:_WarningType
                                          toastPostion:_CenterPostion
                                                   tip:@""
                                               content:KHJLocalizedString(@"noConnCamera", nil)];
    }
    Surebtn.enabled = YES;
}

//连接成功的回调
- (void)connectDevice:(int)success withUid:(NSString *)uidStr
{
    NSLog(@"连接成功?== %d",success);
    if (success == 0) {//连接成功
        CLog(@"连接设备成功");
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJHub shareHub] showText:@"连接成功" addToView:self.view];
        });
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hasDevice" object:uidStr];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ap_Model_Noti object:uidStr];
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }
    else {
        CLog(@"连接设备失败");
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success == -20009) {
                [[KHJToast share] showToastActionWithToastType:_WarningType
                                                  toastPostion:_CenterPostion
                                                           tip:@""
                                                       content:KHJLocalizedString(@"hasBindden", nil)];
                [KHJHub shareHub].hud.hidden = YES;
            }
            else {
                [[KHJToast share] showToastActionWithToastType:_ErrorType
                                                  toastPostion:_CenterPostion
                                                           tip:KHJLocalizedString(@"tips", nil)
                                                       content:KHJLocalizedString(@"addDevFail", nil)];
            }
        });
    }
}

//提示图片国际化
- (void)playView
{
    NSString *language = [NSLocale preferredLanguages].firstObject;
    if ([language hasPrefix:@"en"]) {
        playImageV.image = [UIImage imageNamed:[NSString stringWithFormat:@"setting_en%d", pCount++] ];
    }
    else if ([language hasPrefix:@"zh"]) {
        
        playImageV.image = [UIImage imageNamed:[NSString stringWithFormat:@"setting_%d", pCount++] ];
    }
    else {
        playImageV.image = [UIImage imageNamed:[NSString stringWithFormat:@"setting_en%d", pCount++] ];
    }
    if (pCount == 4 ) {
        pCount=1;
    }
}

- (UIImageView *)getPlayImgV
{
    if (playImageV == nil) {
        NSString *language = [NSLocale preferredLanguages].firstObject;
        playImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64)];
        if ([language hasPrefix:@"en"]) {
            playImageV.image = [UIImage imageNamed:@"setting_en1"];

        } else if ([language hasPrefix:@"zh"]) {
            
            playImageV.image = [UIImage imageNamed:@"setting_1"];
        } else {
            playImageV.image = [UIImage imageNamed:@"setting_en1"];

        }
    }
    return playImageV;
    
}

- (void)setTable
{

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

- (void)callbacksuccessSetWifiAp:(bool)success withUid:(NSString *)uidStr
{
    if(success) {
        CLog(@"设置热点模式成功");
        //搜索设备
    }
    else {
        CLog(@"设置热点模式成功");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end


















