//
//  NetSettingVController.m
//
//  网络设置
//  Network settings
//
//

#import "KHJNetSettingVController.h"
#import "NetCell.h"
#import "KHJAllBaseManager.h"
#import "ZQAlterField.h"
#import "KHJAddHotVController.h"

@interface KHJNetSettingVController ()<UITableViewDelegate,UITableViewDataSource>
{
    UILabel *showLabel1;
    UILabel *showLabel2;
    UILabel *showLabel3;
    /// 网络状态
    /// network status
    UILabel *networkTypeLab;
    UITableView     *mmTable;
    NSMutableArray  *mNetArray;
    UIView *backgroundView;
    UIView * popView;
    NSString *sWifiName;
    BOOL wifiMode;
}
@end

@implementation KHJNetSettingVController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeDataSource];
    [self customizeAppearance];
}

- (void)customizeDataSource
{
    mNetArray   = [NSMutableArray array];
    self.title  = KHJLocalizedString(@"networkSetting", nil);
    self.view.backgroundColor = bgVCcolor;
}

- (void)customizeAppearance
{
    [self setbackBtn];
    [self setRightButton];
    [self setHeader];
    [self setMyTable];
    // 获取当前连接模式
    // Get the current connection mode
    [self GetLickMode];
}

- (UIView *)getPopView
{
    if (!popView) {
        popView = [[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH/2-70, 58, SCREENWIDTH/2+50, 80+1)];
        popView.backgroundColor     = bgVCcolor;
        popView.clipsToBounds       = YES;
        popView.layer.cornerRadius  = 5;
        popView.layer.borderWidth   = 0.5;
        popView.layer.borderColor   = UIColor.lightGrayColor.CGColor;
        
        UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, popView.frame.size.width, 40)];
        btn1.tag = 200 + 6;
        UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 40 + 1, popView.frame.size.width, 40)];
        btn2.tag = 200 + 7;

        btn1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

        btn1.titleLabel.font = [UIFont systemFontOfSize:16];
        btn2.titleLabel.font = [UIFont systemFontOfSize:16];

        [btn1 setTitle:[NSString stringWithFormat:@"    %@",KHJLocalizedString(@"typeWifi", nil)] forState:UIControlStateNormal];
        [btn2 setTitle:[NSString stringWithFormat:@"    %@",KHJLocalizedString(@"typeAp", nil)] forState:UIControlStateNormal];
        
        [btn1 setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
        [btn2 setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
        
        [btn1 addTarget:self action:@selector(clickMode:) forControlEvents:UIControlEventTouchUpInside];
        [btn2 addTarget:self action:@selector(clickMode:) forControlEvents:UIControlEventTouchUpInside];

        btn1.backgroundColor = UIColor.whiteColor;
        btn2.backgroundColor = UIColor.whiteColor;
        
        [popView addSubview:btn2];
        [popView addSubview:btn1];
    }
    return popView;
}

- (void)clickMode:(UIButton *)btn
{
    WeakSelf
    if (btn.tag == 206
        && ![networkTypeLab.text isEqualToString:KHJLocalizedString(@"typeWifi", nil)]) {//wifi模式
        wifiMode = YES;
        KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
        if (dDevice) {
            [dDevice.mDeviceManager switchingAp:NO returnBlock:^(BOOL success) {
                [weakSelf successCallbackSwitchingAp:success];
            }];
        }
        networkTypeLab.text = KHJLocalizedString(@"typeWifi", nil);
    }
    else if(btn.tag == 207 && ![networkTypeLab.text isEqualToString:KHJLocalizedString(@"typeAp", nil)]) {//热点模式

        wifiMode = NO;
        networkTypeLab.text = KHJLocalizedString(@"typeAp", nil);
        KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
        if (dDevice) {
            [dDevice.mDeviceManager switchingAp:YES returnBlock:^(BOOL success) {
                [weakSelf successCallbackSwitchingAp:success];
            }];
        }
    }
    [popView removeFromSuperview];
}

