//
//  SettingViewController.m
//
//
//
//
//

#import "KHJSettingViewController.h"
#import "DeviceInfoVController.h"
#import "TimeVController.h"
#import "KHJSDVedioPhotoVController.h"
#import "KHJNetSettingVController.h"
#import "RecodeVedioSettingVController.h"
#import "DeviceInfo.h"
#import "ViewAndSoundVController.h"
#import "ZQAlterField.h"
#import "ZQUtil.h"
#import "AddSensorVController.h"
#import "AlarmSetVController.h"
#import "DePathChoseView.h"
#import "KHJAllBaseManager.h"
#import "KHJDeviceSwitchVController.h"

#define CellHeigth (44)

@interface KHJSettingViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *mTable;
    NSArray *mTArr;
    UIButton *deleteBtn;

    UIImageView *headImgView;
    UILabel *devIDLab;
    UILabel *nikeNameLab;
    DePathChoseView *pathChoseView;
    BOOL isCloud;
    UISwitch *fSwitchView;
    UILabel *vLabel;
}
@end

@implementation KHJSettingViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (mTable) {
        [mTable reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title  =KHJLocalizedString(@"deviceSetting", nil);
    [self setbackBtn];
    mTArr = [[NSArray alloc] initWithObjects:
             KHJLocalizedString(@"deviceInfo", nil),KHJLocalizedString(@"reverseScreen", nil),
             KHJLocalizedString(@"deviceAblum", nil),KHJLocalizedString(@"networkSetting", nil),
             KHJLocalizedString(@"deviceVolume", nil),KHJLocalizedString(@"alarmSetting", nil),
             KHJLocalizedString(@"recordSet", nil),KHJLocalizedString(@"TimingSwitch", nil),
             KHJLocalizedString(@"addSensor", nil),nil];

    CGFloat gg = Height_NavBar;
    CGFloat ff = Height_TabBar;

    mTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-ff-44-gg-10) style:UITableViewStylePlain];
    mTable.tableFooterView  = [[UIView alloc] initWithFrame:CGRectZero];
    mTable.delegate         = self;
    mTable.dataSource       = self;
    [self.view addSubview:mTable];
    
    deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, SCREENHEIGHT - 44 - gg - 20, SCREENWIDTH - 40, 44)];
    [deleteBtn setTitle:KHJLocalizedString(@"deleteAndUnbindDevice", nil) forState:UIControlStateNormal];
    deleteBtn.clipsToBounds         = YES;
    deleteBtn.layer.cornerRadius    = 8;
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"bgN"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteBtn];
   
    if (self.myInfo.isAPMode) {
        deleteBtn.hidden = YES;
    }
    else {
        deleteBtn.hidden = NO;
    }
}

- (void)deleteClick:(UIButton *)btn
{
    CLog(@"deleteClick");
}

