//
//  DevieceViewController.m
//

#import <AVFoundation/AVFoundation.h>
#import "DevieceViewController.h"
#import "DeviceInfo.h"
#import "TCell.h"
#import "KHJVideoPlayViewController.h"
#import <KHJCameraLib/KHJCameraLib.h>

#import "Calculate.h"
#import "KHJAddDeviveTypeListVController.h"

#import <UserNotifications/UserNotifications.h>
#import <AdSupport/AdSupport.h>
#import "AppDelegate.h"
#import "UIDevice+TFDevice.h"
#import <AudioToolbox/AudioToolbox.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "FourthController/KHJSetWifiViewController.h"
#import "KHJAllBaseManager.h"
#import "KHJBaseDevice.h"

@interface DevieceViewController ()<UITableViewDelegate,UITableViewDataSource,clickProtoc>
{
    UITableView *mTable;
    UILabel *mLabel;
    UIImageView *boximagev;
    UIButton *addDevBtn;
    
    // 当前内存实体数组，已经加载到界面上的
    // The current memory entity array has been loaded on the interface
    NSMutableArray *deviceInfoArr;
    // 当前服务器请求的设备数组
    // Device array requested by the current server
    NSMutableArray *netDevInfoArr;
    
    UIView *backgroundView;
    
    NSString *deleteUID;
    BOOL isFirstInto;
    BOOL isFirstPresnt;
    UISwitch *currentSW;
    BOOL isAPMode;
    dispatch_source_t nTimer;
}

@end

@implementation DevieceViewController
// 网络请求下来的字典数组
// Dictionary array from the network request
@synthesize     dataArray;
// 是否需要刷新列表
// Do you need to refresh the list
@synthesize     isNeedRefreshList;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [UITabBar appearance].translucent = NO;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}
#pragma mark - 页面出现逻辑
- (instancetype)init
{
    self = [super init];
    if (self) {
        isNeedRefreshList   = YES;
        dataArray           = [[NSMutableArray alloc] initWithCapacity:0];
        deviceInfoArr       = [[NSMutableArray alloc] initWithCapacity:0];
        netDevInfoArr       = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)handleHotConnect:(NSNotification *)note
{
    [deviceInfoArr removeAllObjects];
    isAPMode = YES;
    if (!note.object || [note.object isEqualToString:@""]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleNODevice];
            [self->mTable reloadData];
        });
        return;
    }
    DeviceInfo *ddInfo = [[DeviceInfo alloc] init];
    ddInfo.deviceUid = note.object;
    ddInfo.isPtz = 1;
    ddInfo.isShare = YES;
    ddInfo.isAPMode = YES;
    ddInfo.isOpen = YES;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSString *pwd   =  [[NSUserDefaults standardUserDefaults] valueForKey:@"APConnectPWD"];
        if(pwd == nil || [pwd isEqualToString:@""]) {
            pwd = @"888888";
        }
        ddInfo.deviceRealPwd = pwd;

        KHJBaseDevice *bDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:ddInfo.deviceUid];
        if (!bDevice) {
            bDevice = [[KHJBaseDevice alloc] init];
            bDevice.mDeviceInfo = ddInfo;
            [bDevice.mDeviceManager creatCameraBase:ddInfo.deviceUid keyword:@""];
        }
        
        WeakSelf
        ddInfo.DeviceConnectState = [bDevice.mDeviceManager checkDeviceStatus];
        if (ddInfo.DeviceConnectState != 1) {
            
            [bDevice.mDeviceManager connect:pwd withUid:ddInfo.deviceUid flag:0 successCallBack:^(NSString *uidStr, NSInteger isSuccess) {
                [weakSelf connectDevice:(int)isSuccess withUid:uidStr];
            } offLineCallBack:^{
                
            }] ;
        }
    });
    [deviceInfoArr addObject:ddInfo];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self->mTable.hidden = NO;
        self->addDevBtn.hidden = YES;
        self-> mLabel.hidden = YES;
        self->boximagev.hidden = YES;
        [self->mTable reloadData];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.view.backgroundColor = bgVCcolor;
    self.navigationItem.title = KHJLocalizedString(@"deviceList", nil);
    self.automaticallyAdjustsScrollViewInsets = NO;
    isFirstInto         = YES;
    [self setRightButton];
    [self setMtable];
    [self setNoDeviceView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleHotConnect:) name:ap_Model_Noti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable:) name:@"hasDevice" object:nil];
    
    [self addDeviceTest];
}

