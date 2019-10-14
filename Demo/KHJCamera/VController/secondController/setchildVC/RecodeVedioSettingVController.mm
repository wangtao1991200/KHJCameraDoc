//
//  RecodeVedioSettingVController.m
//
//  录像设置
//
//
//

#import "RecodeVedioSettingVController.h"
#import "KHJAllBaseManager.h"
#import "KHJSetStartAndEndTimeVController.h"
#import "RecordPlanCell.h"
#import "DeNormalSelectView.h"
#import <KHJCameraLib/KHJCameraLib.h>
//#import "KHJDeviceManager.h"
//#import "TimeInfo.h"

#define MELLHEIGHT 40
#define CellHeigth 44

@interface RecodeVedioSettingVController ()<UITableViewDelegate,UITableViewDataSource>
{
    CGFloat TTableHeight;
    UITableView     *ttTable;
    NSMutableArray  *ttMarray;
    
    UILabel             *tipLabel;
    DeNormalSelectView *slView;
    UILabel             *recordQualitylab;
    UILabel             *recordModelab;
    
    // 主 tableview 内容
    NSArray     *contentQualityArr;
    NSArray     *contentModelArr;
    NSArray     *contentTitleArr;
    UITableView *contentTableView;
    
    //容量存储信息
    NSMutableDictionary *capacityDict;
    NSString            *recordQualityStr;
    NSString            *recordModeStr;
    
    
    int qInt;
    int mInt;
    
    // 设备不在线
    bool deviceOffLine;
}
@end

@implementation RecodeVedioSettingVController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    WeakSelf
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        // 任务1
        [weakSelf getDevicePlanList];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeDataSource];
    [self customizeAppearance];
}

- (void)customizeDataSource
{
    ttMarray        = [NSMutableArray array];
    capacityDict    = [NSMutableDictionary dictionary];
    self.title      = KHJLocalizedString(@"recordSet", nil);
    contentTitleArr    = @[KHJLocalizedString(@"sdcardCapacity" , nil),    //SD卡容量
                           KHJLocalizedString(@"sdcardFree"     , nil),    //SD卡剩余容量
                           KHJLocalizedString(@"formatSdcard"   , nil),    //格式化SD卡
                           KHJLocalizedString(@"videoQuality"   , nil),    //录像质量
                           KHJLocalizedString(@"RecordingMode"  , nil)];   //录像模式
    contentQualityArr  = @[KHJLocalizedString(@"LD", nil), //流畅
                           KHJLocalizedString(@"SD", nil), //标清
                           KHJLocalizedString(@"HD", nil)];//高清
    contentModelArr    = @[KHJLocalizedString(@"CloseRecord"        , nil),    //关闭录像
                    KHJLocalizedString(@"_24hourRecording"   , nil),    //连续录像
                    KHJLocalizedString(@"TimingPlan"         , nil),    //定时计划
                    KHJLocalizedString(@"AlarmRecording"     , nil)];   //报警录像
}
- (void)customizeAppearance
{
    [self setbackBtn];
    [self setMainView];
}
- (void)setbackBtn
{
    UIButton *but   = [UIButton buttonWithType:UIButtonTypeCustom];
    but.frame       = CGRectMake(0,0, 66, 44);
    [but setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    but.imageEdgeInsets     = UIEdgeInsetsMake(0, -40, 0, 0);//解决按钮不能靠左问题
    UIBarButtonItem *barBut = [[UIBarButtonItem alloc] initWithCustomView:but];
    self.navigationItem.leftBarButtonItem = barBut;
}

- (void)setMainView
{
    self.view.backgroundColor = bgVCcolor;
    contentTableView = [self getContentTableView];
    [self.view addSubview:contentTableView];
    [self setPlanView];
    [self getDeviceInfo];
    [self getRecoderQuality];
    [self getCurrenRecordType];
}

#pragma mark - UITableView 设置

- (UITableView *)getContentTableView
{
    if (contentTableView == nil) {
        contentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, [contentTitleArr count]*44)];
        contentTableView.delegate = self;
        contentTableView.dataSource = self;
    }
    return contentTableView;
}