- (void)showCAlert
{
    if ([[KHJAllBaseManager sharedBaseManager] KHJSingleCheckDeviceOnline:self.uuidStr] != 1) {
        [[KHJToast share] showOKBtnToastWith:KHJLocalizedString(@"tips", nil) content:KHJLocalizedString(@"deviceDropLine", nil)];
        return;
    }
    
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"Calibration", nil) message:KHJLocalizedString(@"CalibrationTips", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *defult = [UIAlertAction actionWithTitle:KHJLocalizedString(@"commit", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        KHJBaseDevice *bDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.myInfo.deviceUid];
        if (bDevice) {
            [bDevice.mDeviceManager setRun:35 withStep:0];
        }
    }];
    [alertview addAction:cancel];
    [alertview addAction:defult];
    [self presentViewController:alertview animated:YES completion:nil];
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
#pragma mark - UITableViewDelegate, UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [mTArr count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"settingCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [NSString stringWithFormat:@"%@",mTArr[indexPath.row]];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    UILabel *lab = [cell viewWithTag:340+indexPath.row];
    if (!self.myInfo.isAPMode) {
        
        if (self.myInfo.isPtz == 1) {
            if (indexPath.row == 2) {
                if (!lab) {
                    lab = [self getDLabel];
                    lab.tag = 340+indexPath.row;
                    [cell addSubview:lab];
                    
                }
                CLog(@"myInfo Address0 =%@",self.myInfo);
                if (self.myInfo.cloudStatus == 0) {
                    lab.text = KHJLocalizedString(@"notAvailable", nil);
                }else if(self.myInfo.cloudStatus == 1 ){
                    
                    NSInteger cTime = self.myInfo.storageTime ;
                    NSInteger cType = self.myInfo.recType;
                    NSString *cTypeStr = @"";
                    if (cType == 1) {
                        cTypeStr = KHJLocalizedString(@"AllDayRecording", nil);
                    }else{
                        cTypeStr = KHJLocalizedString(@"AlarmRecording", nil);
                    }
                    lab.text = [NSString stringWithFormat:@"%ld%@(%@)",(long)cTime,KHJLocalizedString(@"storageTime", nil),cTypeStr];
                }
            }else if (indexPath.row == 3) {
                
                fSwitchView = [self getFSwitch];
                [cell addSubview:fSwitchView];
                cell.accessoryType = UITableViewCellAccessoryNone;
                [self getFlipState];
                
            }else if(indexPath.row == 7){
                vLabel = [self getVlable];
                [cell addSubview:vLabel];
                [self getDVolume];
            }
        }else{
            
            if (indexPath.row == 2) {
                if (!lab) {
                    lab = [self getDLabel];
                    lab.tag = 340+indexPath.row;
                    [cell addSubview:lab];
                    
                }
                CLog(@"myInfo Address0 =%@",self.myInfo);
                if (self.myInfo.cloudStatus == 0) {
                    lab.text = KHJLocalizedString(@"notAvailable", nil);
                }else if(self.myInfo.cloudStatus == 1 ){
                    
                    NSInteger cTime = self.myInfo.storageTime ;
                    NSInteger cType = self.myInfo.recType;
                    NSString *cTypeStr = @"";
                    if (cType == 1) {
                        cTypeStr = KHJLocalizedString(@"AllDayRecording", nil);
                    }else{
                        cTypeStr = KHJLocalizedString(@"AlarmRecording", nil);
                    }
                    lab.text = [NSString stringWithFormat:@"%ld%@(%@)",(long)cTime,KHJLocalizedString(@"storageTime", nil),cTypeStr];
                }
            }else if (indexPath.row == 3) {
                
                fSwitchView = [self getFSwitch];
                [cell addSubview:fSwitchView];
                cell.accessoryType = UITableViewCellAccessoryNone;
                [self getFlipState];
                
            }else if(indexPath.row == 6){
                vLabel = [self getVlable];
                [cell addSubview:vLabel];
                [self getDVolume];
            }
            
        }
        
        
    }else{
    if (indexPath.row == 1) {
            
            fSwitchView = [self getFSwitch];
            [cell addSubview:fSwitchView];
            cell.accessoryType = UITableViewCellAccessoryNone;
            [self getFlipState];
            
        }else if(indexPath.row == 4){
            vLabel = [self getVlable];
            [cell addSubview:vLabel];
            [self getDVolume];
        }
    }
    

    return cell;
}
#pragma mark - 获取设备录制音量
- (void)getDVolume
{
    
    KHJBaseDevice *bDevice =  [[KHJAllBaseManager sharedBaseManager] searchForkey:self.myInfo.deviceUid];
    if (bDevice) {
        WeakSelf
        [bDevice.mDeviceManager getDeviceVolume:^(int volume) {
           
            [weakSelf getDeviceVolumeCallback:volume];
        }];
    }
}
- (void)getDeviceVolumeCallback:(int)success
{
    CLog(@"音量 == %d",success);
    __weak typeof(vLabel) weakVLabel= vLabel;
    dispatch_async(dispatch_get_main_queue(), ^{

        weakVLabel.text = [NSString stringWithFormat:@"%d%%",success];
    });
}
#pragma mark - 获得画面翻转
- (void)getFlipState
{
    KHJBaseDevice *bDevice =  [[KHJAllBaseManager sharedBaseManager] searchForkey:self.myInfo.deviceUid];
    if (bDevice) {
        WeakSelf
        [bDevice.mDeviceManager getFLipping:^(BOOL success) {
            
            [weakSelf getFlippingSuccessCallBack:success];
        }];
    }
}
- (void)getFlippingSuccessCallBack:(BOOL)success
{
    __weak typeof(fSwitchView) weakSwith= fSwitchView;
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSwith.on = YES;
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSwith.on = NO;
        });
    }
}
- (UISwitch *)getFSwitch
{
    if (fSwitchView == nil) {
        
        fSwitchView = [[UISwitch alloc] initWithFrame:CGRectMake(SCREENWIDTH-82, 8, 72, 44)];
        fSwitchView.on = NO;
        fSwitchView.onTintColor = DeCcolor;
        fSwitchView.transform = CGAffineTransformMakeScale( 0.75, 0.75);
        fSwitchView.layer.anchorPoint=CGPointMake(0,0.5);
        [fSwitchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    }
    return fSwitchView;
    
}
#pragma mark - 设置画面翻转
- (void)switchAction:(UISwitch *)sw{
   
    KHJBaseDevice *bDevice =  [[KHJAllBaseManager sharedBaseManager] searchForkey:self.myInfo.deviceUid];
    if (!bDevice) {
        return;
    }
    WeakSelf
    if (sw.on == YES) {
        [bDevice.mDeviceManager setFlippingWithDerect:1 returnBlock:^(BOOL success) {
            [weakSelf setFlippingSuccessCallBack:success];
        }];
    }else{
        [bDevice.mDeviceManager setFlippingWithDerect:0 returnBlock:^(BOOL success) {
            [weakSelf setFlippingSuccessCallBack:success];
        }];
    }
}
- (void)setFlippingSuccessCallBack:(BOOL)success
{
    __weak typeof(fSwitchView) weakSwith= fSwitchView;
    
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
            weakSwith.on = !weakSwith.on;
        });
    }
}