- (void)addDeviceTest
{
    DeviceInfo *dInfo = [[DeviceInfo alloc] init];
    dInfo.devicePwd = @"888888";
    dInfo.deviceRealPwd = @"888888";
    dInfo.deviceUid = @"KHJ-233719-PVNDB";
    dInfo.isOpen = YES;
    dInfo.isShare = YES;
    
    KHJBaseDevice *bDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:@"KHJ-233719-PVNDB"];
    if (!bDevice) {
        bDevice             = [[KHJBaseDevice alloc] init];
        dInfo.isOpen        = YES;
        dInfo.deviceRealPwd = @"888888";
        bDevice.mDeviceInfo = dInfo;
        [bDevice.mDeviceManager creatCameraBase:@"KHJ-233719-PVNDB"
                                        keyword:@""];
        
        /* 创建摄像头对象，并加入到 全局变量 addKHJManager */
        /* Create a camera object and add it to the global variable addKHJManager */
        [[KHJAllBaseManager sharedBaseManager] addKHJManager:bDevice andKey:@"KHJ-233719-PVNDB"];
    }
    
    KHJVideoPlayViewController *vCtrl = [[KHJVideoPlayViewController alloc] init];
    vCtrl.isShare = dInfo.isShare;
    vCtrl.hidesBottomBarWhenPushed = YES;
    vCtrl.myInfo = dInfo;
    [self.navigationController pushViewController:vCtrl animated:YES];
}


- (void)refreshTable:(NSNotification *)note
{
    NSString *uid =note.object;
    [deviceInfoArr removeAllObjects];
    KHJBaseDevice *bdevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:uid];
    [deviceInfoArr addObject:bdevice.mDeviceInfo];
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [self->mTable reloadData];

    });
}
#pragma mark - setMtable
- (void)setMtable
{
    mTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64) style:UITableViewStylePlain];
    mTable.dataSource       = self;
    mTable.delegate         = self;
    mTable.separatorStyle   = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:mTable];
    mTable.estimatedRowHeight           = 0;
    mTable.estimatedSectionHeaderHeight = 0;
    mTable.estimatedSectionFooterHeight = 0;
}

- (void)setRightButton
{
    UIButton *addBut = [UIButton buttonWithType:UIButtonTypeCustom];
    addBut.frame = CGRectMake(0,0,44,44);
    [addBut addTarget:self action:@selector(addDeviceAction) forControlEvents:UIControlEventTouchUpInside];
    [addBut setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    UIBarButtonItem *settingBtnItem = [[UIBarButtonItem alloc] initWithCustomView:addBut];
    self.navigationItem.rightBarButtonItem  = settingBtnItem;
}

// 添加设备
// Add device
- (void)addDeviceAction
{
    KHJAddDeviveTypeListVController *adVc = [[KHJAddDeviveTypeListVController alloc] init];
    adVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:adVc animated:YES];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

#pragma mark - handleNODevice

- (void)handleNODevice
{
    [deviceInfoArr removeAllObjects];
    [mTable reloadData];
    mLabel.hidden = NO;
    boximagev.hidden = NO;
    addDevBtn.hidden = NO;
}

- (void) setNoDeviceView
{
    mLabel = [self getMlabel];
    boximagev = [self getBoxImageV];
    addDevBtn = [self getAddDevBtn];
    [self.view addSubview:mLabel];
    [self.view addSubview:boximagev];
    [self.view addSubview:addDevBtn];
    mLabel.hidden = YES;
    boximagev.hidden = YES;
    addDevBtn.hidden = YES;
    mLabel.center = CGPointMake(self.view.center.x,self.view.center.y-44);
    boximagev.center = CGPointMake(self.view.center.x, self.view.center.y-44-144/2-22);
    addDevBtn.center = CGPointMake(self.view.center.x, self.view.center.y-44+44);
}

- (UILabel *)getMlabel
{
    if (mLabel == nil ) {
        mLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 44)];
        mLabel.font = [UIFont systemFontOfSize:15];
        mLabel.text = KHJLocalizedString(@"noDevice", nil);
        mLabel.textAlignment = NSTextAlignmentCenter;
        mLabel.center = CGPointMake(SCREENWIDTH/2, SCREENHEIGHT/2);
    }
    return mLabel;
}
- (UIImageView *)getBoxImageV
{
    if (boximagev == nil) {
        
        boximagev = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 144)];
        
        boximagev.image = [UIImage imageNamed:@"home_tj"];
    }
    return boximagev;
}

