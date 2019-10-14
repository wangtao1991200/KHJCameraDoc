//
//  AlarmSetVController.m
//
//
//
//
//

#import "AlarmSetVController.h"
#import "CustomSlider.h"
#import "EMailSetVController.h"
#import "DeviceInfo.h"
#import "KHJAllBaseManager.h"

@interface AlarmSetVController ()
{
    UIView *bgView;
    UIButton * deviceSoundBtn;
    UIButton * alarmEmailBtn;

    UIButton * detectSoundBtn;
    UIButton * detectMoveBtn;
    UIButton * detectMoveSentyBtn;

    UIView *lv;
    CustomSlider *cslider;
    UISwitch *swDeviceSound;//声音报警开关
    UISwitch *swDetectSound;//声音侦测开关
    UISwitch *swDetectMove; //移动侦测开关
    
    NSMutableArray *shareList;
    NSMutableArray *unShareList;
    UILabel *tLabel;
}

@end

@implementation AlarmSetVController

- (instancetype)init
{
    self = [super init];
    if (self) {
        shareList = [NSMutableArray array];
        unShareList = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[KHJAllBaseManager sharedBaseManager] KHJSingleCheckDeviceOnline:self.uuidStr] != 1) {
        [[KHJToast share] showOKBtnToastWith:KHJLocalizedString(@"tips", nil)
                                     content:KHJLocalizedString(@"deviceDropLine", nil)];
    }
    self.title = KHJLocalizedString(@"alarmSetting", nil);
    self.view.backgroundColor = bgVCcolor;
    [self setbackBtn];
    [self setMain];
}

#pragma mark - setbackBtn

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

#pragma mark - 声音侦测
- (void)checkAlarmSound
{
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.myInfo.deviceUid];
    WeakSelf
    if (dDevice) {
        
        [dDevice.mDeviceManager getSoundAlarm:^(BOOL isStart) {
            
            [weakSelf getSoundAlarmCallBack:isStart];
        }];
    }
}
- (void)getSoundAlarmCallBack:(BOOL)isStart
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->swDetectSound.on = isStart;
    });
}

- (void)clickDetectSound:(UISwitch *)sw//设备声音报警开关
{
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.myInfo.deviceUid];
    WeakSelf
    if (dDevice) {
        [dDevice.mDeviceManager setSoundAlarm:sw.on returnBlock:^(BOOL success) {
            [weakSelf setSoundAlarmCallBack:success];
        }];
    }
}

- (void)setSoundAlarmCallBack:(BOOL)success
{
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_SuccessType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"setSuccess", nil)];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_ErrorType
                                              toastPostion:_CenterPostion
                                                       tip:KHJLocalizedString(@"tips", nil)
                                                   content:KHJLocalizedString(@"setFail", nil)];
        });
    }
}

#pragma mark - 移动侦测

- (void)checkMoveState
{
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.myInfo.deviceUid];
    WeakSelf
    if (dDevice) {
        [dDevice.mDeviceManager getAlarmSwitch:^(BOOL success) {
            [weakSelf getAlarmSwitchClallBack:success];
        }];
    }
}

- (void)getAlarmSwitchClallBack:(BOOL)success
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self->swDetectMove.on = success;

        if (success) {
            self->detectMoveSentyBtn.hidden = NO;
            [self checkInsensty];
            self->lv.hidden = NO;
            self->cslider.hidden = NO;


        }else{
            
            self->cslider.hidden = YES;
            self->lv.hidden = YES;
            self->detectMoveSentyBtn.hidden = YES;
        }
    });
}

- (void)clickDetectMove:(UISwitch *)sw

{
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.myInfo.deviceUid];
    WeakSelf
    if (dDevice) {
        [dDevice.mDeviceManager setAlarmSwitch:sw.on returnBlock:^(BOOL success) {
            [weakSelf setAlarmSwitchCallback:success];
        }];
    }
    sw.enabled = NO;
    if (sw.on) {
        cslider.hidden = NO;
        lv.hidden = NO;
        detectMoveSentyBtn.hidden = NO;
        [self checkInsensty];

    }else{
        cslider.hidden = YES;
        lv.hidden = YES;
        detectMoveSentyBtn.hidden = YES;
    }
}

