//
//  DeviceSwitchVController.m
//
//  定时开关机
//
//
//

#import "KHJDeviceSwitchVController.h"
#import "KHJAllBaseManager.h"
#import <KHJCameraLib/KHJCameraLib.h>
//#import "KHJDeviceManager.h"
//#import "TimeInfo.h"
#import "KHJSetStartAndEndTimeVController.h"
#import "PlanCell.h"
#import "Calculate.h"

#define CELLHEIGHT 80

@interface KHJDeviceSwitchVController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *ttMarray;//保存设备的计划
    UISwitch *switchView;
    CGFloat TTableHeight;
    UITableView *ttTable;
}
@end

@implementation KHJDeviceSwitchVController

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

- (void)getDevicePlanList
{
    WeakSelf
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
    if (dDevice) {
        [dDevice.mDeviceManager getTimedCameraTask:^(NSMutableArray *mArray) {
            [weakSelf backTimedCameraTask:mArray];
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    ttMarray = [NSMutableArray array];
    self.title = KHJLocalizedString(@"TimingSwitch", nil);
    self.view.backgroundColor = bgVCcolor;
    [self setbackBtn];
    [self setMainView];
}

- (void)setMainView
{
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 66)];
    tipLabel.backgroundColor = bgVCcolor;
    tipLabel.numberOfLines = 2;
    tipLabel.font = [UIFont systemFontOfSize:15.f];
    tipLabel.textColor = UIColor.lightGrayColor;
    tipLabel.text = [NSString stringWithFormat:@"(%@)",KHJLocalizedString(@"onoffPlan", nil)];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:tipLabel];
    TTableHeight = SCREENHEIGHT - (tipLabel.frame.origin.y+tipLabel.frame.size.height)-64;
    ttTable = [[UITableView alloc] initWithFrame:CGRectMake(0, tipLabel.frame.origin.y+tipLabel.frame.size.height, SCREENWIDTH, 60) style:UITableViewStylePlain];
    ttTable.delegate = self;
    ttTable.dataSource = self;
    ttTable.bounces = NO;
    ttTable.showsVerticalScrollIndicator = NO;
    [self.view addSubview:ttTable]; 
}
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
#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

        return [ttMarray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"timeCell";
    PlanCell *cell = (PlanCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {

        cell = [[PlanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    TimeInfo *tInfo = [ttMarray objectAtIndex:indexPath.row];
    
    NSString *Cstring = [Calculate getTimeFormat:tInfo.closeTime];
    NSString *Ostring = [Calculate getTimeFormat:tInfo.openTime];

    cell.closeLab.text =  Cstring;
    NSInteger clTime = [Calculate getUTCTime:Cstring];
    NSInteger olTime = [Calculate getUTCTime:Ostring];

    if (clTime> olTime) {
        cell.openLab.text = [NSString stringWithFormat:@"%@%@",Ostring,KHJLocalizedString(@"nextDay", nil)];
    }else
        cell.openLab.text =  Ostring;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELLHEIGHT;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    KHJSetStartAndEndTimeVController *sAndEndVC = [[KHJSetStartAndEndTimeVController alloc] init];
    sAndEndVC.sIndex = indexPath.row;
    sAndEndVC.vIndex = 0;
    sAndEndVC.planArray = ttMarray;
    sAndEndVC.uuidStr = self.uuidStr;
    [self.navigationController pushViewController:sAndEndVC animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
   
    return 60;

}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIButton *but = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 60)];
    [but setTitle:KHJLocalizedString(@"addPlan", nil) forState:UIControlStateNormal];
    [but setBackgroundColor:[UIColor whiteColor]];
    but.titleLabel.font = [UIFont systemFontOfSize:22];
    [but setTitleColor:DeCcolor forState:UIControlStateNormal];
    [but addTarget:self action:@selector(addPlan) forControlEvents:UIControlEventTouchUpInside];
    
    but.layer.borderWidth = 1;
    but.layer.borderColor = bgVCcolor.CGColor;
    return but;

}
- (void)addPlan//添加计划
{
    KHJSetStartAndEndTimeVController *sAndEndVC = [[KHJSetStartAndEndTimeVController alloc] init];
    sAndEndVC.sIndex = -1;
    sAndEndVC.vIndex = 0;
    sAndEndVC.planArray = ttMarray;
    sAndEndVC.uuidStr = self.uuidStr;
    [self.navigationController pushViewController:sAndEndVC animated:YES];
}

#pragma mark - KHJDeviceManagerDelegate
- (void)backTimedCameraTask:(NSArray *)taskArray
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
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            CGRect fra = weakTtable.frame;
            
            fra.size.height = CELLHEIGHT * count +60;
            if (fra.size.height >= hh) {
                fra.size.height = hh;
            }
            weakTtable.frame = fra;
            [weakTtable reloadData];
        });
    }
    
}

@end




