- (UIButton *)getAddDevBtn
{
    if (addDevBtn == nil) {
        addDevBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 160, 44)];
        addDevBtn.layer.cornerRadius = 2;
        addDevBtn.layer.borderWidth = 0.5;
        addDevBtn.layer.borderColor = UIColor.darkTextColor.CGColor;
        [addDevBtn setTitle:KHJLocalizedString(@"addDevice", nil) forState:UIControlStateNormal];
        [addDevBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [addDevBtn addTarget:self action:@selector(addDeviceAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return  addDevBtn;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 240.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([deviceInfoArr count] != 0)
        return [deviceInfoArr count];
    else return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"identifier";
    TCell *cell;
    cell        = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell    = [[TCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.delegete = self;
    }
    cell.userInteractionEnabled = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    UILongPressGestureRecognizer *gest1 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(LongPressCell:)];
//    gest1.minimumPressDuration          = 0.4f;
//    [cell addGestureRecognizer:gest1];
    
    if ([deviceInfoArr count] != 0) {
        
        DeviceInfo *dInfo       = [deviceInfoArr objectAtIndex:indexPath.row];
        NSString *dName         = dInfo.deviceName;
        
        if ([dName isEqualToString:@""]) {
            dName               = dInfo.deviceUid;
        }
        cell.nikNameLab.text    = dName;
        if (dInfo.isAPMode) {
            CLog(@"AP模式");
            CLog (@"AP mode");
            cell.apLab.hidden   = NO;
        }
        else {
            CLog(@"非AP模式");
            CLog(@"non-AP mode");
            cell.apLab.hidden   = YES;
        }
        // 是否可以分享,变成开关按钮
        // Whether it can be shared and turned into a switch button
        if (dInfo.isShare ) {
            cell.swithV.hidden      = NO;
            cell.shareBtn.hidden    = YES;
        }
        else {
            cell.swithV.hidden      = YES;
            cell.shareBtn.hidden    = NO;
        }
        if (dInfo.isOpen) {
            cell.swithV.on          = YES;
        }
        else {
            cell.swithV.on          = NO;
        }
        cell.swithV.enabled         = YES;
        KHJBaseDevice *bDevice      = [[KHJAllBaseManager sharedBaseManager] searchForkey:dInfo.deviceUid];
        dInfo.DeviceConnectState    = [bDevice.mDeviceManager checkDeviceStatus];
        if (dInfo.DeviceConnectState == 0) {
            cell.ConnStatelab.text  = KHJLocalizedString(@"offline", nil);
        }
        else if(dInfo.DeviceConnectState == 2) {
            cell.ConnStatelab.text  = KHJLocalizedString(@"deviceConnecting", nil);
        }
        else {
            cell.ConnStatelab.text  = KHJLocalizedString(@"online", nil);
        }
        if (!cell.swithV.on) {
            cell.ConnStatelab.text  = KHJLocalizedString(@"deviceClosed", nil);
            cell.contentImageView.image = [UIImage imageNamed:@"content_bgView"];
            cell.playImageView.hidden   = YES;
        }
        else {
            UIImage *tImg = [self getMImage:dInfo.deviceUid];
            if (tImg) {
                cell.contentImageView.image = tImg;
            }
            else {
                cell.contentImageView.image = [UIImage imageNamed:@"video_background"];
            }
            cell.playImageView.hidden = NO;
        }
    }
    [cell.nikNameLab sizeToFit];
    [cell.ConnStatelab sizeToFit];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UIImage *)getMImage:(NSString *)uid
{
    NSString *path_document = NSHomeDirectory();
    NSString *pString       = [NSString stringWithFormat:@"/Documents/%@.png",uid];
    NSString *imagePath     = [path_document stringByAppendingString:pString];
    UIImage *getimage2      = [UIImage imageWithContentsOfFile:imagePath];
    return getimage2;
}

// 连接设备
// Connect the device

- (void)connectDev:(NSString *)uid andPwd:(NSString *)dPwd
{
    if (!dPwd   || [dPwd isEqualToString:@""] || !uid    || [uid isEqualToString:@""]) {
        return ;
    }
    WeakSelf
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        KHJBaseDevice *bDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:uid];
        [bDevice.mDeviceManager reConnect:dPwd withUid:uid flag:0 successCallBack:^(NSString *uidString, NSInteger isSuccess) {
            [weakSelf connectDevice:(int)isSuccess withUid:uidString];
        } offLineCallBack:^{
            
        }] ;
        
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceInfo *dInfo = [deviceInfoArr objectAtIndex:indexPath.row];
    NSString *uID = dInfo.deviceUid;
    KHJVideoPlayViewController *vCtrl = [[KHJVideoPlayViewController alloc] init];
    TCell *cell = (TCell *)[tableView cellForRowAtIndexPath:indexPath];
    if([dInfo.deviceName isEqualToString:@""])
        dInfo.deviceName = uID;
    vCtrl.isShare = dInfo.isShare;

    if (![cell.apLab isHidden]) {
        dInfo.isAPMode  = YES;
    }
    else {
        dInfo.isAPMode  = NO;
    }
    vCtrl.hidesBottomBarWhenPushed = YES;
    vCtrl.myInfo = dInfo;
    [self.navigationController pushViewController:vCtrl animated:YES];
}

- (void)connectDevice:(int)success withUid:(NSString *)uidStr
{
    WeakSelf
    // 连接成功
    // connection succeeded
    if (success == 0) {
        CLog(@"连接设备成功:%@",uidStr);
        CLog(@"Connected to device successfully:%@",uidStr);
        KHJBaseDevice *bDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:uidStr];
        [bDevice.mDeviceManager getDeviceCameraStatus:^(NSString *uidString, int success) {
            [weakSelf backGetForceOpenCameraState:success withUid:uidString];
        }];
  
        [bDevice.mDeviceManager getDeviceAlias:^(NSString *aliasName, NSString *uidString) {
            [weakSelf getDeviceAliasCallback:aliasName withUid:uidString];
        }];
    }
    else if(success == -90) {
        CLog(@"设备离线");
        CLog (@"device offline");
    }
    else {
        CLog(@"连接设备失败:%@",uidStr);
        CLog(@"Failed to connect to device: %@", uidStr);
        if (success != -20009) {
            success = 2;
        }
    }
    CLog(@"设备数组 = %@", deviceInfoArr);
    CLog(@"device array = %@", deviceInfoArr);
    for (DeviceInfo *dInfo in deviceInfoArr) {
        if ([dInfo.deviceUid isEqualToString:uidStr]) {
            if(success == 2) {
                //修改无限连接，只要不是-90和0的状态
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
                    [self connectDev:uidStr andPwd:dInfo.deviceRealPwd];
                });
            }
            else if(success == -20009) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   
                    [[KHJToast share] showToastActionWithToastType:_WarningType
                                                      toastPostion:_CenterPostion
                                                               tip:KHJLocalizedString(@"tips", nil)
                                                           content:KHJLocalizedString(@"devPwdError", nil)];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->mTable reloadData];
                });
            }
            break;
        }
    }
}