- (void)setAlarmSwitchCallback:(BOOL)success
{
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{

            self->swDetectMove.enabled = YES;
            [[KHJToast share] showToastActionWithToastType:_SuccessType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"setSuccess", nil)];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[KHJToast share] showToastActionWithToastType:_ErrorType
                                              toastPostion:_CenterPostion
                                                       tip:KHJLocalizedString(@"tips", nil)
                                                   content:KHJLocalizedString(@"setFail", nil)];
            self->swDetectMove.on = !self->swDetectMove.on;
            self->swDetectMove.enabled = YES;
        });
    }
}
#pragma mark - 移动侦测灵敏度
- (void)checkInsensty
{
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.myInfo.deviceUid];
    WeakSelf
    if (dDevice) {
        [dDevice.mDeviceManager getMotionDetect:^(int success) {
            [weakSelf getMotionDetectCallBack:success];
        }];
    }
}
- (void)getMotionDetectCallBack:(int)success
{
    CLog(@"getMotionDetectCallBack = %d",success);
    __weak typeof(cslider) weakCslider= cslider;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if( (success<6) && (success > 0 )){
                weakCslider.currentIndex = success-1;
            }
            weakCslider.value = success-1;
            [weakCslider setNeedsDisplay];
        });
    });
}

#pragma mark - setMain

- (void)setMain
{
    if (!self.myInfo.isAPMode) {
        bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, SCREENWIDTH, 5*(44 + 1))];
    }
    else {
        bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, SCREENWIDTH, 3*(44 + 1))];
    }
    bgView.backgroundColor = UIColor.grayColor;
    [self.view addSubview:bgView];
    //设备声音开关
    [self setDeviceSound];
    //声音侦测
    [self setSoundDetect];
    //移动侦测
    [self setMoveDetect];
    [bgView addSubview:deviceSoundBtn];
    [bgView addSubview:detectSoundBtn];
    [bgView addSubview:detectMoveBtn];
    [self setMoveSenty];
    [self setAllBtnFont];
}

- (void)setDeviceSound
{
    //设备声音开关
    deviceSoundBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44)];
    [deviceSoundBtn setTitle:[NSString stringWithFormat:@"    %@",KHJLocalizedString(@"DeviceAlarmSound", nil)] forState:UIControlStateNormal];
    [deviceSoundBtn setTitleColor:UIColor.darkTextColor forState:UIControlStateNormal];
    deviceSoundBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [deviceSoundBtn setBackgroundColor:[UIColor whiteColor]];
    
    swDeviceSound = [[UISwitch alloc] initWithFrame:CGRectMake(SCREENWIDTH-82, 8, 72, 44)];
    swDeviceSound.on = NO;//初始状态
    [self checkDeviceAlarmVolume];
    swDeviceSound.onTintColor = DeCcolor;
    swDeviceSound.transform = CGAffineTransformMakeScale( 0.75, 0.75);//缩放
    swDeviceSound.layer.anchorPoint=CGPointMake(0,0.5);
    [swDeviceSound addTarget:self action:@selector(clickDevSound:) forControlEvents:UIControlEventValueChanged];
    [deviceSoundBtn addSubview:swDeviceSound];
}

- (void)checkDeviceAlarmVolume
{
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.myInfo.deviceUid];
    WeakSelf
    if (dDevice) {
        [dDevice.mDeviceManager getDeviceAlarmVolume:^(BOOL isOpen) {
            
            [weakSelf getDeviceAlarmVolumeCallback:isOpen];
        }];
    }
}
- (void)getDeviceAlarmVolumeCallback:(BOOL)isOpen
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->swDeviceSound.on = isOpen;
    });
}

#pragma mark - 设备报警开关
- (void)clickDevSound:(UISwitch *)sw//设备发出报警声音开关
{
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.myInfo.deviceUid];
    WeakSelf
    if (dDevice) {
        [dDevice.mDeviceManager setDeviceAlarmVolume:sw.on returnBlock:^(BOOL success) {
            
            [weakSelf setDeviceAlarmVolumeCallback:success];
        }];
    }
}
- (void)setDeviceAlarmVolumeCallback:(BOOL)success
{
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_SuccessType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"setSuccess", nil)];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_ErrorType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"setFail", nil)];
        });
    }
}


- (void)setSoundDetect
{
    if (!self.myInfo.isAPMode) {
        detectSoundBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, alarmEmailBtn.frame.size.height + alarmEmailBtn.frame.origin.y+1, SCREENWIDTH, 44)];
    }
    else {
        detectSoundBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, deviceSoundBtn.frame.size.height + deviceSoundBtn.frame.origin.y+1, SCREENWIDTH, 44)];
    }
    [detectSoundBtn setBackgroundColor:[UIColor whiteColor]];
    [detectSoundBtn setTitleColor:UIColor.darkTextColor forState:UIControlStateNormal];
    [detectSoundBtn setTitle:[NSString stringWithFormat:@"    %@",KHJLocalizedString(@"soundDetect", nil)] forState:UIControlStateNormal];
    detectSoundBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    swDetectSound = [[UISwitch alloc] initWithFrame:CGRectMake(SCREENWIDTH-82, 8, 72, 44)];
    swDetectSound.on = NO;//初始状态
    swDetectSound.onTintColor = DeCcolor;
    swDetectSound.transform = CGAffineTransformMakeScale( 0.75, 0.75);//缩放
    swDetectSound.layer.anchorPoint=CGPointMake(0,0.5);
    [swDetectSound addTarget:self action:@selector(clickDetectSound:) forControlEvents:UIControlEventValueChanged];
    [detectSoundBtn addSubview:swDetectSound];
    [self checkAlarmSound];
}

