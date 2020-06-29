//
//  TimeVController.m
//
//
//
//
//

#import "TimeVController.h"
#import "KHJAllBaseManager.h"

@interface TimeVController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *TAreaTable;
    NSArray *areaArray;
    UIView *backgroundView;
    
    // 当前的时区索引
    // Current time zone index
    __block NSInteger currentIndex;
    
    // 改变之前的
    // Before the change
    __block NSInteger preIndex;
    
    // 显示时区
    // Show time zone
    UILabel *showAreaLab;
}
@end

@implementation TimeVController



- (void)viewDidLoad {
    [super viewDidLoad];
        areaArray = [NSArray arrayWithObjects:@"UTC-11",@"UTC-10",@"UTC-9",@"UTC-8",@"UTC-7",@"UTC-6",@"UTC-5",@"UTC-4",@"UTC-3.5",@"UTC-3",@"UTC-2",@"UTC-1",@"UTC+0",@"UTC+1",@"UTC+2",@"UTC+3",@"UTC+3.5",@"UTC+4",@"UTC+4.5",@"UTC+5",@"UTC+5.5",@"UTC+6",@"UTC+6.5",@"UTC+7",@"UTC+8",@"UTC+9",@"UTC+9.5",@"UTC+10",@"UTC+11",@"UTC+12", nil];
    self.title = KHJLocalizedString(@"timeSet", nil);
    [self setbackBtn];
    self.view.backgroundColor = bgVCcolor;
    [self setShowView];
    
    TAreaTable = [self getTable];
    TAreaTable.dataSource = self;
    TAreaTable.delegate = self;
    
    [self getTimeZome];
    
}
- (void)getTimeZome
{
//    DeviceManager.delegate = self;
//    [DeviceManager getTimeZone:self.uuidStr];
    
    WeakSelf
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
    if (dDevice) {
        
        [dDevice.mDeviceManager getTimeZone:^(int success) {
           
            [weakSelf backSuccessCallbackGetTimezone:success];
        }];
    }
    
}
- (void)backSuccessCallbackGetTimezone:(int)success
{
    switch (success) {
        case -660:{
            currentIndex = 0;
        }
            break;
        case -600:{
            currentIndex = 1;
        }
            break;
        case -540:{
            currentIndex = 2;
        }
            break;
        case -480:{
            currentIndex = 3;
        }
            break;
        case -420:{
            currentIndex = 4;
        }
            break;
        case -360:{
            currentIndex = 5;
        }
            break;
        case -300:{
            currentIndex = 6;
        }
            break;
        case -240:{
            currentIndex = 7;
        }
            break;
        case -210:{
            currentIndex = 8;
        }
            break;
        case -180:{
            currentIndex = 9;
        }
            break;
            //            @"UTC-2",@"UTC-1",@"UTC+0",@"UTC+1",@"UTC+2",@"UTC+3",@"UTC+3.5",@"UTC+4",@"UTC+4.5",
            
        case -120:{
            currentIndex = 10;
        }
            break;
        case -60:{
            currentIndex = 11;
        }
            break;
        case 0:{
            currentIndex = 12;
        }
            break;
        case 60:{
            currentIndex = 13;
        }
            break;
        case 120:{
            currentIndex = 14;
        }
            break;
        case 180:{
            currentIndex = 15;
        }
            break;
        case 210:{
            currentIndex = 16;
        }
            break;
        case 240:{
            currentIndex = 17;
        }
            break;
        case 270:{
            currentIndex = 18;
        }
            break;
            //            @"UTC+5",@"UTC+5.5",@"UTC+6",@"UTC+6.5",@"UTC+7",@"UTC+8",@"UTC
        case 300:{
            currentIndex = 19;
        }
            break;
        case 330:{
            currentIndex = 20;
        }
            break;
        case 360:{
            currentIndex = 21;
        }
            break;
        case 390:{
            currentIndex = 22;
        }
            break;
        case 420:{
            currentIndex = 23;
        }
            break;
        case 480:{
            currentIndex = 24;
        }
            break;
            //            @"UTC+9",@"UTC+9.5",@"UTC+10",@"UTC+11",@"UTC+12", nil];
        case 540:{
            currentIndex = 25;
        }
            break;
        case 570:{
            currentIndex = 26;
        }
            break;
        case 600:{
            currentIndex = 27;
        }
            break;
        case 660:{
            currentIndex = 28;
        }
            break;
        case 720:{
            currentIndex = 29;
        }
            break;
        default:
            break;
    }
    
    __weak typeof(TAreaTable) tTable = TAreaTable;
    __weak typeof(showAreaLab) sLab = showAreaLab;
    __weak typeof(areaArray) aArray = areaArray;
    __block NSInteger Sindex = currentIndex;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        sLab.text = [aArray objectAtIndex:Sindex];
        if (tTable) {
            
            [tTable reloadData];
        }
        
    });
    
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

- (UITableView *)getTable
{
    if (!TAreaTable) {
        TAreaTable = [[UITableView alloc] initWithFrame:CGRectMake(10, 40, SCREENWIDTH-20, SCREENHEIGHT-50) style:UITableViewStylePlain];
    }
    return TAreaTable;
}

