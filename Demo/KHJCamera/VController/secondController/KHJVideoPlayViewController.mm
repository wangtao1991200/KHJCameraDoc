//
//  VideoPlayViewController.m
//
//  视频播放 + 控制 + 功能
//
//
//

#import <SystemConfiguration/CaptiveNetwork.h>
#import "KHJVideoPlayViewController.h"
#import <KHJCameraLib/KHJCameraLib.h>
#import "Calculate.h"
#import "HZWImageView.h"
#import "KHJSettingViewController.h"
#import "UIDevice+TFDevice.h"
#import "AppDelegate.h"
#import "DePickerView.h"
#import "NSDate+JLZero.h"
#import "DeAlarmImageView.h"
#import "DownLoadView.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <sys/utsname.h>
#import "SPActivityIndicatorView.h"
#import "KHJAllBaseManager.h"
#import "KHJHelpCameraData.h"
#import <IJKMediaFramework/IJKMediaFramework.h>

#define  IMAGEHEIGHT  (SCREENWIDTH*3/5-10)
#define  bHeight (SCREENWIDTH/5)
#define  MSTEP        (10)
#define  MSTEP1        (10)


@interface KHJVideoPlayViewController ()<UIScrollViewDelegate>
{
    OpenGLView20 *glView;   //
    UIScrollView *vScroll;  //

    UIView *bgView;         //视频播放背景view
    UILabel *recodeLabel;   //录制时间显示
    UIImageView *hImgView;  //上层image
    
    dispatch_source_t _conntimer;       //重新连接定时器
    dispatch_source_t _recordMP4timer;  //录制视频定时器
    
    __block NSTimeInterval totalTimerSecond;
    
    bool isRecordVideo;     //是否在录制视频
    bool isRecAudio;        //接受音频
    bool isSendAudio;       //发送音频
    
    UISwitch *switchView;
    UILabel *tipLabel;
    UIView * popView;
    
    BOOL isHengPin;             //临时切换横屏
    UIButton *hBackButton;      //横屏返回按钮
    UIImageView *hBackView;     //横屏导航栏
    
    UIView *bottomView;         //容器：拍照、按住说话、监听
    UIView *bottomLine;         //
    
    UILabel *titleLabel;        // 设备名称
    
    BOOL isIntoTalk;            // 保存发送语音前，设备回传语音的状态
    UIButton *reConnectBtn;     // 重连按钮
    UIImageView *micImageV;     // 音频播放提示
    BOOL isFirstInto;           // 第一次进入
    BOOL hasReceiveData;        // 是否已接收数据
    UIImageView *stateBgView;   // 视频界面下方按钮
    
    BOOL isCheckInitOpenAudio;  // 初始化声音开启或者关闭
    
    NSInteger currentSec;
    int languageValue;          // 语言
    BOOL isNeedConnect;         // 是否需要重连
    SPActivityIndicatorView *KHJACTivityIndicatorView;
    NSTimer *stopRecordTimer;//延时停止
    KHJBaseDevice*bDevice;
    
    int rQuality;//视频质量
}
@property (atomic, retain) id<IJKMediaPlayback> player;
@property (atomic, retain)id<IJKMediaPlayback> prePlayer;

@end

@implementation KHJVideoPlayViewController

@synthesize isShare;

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES ;
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = NO;//关闭横屏仅允许竖屏
    [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self cancelOperater];
    [self handleLiveWhenDisAppear];
    CLog(@"viewDidDisappear");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self changeBottom1];
    CLog(@"viewWillAppear");
    [self handleLiveWhenAppear];
}

#pragma mark - 视频直播逻辑
- (void)handleLiveWhenDisAppear
{
    popView = [self getPopView];
    if ([self.view.subviews containsObject:popView]) {
        popView.hidden = YES;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self changeBottom1];
        [self handleEnterBackground];
        [self changeStateBgViewBtn1];
    });
    if (micImageV.hidden == NO) {
        micImageV.hidden = YES;
    }
    UIButton *btn = [bottomView viewWithTag:103];
    if (btn) {
        if (languageValue == -1) {
            [btn setBackgroundImage:[UIImage imageNamed:@"vediopage4"] forState:UIControlStateNormal];
        }
        else {
            [btn setBackgroundImage:[UIImage imageNamed:@"en-vediopage4"] forState:UIControlStateNormal];
        }
    }
}

- (void)handleLiveWhenAppear
{
    [self settitleName];
    
    if (self.myInfo.DeviceConnectState == 1) {
        if (self.myInfo.isOpen) {
            [self startReciveVide];
        }
        [self getForceOpenCamera];
    }
    else if(self.myInfo.DeviceConnectState == 0) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self->KHJACTivityIndicatorView = [self getSPAActivity];
            [self->KHJACTivityIndicatorView stopAnimating];
            self->reConnectBtn.hidden = NO;
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startTimerWithSeconds:6 endBlock:^{
                CLog(@"进入重连设备456");
                [self reconnectDev];
            }];
        });
    }
}

#pragma mark - 进入设置界面停止播放

- (void)settitleName
{
    titleLabel = [self getTitleLabel];
    titleLabel.text = self.myInfo.deviceName;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
}

- (UILabel *)getTitleLabel
{
    NSString *title = self.myInfo.deviceName;
    CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    if (titleLabel ==nil) {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREENWIDTH - titleSize.width)/ 2, 0, titleSize.width, titleSize.height)];
    }
    return titleLabel;
}

#pragma mark - 报警推送（此处需要理清楚，当前播放是那种类型的视频，（实时，云端，sd卡））

- (void)noRefreshData:(DeviceInfo *)alarmDevInfo
{
    if (isHengPin) {
        [self KHJClickQuanPin];
        [self tapBgView];
    }
}
- (void)refreshData:(DeviceInfo *)alarmDevInfo
{
    //1.先判断是否是当前设备，2.判断是否是回放
    if (isHengPin) {
        [self KHJClickQuanPin];
        [self tapBgView];
    }
    
    if (![alarmDevInfo.deviceUid isEqualToString:self.myInfo.deviceUid]) {
        
        self.myInfo = alarmDevInfo;
        isFirstInto = YES;
        if (stateBgView) {
            [stateBgView removeFromSuperview];
            stateBgView = nil;
        }
        [self setStateView];
        [self settitleName];
    }
    else {
        self.myInfo = alarmDevInfo;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        totalTimerSecond = - 1;
        isFirstInto = YES;
        isCheckInitOpenAudio = [[NSUserDefaults standardUserDefaults] boolForKey:@"initSoundOpen"];
    }
    return self;
}
#pragma mark - 自定义加载框
- (SPActivityIndicatorView *)getSPAActivity
{
    
    if (KHJACTivityIndicatorView == nil) {
        
        KHJACTivityIndicatorView = [[SPActivityIndicatorView alloc] initWithType:SPActivityIndicatorAnimationTypeBallLoopScale tintColor:UIColor.whiteColor size:35];
        CGFloat width = SCREENWIDTH/5.0; // 每行排5个(5列)
        CGFloat height = width;
        KHJACTivityIndicatorView.frame = CGRectMake(0, 0, width, height);
       
    }
    if (![bgView.subviews containsObject:KHJACTivityIndicatorView]) {
        
        [bgView addSubview:KHJACTivityIndicatorView];
        KHJACTivityIndicatorView.center = CGPointMake(bgView.frame.size.width/2, bgView.frame.size.height/2);
        
    }else{
        [bgView bringSubviewToFront:KHJACTivityIndicatorView];
    }
    return KHJACTivityIndicatorView;
}

#pragma mark - viewDidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.view.backgroundColor = bgVCcolor;
    [self setbackBtn];
    [self setRightBtn];
    [self setVedioView];
    [self setStateView];
    [self checkLanguage];
    [self seBottomButton];
    [self setControlDevcieView];
    [self addNotificatio];
    [self getHBackView];
    CLog(@"viewDidLoad");
    bDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.myInfo.deviceUid];
    if (bDevice == nil) {
        CLog(@"bDevice = nil");
    }
    else {
        CLog(@"bDevice = %@",bDevice);
    }
}

- (void)handleEndTime:(NSString *)endTime
{
    NSTimeInterval cTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval dTime =[endTime doubleValue]/1000;
    if((dTime-cTime)<= 7*24*60*60 && (dTime-cTime) >= 0){//时间段判断
        [self showDeadLine];
    }
}