- (UILabel *)getDLabel
{
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH/2 - 50, 0, SCREENWIDTH/2 + 20, CellHeigth)];
    [lab setTextColor:[UIColor grayColor]];
    [lab setTextAlignment:NSTextAlignmentRight];
    lab.font = [UIFont systemFontOfSize:14];
    return lab;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (ttTable == tableView) {
        return [ttMarray count];
    }
    else {
        return [contentTitleArr count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (ttTable == tableView) {
        static NSString *cellID = @"recordCell"; 
        RecordPlanCell *cell    = (RecordPlanCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[RecordPlanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        TimeInfo *tInfo     = [ttMarray objectAtIndex:indexPath.row];
        NSString *Cstring   = [Calculate getTimeFormat:tInfo.closeTime];
        NSString *Ostring   = [Calculate getTimeFormat:tInfo.openTime];
        
        cell.closeLab.text  =  Cstring;
        NSInteger clTime    = [Calculate getUTCTime:Cstring];
        NSInteger olTime    = [Calculate getUTCTime:Ostring];
        
        if (clTime > olTime) {
            cell.openLab.text = [NSString stringWithFormat:@"%@%@",Ostring,KHJLocalizedString(@"nextDay", nil)];
        }
        else {
            cell.openLab.text =  Ostring;
        }
        cell.timeLab.text = [NSString stringWithFormat:@"%@ - %@",cell.closeLab.text, cell.openLab.text];
        return cell;
    }
    else {
        static NSString *cellId = @"recordCell";
        UITableViewCell *cell   = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        UILabel *lab = [cell viewWithTag:340 + indexPath.row];
        if (!lab) {
            lab     = [self getDLabel];
            lab.tag = 340 + indexPath.row;
            [cell addSubview:lab];
        }
        switch (indexPath.row) {
            case 0:
            {
#pragma mark - change fix
                NSNumber * allCapNum = capacityDict[@"allCapacity"];
                if (allCapNum != nil) {
                    CLog(@"总容量为0");
                    NSString *allCapacity = String(@"%d",[allCapNum intValue]);
                    if (![allCapacity isEqualToString:@""] && allCapacity != nil) {
                        lab.text = String(@"%@MB",allCapacity);
                    }
                }
                else {
                    if (deviceOffLine) {
                        lab.text = String(@"未知");
                    }
                }
            }
                break;
            case 1://设备ID
            {
#pragma mark - change fix
                NSNumber * leaveCapNum = capacityDict[@"leftCapacity"];
                if (leaveCapNum != nil) {
                    NSString *leftCapacity = String(@"%d",[leaveCapNum intValue]);
                    if (![leftCapacity isEqualToString:@""] && leftCapacity != nil) {
                        lab.text = String(@"%@MB",leftCapacity);
                    }
                }
                else {
                    if (deviceOffLine) {
                        lab.text = String(@"未知");
                    }
                }
            }
                break;
            case 2:
            {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                lab.hidden = YES;
            }
                break;
            case 3:
            {
                lab.text = deviceOffLine ? @"" : recordQualityStr;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
                break;
            case 4:
            {
                lab.text = deviceOffLine ? @"" : recordModeStr;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
                break;
            default:
                break;
        }
        cell.textLabel.font = [UIFont systemFontOfSize:15.f];
        cell.textLabel.text = [NSString stringWithFormat:@"%@",contentTitleArr[indexPath.row]];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!deviceOffLine) {
        if (ttTable == tableView) {
            KHJSetStartAndEndTimeVController *sAndEndVC = [[KHJSetStartAndEndTimeVController alloc] init];
            sAndEndVC.sIndex = indexPath.row;
            sAndEndVC.vIndex = 1;
            sAndEndVC.planArray = ttMarray;
            sAndEndVC.uuidStr = self.uuidStr;
            [self.navigationController pushViewController:sAndEndVC animated:YES];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.selected = NO;
        }
        else {
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.selected = NO;
            switch (indexPath.row) {
                case 2:
                    [self showAlert];
                    break;
                case 3:
                    [self changeRecordQuality];
                    break;
                case 4:
                    [self changeMode];
                    break;
                default:
                    break;
            }
        }
    }
    else {
        if (ttTable != tableView) {
            if (indexPath.row > 1) {
                [[KHJToast share] showOKBtnToastWith:KHJLocalizedString(@"tips", nil) content:KHJLocalizedString(@"deviceDropLine", nil)];
            }
        }
        else {
            [[KHJToast share] showOKBtnToastWith:KHJLocalizedString(@"tips", nil) content:KHJLocalizedString(@"deviceDropLine", nil)];
        }
    }
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
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (ttTable == tableView) {
        return 60;
    }
    else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (ttTable == tableView) {
        UIButton *but = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 60)];
        but.layer.borderWidth   = 1;
        but.layer.borderColor   = bgVCcolor.CGColor;
        [but setBackgroundColor:[UIColor whiteColor]];
        but.titleLabel.font     = [UIFont systemFontOfSize:22];
        [but setTitleColor:DeCcolor forState:UIControlStateNormal];
        [but setTitle:KHJLocalizedString(@"addPlan", nil) forState:UIControlStateNormal];
        [but addTarget:self action:@selector(addPlan) forControlEvents:UIControlEventTouchUpInside];
        return but;
    }
    return nil;
}

- (void)showAlert
{
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"formatSdcard", nil) message:KHJLocalizedString(@"sureFormateSDCard", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *defult = [UIAlertAction actionWithTitle:KHJLocalizedString(@"commit", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //格式化sd
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJHub shareHub] showText:KHJLocalizedString(@"processing", nil) addToView:self.view type:_lightGray];
        });
        WeakSelf
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


/**
 格式化回调
 */
- (void)callBackSuccessFormateSD:(int)success
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [KHJHub shareHub].hud.hidden = YES;
    });
    if (success == 0) {
        CLog(@"格式化成功");
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_SuccessType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"formatSuccess", nil)];
        });
    }
    else if(success == -1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_ErrorType
                                              toastPostion:_CenterPostion
                                                       tip:KHJLocalizedString(@"tips", nil)
                                                   content:KHJLocalizedString(@"formatFailure", nil)];
        });
    }
    else if(success == -2) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_WarningType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"noSDCard", nil)];
        });
    }
}