#pragma mark - 设备设置别名
#pragma mark-Device setting alias

- (void)handleDeviceAname:(NSString *)nameStr with:(NSString *)uidStr
{
    KHJBaseDevice *bDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:uidStr];
    [bDevice.mDeviceManager setDeviceAlias:nameStr returnBlock:^(BOOL success) {
        
    }];
}

- (void)getDeviceAliasCallback:(NSString *)name withUid:(NSString *)uidStr
{
    for (DeviceInfo *dInfo in deviceInfoArr) {
        if ([dInfo.deviceUid isEqualToString:uidStr]) {
            if (![dInfo.deviceName isEqualToString:name]) {
                [self handleDeviceAname:dInfo.deviceName with:uidStr];
            }
            break;
            
        }
    }
}



- (void)connectofflineDevice:(NSString *)uid
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->mTable reloadData];
    });
}

- (void)openClick:(UISwitch *)sw
{
    TCell *ce = (TCell *)sw.superview;
    currentSW = sw;
    NSIndexPath *indexP = [mTable indexPathForCell:ce];
    DeviceInfo *dInfo = [deviceInfoArr objectAtIndex:indexP.row];
    KHJBaseDevice *bDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:dInfo.deviceUid];

    sw.enabled = NO;
    CLog(@"dInof.connectState333 = %ld",(long)dInfo.DeviceConnectState);
    WeakSelf
    [bDevice.mDeviceManager setDeviceCameraStatusWithOpen:sw.on returnBlock:^(NSString *uidString, BOOL success) {
        [weakSelf backSetForceOpenCameraState:success withUid:uidString];
    }];
}