- (void)showDeadLine
{
    UIAlertController *alertview=[UIAlertController alertControllerWithTitle:KHJLocalizedString(@"tips", nil) message:KHJLocalizedString(@"cloudTips", nil) preferredStyle:UIAlertControllerStyleAlert];
    // 设置按钮
    UIAlertAction *cancel=[UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *defult = [UIAlertAction actionWithTitle:KHJLocalizedString(@"commit", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertview addAction:cancel];
    [alertview addAction:defult];
    [self presentViewController:alertview animated:YES completion:nil];
}

/**
 检测语言
 */
- (void)checkLanguage
{
    //获取手机系统语言
    NSString *language = [NSLocale preferredLanguages].firstObject;
    if ([language hasPrefix:@"en"]) {
        languageValue = 1;
    }
    else if ([language hasPrefix:@"zh"]) {
        languageValue = -1;
    }
    else {
        languageValue = 1;
    }
}

- (void)addNotificatio
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDevName:)
                                                 name:changeDeviceName_Noti
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VideoDecoderBadDataErrNotification:)
                                                 name:VideoDecoderBadDataErrNotification_Noti
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(EnterForeground:)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lockSreen)
                                                 name: UIApplicationProtectedDataWillBecomeUnavailable
                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkDidReceiveMessage:)
//                                                 name:kJPFNetworkDidReceiveMessageNotification
//                                               object:nil];
    [self installMovieNotificationObservers];
}

- (void)removeNOtification
{

    [[NSNotificationCenter defaultCenter] removeObserver:self name:changeDeviceName_Noti object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VideoDecoderBadDataErrNotification_Noti object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kJPFNetworkDidReceiveMessageNotification object:nil];
    [self removeMovieNotificationObservers];
}

- (void)lockSreen
{
    isNeedConnect = YES;
    CLog(@"lockSreen1");
}

- (void)networkDidReceiveMessage:(NSNotification *)note
{
    
}

#pragma mark - NOtification
- (void)handleDevIsOpen:(NSNotification *)noti
{
    NSNumber *num = noti.object;
    BOOL isOpen = [num boolValue];
    self.myInfo.isOpen = isOpen;

    if (isOpen) {
        __weak typeof(tipLabel) weakTipLabel = tipLabel;
        __weak typeof(switchView) weakSwitchView = switchView;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakTipLabel.hidden = YES;
            weakSwitchView.hidden = YES;
        });
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)note
{
    [KHJDeviceManager cameraEnterBackground];
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSTimeInterval interVal = [datenow timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults] setDouble:interVal  forKey:@"testSleep1"];
    
    isNeedConnect = NO;
    CLog(@"applicationDidEnterBackground2222");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideTime];
        if (self->_conntimer) {
            dispatch_source_cancel(self->_conntimer);
        }
        [self changeBottom1];
        [self handleEnterBackground];
        [self changeStateBgViewBtn1];
        [self stopPlayVideo:nil];
    });
}

- (void)handleEnterBackground
{
    if (_conntimer) {
        dispatch_source_cancel(_conntimer);
    }
    [bDevice.mDeviceManager startRecvVideo:NO withUid:self.myInfo.deviceUid reternBlock:^(BOOL k) {
        
    }];
    hasReceiveData  = NO;
    NSString *filePath = [[[KHJHelpCameraData sharedModel] getTakeVideoDocPath] stringByAppendingPathComponent:[[KHJHelpCameraData sharedModel] getVideoNameWithType:@"mp4"]];
    [bDevice.mDeviceManager startRecordMp4:NO path:filePath];
    [self otherStopRecodeVedio];
    isRecordVideo = NO;
    [bDevice.mDeviceManager startSendAudio:NO];
    isSendAudio = NO;
    [bDevice.mDeviceManager isPlayRecvAudio:NO];
    [bDevice.mDeviceManager startRecvAudio:NO];
    isRecAudio = NO;
}
- (void)otherStopRecodeVedio
{
    if (isRecordVideo) {//停止录制视频
        CLog(@"isRecordVideo222");
        recodeLabel.hidden = YES;
        [self hideTime];
        NSString *filePath = [[[KHJHelpCameraData sharedModel] getTakeVideoDocPath] stringByAppendingPathComponent:[[KHJHelpCameraData sharedModel] getVideoNameWithType:@"mp4"]];
        [bDevice.mDeviceManager startRecordMp4:NO path:filePath];
        [self deleteLittleVedio];
    }
}
- (void)VideoDecoderBadDataErrNotification:(NSNotification *)note
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[KHJToast share] showToastActionWithToastType:_WarningType
                                          toastPostion:_CenterPostion
                                                   tip:@""
                                               content:KHJLocalizedString(@"Data Error", nil)];
    });
    
    [bDevice.mDeviceManager startRecvVideo:NO withUid:self.myInfo.deviceUid reternBlock:^(BOOL k) {
        
    }];
}

#pragma mark - startTimerWithSeconds
- (void)startTimerWithSeconds:(long)seconds endBlock:(void(^)())endBlock
{
    __block long timeout = seconds;//倒计时时间
    timeout = 5;
    if (_conntimer) {
        dispatch_source_cancel(_conntimer);
    }
    dispatch_queue_t queue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    _conntimer =dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0,0,queue);
    dispatch_source_set_timer(_conntimer,dispatch_walltime(NULL,0),1.0*NSEC_PER_SEC,0);//每秒执行
    dispatch_source_set_event_handler(_conntimer, ^{
        if(timeout < 0){ //倒计时结束，回调block
            dispatch_source_cancel(self->_conntimer);
            dispatch_async(dispatch_get_main_queue(), ^{
                if(endBlock) {
                    endBlock();
                }
            });
        }
        else {
            timeout -= 1;
        }
    });
    dispatch_resume(_conntimer);
}

#pragma mark - 返回按钮

- (void)setbackBtn
{
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    but.frame =CGRectMake(0,0, 66, 44);
    but.imageEdgeInsets = UIEdgeInsetsMake(0,-40, 0, 0);//解决按钮不能靠左问题
    
    [but setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem  *barBut = [[UIBarButtonItem alloc]initWithCustomView:but];
    //解决按钮不靠左 靠右的问题.
    self.navigationItem.leftBarButtonItem = barBut;
}
- (void)backViewController
{
      if (_conntimer) {
        dispatch_source_cancel(_conntimer);
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self handleEnterBackground];
        [self stopPlayVideo:nil];
        [self releasePlayer];
    });

    CLog(@"backViewController");
    if (hasReceiveData) {
        [self saveImage];
    }
    if (glView) {
        [glView removeFromSuperview];
        glView = nil;
    }
    [self removeNOtification];
    [UIApplication sharedApplication].idleTimerDisabled = NO;

    if (self.isFromAlarm) {
        //报警界面push过来的
        NSInteger mIndex = [self.navigationController.viewControllers indexOfObject:self];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:(mIndex-2)] animated:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - saveImage

- (void)saveImage
{
    //拿到图片
    UIImage *screenImage = [self  snapsHotView:glView] ;
    NSString *path_document = NSHomeDirectory();
    NSString *pString = [NSString stringWithFormat:@"/Documents/%@.png",self.myInfo.deviceUid];
    NSString *imagePath = [path_document stringByAppendingString:pString];
    //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
    [UIImagePNGRepresentation(screenImage) writeToFile:imagePath atomically:YES];
}

#pragma mark - 全屏的导航栏

- (UIButton *)getHbackButton
{
    if (!hBackButton) {
        hBackButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 4, 60, 36)];
        [hBackButton setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
        [hBackButton addTarget:self action:@selector(KHJClickQuanPin) forControlEvents:UIControlEventTouchUpInside];
        hBackButton.userInteractionEnabled = YES;
    }
    return hBackButton;
}

- (void)getHBackView
{
    if (hBackView == nil) {
        hBackView =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44)];
        hBackView.image = [UIImage imageNamed:@"bgN"];
        hBackButton = [self getHbackButton];
        [hBackView addSubview:hBackButton];
        [self.view addSubview:hBackView];
        hBackView.hidden = YES;
        hBackView.userInteractionEnabled = YES;
        [self setTLabel];
    }
}

- (void)setTLabel
{
    UILabel *lab = (UILabel *)[hBackView viewWithTag:601];
    if (lab == nil) {
        lab = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH/2-60, 0, 120, 44)];
        lab.tag = 601;
        lab.textColor = UIColor.whiteColor;
        lab.textAlignment = NSTextAlignmentCenter;
        [hBackView addSubview:lab];
    }
    else {
        lab.frame = CGRectMake(SCREENWIDTH/2-60, 0, 120, 44);
    }
    if (self.myInfo.deviceName) {
        lab.text = self.myInfo.deviceName;
    }
    else {
        lab.text = self.myInfo.deviceUid;
    }
}