#pragma mark - 得到设备信息

- (void)getDeviceInfo
{
    if ([[KHJAllBaseManager sharedBaseManager] KHJSingleCheckDeviceOnline:self.uuidStr] != 1) {
        deviceOffLine = YES;
        [[KHJToast share] showOKBtnToastWith:KHJLocalizedString(@"tips", nil) content:KHJLocalizedString(@"deviceDropLine", nil)];
        return;
    }
    deviceOffLine = NO;
    WeakSelf
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
    if (dDevice) {
//        [dDevice.mDeviceManager queryDeviceInfo:self.uuidStr reternBlock:^(int allCapacity, int leftCapacity, int edition, NSString *model, NSString *vendor) {
//            [weakSelf backDeviceInfo:allCapacity LeftCapacity:leftCapacity Version:edition Model:model Vendor:vendor];
//        }];
    }
}

- (void)backDeviceInfo:(int)allCapacity
          LeftCapacity:(int)leftCapacity
               Version:(int)version
                 Model:(NSString *)model
                Vendor:(NSString *)vendor
{
    // 总容量
    [capacityDict setValue:[NSNumber numberWithInt:allCapacity] forKey:@"allCapacity"];
    // 剩余容量
    [capacityDict setValue:[NSNumber numberWithInt:leftCapacity] forKey:@"leftCapacity"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->contentTableView reloadData];
    });
}

- (void)getCurrenRecordType
{
    WeakSelf
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
    if (dDevice) {
        [dDevice.mDeviceManager getVideoRecordType:^(int type) {
            
            [weakSelf getVideoRecordTypeCallback:type];
        }];
    }
}

- (void)getVideoRecordTypeCallback:(int)type
{
    CLog(@"type = %d",type);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self handleRecordType:type];
    });
}