- (void)successCallbackSwitchingAp:(bool)success
{
    if (success) {
        CLog(@"切换成功 = %d",success);
        CLog(@"Switchover succeeded = %d",success);
        
        if (self->wifiMode) {
            // wifi模式
            // wifi mode
            dispatch_async(dispatch_get_main_queue(), ^{
                [[KHJToast share] showToastActionWithToastType:_SuccessType
                                                  toastPostion:_CenterPostion
                                                           tip:@""
                                                       content:KHJLocalizedString(@"changeSuccess", nil)];
            });
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSInteger index = [self.navigationController.viewControllers indexOfObject:self];
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index-3] animated:YES];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                KHJAddHotVController *adHotVC = [[KHJAddHotVController alloc] init];
                adHotVC.isAP = YES;
                [self.navigationController pushViewController:adHotVC animated:YES];
            });
        }
    }
    else {
        CLog(@"切换失败 = %d",success);
        CLog(@"Switchover failed = %d",success);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_ErrorType
                                              toastPostion:_CenterPostion
                                                       tip:KHJLocalizedString(@"tips", nil)
                                                   content:KHJLocalizedString(@"changeFail", nil)];
        });
    }
}
- (void)GetLickMode
{
    WeakSelf
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
    if (dDevice) {
        [dDevice.mDeviceManager getNetworkLinkStatus:^(int mode) {
            // mode = 0 : wifi 1: 网线 2:ap 3:失败
            // mode = 0: wifi 1: network cable 2: ap 3: failed
            [weakSelf backGetLinkMode:mode];
        }];
    }
    [self addShadow];
}

// 添加遮罩
// Add mask
- (void)addShadow
{
    backgroundView = [[UIView alloc] init];
    backgroundView.frame            = CGRectMake(0, 1,SCREENWIDTH,SCREENHEIGHT);
    backgroundView.backgroundColor  = [UIColor colorWithRed:(40/255.0f) green:(40/255.0f) blue:(40/255.0f) alpha:1.0f];
    backgroundView.alpha            = 0.6;
    [[[UIApplication sharedApplication] keyWindow] addSubview:backgroundView];
    
    [[KHJHub shareHub] showText:KHJLocalizedString(@"loading", nil) addToView:backgroundView type:_lightGray];

    // 设置超时，以防设备断开，一直请求

    // Set a timeout to prevent the device from disconnecting and keep requesting
    
    __weak typeof(backgroundView) weakVackgroundView = backgroundView;
    __weak typeof(networkTypeLab) weakNetworkTypeLab = networkTypeLab;
    [self startTimerWithSeconds:10 endBlock:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakNetworkTypeLab.text isEqualToString:@""]) {
                // 如无法获取网络模式，请检查设备是否掉线
                // If the network mode cannot be obtained, please check whether the device is offline
                [[KHJToast share] showOKBtnToastWith:KHJLocalizedString(@"tips", nil) content:KHJLocalizedString(@"checkNetworkStatus", nil)];
            }
            [KHJHub shareHub].hud.hidden = YES;
            [weakVackgroundView removeFromSuperview];
        });
    }];
}

- (void)backGetLinkMode:(int)state
{
    __block int sta = state;
    __weak typeof(backgroundView) weakVackgroundView = backgroundView;
    WeakSelf
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf handleState:sta];
        [weakVackgroundView removeFromSuperview];
    });
}

/**
 获取wifi列表
 Get wifi list
 */