#pragma mark - 视频全屏点击

/**
 横屏
 */
- (void)KHJClickQuanPin
{
    CLog(@"clickQuanPin");
    if(!isHengPin){
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate ;
        appDelegate.allowRotation = YES ;
        [UIDevice switchNewOrientation:UIInterfaceOrientationLandscapeRight];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    else {
        [self backShuPin];
    }
    isHengPin = !isHengPin;
    [self RedrawView];
}

/**
 竖屏
 */
- (void) backShuPin
{
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = NO;//关闭横屏仅允许竖屏
    //切换到竖屏
    [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)RedrawView
{
    popView.hidden = YES;
    if (isHengPin) {//
        if (isSendAudio) {
            UIButton *btn = (UIButton *)[bottomView viewWithTag:101];
            [self clickBtn:btn];
        }
        bgView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
        bottomLine.hidden =YES;
        hBackView.frame = CGRectMake(0, 0, SCREENWIDTH, 44);
        hBackView.hidden = NO;
        [self setTLabel];
    }
    else {
        hBackView.frame = CGRectMake(0, 0, SCREENWIDTH, 44);
        hBackView.hidden = YES;
        [self setTLabel];
        
        bgView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH*9/16);
        stateBgView.hidden = NO;
        bottomView.backgroundColor = UIColor.clearColor;
        bottomLine.hidden = NO;
    }
    
    KHJACTivityIndicatorView = [self getSPAActivity];
    KHJACTivityIndicatorView.center = CGPointMake(bgView.frame.size.width/2, bgView.frame.size.height/2);
    recodeLabel.frame = CGRectMake(SCREENWIDTH-60-10, 0, 60, 22);
    tipLabel.frame =CGRectMake(0, 0, 120, 30);
    tipLabel.center = CGPointMake(bgView.frame.size.width/2, bgView.frame.size.height/2);
    switchView.frame = CGRectMake(bgView.frame.size.width/2-30, tipLabel.frame.size.height+tipLabel.frame.origin.y, 60, 44);
    reConnectBtn.frame = CGRectMake(0, SCREENWIDTH/2-50, 160, 40);
    reConnectBtn.center =CGPointMake(bgView.frame.size.width/2, bgView.frame.size.height/2-20);
    
    stateBgView.frame = CGRectMake(0, bgView.frame.size.height+bgView.frame.origin.y, SCREENWIDTH, 44);
    [self RedrawViewBottom];
}

#pragma mark - setSwitchView

- (void)setSwitchView
{
    tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    tipLabel.text = KHJLocalizedString(@"deviceClosed", nil);
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.font = [UIFont systemFontOfSize:17];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview: tipLabel];
    
    tipLabel.center = CGPointMake(bgView.frame.size.width/2, bgView.frame.size.height/2);
    
    switchView = [[UISwitch alloc] initWithFrame:CGRectMake(bgView.frame.size.width/2-30, tipLabel.frame.size.height+tipLabel.frame.origin.y, 60, 44)];
    switchView.on = NO;//设置初始为ON的一边
    switchView.onTintColor = ssRGB(55, 118, 234);
    switchView.tintColor = UIColor.lightGrayColor;
    switchView.backgroundColor = UIColor.lightGrayColor;
    switchView.layer.masksToBounds = true;
    switchView.layer.cornerRadius = switchView.bounds.size.height/2;
    [switchView addTarget:self action:@selector(openClick:) forControlEvents:UIControlEventValueChanged];
    [bgView addSubview: switchView];
    
    tipLabel.hidden = YES;
    switchView.hidden = YES;
    reConnectBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREENWIDTH/2-50, 160, 40)];
    [reConnectBtn setTitle:KHJLocalizedString(@"reConnected", nil) forState:UIControlStateNormal];
    reConnectBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [reConnectBtn addTarget:self action:@selector(reconnectDev) forControlEvents:UIControlEventTouchUpInside];
    reConnectBtn.center =CGPointMake(bgView.frame.size.width/2, bgView.frame.size.height/2-20);
    [bgView addSubview:reConnectBtn];
    reConnectBtn.hidden = YES;;
    
    UIImageView *reconnImgV = [[UIImageView alloc] initWithFrame:CGRectMake(reConnectBtn.frame.size.width-14, 13, 14, 14)];
    reconnImgV.image = [UIImage imageNamed:@"reconnect"];
    [reConnectBtn addSubview:reconnImgV];
}

#pragma mark - 设备重连

- (void)reconnectDev
{
    hasReceiveData = NO;
    __weak typeof(reConnectBtn) weakReConnectBtn= reConnectBtn;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakReConnectBtn.hidden = YES;
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        self->KHJACTivityIndicatorView = [self getSPAActivity];
        [self->KHJACTivityIndicatorView startAnimating];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{

            WeakSelf
            int flag = self.myInfo.connectTimes < 3 ? 0 : 2;

            if (self.myInfo.isAPMode) {
                [self->bDevice.mDeviceManager disconnect];
                [self->bDevice.mDeviceManager connect:self.myInfo.deviceRealPwd withUid:self.myInfo.deviceUid flag:flag successCallBack:^(NSString *uidStr, NSInteger isSuccess) {
                    [weakSelf connectDevice:(int)isSuccess withUid:uidStr];
                } offLineCallBack:^{
                    [weakSelf connectofflineDevice];
                }];

            }
            else {
                [self->bDevice.mDeviceManager disconnect];
                [self->bDevice.mDeviceManager connect:self.myInfo.deviceRealPwd withUid:self.myInfo.deviceUid flag:flag successCallBack:^(NSString *uidStr, NSInteger isSuccess) {
                    [weakSelf connectDevice:(int)isSuccess withUid:uidStr];
                } offLineCallBack:^{
                    [weakSelf connectofflineDevice];
                }];
            }
        });
    });
}

//设备断开
- (void)connectofflineDevice
{
    __weak typeof(reConnectBtn) weakReConnectBtn= reConnectBtn;
    __weak typeof(glView) weakGlView= glView;
    self.myInfo.DeviceConnectState = [bDevice.mDeviceManager checkDeviceStatus];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [KHJHub shareHub].hud.hidden = YES;
        weakReConnectBtn.hidden = NO;
        weakGlView.hidden = YES;
    });
}