- (void)handleRecordType:(int)type
{
    mInt = type;

    if (type == 0){
        recordModeStr = KHJLocalizedString(@"CloseRecord", nil);
        tipLabel.hidden = YES;
        ttTable.hidden = YES;
    }
    else if(type == 2) {    //0:没有录像 1：z正在录像
        recordModeStr = KHJLocalizedString(@"TimingPlan", nil);
        tipLabel.hidden = NO;
        ttTable.hidden = NO;
    }
    else if(type == 1) {
        recordModeStr = KHJLocalizedString(@"_24hourRecording", nil);
        tipLabel.hidden = YES;
        ttTable.hidden = YES;
    }
    else if(type == 3) {
        recordModeStr = KHJLocalizedString(@"AlarmRecording", nil);
        tipLabel.hidden = YES;
        ttTable.hidden = YES;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->contentTableView reloadData];
    });
}

- (void)setPlanView
{
    tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, contentTableView.frame.origin.y+contentTableView.frame.size.height, SCREENWIDTH, 66)];
    tipLabel.numberOfLines      = 2;
    tipLabel.backgroundColor    = bgVCcolor;
    tipLabel.textAlignment      = NSTextAlignmentCenter;
    tipLabel.textColor          = UIColor.lightGrayColor;
    tipLabel.font               = [UIFont systemFontOfSize:15.f];
    tipLabel.text               = KHJLocalizedString(@"deviceWillRecord", nil);
    tipLabel.text               = [NSString stringWithFormat:@"(%@)",KHJLocalizedString(@"deviceWillRecord", nil)];
    [self.view addSubview:tipLabel];
    
    TTableHeight = SCREENHEIGHT - (tipLabel.frame.origin.y + tipLabel.frame.size.height) - 64;
    ttTable = [[UITableView alloc] initWithFrame:CGRectMake(0, tipLabel.frame.origin.y + tipLabel.frame.size.height, SCREENWIDTH, 60) style:UITableViewStylePlain];
    ttTable.bounces     = NO;
    ttTable.delegate    = self;
    ttTable.dataSource  = self;
    ttTable.showsVerticalScrollIndicator = NO;
    [self.view addSubview:ttTable];
    
    tipLabel.hidden = YES;
    ttTable.hidden = YES;
}

#pragma mark - 设置录像模式
- (void)changeMode
//设置录像模式
{
    WeakSelf
    slView = [self getSelectView];
    slView.titleStr = KHJLocalizedString(@"SelectRecordMode", nil);
    slView.dArray = contentModelArr;
    slView.cateStrIn = mInt;
    [slView refreshData];
    [slView show];
    [slView setSelBlock:^(int intS) {
        
        [weakSelf changeRecordeMode:intS];
    }];
}

#pragma mark - 设置录像模式

- (void)changeRecordeMode:(int)mode
{
    if (mInt == mode) {
        return;
    }
    mInt = mode;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[KHJHub shareHub] showText:@"" addToView:self.view type:_lightGray];
    });
    WeakSelf
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
    if (dDevice) {
        
        [dDevice.mDeviceManager setVideoRecordType:mode returnBlock:^(BOOL success) {
           
            [weakSelf setVideoRecordTypeCallback:success];
        }];
    }
}

- (void)setVideoRecordTypeCallback:(BOOL)success
{
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[KHJToast share] showToastActionWithToastType:_SuccessType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"setSuccess", nil)];
            [KHJHub shareHub].hud.hidden = YES;

            [self handleRecordType:self->mInt];
        });
    }
}

- (void)backVedioRecodeOrScreenShot:(int)success withUid:(NSString *)uidStr
{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [self showInfo:success];
    });
}

- (void)showInfo:(int)success
{
    switch (success) {
        case 0://成功
            {
                [[KHJToast share] showToastActionWithToastType:_SuccessType
                                                  toastPostion:_CenterPostion
                                                           tip:@""
                                                       content:KHJLocalizedString(@"modifySuccess", nil)];
                recordModelab.text = [contentModelArr objectAtIndex:mInt];
                [self checkMode];
            }
            break;
        case 1://无SD卡
        {
            [[KHJToast share] showToastActionWithToastType:_WarningType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"noSDCard", nil)];
        }
            break;
        case 2://失败
        {
            [[KHJToast share] showToastActionWithToastType:_ErrorType
                                              toastPostion:_CenterPostion
                                                       tip:KHJLocalizedString(@"tips", nil)
                                                   content:KHJLocalizedString(@"modifyFailure", nil)];
        }
            break;
        default:
            break;
    }
}

