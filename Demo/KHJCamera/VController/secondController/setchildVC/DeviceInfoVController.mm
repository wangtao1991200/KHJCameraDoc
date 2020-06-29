//
//  DeviceInfoVController.m
//
//
//
//
//

#import "DeviceInfoVController.h"
#import "KHJAllBaseManager.h"
#import "ZQAlterField.h"
#import "DeviceInfo.h"
#import "CopyLabel.h"

#define CellHeigth (44)

@interface DeviceInfoVController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *mTable;
    NSArray *mPArr;
    NSArray *mTArr;
    
    // 存储显示信息
    // Store display information
    NSMutableDictionary * showDic;
    UIImageView *verImageV;
    // 是否有新的固件版本
    // Is there a new firmware version
    BOOL isNeedVer;
    // 服务端固件版本号
    // Server firmware version number
    NSString *verString;
    UILabel *devNameLab;
    // 定时器
    // Timer
    dispatch_source_t _conntimer;

    // 设备是否掉线
    // Whether the device is offline
    bool deviceDropInfo;
}
@end

@implementation DeviceInfoVController

- (void)viewDidLoad
{
    [super viewDidLoad];
    isNeedVer = NO;
    self.title  = KHJLocalizedString(@"deviceInfo", nil);
    self.view.backgroundColor = bgVCcolor;
    [self setbackBtn];
    [self setRightBtn];
    
    mPArr = [[NSArray alloc] initWithObjects:KHJLocalizedString(@"deviceNickname", nil),KHJLocalizedString(@"deviceID", nil),KHJLocalizedString(@"设备类型", nil),KHJLocalizedString(@"firmwareVersion", nil),KHJLocalizedString(@"ip", nil),KHJLocalizedString(@"mac", nil),nil];
    showDic = [[NSMutableDictionary alloc] initWithCapacity:0];

    mTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64) style:UITableViewStylePlain];
    mTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    mTable.delegate = self;
    mTable.dataSource = self;
    [self.view addSubview:mTable];
    
    if ([[KHJAllBaseManager sharedBaseManager] KHJSingleCheckDeviceOnline:self.uuidStr] != 1) {
        deviceDropInfo = YES;
        [[KHJToast share] showOKBtnToastWith:KHJLocalizedString(@"tips", nil) content:KHJLocalizedString(@"deviceDropLine", nil)];
        return;
    }
    deviceDropInfo = NO;
    [self checkInfo];
    [self startTimerWithSeconds:6 endBlock:^{
        [KHJHub shareHub].hud.hidden = YES;

    }];
}

- (void)checkInfo
{
    [self getDeviceInfo];
    [self getMACIP];
    [[KHJHub shareHub] showText:@"" addToView:self.view type:_lightGray];
}

- (void)setRightBtn
{
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    but.frame =CGRectMake(0,0, 44, 44);
    but.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    [but setTitle:KHJLocalizedString(@"refresh", nil) forState:UIControlStateNormal];
    [but setTintColor:[UIColor whiteColor]];
    [but addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem  *barBut = [[UIBarButtonItem alloc]initWithCustomView:but];
    self.navigationItem.rightBarButtonItem = barBut;
}
- (void)refreshData
{
    if (!deviceDropInfo) {
        [self checkInfo];
    }
}
#pragma mark - startTimerWithSeconds

- (void)startTimerWithSeconds:(long)seconds endBlock:(void(^)())endBlock
{
    __block long timeout = seconds;
    
    dispatch_queue_t queue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    _conntimer =dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0,0,queue);
    dispatch_source_set_timer(_conntimer,dispatch_walltime(NULL,0),1.0*NSEC_PER_SEC,0);
    dispatch_source_set_event_handler(_conntimer, ^{
        if (timeout < 0) {
            // 倒计时结束，回调block
            // End of countdown, callback block
            dispatch_source_cancel(self->_conntimer);
            dispatch_async(dispatch_get_main_queue(), ^{
                if(endBlock) {
                    endBlock();
                }
            });
        }else{
            timeout -= 1;
 
        }
    });
    dispatch_resume(_conntimer);
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
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIImageView *)getDevImageV
{
    if(verImageV == nil){
        verImageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new"]];
    }
    return verImageV;
}
- (void)getMACIP
{
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
    WeakSelf
    if (dDevice) {
        [dDevice.mDeviceManager getMacIp:^(int success, NSString *mac, NSString *ip) {
            [weakSelf backDeviceMac:mac withIP:ip];
        }];
    }
}
- (void)backDeviceMac:(NSString *)mac withIP:(NSString *)ip
{
    CLog(@"mac = %@, ip = %@",mac, ip);
    [showDic setValue:mac forKey:@"mac"];
    [showDic setValue:ip forKey:@"ip"];
    
    WeakSelf
    dispatch_async(dispatch_get_main_queue(), ^{
        [KHJHub shareHub].hud.hidden = YES;
        [weakSelf refreshTable];
    });
}