- (void)connectDevice:(int)success withUid:(NSString *)uidStr
{
    NSArray *arr = [uidStr componentsSeparatedByString:@","];
    uidStr = arr.firstObject;
    self.myInfo.DeviceConnectState = [bDevice.mDeviceManager checkDeviceStatus];
    WeakSelf
    if([uidStr isEqualToString:self.myInfo.deviceUid]) {
        if (success == 0) {
            
            isFirstInto = YES;
            CLog(@"连接设备成功");
            self.myInfo.connectTimes = 1;
            if (_conntimer) {
                dispatch_source_cancel(_conntimer);
            }
            [self startReciveVide];
            
            //注册监听
            [bDevice.mDeviceManager registerActivePushListener:^(int type, NSString *dString, NSString *uidStr) {
                [weakSelf backGetPushListenerState:type withDstring:dString];
            }];
            
            if (self.myInfo.isAPMode) {
                
                NSInteger y = 100000 +  (arc4random() % 100001);
                NSString * newPwdString = [NSString stringWithFormat:@"%ld",y];
                __weak typeof(newPwdString) weakNewPwd = newPwdString;
                [bDevice.mDeviceManager setPassword:bDevice.mDeviceInfo.devicePwd Newpassword:newPwdString withUid:uidStr returnCallBack:^(BOOL b) {
                    if (b) {
                        [[NSUserDefaults standardUserDefaults] setObject:weakNewPwd  forKey:@"APConnectPWD"];
                    }
                }];
            }
        }
        else if(success == -90) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CLog(@"设备离线");
                self->KHJACTivityIndicatorView = [self getSPAActivity];
                [self->KHJACTivityIndicatorView stopAnimating];
                [self->reConnectBtn setTitle:KHJLocalizedString(@"reConnected", nil) forState:UIControlStateNormal];
                self->reConnectBtn.hidden = NO;
            });
        }
        else {
            CLog(@"连接设备失败");
            __weak typeof(reConnectBtn)  weakReConnectBtn= reConnectBtn;

            if (success == -20009) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self->KHJACTivityIndicatorView = [self getSPAActivity];
                    [self->KHJACTivityIndicatorView stopAnimating];
                    [weakReConnectBtn setTitle:KHJLocalizedString(@"pwdError", nil) forState:UIControlStateNormal];
                    weakReConnectBtn.hidden = NO;
                    [weakSelf changeBottom1];
                });
                return;
            }
            
            if (self.myInfo.connectTimes < 3) {
                [self reconnectDev];
                self.myInfo.connectTimes ++;
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self->KHJACTivityIndicatorView = [self getSPAActivity];
                    [self->KHJACTivityIndicatorView stopAnimating];
                    [weakReConnectBtn setTitle:KHJLocalizedString(@"reConnected", nil) forState:UIControlStateNormal];
                    weakReConnectBtn.hidden = NO;
                    [weakSelf changeBottom1];
                });
            }
        }
    }
}
#pragma mark - 开关摄像头
- (void)openClick:(UISwitch *)sw
{
    WeakSelf
    if (sw.on) {
        hasReceiveData = NO;
        [bDevice.mDeviceManager setDeviceCameraStatusWithOpen:YES returnBlock:^(NSString *uidString, BOOL success) {
            [weakSelf backSetForceOpenCameraState:success];
            
        }];
        sw.hidden = YES;
    }
    else {
        [bDevice.mDeviceManager setDeviceCameraStatusWithOpen:NO  returnBlock:^(NSString *uidString,BOOL success) {
            [weakSelf backSetForceOpenCameraState:success];
        }];
    }
}
- (void)backSetForceOpenCameraState:(BOOL)success
{
    __weak typeof(switchView) wswitchView= switchView;
    __weak typeof(tipLabel) wtipLabel= tipLabel;
    __weak typeof(glView)  wglView=  glView;
    if (!success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            wswitchView.on = !wswitchView.on;
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.myInfo.isOpen = wswitchView.on;
        
        if(wswitchView.on){
            
            
            wtipLabel.hidden = YES;
            wglView.hidden = NO;
            if(self.myInfo.isOpen)
            {
                self->KHJACTivityIndicatorView = [self getSPAActivity];
                [self->KHJACTivityIndicatorView startAnimating];
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    
                    [self startReciveVide];
                });
            }
            
        }else{
            [self->bDevice.mDeviceManager startRecvVideo:NO withUid:self.myInfo.deviceUid reternBlock:^(BOOL k) {
                
            }];
        }
    });
}
#pragma mark - 设置界面
- (void)setRightBtn
{
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    but.frame =CGRectMake(0,0, 44, 44);
    [but setBackgroundImage:[UIImage imageNamed:@"Setting_icon"] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(inputSettingVC) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem  *barBut = [[UIBarButtonItem alloc]initWithCustomView:but];
    self.navigationItem.rightBarButtonItem = barBut;
}

- (void)inputSettingVC
{
    KHJSettingViewController *settingVctrl = [[KHJSettingViewController alloc] init];
    settingVctrl.uuidStr = self.myInfo.deviceUid;
    settingVctrl.deviceName = self.myInfo.deviceName;
    settingVctrl.myInfo = self.myInfo;
    [self.navigationController pushViewController:settingVctrl animated:YES];
}

- (void)setControlDevcieView
{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH/2.0 - 50, SCREENHEIGHT/2.0 - 50, 100, 100)];
    [self.view addSubview:contentView];
    
    UIButton *upBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    upBtn.titleLabel.font = [UIFont systemFontOfSize:30];
    [upBtn setTitle:@"⬆️" forState:UIControlStateNormal];
    [upBtn setFrame:CGRectMake(CGRectGetWidth(contentView.frame)/2.0 - 20, 0, 40, 40)];
    [upBtn addTarget:self action:@selector(upBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:upBtn];
    
    UIButton *downBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    downBtn.titleLabel.font = [UIFont systemFontOfSize:30];
    [downBtn setTitle:@"⬇️" forState:UIControlStateNormal];
    [downBtn setFrame:CGRectMake(CGRectGetWidth(contentView.frame)/2.0 - 20, CGRectGetHeight(contentView.frame) - 40, 40, 40)];
    [downBtn addTarget:self action:@selector(downBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:downBtn];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:30];
    [leftBtn setTitle:@"⬅️" forState:UIControlStateNormal];
    [leftBtn setFrame:CGRectMake(0, CGRectGetWidth(contentView.frame)/2.0 - 20, 40, 40)];
    [leftBtn addTarget:self action:@selector(leftBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:leftBtn];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:30];
    [rightBtn setTitle:@"➡️" forState:UIControlStateNormal];
    [rightBtn setFrame:CGRectMake(CGRectGetWidth(contentView.frame) - 40, CGRectGetWidth(contentView.frame)/2.0 - 20, 40, 40)];
    [rightBtn addTarget:self action:@selector(rightBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:rightBtn];
}

- (void)upBtnAction
{
    [bDevice.mDeviceManager setRun:1 withStep:MSTEP];
}

- (void)downBtnAction
{
    [bDevice.mDeviceManager setRun:2 withStep:MSTEP];
}

- (void)leftBtnAction
{
    [bDevice.mDeviceManager setRun:6 withStep:MSTEP];
}

- (void)rightBtnAction
{
    [bDevice.mDeviceManager setRun:3 withStep:MSTEP];
}

#pragma mark - 云台定时器

- (void)cancelOperater
{
    if (hImgView) {
        hImgView.image = nil;
        [hImgView removeFromSuperview];
    }
}

#pragma mark - glayer
- (OpenGLView20 *)getGLView
{
    if (glView == nil) {
        
        glView = [[OpenGLView20 alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH*9/16)];
    }
    return glView;
}
#pragma mark UIScrollViewDelegate
//返回需要缩放的视图控件 缩放过程中
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    if (self.player && self.player.view.hidden == NO) {
        return self.player.view;
    }else
        return glView;
}
//开始缩放
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
    NSLog(@"开始缩放");
}
//结束缩放
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    NSLog(@"结束缩放");
}
//缩放中
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    //     延中心点缩放
    if (scrollView.zoomScale < 1) {
        scrollView.zoomScale = 1;
        
    }
    CGFloat mScale = scrollView.zoomScale;
    CGFloat imageScaleWidth = mScale * SCREENWIDTH;
    CGFloat imageScaleHeight = mScale * (SCREENWIDTH*9/16);
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    CLog(@"scrollView.zoomScale = %f",mScale);
    
    if (self.player && self.player.view.hidden == NO) {
        imageY = floorf((self.player.view.frame.size.height- imageScaleHeight) / 2.0);
        imageX = floorf((self.player.view.frame.size.width - imageScaleWidth) / 2.0);
        self.player.view.frame = CGRectMake(imageX, imageY, imageScaleWidth, imageScaleHeight);
    }else{
        
        imageY = floorf((glView.frame.size.height- imageScaleHeight) / 2.0);
        imageX = floorf((glView.frame.size.width - imageScaleWidth) / 2.0);
        glView.frame = CGRectMake(imageX, imageY, imageScaleWidth, imageScaleHeight);
    }
}
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    //UIGestureRecognizerStateBegan意味着手势已经被识别
    if (gestureRecognizer.state ==UIGestureRecognizerStateBegan)
    {
        //手势发生在哪个view上
        UIView *piece = gestureRecognizer.view;
        //获得当前手势在view上的位置。
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        piece.layer.anchorPoint =CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        //根据在view上的位置设置锚点。
        //防止设置完锚点过后，view的位置发生变化，相当于把view的位置重新定位到原来的位置上。
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        piece.center = locationInSuperview;
    }
}
#pragma mark - 中间状态栏按钮
- (void)setStateView
{
    stateBgView = [self getStateBgView];
    [stateBgView setImage:[UIImage imageNamed:@"stateBgView3"]];

    [self setStateViewBtn];
}

- (void)setStateViewBtn
{
    for (int i = 0; i < 2; i++) {
        UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH/2.0*i, 2, SCREENWIDTH/2.0, 40)];
        button.tag = 110+i;
        [button setTitle:[self getDisAbleButtonImg:i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickStateBtn:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize: 15.0];
        [stateBgView addSubview:button];
    }
    stateBgView.userInteractionEnabled = YES;
}

