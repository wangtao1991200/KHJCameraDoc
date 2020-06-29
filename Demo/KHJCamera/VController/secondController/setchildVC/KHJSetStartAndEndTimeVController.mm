//
//  SetStartAndEndTimeVController.m
//
//  开关机计划 + 录像计划
//
//  Power on/off plan + video plan
//
//  设置开始和结束时间
//
//  Set start and end time
//
//

#import "KHJSetStartAndEndTimeVController.h"
#import "KHJAllBaseManager.h"
#import "HZWPicker.h"
#import <KHJCameraLib/KHJCameraLib.h>

@interface KHJSetStartAndEndTimeVController ()
{
    BOOL isClickClose;
    UIButton *closeTimeButton;
    UIButton *openTimeButton;
    UILabel *clab;
    UILabel *olab;
    
    // 删除计划按钮
    
    // Delete plan button
    
    UIButton *deletePlanBtn;
}

@end

@implementation KHJSetStartAndEndTimeVController
@synthesize planArray;
@synthesize sIndex;

- (instancetype)init
{
    self = [super init];
    if (self) {
        planArray = [NSMutableArray array];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.vIndex == 0){
        self.title = KHJLocalizedString(@"onOffPlan", nil);
    }else
        self.title = KHJLocalizedString(@"recordPlan", nil);
    
    
    self.view.backgroundColor = bgVCcolor;
    [self setbackBtn];
    [self  setMianView];
    [self setRightButton];
    
}
- (void)setRightButton
{
    UIButton *changeVideo = [UIButton buttonWithType:UIButtonTypeCustom];
    changeVideo.frame = CGRectMake(0,0,44,44);

    [changeVideo setTitle:KHJLocalizedString(@"save", nil) forState:UIControlStateNormal];
    [changeVideo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [changeVideo addTarget:self action:@selector(saveTime) forControlEvents:UIControlEventTouchUpInside];
    [changeVideo sizeToFit];
    UIBarButtonItem *informationCardItem = [[UIBarButtonItem alloc] initWithCustomView:changeVideo];
    self.navigationItem.rightBarButtonItem  = informationCardItem;
}

- (void)saveTime
{
    // 1. 判断开启和关闭时间是否都设置
    // 1. Determine whether the opening and closing time are set
    if ([olab.text isEqualToString:@""] || [clab.text isEqualToString:@""]) {
        [[KHJToast share] showToastActionWithToastType:_WarningType
                                          toastPostion:_CenterPostion
                                                   tip:@""
                                               content:KHJLocalizedString(@"CloseOrOpenUnSet", nil)];
        return;
    }
    // 2. 比较时间是否相等
    // 2. Compare time is equal
    NSString *oString = olab.text;
    oString = [oString stringByReplacingOccurrencesOfString:@" " withString:@""];
    oString = [Calculate formateTimeStamp:oString];
    
    NSString *cString = clab.text;
    cString = [cString stringByReplacingOccurrencesOfString:@" " withString:@""];
    cString = [Calculate formateTimeStamp:cString];
    
    TimeInfo *nowTimeInfo = [[TimeInfo alloc] init];
    nowTimeInfo.closeTime = cString;
    nowTimeInfo.openTime = oString;
    
    if (sIndex != -1) {
        // 修改之前的计划
        // modify the previous plan
        [planArray removeObject:planArray[sIndex]];
    }
    if ([oString isEqualToString:cString]) {
        [[KHJToast share] showToastActionWithToastType:_WarningType
                                          toastPostion:_CenterPostion
                                                   tip:@""
                                               content:KHJLocalizedString(@"CloseOrOpenCannotSame", nil)];
    }
    else {
        // 3. 比较时间大小
        // 3. Compare time size
        NSInteger nc =[nowTimeInfo.closeTime integerValue];
        NSInteger no = [nowTimeInfo.openTime integerValue];
        if (nc > no) {
            // 4.open < close ,则 open需要+24小时
            // 4.open <close, then open takes +24 hours
            no = no+24*3600;
            nowTimeInfo.openTime = [NSString stringWithFormat:@"%ld",(long)no];
        }
        // 5. 则需要遍历已保存的计划数组
        // 5. You need to traverse the saved plan array
        bool isNeedAdd = true;
        // 判断是否计划时间有重复
        // Determine if there is any duplication of planned time
        for (int i = 0; i< planArray.count; i++) {
            TimeInfo *tInfo = [planArray objectAtIndex:i];
            NSInteger tc = [tInfo.closeTime integerValue];
            NSInteger to = [tInfo.openTime integerValue];
            if ((nc >= tc && no <= to) ||
                (nc >= tc && nc <= to && no> to) ||
                (nc < tc  && no > tc  && no < to ) ||
                (nc <= tc && no >=to)) {
                isNeedAdd = false;
            }
            else if(nc <= to-24*3600) {
                isNeedAdd = false;
            }
        }
        if (isNeedAdd) {
            [self.view resignFirstResponder];
            [[KHJToast share] showSingleToastWithContent:KHJLocalizedString(@"adding", nil)];
            // 修改或者添加排序后再发出去
            // modify or add the order before sending
            NSInteger sertIndex = 0;
            for (int i = 0; i< [planArray count]; i++) {

                TimeInfo *tInfo = [planArray objectAtIndex:i];
                NSInteger tc = [tInfo.closeTime integerValue];
                NSInteger to = [tInfo.openTime integerValue];
                if (i == [planArray count] -1 ) {
                    sertIndex = [planArray count];
                    break;
                }
                else {
                    TimeInfo *tInfo1 = [planArray objectAtIndex:i+1];
                    NSInteger tc1 = [tInfo1.closeTime integerValue];
                    if (no < tc) {
                        sertIndex = 0;
                        break;
                    }
                    else if (nc > to && no < tc1) {
                        sertIndex = i + 1;
                        break;
                    }
                }
            }
            [planArray insertObject:nowTimeInfo atIndex:sertIndex];
           
            if (self.vIndex == 0) {
                
                WeakSelf
                KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
                if (dDevice) {
                    [dDevice.mDeviceManager addTimedCameraTask:planArray returnBloc:^(BOOL success) {
                        [weakSelf successCallbackAddTimedCameraTask:success];
                    }];
                }
            }
            else {
                
                WeakSelf
                KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
                if (dDevice) {
                    [dDevice.mDeviceManager addTimedRecordVideoTask:planArray returnBloc:^(BOOL success) {
                        [weakSelf setTimedRecordVideoTaskCallback:success];
                    }];
                }
            }
        }
        else {
            [[KHJToast share] showToastActionWithToastType:_WarningType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"existPlan", nil)];
            return;
        }
    }
}
- (void)setMianView
{
    closeTimeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44)];
    [closeTimeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    if(self.vIndex == 0){
        [closeTimeButton setTitle:[NSString stringWithFormat:@"    %@",KHJLocalizedString(@"closeTime", nil)] forState:UIControlStateNormal];

    }else{
        [closeTimeButton setTitle:[NSString stringWithFormat:@"    %@",KHJLocalizedString(@"recordVedioStart", nil)] forState:UIControlStateNormal];
    }
    [closeTimeButton setBackgroundColor:[UIColor whiteColor]];
    closeTimeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

    [closeTimeButton addTarget:self action:@selector(clickShow:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeTimeButton];
    
    openTimeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 44+1, SCREENWIDTH, 44)];
    [openTimeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    if(self.vIndex == 0){
        [openTimeButton setTitle:[NSString stringWithFormat:@"    %@",KHJLocalizedString(@"openTime", nil)] forState:UIControlStateNormal];

    }else{
        [openTimeButton setTitle:[NSString stringWithFormat:@"    %@",KHJLocalizedString(@"recordVedioClose", nil)] forState:UIControlStateNormal];
    }
    openTimeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [openTimeButton setBackgroundColor:[UIColor whiteColor]];
    [openTimeButton addTarget:self action:@selector(clickShow:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openTimeButton];
    
    //添加label和image
    clab = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH-150, 0, 120, 44)];
    clab.textColor = UIColor.blueColor;
    clab.textAlignment = NSTextAlignmentCenter;
    [closeTimeButton addSubview:clab];
    
    UIImageView *imagec = [[UIImageView alloc] initWithFrame:CGRectMake(SCREENWIDTH-30, 9, 15, 26)];
    [imagec setImage:[UIImage imageNamed:@"icon_right_blue"]];
    [closeTimeButton addSubview:imagec];
    
    olab = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH-150, 0, 120, 44)];
    olab.textColor = UIColor.blueColor;
    olab.textAlignment = NSTextAlignmentCenter;
    [openTimeButton addSubview:olab];
    
    clab.font  = [UIFont fontWithName:@"Helvetica Neue" size:17.f];//解决数字宽度不一样
    olab.font  = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
    
    UIImageView *imageo = [[UIImageView alloc] initWithFrame:CGRectMake(SCREENWIDTH-30, 9, 15, 26)];
    [imageo setImage:[UIImage imageNamed:@"icon_right_blue"]];
    [openTimeButton  addSubview:imageo];
    
    deletePlanBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, openTimeButton.frame.origin.y+openTimeButton.frame.size.height +20, SCREENWIDTH-40, 44)];
    [deletePlanBtn setTitle:KHJLocalizedString(@"deletePlan", nil) forState:UIControlStateNormal];
    deletePlanBtn.clipsToBounds = YES;
    deletePlanBtn.layer.cornerRadius = 5;
    [deletePlanBtn setBackgroundImage:[UIImage imageNamed:@"bgN"] forState:UIControlStateNormal];
    [deletePlanBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    deletePlanBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [deletePlanBtn addTarget:self action:@selector(deletePlan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deletePlanBtn];

    if (sIndex == -1) {
        deletePlanBtn.hidden = YES;
    }
    else {
        deletePlanBtn.hidden = NO;
        TimeInfo *tInfo = [planArray objectAtIndex:sIndex];
        NSString *Cstring = [Calculate getTimeFormat:tInfo.closeTime];
        NSString *Ostring = [Calculate getTimeFormat:tInfo.openTime];
        clab.text =  Cstring;
        NSInteger clTime = [Calculate getUTCTime:Cstring];
        NSInteger olTime = [Calculate getUTCTime:Ostring];
        if (clTime> olTime) {
            olab.text = [NSString stringWithFormat:@"%@%@",Ostring,KHJLocalizedString(@"nextDay", nil)];
        }
        else {
            olab.text =  Ostring;
        }
    }
    
}

// 删除计划
// Delete plan
- (void)deletePlan
{
    if (planArray.count - 1 >= sIndex) {
        [planArray removeObjectAtIndex:sIndex];
        // 添加计划
        // Add plan
        if (self.vIndex == 0) {
            WeakSelf
            KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
            if (dDevice) {
                [dDevice.mDeviceManager addTimedCameraTask:planArray returnBloc:^(BOOL success) {
                    [weakSelf successCallbackAddTimedCameraTask:success];
                }];
            }
        }
        else {
            
            WeakSelf
            KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
            if (dDevice) {
                [dDevice.mDeviceManager addTimedRecordVideoTask:planArray returnBloc:^(BOOL success) {
                    [weakSelf setTimedRecordVideoTaskCallback:success];
                }];
            }
        }
    }
    else {
        [[KHJToast share] showToastActionWithToastType:_ErrorType
                                          toastPostion:_CenterPostion
                                                   tip:KHJLocalizedString(@"tips", nil)
                                               content:KHJLocalizedString(@"DeleteFail", nil)];
    }
}
- (void)clickShow:(UIButton *)but
{
    if (but == closeTimeButton) {
        isClickClose = YES;
    }else{
        isClickClose = NO;
    }

    WeakSelf
    HZWPicker *pick = [[HZWPicker alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT-250+44, SCREENWIDTH, 324)];
    pick.confirmBlock = ^(NSString *strings) {
        
            NSLog(@" strings = %@",strings);
        [weakSelf showTime:strings];
    };
}
- (void)showTime:(NSString *)str
{
    
    __block BOOL isclose = isClickClose;
    __block UILabel *ccl = clab;
    __block UILabel *ool = olab;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (isclose) {
            ccl.text = str;
        }else{
            ool.text = str;
        }
    });
    
}