- (void)setMoveDetect
{
    detectMoveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, detectSoundBtn.frame.size.height + detectSoundBtn.frame.origin.y+1, SCREENWIDTH, 44)];
    [detectMoveBtn setBackgroundColor:[UIColor whiteColor]];
    [detectMoveBtn setTitleColor:UIColor.darkTextColor forState:UIControlStateNormal];
    [detectMoveBtn setTitle:[NSString stringWithFormat:@"    %@",KHJLocalizedString(@"moveDetect", nil)] forState:UIControlStateNormal];
    detectMoveBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    swDetectMove = [[UISwitch alloc] initWithFrame:CGRectMake(SCREENWIDTH-82, 8, 72, 44)];
    swDetectMove.on = NO;//初始状态
    swDetectMove.onTintColor = DeCcolor;
    swDetectMove.transform = CGAffineTransformMakeScale( 0.75, 0.75);//缩放
    swDetectMove.layer.anchorPoint=CGPointMake(0,0.5);
    [swDetectMove addTarget:self action:@selector(clickDetectMove:) forControlEvents:UIControlEventValueChanged];
    [detectMoveBtn addSubview:swDetectMove];
    [self checkMoveState];
}

- (void)setMoveSenty
{
    detectMoveSentyBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, bgView.frame.size.height + bgView.frame.origin.y + 1, SCREENWIDTH, 44)];
    [detectMoveSentyBtn setBackgroundColor:bgVCcolor];
    [detectMoveSentyBtn setTitleColor:UIColor.darkTextColor forState:UIControlStateNormal];
    [detectMoveSentyBtn setTitle:[NSString stringWithFormat:@"    %@",KHJLocalizedString(@"setMoveSensitive", nil)] forState:UIControlStateNormal];
    detectMoveSentyBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.view addSubview:detectMoveSentyBtn];
    lv = [[UIView alloc] initWithFrame:CGRectMake(0, detectMoveSentyBtn.frame.size.height + detectMoveSentyBtn.frame.origin.y+1, SCREENWIDTH, 1)];
    lv.backgroundColor = [UIColor grayColor];
    [self.view addSubview:lv];
    detectMoveSentyBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    
    cslider = [[CustomSlider alloc] initWithFrame:CGRectMake(0, detectMoveSentyBtn.frame.size.height+detectMoveSentyBtn.frame.origin.y+10,SCREENWIDTH, 80)];
    cslider.backgroundColor = [UIColor clearColor];
    cslider.sliderBarHeight = 2;
    cslider.numberOfPart = 5;
    cslider.thumbImage = [UIImage imageNamed:@"round1.png"];
    cslider.partNameOffset = CGPointMake(0, -30);
    cslider.thumbSize = CGSizeMake(32, 32);
    cslider.partSize = CGSizeMake(15, 15);
    cslider.partNameArray = @[KHJLocalizedString(@"low", nil),@" ",@" ",@" ",KHJLocalizedString(@"high", nil)];
    //    slider.sliderColor = [UIColor lightGrayColor];
    cslider.partColor = [UIColor lightGrayColor];
    cslider.value = 4;
    [cslider addTarget:self action:@selector(valuechange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:cslider];
    
    lv.hidden = YES;
    cslider.hidden = YES;
}

- (void)valuechange:(CustomSlider *)slider
{
    slider.enabled = NO;
    CLog(@"slider.value == %ld",slider.value);
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.myInfo.deviceUid];
    WeakSelf
    if (dDevice) {
        [dDevice.mDeviceManager setMotiondetect:(int)(slider.value+1) returnBlock:^(BOOL success) {
            [weakSelf setMotionDetectCallBack:success];
        }];
    }
}

- (void)setMotionDetectCallBack:(BOOL)success
{
    __weak typeof(cslider) weakCslider= cslider;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        weakCslider.enabled = YES;
    });
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[KHJToast share] showToastActionWithToastType:_SuccessType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"setSuccess", nil)];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_ErrorType
                                              toastPostion:_CenterPostion
                                                       tip:KHJLocalizedString(@"tips", nil)
                                                   content:KHJLocalizedString(@"setFail", nil)];
        });
    }
}

- (void)setAllBtnFont
{
    UIFont *ffFont = [UIFont systemFontOfSize:15];
    deviceSoundBtn.titleLabel.font = ffFont;
    alarmEmailBtn.titleLabel.font = ffFont;
    detectSoundBtn.titleLabel.font = ffFont;
    detectMoveBtn.titleLabel.font = ffFont;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end