#pragma mark - 中间状态按钮
- (void)clickStateBtn:(UIButton *)btn
{
    btn.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        btn.userInteractionEnabled = YES;
    });
    
    switch (btn.tag) {
        case 110:
        {
            //视频质量切换
            [self changeQualityClick];
        }
            break;
        case 111:
        {
            //录屏
            [self startRecodePhone:btn];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 改变中间状态栏状态

- (void)changeStateBgViewBtn
{
    for (int i = 0; i < 2; i++) {
        
        UIButton * button = [stateBgView viewWithTag:(110+i)];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [button setTitle:[self getButtonImg:i] forState:UIControlStateNormal];
        button.enabled = YES;
    }
}
- (void)changeStateBgViewBtn1
{
    int totalNum = 0;
    if(self.myInfo.isShare || [self.myInfo.deviceRemark intValue] == 1){
        totalNum = 4;
    }else{
        totalNum = 3;
    }
    for (int i = 0; i < totalNum; i++) {
        
        stateBgView = [self getStateBgView];
        UIButton * button  = [stateBgView viewWithTag:110+i] ;
        [button setTitle:[self getDisAbleButtonImg:i] forState:UIControlStateNormal];
        [button setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
        if (i == 0 || i ==1) {
            button.enabled = NO;
        }else{
            button.enabled = YES;
        }
    }
}
- (NSString *)setAbleForQuality
{
    switch (rQuality) {
        case 5:
            return  @"流畅";
            break;
        case 3:
            return  @"标清";
            break;
        case 1:
            return  @"高清";
            break;
        default:
            return  @"标清";
            break;
    }
}

- (NSString *)getDisAbleButtonImg:(int)tag
{
    NSString *string = @"";
    switch (tag) {
        case 0:
            string = [self setAbleForQuality];
            break;
        case 1:
            string = @"录屏";
            break;
        default:
            break;
    }
    return string;
}

- (NSString *)getButtonImg:(int)tag
{
    NSString *string = @"";
    switch (tag) {
        case 0:
            string = [self setAbleForQuality];
            break;
        case 1:
            string = @"录屏";
            break;
        default:
            break;
    }
    return string;
}
- (UIImageView *)getStateBgView
{
    if (stateBgView ==nil) {
        stateBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, bgView.frame.size.height+bgView.frame.origin.y, SCREENWIDTH, 44)];
        [self.view addSubview:stateBgView];
    }
    return stateBgView;
}

#pragma mark - 释放掉ijk播放器

- (void)releasePlayer
{
    if(self.player) {
        [self.player shutdown];
        self.player = nil;
    }
}

- (void)avPlayerMethod:(NSString *)urlPath with:(NSInteger)sec
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->reConnectBtn.hidden = YES;
    });
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_SILENT];
    
    _prePlayer = self.player;
    [self releasePlayer];
    IJKFFOptions *options   = [IJKFFOptions optionsByDefault];
    self.player             = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:urlPath] withOptions:options];
    self.player.view.frame  = bgView.bounds;
    currentSec              = sec;
    [self.player prepareToPlay];
    [self handleRebackPlayAudio];
}

- (void)handleRebackPlayAudio
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self changeBottom];
    });
    [self handleRepayAudio];
    if (!isRecAudio) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIButton * btn = (UIButton *)[self->bottomView viewWithTag:102];
            if (self->languageValue == -1) {
                [btn setBackgroundImage:[UIImage imageNamed:@"vediopage3"] forState:UIControlStateNormal];
            }
            else {
                [btn setBackgroundImage:[UIImage imageNamed:@"en-vediopage3"] forState:UIControlStateNormal];
            }
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIButton * btn = (UIButton *)[self->bottomView viewWithTag:102];
            if (self->languageValue == -1) {
                [btn setBackgroundImage:[UIImage imageNamed:@"vediopage3_press"] forState:UIControlStateNormal];
            }
            else {
                [btn setBackgroundImage:[UIImage imageNamed:@"en-vediopage3_press"] forState:UIControlStateNormal];
            }
        });
    }
}

- (void)handleRepayAudio
{
    [[NSUserDefaults standardUserDefaults] setBool:isRecAudio forKey:@"startRecvAudio"];
    [self reciveAudio];
}

- (void)stopPlayVideo:(NSString *)tFilename//停止播放视频，在按回放按钮的时候，需要重新接受直播视频
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (tFilename) {
            [self->bDevice.mDeviceManager playSDVideo:tFilename withStart:NO seekTo:0 withUid:self.myInfo.deviceUid returnBlock:^(int mTotal, int mCurrentP) {
            }];
        }
    });
}

#pragma mark - TimeLineDelegate代理方法

- (void)LineBeginMove
{
    [self stopPlayVideo:nil];
}

//监控播放进度方法
- (void)avkTimer
{
    
}

#pragma mark - IJKMoviePlayer stateCallBack

//播放完成
- (void)playerItemDidPlayToEnd
{
    
}

- (void)loadStateDidChange:(NSNotification*)notification
{
    IJKMPMovieLoadState loadState = _player.loadState;
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {//删除掉之前的ijk播放器界面
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}
- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded://播放完成
        {
            [self playerItemDidPlayToEnd];
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
        }
            break;
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            break;
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    switch (_player.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {//
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(![self->vScroll.subviews containsObject:self.player.view]){
                    
                    [self->vScroll addSubview:self.player.view];
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [self.prePlayer.view removeFromSuperview];
                    self->glView.hidden = YES;
                });
            });
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}
#pragma mark Install Movie Notifications
/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
}

#pragma mark Remove Movie Notification Handlers

- (void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
}

#pragma mark - 加载所有界面

- (UIScrollView *)getVScrollView
{
    if (vScroll == nil) {
        vScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH*9/16)];
        vScroll.minimumZoomScale = 1.0f;
        vScroll.maximumZoomScale = 3.0f;
        vScroll.zoomScale= 1;
        vScroll.bounces = NO;
        vScroll.backgroundColor = [UIColor blackColor];
        vScroll.showsVerticalScrollIndicator = NO;
        vScroll.showsHorizontalScrollIndicator = NO;
    }
    return vScroll;
}

- (UIView *)getBgView
{
    if (bgView == nil) {
        bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH*9/16)];
        bgView.backgroundColor = [UIColor blackColor ];
        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgView)];
        [bgView addGestureRecognizer:tapG];
    }
    return bgView;
}

- (void)setVedioView
{
    bgView = [self getBgView];
    vScroll = [self getVScrollView];
    [bgView addSubview:vScroll];
    [self.view addSubview:bgView];
    [self addGestureForBgView];
    //给bgView增加水波效果
    if (self.myInfo.isOpen) {
        KHJACTivityIndicatorView = [self getSPAActivity];
        [KHJACTivityIndicatorView startAnimating];
    }
    glView          = [self getGLView];
    glView.hidden   = NO;
    [vScroll addSubview:glView];
    recodeLabel     =  [self getRecodeLabel];
    [bgView addSubview:recodeLabel];
    [self setSwitchView];
}

- (void)tapBgView
{
    popView.hidden = YES;
    if (isHengPin) {
        bottomView.hidden = !bottomView.hidden;
        hBackView.hidden = !hBackView.hidden;
        stateBgView.hidden = YES;
    }
    else {
        bottomView.hidden = NO;
        stateBgView.hidden = NO;
        hBackView.hidden = YES;
    }
}
#pragma mark -addGestureForBgView
- (void)addGestureForBgView
{
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipes:)];
    left.direction=UISwipeGestureRecognizerDirectionLeft;
    [vScroll addGestureRecognizer:left];
    
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipes:)];
    right.direction=UISwipeGestureRecognizerDirectionRight;
    [vScroll addGestureRecognizer:right];
    
    UISwipeGestureRecognizer *up = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipes:)];
    up.direction=UISwipeGestureRecognizerDirectionUp;
    [vScroll addGestureRecognizer:up];
    
    UISwipeGestureRecognizer *down = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipes:)];
    down.direction=UISwipeGestureRecognizerDirectionDown;
    [vScroll addGestureRecognizer:down];
}

