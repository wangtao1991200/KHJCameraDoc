//
//  LANVController.m
//  KHJCamera
//
//  Created by hezewen on 2018/6/23.
//  Copyright © 2018年 khj. All rights reserved.
//

#import "LANVController.h"
//#import "KHJDeviceManager.h"
#import <KHJCameraLib/KHJCameraLib.h>

#import "RemberUserListView.h"
#import "WCQRCodeScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "KHJAllBaseManager.h"
@interface LANVController ()
{
    UIView *backgroundView;
    RemberUserListView *remListView;
    UIButton *searchBtn;
    NSArray *deviceArray;
    NSString *newPwdString;//设备密码

    NSString *deviceName;
    dispatch_source_t _timer;
    KHJDeviceManager *dManager;
}

@property (nonatomic,copy)NSString * uuidStr;

@end

@implementation LANVController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = KHJLocalizedString(@"addDevice", nil);
    self.view.backgroundColor = bgVCcolor;
    _bgView.backgroundColor = bgVCcolor;
    [self setbackBtn];
    [self addNoti];
}

- (void)addNoti
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveUID:) name:recieveUID_Noti object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:recieveUID_Noti object:nil];
}

- (void)recieveUID:(NSNotification *)noti
{
    WeakSelf
    NSString *uidStr = noti.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.uidTextField.text = uidStr;
    });
}

- (void)setbackBtn
{
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    but.frame =CGRectMake(0,0, 66, 44);
    but.imageEdgeInsets = UIEdgeInsetsMake(0,-40, 0, 0);//解决按钮不能靠左问题
    [but setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem  *barBut = [[UIBarButtonItem alloc]initWithCustomView:but];
    self.navigationItem.leftBarButtonItem = barBut;
}

- (void)popViewController
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:recieveUID_Noti object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:needReloadList_Noti object:nil];;
    [self.navigationController popViewControllerAnimated:YES];
}

//二维码扫描uid
- (IBAction)swipERClick:(UIButton *)sender
{
    WCQRCodeScanViewController *WCVC = [[WCQRCodeScanViewController alloc] init];
    WCVC.indexP = 1;
    [self QRCodeScanVC:WCVC];
}

- (void)QRCodeScanVC:(WCQRCodeScanViewController *)scanVC
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (status) {
            case AVAuthorizationStatusAuthorized: {
                scanVC.indexP = 1;
                [self.navigationController pushViewController:scanVC animated:YES];
                break;
            }
            case AVAuthorizationStatusNotDetermined: {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (granted) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self.navigationController pushViewController:scanVC animated:YES];
                        });
                        NSLog(@"用户第一次同意了访问相机权限 - - %@", [NSThread currentThread]);
                    }
                    else {
                        NSLog(@"用户第一次拒绝了访问相机权限 - - %@", [NSThread currentThread]);
                    }
                }];
                break;
            }
            case AVAuthorizationStatusDenied: {
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"tips", nil) message:KHJLocalizedString(@"cameraPrivacy", nil) preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *alertA = [UIAlertAction actionWithTitle:KHJLocalizedString(@"commit", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                [alertC addAction:alertA];
                [self presentViewController:alertC animated:YES completion:nil];
                break;
            }
            case AVAuthorizationStatusRestricted: {
                NSLog(@"因为系统原因, 无法访问相册");
                break;
            }
            default:
                break;
        }
        return;
    }
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"tips", nil) message:KHJLocalizedString(@"noCamera", nil) preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *alertA = [UIAlertAction actionWithTitle:KHJLocalizedString(@"commit", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertC addAction:alertA];
    [self presentViewController:alertC animated:YES completion:nil];
}

- (IBAction)searchWifi:(UIButton *)sender
{
    searchBtn = sender;
    [self seachDevice];
}

- (IBAction)addDeviceClick:(UIButton *)sender
{
    if ([_uidTextField.text isEqualToString:@""]) {

        [[KHJToast share] showToastActionWithToastType:_WarningType
                                          toastPostion:_CenterPostion
                                                   tip:@""
                                               content:KHJLocalizedString(@"uidNotNull", nil)];
        return;
    }
    NSString *str =  _uidTextField.text;
    NSLog(@"str == %@",str);
    [[KHJHub shareHub] showText:KHJLocalizedString(@"adding", nil) addToView:self.view type:_lightGray];

    WeakSelf

    KHJBaseDevice *bdevice = [[KHJBaseDevice alloc] init];
    bdevice.mDeviceManager = [[KHJDeviceManager alloc] init];
    
    // KHJ
    [bdevice.mDeviceManager creatKHJCameraBase:str];
    // MAEVIA
//    [bdevice.mDeviceManager creatMAEVIACameraBase:str];
    DeviceInfo *dInfo = [[DeviceInfo alloc] init];
    dInfo.deviceUid = str;
    dInfo.deviceRealPwd = @"888888";
    dInfo.isOpen = YES;
    dInfo.isAPMode = NO;
    bdevice.mDeviceInfo = dInfo;
    [[KHJAllBaseManager sharedBaseManager] addKHJManager:bdevice andKey:str];
    
    [bdevice.mDeviceManager connect:@"888888" withUid:str flag:0 successCallBack:^(NSString *uidStr, NSInteger isSuccess) {
        
        [weakSelf connectDevice:(int)isSuccess withUid:uidStr];
    } offLineCallBack:^{
        CLog(@"________");
    }] ;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [_uidTextField resignFirstResponder];
}