- (void)clickClose:(UIButton *)btn
{

}
- (void)clickOpen:(UIButton *)btn
{
    
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -KHJDeviceManagerDelegate

- (void)setTimedRecordVideoTaskCallback:(bool)success
{
    if (success) {
        CLog(@"添加录像任务成功");
        
        CLog(@"Successfully added recording task");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_SuccessType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"addSuccess", nil)];
        });
        WeakSelf
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf backViewController];
        });
        
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_ErrorType
                                              toastPostion:_CenterPostion
                                                       tip:KHJLocalizedString(@"tips", nil)
                                                   content:KHJLocalizedString(@"addFail", nil)];
        });
        CLog(@"添加录像任务失败");
        
        CLog(@"Failed to add recording task");
    }
}
- (void)successCallbackAddTimedCameraTask:(bool)success
{
  
    if (success) {
        CLog(@"添加定时成功");
        
        CLog(@"Add timing success");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_SuccessType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"addSuccess", nil)];
        });
        WeakSelf
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf backViewController];
        });
        
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_ErrorType
                                              toastPostion:_CenterPostion
                                                       tip:KHJLocalizedString(@"tips", nil)
                                                   content:KHJLocalizedString(@"addFail", nil)];
        });
        CLog(@"添加定时失败");
        
        CLog(@"Failed to add timer");
    }
}


@end

