- (void)handleSwipes:(UISwipeGestureRecognizer *)recognizer
{
    BOOL isHorGestRev = [[NSUserDefaults standardUserDefaults] boolForKey:@"isHorGestRev"];
    BOOL isVerGestRev = [[NSUserDefaults standardUserDefaults] boolForKey:@"isVerGestRev"];
    
    if (!self.myInfo.isShare &&[self.myInfo.deviceRemark intValue] != 1) {
        
        return;
    }
    if(recognizer.direction==UISwipeGestureRecognizerDirectionLeft){
        CLog(@"向左边滑动了!!!!!!");
        if(!isHorGestRev){
            [bDevice.mDeviceManager setRun:6 withStep:MSTEP];
        }else{
            [bDevice.mDeviceManager setRun:3 withStep:MSTEP];
        }

    }else if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {

        if(!isHorGestRev){
            [bDevice.mDeviceManager setRun:3 withStep:MSTEP];
        }else{
            [bDevice.mDeviceManager setRun:6 withStep:MSTEP];
        }
        CLog(@"向右边滑动了!!!!!!");
    }else if(recognizer.direction == UISwipeGestureRecognizerDirectionUp) {

        if(!isVerGestRev){
            [bDevice.mDeviceManager setRun:1 withStep:MSTEP];

        }else{
            [bDevice.mDeviceManager setRun:2 withStep:MSTEP];
        }
        CLog(@"向上边滑动了!!!!!!");
    }else if (recognizer.direction == UISwipeGestureRecognizerDirectionDown) {
        if(!isVerGestRev){
            [bDevice.mDeviceManager setRun:2 withStep:MSTEP];
        }else{
            [bDevice.mDeviceManager setRun:1 withStep:MSTEP];
        }
        CLog(@"向下边滑动了!!!!!!");
    }
}

#pragma mark - updateDevName

- (void)updateDevName:(NSNotification *)note
{
    __block NSString *ss = note.object;
    WeakSelf
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.myInfo.deviceName = ss;
        weakSelf.title = ss;
        [weakSelf settitleName];
    });
}

- (UILabel *)getRecodeLabel
{
    if (recodeLabel == nil) {
        //录制时间显示
        recodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH-60-10, 0, 60, 22)];
        recodeLabel.backgroundColor = [UIColor clearColor];
        recodeLabel.textColor = [UIColor whiteColor];
        recodeLabel.hidden = YES;
        recodeLabel.textAlignment = NSTextAlignmentRight;
        recodeLabel.font  = [UIFont fontWithName:@"Helvetica Neue" size:12.f];//解决数字宽度不一样
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 7, 8, 8)];
        imgV.image = [UIImage imageNamed:@"recodeRound"];
        [recodeLabel addSubview:imgV];
    }
    return recodeLabel;
}

- (void)changeQualityClick
{
    CLog(@"changeQualityClick");
    popView = [self getPopView];
    if ([self.view.subviews containsObject:popView]) {
        popView.hidden = !popView.hidden;
    }
    else {
        [self.view addSubview:popView];
        [self.view bringSubviewToFront:popView];
    }
}

- (UIImageView *)getMicImageV
{
    if (micImageV == nil) {
        micImageV = [[UIImageView alloc] initWithFrame:CGRectMake(SCREENWIDTH-64, bottomView.frame.origin.y-100-20 , 65, 62)];
        micImageV.image = [UIImage imageNamed:@"microphone0"];
    }
    return micImageV;
}

#pragma mark - 设置底部按钮

- (UIView *)getBottomLine
{
    if (bottomLine ==nil) {
        bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 1)];
        bottomLine.backgroundColor = ssRGB(230, 230, 230);
    }
    return bottomLine;
}

- (void)seBottomButton
{
    //定义底部4个按钮,有三种状态，不可选，可选，点击。
    CGFloat cHeight = 48;
    CGFloat bbHeight = 60;
    
    CGFloat cY = (bbHeight-cHeight)/2;
    bottomView = [self getBottomView];
    bottomLine = [self getBottomLine];
    if (![bottomView.subviews containsObject:bottomLine]) {
        [bottomView addSubview:bottomLine];
    }
    [self.view addSubview:bottomView];
    
    micImageV = [self getMicImageV];
    [self.view addSubview:micImageV];
    micImageV.hidden = YES;
    
    for (int i = 0; i < 3; i++) {
        
        UIButton *btn   = [UIButton buttonWithType:UIButtonTypeCustom];
        NSInteger space = (bottomView.frame.size.width - 3 * cHeight)/4;
        btn.frame       = CGRectMake(space*(i + 1) + cHeight * i, cY, cHeight, cHeight);
        
        btn.tag = 100 + i;
        if (i == 0 ) {
            btn.backgroundColor = [UIColor orangeColor];
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            [btn setTitle:KHJLocalizedString(@"Photo", nil) forState:UIControlStateNormal];
        }
        else if (i == 1) {
            btn.backgroundColor = [UIColor orangeColor];
            btn.titleLabel.font = [UIFont systemFontOfSize:11];
            [btn setTitle:KHJLocalizedString(@"speak", nil) forState:UIControlStateNormal];
        }
        else if (i == 2) {
            btn.backgroundColor = [UIColor orangeColor];
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            [btn setTitle:KHJLocalizedString(@"listence", nil) forState:UIControlStateNormal];
            [btn setTitle:KHJLocalizedString(@"listening", nil) forState:UIControlStateSelected];
        }
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        if (i != 2) {
            [btn addTarget:self action:@selector(clickBtn1:) forControlEvents:UIControlEventTouchDown];
        }
        [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpOutside];
        [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:btn];
    }
}

- (UIView *)getBottomView
{
    if (!bottomView) {
        CGFloat bbHeight = 60;
        CGFloat gg = Height_NavBar;
        CGFloat ff = Height_TabBar;
        CGFloat yy = 0;
        if (IS_IPHONE_X) {
            
            yy = SCREENHEIGHT-gg-ff;
        }else{
            yy = SCREENHEIGHT-64-bbHeight;
        }
        bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, yy, SCREENWIDTH, bbHeight)];
        //        bottomView.backgroundColor = UIColor.purpleColor;
        bottomView.clipsToBounds = YES;
    }
    return bottomView;
}
#pragma mark - clickBtnForBottom
- (void)clickBtn1:(UIButton *)btn//对讲按钮
{
    if(btn.tag == 101){
        [btn setTitle:@"正在说话" forState:UIControlStateNormal];
        isIntoTalk = isRecAudio;
        if (isRecAudio == YES) {
            isRecAudio = NO;
            CLog(@"reciveAudio .....");
            [self reciveAudio];
        }
        isSendAudio = NO;
        CLog(@"sendAudio  ....");
        [self sendAudio];
    }
    else if(btn.tag == 100) {
        
    }
}
- (void)clickBtn:(UIButton *)btn
{
    CLog(@"[btn isSelected]== %ld",(long)[btn isSelected]);
    switch (btn.tag) {
        case 100:
        {
            btn.enabled = NO;
            // 截图保存到手机端
            [self screenShort:btn];
            CLog(@"点击了拍照按钮");
            btn.enabled = YES;
        }
            break;
        case 101://设备播放手机音频
        {
            btn.enabled = NO;
            [btn setTitle:@"按键说话" forState:UIControlStateNormal];
            [self sendAudio];
            
            if (isIntoTalk) {
                isRecAudio = !isRecAudio;
                [self reciveAudio];
            }

            btn.enabled = YES;
        }
            break;
        case 102://获取设备音频
        {
            btn.enabled = NO;
            isRecAudio = !isRecAudio;
            btn.selected = isRecAudio;
            [self reciveAudio];

            btn.enabled = YES;
        }
            break;
        default:
            break;
    }
}

- (void)downLoadCloudVedio:(UIButton *)btn//下载云存储
{
    CLog(@"downLoadCloudVedio");
}
- (void)realStopRecord
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [self->bDevice.mDeviceManager startSendAudio:NO];
    });
}
- (void)sendAudio
{
    if (isSendAudio) {// 
        //定时器不断更新
        if (stopRecordTimer) {
            [stopRecordTimer invalidate];
            stopRecordTimer = nil;
        }
        [bDevice.mDeviceManager delayStopRerord:YES];
        stopRecordTimer = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(realStopRecord) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:stopRecordTimer forMode:NSRunLoopCommonModes];
        if (micImageV) {
            micImageV.hidden =YES;
        }
    }
    else {
        if (stopRecordTimer) {
            [stopRecordTimer invalidate];
            stopRecordTimer = nil;
        }
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self->bDevice.mDeviceManager startSendAudio:YES];
            [self->bDevice.mDeviceManager delayStopRerord:NO];
        });
    }
    isSendAudio = !isSendAudio;
}

// 是否播放音频
- (void)reciveAudio
{
    if (!isRecAudio) {//
        [bDevice.mDeviceManager isPlayRecvAudio:NO];
        isCheckInitOpenAudio = NO;
    }
    else {
        [bDevice.mDeviceManager isPlayRecvAudio:YES];
        isCheckInitOpenAudio = YES;
    }
}