- (void)setShowView
{
    UIButton *but = [[UIButton alloc] initWithFrame:CGRectMake(0, 10, SCREENWIDTH, 44)];
    [but setTitle:@"设置时区" forState:UIControlStateNormal];
    [but setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    but.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    but.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    [but setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:but];
    showAreaLab = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH/2, 0, SCREENWIDTH/2-54, 44)];
    showAreaLab.textColor = [UIColor blueColor];
    [showAreaLab setTextAlignment:NSTextAlignmentRight];
//    showAreaLab.text = [areaArray objectAtIndex:currentIndex];
//    [lab setBackgroundColor:[UIColor purpleColor]];
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(SCREENWIDTH-54, 0, 44, 44)];
    imgV.image = [UIImage imageNamed:@"arrowdown"];
    [but addSubview:showAreaLab];
    [but addSubview:imgV];
    [but addTarget:self action:@selector(clickBut:) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)clickBut:(UIButton *)btn
{
    CLog(@"clickBut");
    [self addShadow];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self setTable];

    });
}
- (void)setTable
{
    [[[UIApplication sharedApplication] keyWindow] addSubview:TAreaTable];
    [TAreaTable reloadData];
}
#pragma mark - UITableViewDelegate, UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [areaArray count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"TimeCell";
  
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        
    }
    if (indexPath.row == currentIndex) {
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
        img.image = [UIImage imageNamed:@"icon_select"];
        cell.accessoryView = img;
    }else{
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
        img.image = [UIImage imageNamed:@"icon_unselect"];
        cell.accessoryView = img;
    }
    cell.textLabel.text = [areaArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    preIndex = indexPath.row;
    [self changArea:preIndex];
    [backgroundView removeFromSuperview];

    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 44.f;
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREENHEIGHT-20, 44)];
    lab.text = @"设置时区";
    lab.textColor = [UIColor blackColor];
    lab.backgroundColor = [UIColor whiteColor];
    lab.textAlignment = NSTextAlignmentLeft;
    return lab;
}


- (void)changArea:(NSInteger) index
{
    [TAreaTable removeFromSuperview];
    // 发送命令
    
    // send command
    
    // 参数是分钟，如+8 ，则 +480， -6，则-360
    
    // The parameter is minutes, such as +8, then +480, -6, then -360
    
    NSInteger timeZone = 0;
    switch (index) {
        case 0:
            timeZone = -11*60;
            break;
        case 1:
            timeZone = -10*60;
            break;
        case 2:
            timeZone = -9*60;
            break;
        case 3:
            timeZone = -8*60;
            break;
        case 4:
            timeZone = -7*60;
            break;
        case 5:
            timeZone = -6*60;
            break;
        case 6:
            timeZone = -5*60;
            break;
        case 7:
            timeZone = -4*60;
            break;
        case 8:
            timeZone = -3.5*60;
            break;
        case 9:
            timeZone = -3*60;
            break;
        case 10:
            timeZone = -2*60;
            break;
        case 11:
            timeZone = -1*60;
            break;
        case 12:
            timeZone = 0;
            break;
            
        case 13:
            timeZone = 60;
            break;
        case 14:
            timeZone = 2*60;
            break;
        case 15:
            timeZone = 3*60;
            break;
        case 16:
            timeZone = 3.5*60;
            break;
        case 17:
            timeZone = 4*60;
            break;
        case 18:
            timeZone = 4.5*60;
            break;
        case 19:
            timeZone = 5*60;
            break;
        case 20:
            timeZone = 5.5*60;
            break;
        case 21:
            timeZone = 6*60;
            break;
        case 22:
            timeZone = 6.5*60;
            break;
        case 23:
            timeZone = 7*60;
            break;
        case 24:
            timeZone = 8*60;
            break;
        case 25:
            timeZone = 9*60;
            break;
        case 26:
            timeZone = 9.5*60;
            break;
        case 27:
            timeZone = 10*60;
            break;
        case 28:
            timeZone = 11*60;
            break;
            
        case 29:
            timeZone = 12*60;
            break;

        default:
            break;
    }
    
    WeakSelf
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
    if (dDevice) {
        
       [dDevice.mDeviceManager setTimezone:timeZone returnBlock:^(BOOL success) {
            [weakSelf backSuccessCallbackSetTimezone:success];
        }];
    }
}
- (void)backSuccessCallbackSetTimezone:(bool)success
{
    if (success) {
        
        WeakSelf
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[KHJToast share] showToastActionWithToastType:_WarningType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"setSuccess", nil)];
            [weakSelf changeSuccess];
        });
        
    }else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_WarningType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"setFail", nil)];
        });
    }
}

- (void)addShadow
{
    backgroundView = [[UIView alloc] init];
    backgroundView.frame = CGRectMake(0, 1,SCREENWIDTH,SCREENHEIGHT);
    backgroundView.backgroundColor = [UIColor colorWithRed:(40/255.0f) green:(40/255.0f) blue:(40/255.0f) alpha:1.0f];
    backgroundView.alpha = 0.6;
    [[[UIApplication sharedApplication] keyWindow] addSubview:backgroundView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changeSuccess
{
    showAreaLab.text = [areaArray objectAtIndex:preIndex];
    currentIndex = preIndex;
}
@end