- (void)getwifiList
{
    WeakSelf
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
    if (dDevice) {
        [dDevice.mDeviceManager listWifiAp:^(NSString *connectingWifiName) {
            [weakSelf backWifiConnectting:connectingWifiName];
        } returnBlock:^(NSMutableArray *mArray) {
            [weakSelf backListWifi:mArray];
        }];
    }
    [mNetArray removeAllObjects];
    [mmTable reloadData];
    showLabel3.text = @"";
    [self addShadow];
}
- (void)backListWifi:(NSArray *)wifiArray
{
    [mNetArray addObjectsFromArray:wifiArray];
    __weak typeof(mmTable) weakmmTable = mmTable;
    __weak typeof(backgroundView) weakVackgroundView = backgroundView;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [weakmmTable reloadData];
        [KHJHub shareHub].hud.hidden = YES;
        [weakVackgroundView removeFromSuperview];
    });
}
- (void)backWifiConnectting:(NSString *)wifiName
{
    __weak typeof(showLabel3) weakShowLabel3 = showLabel3;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakShowLabel3.text = wifiName;
    });
}

- (void)startTimerWithSeconds:(long)seconds endBlock:(void(^)())endBlock
{
    __block long timeout = seconds;
    dispatch_queue_t queue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    dispatch_source_t _timer =dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0,0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL,0),1.0*NSEC_PER_SEC,0);
    dispatch_source_set_event_handler(_timer, ^{
        if (timeout < 0) {
            dispatch_source_cancel(_timer);
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
    dispatch_resume(_timer);
}

- (void)setMyTable
{
    mmTable             = [[UITableView alloc] initWithFrame:CGRectMake(0, 88 + 10 + 1, SCREENWIDTH, SCREENHEIGHT - 165) style:UITableViewStylePlain];
    mmTable.delegate    = self;
    mmTable.dataSource  = self;
    mmTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:mmTable];
}

- (void)setHeader
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, SCREENWIDTH, 44*2 + 1)];
    [headView setBackgroundColor:[UIColor whiteColor]];
    headView.layer.borderWidth = 0.8;
    headView.layer.borderColor = bgVCcolor.CGColor;
    [self.view addSubview:headView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, SCREENWIDTH, 0.8)];
    lineView.backgroundColor = bgVCcolor;
    [headView addSubview:lineView];
    
    showLabel1              = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH/2, 44)];
    showLabel1.textColor    = [UIColor blackColor];
    showLabel1.text         = [NSString stringWithFormat:@"    %@",KHJLocalizedString(@"netMode", nil)];
    
    networkTypeLab               = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH/2, 0, SCREENWIDTH/2 - 60, 44)];
    networkTypeLab.textColor     = [UIColor blueColor];
    networkTypeLab.textAlignment = NSTextAlignmentRight;
    networkTypeLab.text = @"";
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMode)];
    networkTypeLab.userInteractionEnabled = YES;
    [networkTypeLab addGestureRecognizer:tap];
    
    UIImageView *imgV   = [[UIImageView alloc] initWithFrame:CGRectMake(SCREENWIDTH - 60, 0, 44, 44)];
    imgV.image          = [UIImage imageNamed:@"arrowdown"];
    [headView addSubview:imgV];
    [headView addSubview:networkTypeLab];
    
    showLabel2              = [[UILabel alloc] initWithFrame:CGRectMake(0, 44 + 1, SCREENWIDTH/2, 44)];
    showLabel2.textColor    = [UIColor blackColor];
    showLabel2.text         = [NSString stringWithFormat:@"    %@",KHJLocalizedString(@"ConnectedWifiName", nil)];

    showLabel3                  = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH/2, 44 + 1, SCREENWIDTH/2 - 20, 44)];
    showLabel3.textColor        = [UIColor blueColor];
    showLabel3.textAlignment    = NSTextAlignmentRight;
    [headView addSubview:showLabel1];
    [headView addSubview:showLabel2];
    [headView addSubview:showLabel3];
}

- (void)tapMode
{
    popView = [self getPopView];
    [self.view addSubview:popView];
}