- (void)getDeviceInfo
{
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
    WeakSelf
    if (dDevice) {
//        [dDevice.mDeviceManager queryDeviceInfo:self.uuidStr reternBlock:^(int allCapacity, int leftCapacity, int edition, NSString *model, NSString *vendor) {
//            [weakSelf backDeviceInfo:allCapacity LeftCapacity:leftCapacity Version:edition Model:model Vendor:vendor];
//        }];
    }
}

-(void)backDeviceInfo:(int)allCapacity LeftCapacity:(int)leftCapacity Version:(int)version Model:(NSString *)model Vendor:(NSString *)vendor
{
    
    int a = version & 0xff;
    int b = (version >> 8) & 0xff;
    int c = (version >> 16) & 0xff;
    
    NSString *ver = [NSString stringWithFormat:@"%d.%d.%d",c,b,a];
    [showDic setValue:ver forKey:@"version"];
    WeakSelf
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [weakSelf refreshTable];
    });
    // 得到设备信息，再获取设备类型。
    // Get device information, and then get the device type.
    if (!self.myInfo.isAPMode) {
        [self getDeviceType];
    }
}
#pragma mark - UITableViewDelegate, UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [mPArr count];
}
- (UILabel *)getDevLab
{
    if (devNameLab == nil) {
        devNameLab =[[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH/2-50, 0, SCREENWIDTH/2+20, 44)];
        devNameLab.textAlignment = NSTextAlignmentRight;
        devNameLab.textColor = [UIColor blueColor];
        devNameLab.font = [UIFont systemFontOfSize:15.f];
    }
    return devNameLab;
}
- (CopyLabel *)getDLabel
{
    CopyLabel *lab = [[CopyLabel alloc] initWithFrame:CGRectMake(SCREENWIDTH/2-50, 0, SCREENWIDTH/2+20, CellHeigth)];
    [lab setTextAlignment:NSTextAlignmentRight];
    [lab setTextColor:[UIColor blueColor]];
    lab.font = [UIFont systemFontOfSize:15];
    return lab;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellId = @"setCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
 
    UILabel *lab = [cell viewWithTag:320+indexPath.row];

    if (indexPath.row !=0 && indexPath.row != 7) {
        if (!lab) {
            lab = [self getDLabel];
            lab.tag = 320+indexPath.row;
            [cell addSubview:lab];
        }
    }
    switch (indexPath.row) {
        case 0:
        {
            devNameLab = [self getDevLab];
            devNameLab.text = self.deviceName;
            [cell addSubview:devNameLab];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case 1:
        {
            // 设备ID
            // Device ID
            lab.text = self.uuidStr;
        }
            break;
            
        case 2:
        {
            // 设备类型
            // Equipment type
            lab.text =  [NSString stringWithFormat:@"IPC%@",self.myInfo.deviceType];
        }
            break;
        case 3:
        {
            if (deviceDropInfo) {
                lab.text = @"unknown";
            }
            else {
                NSString *version = [showDic objectForKey:@"version"];
                if (![version isEqualToString:@""] && version != nil) {
                    verImageV = [self getDevImageV];
                    CGRect ff = CGRectMake(lab.frame.size.width, 0, 16, 16);
                    verImageV.frame = ff;
                    [lab addSubview:verImageV];
                    if(isNeedVer){
                        verImageV.hidden = NO;
                        lab.text = [NSString stringWithFormat:@"%@   ",version];
                    }else{
                        verImageV.hidden = YES;
                        lab.text = version;
                    }
                }
            }
        }
            break;
        case 4:
        {
            if (deviceDropInfo) {
                lab.text = @"unknown";
            }
            else {
                NSString * ip = [showDic objectForKey:@"ip"];
                if (![ip isEqualToString:@""] && ip != nil) {
                    lab.text = ip;
                }
            }
        }
            break;
        case 5:
        {
            if (deviceDropInfo) {
                lab.text = @"unknown";
            }
            else {
                NSString * mac = [showDic objectForKey:@"mac"];
                if (![mac isEqualToString:@""] && mac != nil) {
                    lab.text = mac;
                }
            }
        }
            break;

        default:
            break;
    }
    cell.textLabel.font = [UIFont systemFontOfSize:15.f];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",mPArr[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 2) {
        if (verImageV && verImageV.hidden == NO) {
            if (!deviceDropInfo) {
                [self showAlertForUpdate];
            }
        }
    }
    else if (indexPath.row == 0) {
        // 修改设备名称
        // Modify the device name
        if (!self.myInfo.isAPMode) {
            if (!deviceDropInfo) {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                [self clickEditBtn:cell];
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[KHJToast share] showToastActionWithToastType:_WarningType
                                                  toastPostion:_CenterPostion
                                                           tip:@""
                                                       content:KHJLocalizedString(@"apModeNotUpdateName", nil)];
            });
        }
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CellHeigth;
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