- (void)startRecodePhone:(UIButton *)btn//手机录制
{
    if (isRecordVideo) {//停止录制视频
        recodeLabel.hidden = YES;
        [self hideTime];
        // path 视频路径
        NSString *filePath = [[[KHJHelpCameraData sharedModel] getTakeVideoDocPath] stringByAppendingPathComponent:[[KHJHelpCameraData sharedModel] getVideoNameWithType:@"mp4"]];
        [bDevice.mDeviceManager startRecordMp4:NO path:filePath];
        [self deleteLittleVedio];
        btn.userInteractionEnabled = YES;
    }
    else {
        [self showTime];
        // path 视频路径
        NSString *filePath = [[[KHJHelpCameraData sharedModel] getTakeVideoDocPath] stringByAppendingPathComponent:[[KHJHelpCameraData sharedModel] getVideoNameWithType:@"mp4"]];
        [bDevice.mDeviceManager startRecordMp4:YES path:filePath];
        [self clickTime:btn];
    }
    isRecordVideo = !isRecordVideo;
}
- (void)deleteLittleVedio//需要排序，返回的不是倒序的
{
    
}

- (void)hideTime
{
    recodeLabel.hidden = YES;
    recodeLabel.text = @"";
    if (_recordMP4timer) {
        dispatch_source_cancel(_recordMP4timer);//关闭倒计时
    }
}
- (void)clickTime:(UIButton *)btn
{
    __block NSInteger tTimerSecond = 0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t clickTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(clickTimer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0); // 每--秒执行一次
    CLog(@"clickTimer1");
    dispatch_source_set_event_handler(clickTimer, ^{
        if (tTimerSecond > 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                btn.userInteractionEnabled = YES;
                CLog(@"clickTimer3");
                dispatch_source_cancel(clickTimer);//关闭倒计时
            });
            CLog(@"clickTimer2");
        }
        tTimerSecond++;
    });
    dispatch_resume(clickTimer);
}
- (void)showTime
{
    recodeLabel = [self getRecodeLabel];
    recodeLabel.hidden = NO;
    [bgView bringSubviewToFront:recodeLabel];
    totalTimerSecond = 0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _recordMP4timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_recordMP4timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0); // 每秒执行一次
    
    __weak typeof(recodeLabel) weakRecodeLabel = recodeLabel;
    dispatch_source_set_event_handler(_recordMP4timer, ^{
        
        int hour = self->totalTimerSecond / 3600;
        int min  = (self->totalTimerSecond - hour * 3600) / 60;
        int sec  = self->totalTimerSecond - hour * 3600 - min * 60;
        self->totalTimerSecond ++;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakRecodeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, min, sec];
        });
    });
    dispatch_resume(_recordMP4timer);
}
- (UIImage *)snapsHotView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size,YES,[UIScreen mainScreen].scale);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


//videoPath为视频下载到本地之后的本地路径
- (void)saveVideo:(NSString *)videoPath{
    
    PHAssetCollection *desCollection;
    PHFetchResult <PHAssetCollection*>*result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collect in result) {
        desCollection = collect;
        NSLog(@"%@",collect.localizedTitle);
    }
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"KHJCloudVedio"];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            
            NSLog(@"创建相册成功!");
        }
    }];
    __block PHObjectPlaceholder *placeholderAsset=nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest*changeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL URLWithString: videoPath]];
        placeholderAsset = changeRequest.placeholderForCreatedAsset;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            
            PHAsset *asset = [[PHAsset fetchAssetsWithLocalIdentifiers:@[placeholderAsset.localIdentifier] options:nil] lastObject];
            
            [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:desCollection] addAssets:@[asset]];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIButton *btn = (UIButton *)[self->bottomView viewWithTag:101];
                btn.enabled = YES;
            });
            if (success) {
                NSLog(@"存入相册成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[KHJToast share] showToastActionWithToastType:_SuccessType
                                                      toastPostion:_CenterPostion
                                                               tip:@""
                                                           content:KHJLocalizedString(@"CloudDownloadFinished", nil)];
                    
                });
            }
        }];
    }];
}
//保存视频完成之后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"保存视频失败%@", error.localizedDescription);
    }
    else {
        NSLog(@"保存视频成功");
    }
}

- (void)screenShort:(UIButton *)btn
{
    // 获取截图 screenImage
    UIImage *screenImage = [self snapsHotView:bgView];
    CLog(@"screenImage size = %@",NSStringFromCGSize(screenImage.size));
}

#pragma mark - 获取设备开关状态

- (void)getForceOpenCamera
{
    WeakSelf
    [bDevice.mDeviceManager getDeviceCameraStatus:^(NSString *uidString, int success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf handleDevOpenState:success];
        });
    }];
}
-(void)backGetForceOpenCameraState:(int)success
{
    if (_conntimer) {
        dispatch_source_cancel(_conntimer);
    }
    [self handleDevOpenState:success];
}
- (void)handleDevOpenState:(int)success
{
    __weak typeof(switchView) weakSwitchView= switchView;
    __weak typeof(tipLabel) weakTipLabel= tipLabel;
    glView = [self getGLView];
    __weak typeof(glView) weakGlview= glView;
    WeakSelf
    if(success == 1){
        CLog(@"设备状态222：开 %d",success);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            weakTipLabel.hidden = YES;
            weakSwitchView.hidden = YES;
            weakGlview.hidden = NO;
            weakSelf.myInfo.isOpen = YES;
        });
        
    }else if(success == 0){
        
        CLog(@"设备状态：关 %d",success);
        dispatch_async(dispatch_get_main_queue(), ^{
            weakTipLabel.text = KHJLocalizedString(@"deviceClosed", nil);
            weakTipLabel.textColor = UIColor.whiteColor;
            weakSelf.myInfo.isOpen = NO;
            weakTipLabel.hidden = NO;
            weakGlview.hidden = YES;
            [self changeBottom1];
            [self changeStateBgViewBtn1];
            
        });
    }
}
#pragma mark - 所有开启接受视频数据,开启视频同时开启音频
- (void)startReciveVide
{
    isFirstInto = YES;
    bDevice.mDeviceManager.glView = [self getGLView];
    [bDevice.mDeviceManager isPlayRecvAudio:NO];
    BOOL ret = [bDevice.mDeviceManager startRecvVideo:YES withUid:self.myInfo.deviceUid reternBlock:^(BOOL k) {
        
        [self videoDataBackKey:k];
    }];
    [bDevice.mDeviceManager startRecvAudio:YES];
    hasReceiveData = NO;
    dispatch_async(dispatch_get_main_queue(), ^{

        [self startTimerWithSeconds:6 endBlock:^{
            CLog(@"进入重连设备");
            [self reconnectDev];
        }];
    });
    if(ret) {
        CLog(@"放入队列成功");
    }else{
        CLog(@"设备不在线");
    }
}
#pragma mark - 得到视频质量
- (void)getVedioQuality{
    
    rQuality = 0;
    rQuality = [bDevice.mDeviceManager getVideoQuality];
    UIButton *bbtn = [stateBgView viewWithTag:110];
        [bbtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    bbtn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    
    CLog(@"视频质量 == %d",rQuality);
    switch (rQuality) {
        case 5:
        {
            [bbtn setTitle:@"流畅" forState:UIControlStateNormal];
        }
            break;
        case 3:
        {
            [bbtn setTitle:@"标清" forState:UIControlStateNormal];
        }
            break;
        case 1:
        {
            [bbtn setTitle:@"高清" forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 切换视频质量
- (UIView *)getPopView
{
    if (!popView) {
        NSArray *arr = [NSArray arrayWithObjects:@"HD",@"SD",@"LD", nil];
        popView = [[UIView alloc] initWithFrame:CGRectMake(30, bgView.frame.origin.y+ bgView.frame.size.height-120-10  , 148, 120)];
        popView.backgroundColor = bgVCcolor;
        popView.clipsToBounds = YES;
        popView.layer.cornerRadius = 5;
        popView.layer.borderWidth = 0.5;
        popView.layer.borderColor = UIColor.lightGrayColor.CGColor;
        
        for (int i = 0; i<3; i++) {
            
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, (40+1)*i, popView.frame.size.width, 40)];
            btn.tag = 200+i;
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            btn.titleLabel.font = [UIFont systemFontOfSize:16];
            [btn setTitle:[NSString stringWithFormat:@"  %@",KHJLocalizedString([arr objectAtIndex:i], nil)] forState:UIControlStateNormal];
            [btn setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(clickMode:) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = UIColor.whiteColor;
            [popView addSubview:btn];
            
        }
    }
    return popView;
}
- (void)clickMode:(UIButton *)btn//切换清晰度
{
    WeakSelf
    switch (btn.tag) {
        case 200:
        {
            [bDevice.mDeviceManager setVideoQuality:KHJVideoQualityMax returnBloc:^(BOOL success) {
                
                [weakSelf successCallbackForSetVideoQuality:success];
            }];
            [btn setTitle:@"高清" forState:UIControlStateNormal];
            rQuality = 1;
        }
            break;
        case 201:
        {
            [bDevice.mDeviceManager setVideoQuality:KHJVideoQualityMiddle returnBloc:^(BOOL success) {
                [weakSelf successCallbackForSetVideoQuality:success];

            }];
            [btn setTitle:@"标清" forState:UIControlStateNormal];
            rQuality = 3;
        }
            break;
        case 202:
        {
            [bDevice.mDeviceManager setVideoQuality:KHJVideoQualityMin returnBloc:^(BOOL success) {
                [weakSelf successCallbackForSetVideoQuality:success];

            }];
            [btn setTitle:@"流畅" forState:UIControlStateNormal];
            rQuality = 5;
        }
            break;
        default:
            break;
    }
    popView.hidden = YES;
}
- (void)successCallbackForSetVideoQuality:(BOOL)success
{
    if (success) {
        CLog(@"设置视频质量成功");
        
    }else{
        CLog(@"设置视频质量失败");
        [self getVedioQuality];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_ErrorType
                                              toastPostion:_CenterPostion
                                                       tip:KHJLocalizedString(@"tips", nil)
                                                   content:KHJLocalizedString(@"setFail", nil)];
        });
    }
}
#pragma mark - 视频数据回调-KHJDeviceManagerDelegate

//解码数据回调,网络延时收不到数据，6s后重连
- (void)videoDataBackKey:(BOOL)key
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self->glView.hidden == YES){
            
            self->glView.hidden = NO;
            [self->vScroll bringSubviewToFront:self->glView];
        }
    });
    WeakSelf
    __weak typeof(vScroll) WvScroll= vScroll;
    __weak typeof(reConnectBtn) wreConnectBtn= reConnectBtn;
    __block BOOL isHP = isHengPin;
    if (key) {
        
        hasReceiveData = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self startTimerWithSeconds:6 endBlock:^{
                CLog(@"进入重连设备");
                [self reconnectDev];
            }];
        });
        if (isFirstInto) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf getVedioQuality];
            });
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf changeStateBgViewBtn];
                [weakSelf changeBottom];
                self->KHJACTivityIndicatorView = [self getSPAActivity];
                [self->KHJACTivityIndicatorView stopAnimating];
            });
            isFirstInto = NO;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!isHP) {
                if (wreConnectBtn.hidden == NO) {
                    wreConnectBtn.hidden = YES;
                }
            }
            WvScroll.delegate= weakSelf;
        });
    }
}