- (void)setbackBtn
{
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    but.frame =CGRectMake(0,0, 66, 44);
    but.imageEdgeInsets = UIEdgeInsetsMake(0,-40, 0, 0);
    [but setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem  *barBut = [[UIBarButtonItem alloc]initWithCustomView:but];
    self.navigationItem.leftBarButtonItem = barBut;
}

- (void)setRightButton
{
    UIButton *changeVideo = [UIButton buttonWithType:UIButtonTypeCustom];
    changeVideo.frame = CGRectMake(0,0,44,44);
    [changeVideo setTitle:KHJLocalizedString(@"refresh", nil) forState:UIControlStateNormal];
    [changeVideo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [changeVideo addTarget:self action:@selector(reFreshData) forControlEvents:UIControlEventTouchUpInside];
    [changeVideo sizeToFit];
    UIBarButtonItem *informationCardItem = [[UIBarButtonItem alloc] initWithCustomView:changeVideo];
   
    self.navigationItem.rightBarButtonItem  = informationCardItem;
}

- (void)reFreshData//
{
    [self getwifiList];
}

- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return mNetArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"NetCell";
    NetCell *cell = (NetCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        
        cell = [[NetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = [mNetArray objectAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    NSString *wSSID =  [mNetArray objectAtIndex:indexPath.row];
    sWifiName = wSSID;
    [self showAlert:wSSID];
    
    
}
- (void)showAlert:(NSString *)wSSID
{

    UIAlertController *alertview=[UIAlertController alertControllerWithTitle:KHJLocalizedString(@"warning", nil) message:KHJLocalizedString(@"maybeDisconnectNetwork", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel=[UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *defult = [UIAlertAction actionWithTitle:KHJLocalizedString(@"commit", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self popPwdView:wSSID];
        });
    }];
    [alertview addAction:cancel];
    [alertview addAction:defult];
    [self presentViewController:alertview animated:YES completion:nil];
}
- (void)popPwdView:(NSString *)wSSID
{
    
    WeakSelf
    ZQAlterField *alertView = [ZQAlterField alertView];
    
    alertView.title = [NSString stringWithFormat:@"%@%@",KHJLocalizedString(@"changeWifi", nil),wSSID];
    alertView.placeholder = KHJLocalizedString(@"inputWifiPWD", nil);
    
    alertView.Maxlength = 20;//最大字符
    alertView.ensureBgColor = DeCcolor;
    [alertView ensureClickBlock:^(NSString *inputString) {
        [weakSelf changeConnectWifi:inputString];
        
    }];
    [alertView show];
}

- (void)changeConnectWifi:(NSString *)pwd
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[KHJHub shareHub] showText:@"" addToView:self.view type:_default];
    });
    WeakSelf
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
    if (dDevice) {
        [dDevice.mDeviceManager setWifiAp:sWifiName withPwd:pwd andType:1 returnBloc:^(BOOL success) {
            [weakSelf callbacksuccessSetWifiAp:success];
        }];
    }
}

- (void)callbacksuccessSetWifiAp:(bool)success
{
    if(success){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_SuccessType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"changeSuccess", nil)];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
        CLog(@"切换wifi成功");
        CLog(@"Switch wifi successfully");
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_WarningType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"changeFail", nil)];
        });
        CLog(@"切换wifi失败");
        CLog(@"Wifi switch failed");
    }
}
- (void)handleState:(int) state
{
    // 0 :wifi 1: 网线 2:ap(热点) 3:失败
    // 0: wifi 1: network cable 2: ap (hotspot) 3: failure
    switch (state) {
        case 0:
        {
            networkTypeLab.text = KHJLocalizedString(@"typeWifi", nil);
            [self getwifiList];
        }
            break;
        case 1:
        {
            networkTypeLab.text = KHJLocalizedString(@"typeLine", nil);
            [self getwifiList];
        }
            break;
        case 2:
        {
            networkTypeLab.text = KHJLocalizedString(@"typeAp", nil);

        }
            break;
        case 3:
        {
            [[KHJToast share] showToastActionWithToastType:_WarningType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"GetConnFail", nil)];
        }
            break;
        default:
            break;
    }
}
@end



