#pragma mark - ZQAlterField

- (void)clickEditBtn:(UITableViewCell *)cell
{
    
}

- (void)handleDeviceAname:(NSString *)nameStr
{
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
    if (dDevice) {
        [dDevice.mDeviceManager setDeviceAlias:nameStr returnBlock:^(BOOL success) {
            
        }];
    }
}

- (void)showAlertForUpdate
{
    WeakSelf
    UIAlertController *alertview=[UIAlertController alertControllerWithTitle:KHJLocalizedString(@"updateNewVersion", nil) message:KHJLocalizedString(@"ensureUpdate", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel=[UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *defult = [UIAlertAction actionWithTitle:KHJLocalizedString(@"commit", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJHub shareHub] showText:KHJLocalizedString(@"updating", nil) addToView:self.view type:_lightGray];
        });
        KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
        if (dDevice) {
            [dDevice.mDeviceManager notifyUpgrade:^(int success) {
                [weakSelf notifyUpgradeCallBack:success];
            }];
        }
        
    }];
    [alertview addAction:cancel];
    [alertview addAction:defult];
    [self presentViewController:alertview animated:YES completion:nil];
}
- (void)notifyUpgradeCallBack:(int)success
{
    if (success == 0) {
        CLog(@"设备升级成功");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_SuccessType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"updateSuccess", nil)];
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }
    else {
        CLog(@"升级失败");
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_ErrorType
                                              toastPostion:_CenterPostion
                                                       tip:KHJLocalizedString(@"tips", nil)
                                                   content:KHJLocalizedString(@"updateFailure", nil)];
        });
    }
}
- (void)showAlert
{
    WeakSelf
    UIAlertController *alertview=[UIAlertController alertControllerWithTitle:KHJLocalizedString(@"formatSdcard", nil) message:KHJLocalizedString(@"sureFormateSDCard", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel=[UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *defult = [UIAlertAction actionWithTitle:KHJLocalizedString(@"commit", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 格式化
        // format
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJHub shareHub] showText:KHJLocalizedString(@"processing", nil) addToView:self.view type:_lightGray];
        });
        KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
        if (dDevice) {
            [dDevice.mDeviceManager formatSdcard:^(int success) {
                
                [weakSelf callBackSuccessFormateSD:success];
            }];
        }
    }];
    [alertview addAction:cancel];
    [alertview addAction:defult];
    [self presentViewController:alertview animated:YES completion:nil];
}

// successCallbackI int: 0 成功 -1 失败 -2 没有插入sdcard

// successCallbackI int: 0 Success -1 Failure -2 No sdcard inserted

- (void)callBackSuccessFormateSD:(int)success
{
    if (success == 0) {
        CLog(@"格式化成功");
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_SuccessType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"formatSuccess", nil)];
        });
    }else if(success == -1){
       
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_WarningType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"formatFailure", nil)];
        });
    }else if(success == -2){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_WarningType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"noSDCard", nil)];
        });
    }
}
- (void)getDeviceType
{
    
}

- (void)checkDevVer:(NSString *)devVer
{
    WeakSelf
    NSString *version = [[showDic objectForKey:@"version"] stringByReplacingOccurrencesOfString:@"." withString:@""];
    devVer = [devVer stringByReplacingOccurrencesOfString:@"." withString:@""];
    __weak typeof(mTable) weakMtable= mTable;
    if ([devVer intValue] > [version intValue]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakMtable reloadData];
            [weakSelf setNewVer];
        });
        
    }
}
- (void)setNewVer
{
    isNeedVer = YES;
}
- (void)refreshTable
{
    [mTable reloadData];
}
@end