- (void)checkMode
{
    if(mInt == 0) {
        [self getDevicePlanList];
        ttTable.hidden = NO;
        tipLabel.hidden = NO;
        
    }
    else {
        ttTable.hidden = YES;
        tipLabel.hidden = YES;
    }
}

#pragma mark - 设置录像质量

- (void)changeRecordQuality//切换录制质量
{
    WeakSelf
    slView = [self getSelectView];
    slView.titleStr = KHJLocalizedString(@"ChooseRecordQuality", nil);
    slView.dArray = contentQualityArr;
    slView.cateStrIn = qInt - 1;
    [slView refreshData];
    [slView show];
    [slView setSelBlock:^(int intS) {
        [weakSelf selectQuality:intS];
    }];
}

- (void)selectQuality:(int)intS
{
    if (qInt == (intS + 1)) {
        return ;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[KHJToast share] showToastActionWithToastType:_WarningType
                                          toastPostion:_CenterPostion
                                                   tip:@""
                                               content:KHJLocalizedString(@"setVideoQuality", nil)];
    });
    qInt = intS + 1;
    WeakSelf
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
    if (dDevice) {
        [dDevice.mDeviceManager setRecordVideoQuality:qInt returnBlock:^(BOOL success) {
            [weakSelf setRecordVideoQualityCallBack:success];
        }];
    }
}

- (void)getRecoderQuality
{
    WeakSelf
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
    if (dDevice) {
        [dDevice.mDeviceManager getRecordVideoQuality:^(int level) {
            [weakSelf getRecordVideoQualityCallBack:level];
        }];
    }
}

- (void)getRecordVideoQualityCallBack:(int)success
{
    CLog(@"success = %d",success );
    WeakSelf
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [weakSelf showQuality:success];
    });
}

- (void)showQuality:(int)quality
{
    qInt = quality;
    recordQualityStr = [contentQualityArr objectAtIndex:(quality - 1)];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->contentTableView reloadData];

    });
}

- (void)setRecordVideoQualityCallBack:(BOOL)success
{
    WeakSelf
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[KHJToast share] showToastActionWithToastType:_SuccessType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"setSuccess", nil)];
            [weakSelf showQuality:self->qInt];
            [KHJHub shareHub].hud.hidden = YES;
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_ErrorType
                                              toastPostion:_CenterPostion
                                                       tip:KHJLocalizedString(@"tips", nil)
                                                   content:KHJLocalizedString(@"setFail", nil)];
            [KHJHub shareHub].hud.hidden = YES;

        });
    }
}

#pragma mark - SelectView

- (DeNormalSelectView *)getSelectView
{
    if (slView == nil) {
        slView = [[DeNormalSelectView alloc] initWithFrame:CGRectZero];
    }
    return slView;
}

- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getDevicePlanList
{
    WeakSelf
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
    if (dDevice) {
        [dDevice.mDeviceManager getTimedRecordVideoTask:^(NSMutableArray *mArray) {
            [weakSelf getTimedRecordVideoTaskCallback:mArray];
        }];
    }
}

- (void)getTimedRecordVideoTaskCallback:(NSArray *)taskArray
{
    [ttMarray removeAllObjects];
    [ttMarray  addObjectsFromArray:taskArray];
    __block NSInteger count = [taskArray count];
    __weak typeof(ttTable) weakTtable =ttTable;
    __block CGFloat hh = TTableHeight;
    if (count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakTtable reloadData];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGRect fra = weakTtable.frame;
            
            fra.size.height =  MELLHEIGHT* count +60;
            if (fra.size.height >= hh) {
                fra.size.height = hh;
            }
            weakTtable.frame = fra;
            [weakTtable reloadData];
        });
    }
}

#pragma mark - addPlan

- (void)addPlan
{
    KHJSetStartAndEndTimeVController *sAndEndVC = [[KHJSetStartAndEndTimeVController alloc] init];
    sAndEndVC.sIndex    = -1;
    sAndEndVC.vIndex    = 1;
    sAndEndVC.planArray = ttMarray;
    sAndEndVC.uuidStr   = self.uuidStr;
    [self.navigationController pushViewController:sAndEndVC animated:YES];
}

@end
