- (UILabel *)getDLabel
{
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH/2-50, 0, SCREENWIDTH/2+20, CellHeigth)];
    [lab setTextAlignment:NSTextAlignmentRight];
    [lab setTextColor:[UIColor blueColor]];
    lab.font = [UIFont systemFontOfSize:15];
    return lab;
}
- (UILabel *)getVlable
{
    if (vLabel == nil) {
        vLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH/2-50, 0, SCREENWIDTH/2+20, CellHeigth)];
        [vLabel setTextAlignment:NSTextAlignmentRight];
        [vLabel setTextColor:[UIColor blueColor]];
        vLabel.font = [UIFont systemFontOfSize:15];
    }
    return vLabel;
}

- (DePathChoseView *)getPathChoseView
{
    if (pathChoseView == nil) {
        pathChoseView =  [[DePathChoseView alloc] initWithFrame:CGRectZero];
    }
    return pathChoseView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
            
        case 0:
        {
            // 设备信息
            // Device Information
            DeviceInfoVController *dInfoVC =  [[DeviceInfoVController alloc] init];
            dInfoVC.uuidStr = self.uuidStr;
            dInfoVC.deviceName =  self.deviceName;
            dInfoVC.myInfo = self.myInfo;
            [self.navigationController pushViewController:dInfoVC animated:YES];
        }
            break;
        case 1:
            // 画面翻转
            // Screen flip
            break;
            
        case 2:
        {
            // 设备相册
            // Device album
            KHJSDVedioPhotoVController *sdVPVC = [[KHJSDVedioPhotoVController alloc] init];
            sdVPVC.uuidStr = self.uuidStr;
            sdVPVC.pwd = self.myInfo.devicePwd;
            [self.navigationController pushViewController:sdVPVC animated:YES];
        }
            break;
        case 3:
        {
            // 网络设置
            // Network settings
            KHJNetSettingVController *netVC= [[KHJNetSettingVController alloc] init];
            netVC.uuidStr = self.uuidStr;
            netVC.myInfo = self.myInfo;
            [self.navigationController pushViewController:netVC animated:YES];
        }
            break;
        case 4:
        {
            // 设备音量
            // Device volume
            ViewAndSoundVController *vsVc = [[ViewAndSoundVController alloc] init];
            vsVc.uuidStr = self.uuidStr;
            [self.navigationController pushViewController:vsVc animated:YES];
        }
            break;
        case 5:
        {
            // 报警设置
            // Alarm Settings
            AlarmSetVController  *alarmVC = [[AlarmSetVController alloc] init];
            alarmVC.uuidStr = self.uuidStr;
            alarmVC.myInfo = self.myInfo;
            
            [self.navigationController pushViewController:alarmVC animated:YES];
        }
            break;
        case 6:
        {
            // 录像设置
            // Record settings
            RecodeVedioSettingVController *rVVC = [[RecodeVedioSettingVController alloc] init];
            rVVC.uuidStr = self.uuidStr;
            [self.navigationController pushViewController:rVVC animated:YES];
        }
            break;
        case 7:
        {
            // 定时开关机
            // Timer switch
            KHJDeviceSwitchVController *deSwitchVC = [[KHJDeviceSwitchVController alloc] init];
            deSwitchVC.uuidStr = self.uuidStr;
            [self.navigationController pushViewController:deSwitchVC animated:YES];
        }
            break;
        case 8:
        {
            // 传感器
            // Sensor
            AddSensorVController *addSensorVc = [[AddSensorVController alloc] init];
            addSensorVc.uuidStr = self.uuidStr;
            [self.navigationController pushViewController:addSensorVc animated:YES];
        }
            break;
        default:
            break;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


@end