#pragma mark - 搜索回调

- (void)seachDevice
{
    WeakSelf
    [self addShadow];
    [[KHJHub shareHub] showText:KHJLocalizedString(@"searching", nil) addToView:self.view type:_lightGray];
    [KHJDeviceManager searchDevice:^(NSMutableArray *darray) {
        [weakSelf backDeviceinfo:darray];
    }];
    [self openCountdown];
}

- (void)backDeviceinfo:(NSMutableArray *)array
{
    dispatch_source_cancel(_timer);
    deviceArray = array;
    CLog(@"deviceArr == %@",deviceArray);
    WeakSelf
    __weak typeof(array) weakDeviceArray= array;
    dispatch_async(dispatch_get_main_queue(), ^{
        int i = (int)[weakDeviceArray count];
        
        [[KHJToast share] showToastActionWithToastType:_WarningType
                                          toastPostion:_CenterPostion
                                                   tip:@""
                                               content:[NSString stringWithFormat:@"%@%d",KHJLocalizedString(@"searchDevNum", nil),i]];
        [weakSelf deleteShadow];
        [KHJHub shareHub].hud.hidden = YES;
        if ([weakDeviceArray count]> 0) {
            [weakSelf handleListView];
        }
    });
}
-(void)openCountdown{
    
    WeakSelf
    __block NSTimeInterval seconds = 10.f;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
     _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0); // 每秒执行一次
    
    dispatch_source_set_event_handler(_timer, ^{
        seconds--;
        if (seconds == 0) {
            
            [KHJDeviceManager stopSearchDevice];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[KHJToast share] showToastActionWithToastType:_WarningType
                                                  toastPostion:_CenterPostion
                                                           tip:@""
                                                       content:KHJLocalizedString(@"searchTimeOut", nil)];
                [weakSelf deleteShadow];
                dispatch_source_cancel(self->_timer);
            });
        }
    });
    dispatch_resume(_timer);
}
//添加遮罩
- (void)addShadow
{
    backgroundView = [[UIView alloc] init];
    backgroundView.frame = CGRectMake(0, 1,SCREEN_WIDTH,SCREEN_HEIGHT);
    backgroundView.backgroundColor = [UIColor colorWithRed:(40/255.0f) green:(40/255.0f) blue:(40/255.0f) alpha:1.0f];
    backgroundView.alpha = 0.6;
    [[[UIApplication sharedApplication] keyWindow] addSubview:backgroundView];
}
- (RemberUserListView *)getRemUserList
{
    if (remListView == nil) {
        remListView = [[RemberUserListView alloc] init];
    }
    return remListView;
}
- (void)handleListView
{
    remListView = [self getRemUserList];
        UIWindow* desWindow=[UIApplication sharedApplication].keyWindow;
    CGRect frame = [searchBtn convertRect:searchBtn.bounds toView:desWindow];
    
    CGFloat rWidth = 240;
    CGRect rg = remListView.frame;
    rg.origin = CGPointMake(frame.size.width +frame.origin.x - rWidth,frame.size.height+frame.origin.y);
    if ([deviceArray count]<3) {
        rg.size = CGSizeMake(rWidth, [deviceArray count]*40);
    }else{
        rg.size = CGSizeMake(rWidth, 3*40);
    }
    remListView.frame = rg;
    remListView.dataArray = deviceArray;
    [remListView show];
    [remListView refreshTable];
    __weak typeof(_uidTextField) weakUidTextField= _uidTextField;
    [remListView setTableClickBlock:^(NSString * str ) {

        CLog(@"setTableClickBlock");
        weakUidTextField.text = str;

    }];
}
- (void)deleteShadow
{
    if (backgroundView) {
        [backgroundView removeFromSuperview];
    }
}
//连接成功的回调
- (void)connectDevice:(int)success withUid:(NSString *)uidStr{
    
    NSLog(@"连接成功?== %d",success);
    self.uuidStr = uidStr;
    WeakSelf
    if (success == 0) {//连接成功
        CLog(@"连接设备成功");
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJHub shareHub] showText:@"连接成功" addToView:self.view];
        });
        //此处需要SDK使用者，对设备设置相关信息，让设备去服务器注册绑定账户，
//        [dManager setAccount:@"用户账号" andSsid:@"" andSPwd:@"" andType:3 andService:@"serverURL" returnBlock:^(BOOL success) {
//
//        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hasDevice" object:uidStr];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }
    else if (success == -20009) {
        // 密码错误
    }
    else if (success == -90) {
        // 离线
    }
    else {
        CLog(@"连接设备失败");
    }
}

@end






