- (void)clickEditBtn:(UIButton *)btn {
    
}


- (void)shareClick:(UIButton *)btn {
    
}


#pragma mark - KHJDevice
- (void)backGetPushListenerState:(int)success withUid:(NSString *)uidStr
{
    for (DeviceInfo *dInfo in deviceInfoArr) {
        if ([dInfo.deviceUid isEqualToString:uidStr]) {
            KHJBaseDevice *bDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:dInfo.deviceUid];
            if(success == 1){
                CLog(@"设备状态 backGetPushListenerState：开 %d",success);
                CLog(@"device status backGetPushListenerState: open %d", success);
                dInfo.isOpen = YES;
            }
            else if(success == 0) {
                CLog(@"设备状态：关 %d",success);
                CLog(@"Device Status: Off %d", success);
                dInfo.isOpen = NO;
            }
            bDevice.mDeviceInfo = dInfo;
            break;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->mTable reloadData];
    });
}

- (void)backSetForceOpenCameraState:(BOOL)success withUid:(NSString *)uidStr
{
    if (success) {
        CLog(@"设备开关设置成功：%d",success);
        CLog(@"Device switch set successfully: %d", success);
        for (DeviceInfo *dInfo in deviceInfoArr) {
            if ([dInfo.deviceUid isEqualToString:uidStr]) {
                
                KHJBaseDevice *bDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:dInfo.deviceUid];
                
                dInfo.isOpen = !dInfo.isOpen;
                bDevice.mDeviceInfo = dInfo;
                break;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[KHJToast share] showToastActionWithToastType:_SuccessType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"setSuccess", nil)];
            [self->mTable reloadData];
            self->currentSW.enabled = YES;
            
        });
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[KHJToast share] showToastActionWithToastType:_ErrorType
                                              toastPostion:_CenterPostion
                                                       tip:KHJLocalizedString(@"tips", nil)
                                                   content:KHJLocalizedString(@"setFail", nil)];
            self->currentSW.enabled = YES;
        });
        CLog(@"设备开关设置失败：%d",success);
        CLog(@"Device switch setting failed: %d", success);
    }
}

- (void)backGetForceOpenCameraState:(int)success withUid:(NSString *)uidStr
{
    for (DeviceInfo *dInfo in deviceInfoArr) {
        if ([dInfo.deviceUid isEqualToString:uidStr]) {
            
            KHJBaseDevice *bDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:dInfo.deviceUid];
            
            if(success){
                CLog(@"设备状态1：开 %d",success);
                CLog(@"device status 1: open %d", success);
                dInfo.isOpen = YES;
            }
            else {
                CLog(@"设备状态1：关 %d",success);
                CLog(@"Device Status 1: Off %d", success);
                dInfo.isOpen = NO;
            }
            bDevice.mDeviceInfo = dInfo;
            break;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self->currentSW.enabled = YES;
        [self->mTable reloadData];
    });
}

@end