#pragma mark - 改变底部按钮状态

- (void)changeBottom
{
    for (int i = 0; i < 3; i++) {
        UIButton *btn = [bottomView viewWithTag:100+i];
        bottomView.userInteractionEnabled = YES;
        
        btn.userInteractionEnabled = YES;
        btn.hidden = NO;

        if (i == 2 && isCheckInitOpenAudio) {
            
            BOOL isOpen =  [[NSUserDefaults standardUserDefaults] boolForKey:@"initSoundOpen"];//初始化声音开启
            if (isOpen && hasReceiveData) {
                [self clickBtn:btn];
            }
        }
    }
}

- (void)changeBottom1
{
    if (!self.myInfo.isOpen) {
        if (isShare) {
            switchView.hidden = NO;
            switchView.on = NO;
        }
        tipLabel.hidden = NO;
    }
    for (int i = 0; i <3; i++) {
        
        UIButton *btn = [bottomView viewWithTag:100+i];
        btn.userInteractionEnabled = NO;
    }
    [self hideTime];
    popView = [self getPopView];
    popView.hidden = YES;
    micImageV.hidden = YES;
}

#pragma mark - 设备监听返回

/**
 切换清晰度
 */
- (void)backGetPushListenerStateChangeQuality:(int)quality
{
    switch (quality) {
        case 5://流畅
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIButton *bbtn = [self->stateBgView viewWithTag:110];
                [bbtn setTitle:@"流畅" forState:UIControlStateNormal];
            });
        }
            break;
        case 3://标清
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIButton *bbtn = [self->stateBgView viewWithTag:110];
                [bbtn setTitle:@"标清" forState:UIControlStateNormal];
            });
        }
            break;
        case 1://高清
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIButton *bbtn = [self->stateBgView viewWithTag:110];
                [bbtn setTitle:@"高清" forState:UIControlStateNormal];
            });
        }
            break;
        default:
            break;
    }
}
- (void)backGetPushListenerState:(int)success withDstring:(NSString *)dString
{
    switch (success) {
        case 0:
            [self handleDevOpenState:success];
            break;
        case 1:
            [self handleDevOpenState:success];
            break;
        case 5://设备SD卡插拔 5
        CLog(@"设备SD卡插拔!");
            break;
        case 6:
        {
            int num = [dString intValue];
            [self backGetPushListenerStateChangeQuality:num];
        }
            break;
        default:
            break;
    }
}

- (void)changeBottomBtnFrame{
    
    for (int i = 0; i <3; i++) {
        UIButton *btn = [bottomView viewWithTag:100+i];
        //        bottomView.userInteractionEnabled = YES;
        CGFloat cHeight = 48;
        CGFloat bbHeight = 60;
        CGFloat cY = (bbHeight-cHeight)/2;
        NSInteger space = (bottomView.frame.size.height-3*cHeight)/4;
        btn.frame = CGRectMake(cY,space*(i+1)+cHeight*i, cHeight, cHeight);
    }
}
- (void)RedrawViewBottom
{
    CGFloat cHeight = 48;
    CGFloat cY =0;
    CGFloat bbHeight =60;
    if(isHengPin){
        
        bottomView.frame = CGRectMake(0, SCREENHEIGHT-bbHeight, SCREENWIDTH, bbHeight);
        bottomView.backgroundColor = UIColor.whiteColor;
        cY = (bbHeight-cHeight)/2;
        for (int i = 0; i <3; i++) {
            
            UIButton *btn = [bottomView viewWithTag:(100+i)];
            NSInteger space = (bottomView.frame.size.width-3*cHeight)/4;
            btn.frame = CGRectMake(space*(i+1)+cHeight*i,cY, cHeight, cHeight);
        }
    }
    else {
        
        cY = (bbHeight-cHeight)/2;
        CGFloat gg = Height_NavBar;
        CGFloat ff = Height_TabBar;
        CGFloat yy = 0;
        if (IS_IPHONE_X) {
            
            yy = SCREENHEIGHT-gg-ff;
        }else{
            yy = SCREENHEIGHT-64-bbHeight;
        }
        bottomView.frame =CGRectMake(0, yy, SCREENWIDTH, bbHeight);
        for (int i = 0; i <3; i++) {
            
            UIButton *btn = [bottomView viewWithTag:(100+i)];
            NSInteger space = (bottomView.frame.size.width-3*cHeight)/4;
            btn.frame = CGRectMake(space*(i+1)+cHeight*i,cY, cHeight, cHeight);
        }
    }
    micImageV.frame = CGRectMake(SCREENWIDTH-64, bottomView.frame.origin.y-100-20 , 65, 62);
}

#pragma mark - 进入前台

- (void)EnterForeground:(NSNotification *)note
{
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSTimeInterval interVal = [datenow timeIntervalSince1970];
    NSTimeInterval iTimer = [[NSUserDefaults standardUserDefaults] doubleForKey:@"testSleep1"];
    if ((interVal - iTimer)>40) {
        CLog(@"可以重连！");
        isNeedConnect = YES;
    }
    
    if (self.navigationController.topViewController == self) {
        
        CLog(@"EnterForeground");
        isFirstInto = YES;
        if (isNeedConnect) {
            
            [KHJDeviceManager reinitsocket];
            [self reconnectDev];
            isNeedConnect = NO;
            
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self->KHJACTivityIndicatorView = [self getSPAActivity];
            [self->KHJACTivityIndicatorView startAnimating];
            [self startReciveVide];
            
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (popView && popView.isHidden == NO) {
        popView.hidden = YES;
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight|UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures
{
    return UIRectEdgeBottom;
}

@end



















