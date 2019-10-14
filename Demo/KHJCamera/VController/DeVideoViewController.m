//
//  KHJVideoViewController.m
//  TestRunloop
//
//  Created by khj888 on 2018/12/5.
//  Copyright © 2018 kevin. All rights reserved.
//

#import "DeVideoViewController.h"
#import "KHJVideoTBCell.h"
#import "JKUIPickDate.h"
#import "RemberUserListView.h"
#import "LvedioViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

// 任务block
typedef void(^runloopBlock)(void);

@interface DeVideoViewController () <UITableViewDelegate,UITableViewDataSource>
{
    UIButton *leftBarItemBtn;       //左边按钮
    UIButton *rightBar_editBtn;     //选择按钮
    UIButton *rightBar_deleteBtn;   //删除按钮
    
    // 当前是否处于编辑状态
    bool isEdit;
    // 是否全选
    bool isAllSelect;
    
    BOOL isSelected;
    UIView *selectBGView;
    UIView *collectBGView;
    
    UIButton *dateBtn;
    UIButton *devBtn;
    NSMutableArray *deviceArr;              //不同的设备
    RemberUserListView *remListView;
    
    NSMutableArray *sortSourceArr;
    NSMutableArray *editArray;              //存放编辑状态下，已经选中的cell。
    NSMutableDictionary *sortSourceDict;    //用字典存日期分类的视频
    NSString *checkDateStr;     //选择日期查看
    NSString *checkDevName;     //选择设备查看
    __weak IBOutlet UITableView *contentTableView;
}

// 所有图片、视频数组
@property (nonatomic, strong) NSMutableArray *sourceArr;

@end

@implementation DeVideoViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sourceArr      = [NSMutableArray array];
        sortSourceArr   = [NSMutableArray array];
        editArray       = [NSMutableArray array];
        sortSourceDict  = [NSMutableDictionary dictionary];
        deviceArr       = [NSMutableArray arrayWithObject:KHJLocalizedString(@"allDevice", nil)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeDataSource];
    [self customizeAppearance];
}

- (void)customizeDataSource
{
    self.navigationItem.title = KHJLocalizedString(@"discovery", nil);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCollectionView) name:reloadVideoVC_Noti object:nil];
}

- (void)reloadCollectionView
{
    if (collectBGView) {
        [self getRefreshData];
    }
}

- (void)customizeAppearance
{
    [self setLeftButton];
    [self setRightButton];
    [self setColletBGView];
    [self setSelectBgView];
    [self getRefreshData];
}

#pragma mark - private

- (void)setLeftButton
{
    leftBarItemBtn  = [self get_leftBarItemBtn];
    UIBarButtonItem *informationCardItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarItemBtn];
    self.navigationItem.leftBarButtonItem = informationCardItem;
}

- (void)setRightButton
{
    rightBar_editBtn            = [self get_rightBar_editBtn];
    rightBar_deleteBtn          = [self getrightBar_deleteBtn];
    UIBarButtonItem *editItem   = [[UIBarButtonItem alloc] initWithCustomView:rightBar_editBtn];
    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithCustomView:rightBar_deleteBtn];
    self.navigationItem.rightBarButtonItems  = @[editItem,deleteItem];
    rightBar_deleteBtn.hidden   = YES;
}

- (UIButton *)get_leftBarItemBtn
{
    if (leftBarItemBtn == nil) {
        leftBarItemBtn          = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBarItemBtn.frame    = CGRectMake(0,0, 66, 44);
        [leftBarItemBtn addTarget:self action:@selector(leftBarItemBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [leftBarItemBtn setTitle:KHJLocalizedString(@"filtrate", nil) forState:UIControlStateNormal];
        leftBarItemBtn.titleLabel.font = [UIFont systemFontOfSize: 15.0];
    }
    return leftBarItemBtn;
}

- (UIButton *)get_rightBar_editBtn
{
    if(rightBar_editBtn == nil) {
        rightBar_editBtn        = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBar_editBtn.frame  = CGRectMake(0,0, 66, 46);
        [rightBar_editBtn addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
        [rightBar_editBtn setTitle:KHJLocalizedString(@"select", nil) forState:UIControlStateNormal];
        rightBar_editBtn.titleLabel.font = [UIFont systemFontOfSize: 15.0];
    }
    return rightBar_editBtn;
}

- (UIButton *)getrightBar_deleteBtn
{
    if(rightBar_deleteBtn == nil) {
        rightBar_deleteBtn       = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBar_deleteBtn.frame = CGRectMake(0,0,46,46);
        [rightBar_deleteBtn addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
        [rightBar_deleteBtn setImage:[UIImage imageNamed:@"screenshot_delete_white"] forState:UIControlStateNormal];
    }
    return rightBar_deleteBtn;
}

- (void)editAction:(UIButton *)btn
{
    if (!isEdit) {
        rightBar_deleteBtn.hidden = NO;
        // 全选
        [rightBar_editBtn setTitle:KHJLocalizedString(@"selectALL", nil) forState:UIControlStateNormal];
        // 筛选
        [leftBarItemBtn setTitle:@"" forState:UIControlStateNormal];
        [leftBarItemBtn setBackgroundImage:[UIImage imageNamed:@"bt_shutdown"] forState:UIControlStateNormal];
        isEdit = !isEdit;
        isAllSelect = NO;
    }
    else {
        isAllSelect = !isAllSelect;
        if (isAllSelect) {
            [editArray removeAllObjects];
            [editArray addObjectsFromArray:self.sourceArr];
            // 取消
            [rightBar_editBtn setTitle:KHJLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
        }
        else {
            [editArray removeAllObjects];
            // 全选
            [rightBar_editBtn setTitle:KHJLocalizedString(@"selectALL", nil) forState:UIControlStateNormal];
        }
    }
    [contentTableView setContentOffset:contentTableView.contentOffset animated:YES];
    [contentTableView reloadData];
}

#pragma mark - deleteClick

- (void)deleteClick:(UIButton *)btn
{
    CLog(@"deleteClick");
    if ([editArray count] == 0) {
        [[DeToast share] showToastActionWithToastType:_WarningType
                                          toastPostion:_CenterPostion
                                                   tip:@""
                                               content:KHJLocalizedString(@"chooseNoPicture", nil)];
    }
    else {
        [self showAlert];
    }
}

- (void)showAlert
{
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"deleteFile", nil)
                                                                       message:KHJLocalizedString(@"ensureDeleteSelectFile", nil)
                                                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    WeakSelf
    UIAlertAction *defult = [UIAlertAction actionWithTitle:KHJLocalizedString(@"commit", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf deleteSelectFile];
    }];
    [alertview addAction:cancel];
    [alertview addAction:defult];
    [self presentViewController:alertview animated:YES completion:nil];
}

///
- (void)deleteSelectFile
{
    
}
//{
//    CLog(@"thread = %@",[NSThread currentThread]);
//
//    NSString * docPath      = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *khjFileName   = [NSString stringWithFormat:@"KHJFileName_%@",SaveManager.userID];//关联账户
//    khjFileName             = [docPath stringByAppendingPathComponent:khjFileName];
//    __weak typeof(contentTableView) weakContentTB       = contentTableView;
//    __weak typeof(sortSourceDict) weakSortSourceDict    = sortSourceDict;
//
//    __block NSMutableArray *allKey      = [NSMutableArray arrayWithArray:[sortSourceDict allKeys]];
//    __block NSMutableArray *valueArr    = [NSMutableArray array];
//
//    for (int i = 0; i < editArray.count; i++) {
//        NSString *path              = editArray[i];
//        NSString *deleteFileName    = [khjFileName stringByAppendingPathComponent:path];
//        NSLock *myLock              = [[NSLock alloc] init];
//        [myLock lock];
//        BOOL ret                    = [[KHJHelpCameraData sharedModel] DeleateFileWithPath:deleteFileName];
//        [myLock unlock];
//
//        if (ret) {
//            CLog(@"删除成功");
//            NSArray *_subAllKey = [allKey copy];
//
//            for (NSString *key in _subAllKey) {
//
//                valueArr = [weakSortSourceDict[key] mutableCopy];
//                bool isDelete = NO;
//                for (NSString *path in valueArr) {
//
//                    NSString * pathaaa = [khjFileName stringByAppendingPathComponent:path];
//                    if ([pathaaa isEqualToString:deleteFileName]) {
//                        isDelete = YES;
//                        [valueArr removeObject:path];
//                        NSLog(@"valueArr = %@",valueArr);
//
//                        [sortSourceDict setObject:valueArr forKey:key];
//                        NSLog(@"sortSourceDict = %@",sortSourceDict);
//                        break;
//                    }
//                }
//                if (isDelete) {
//                    if (valueArr.count == 0) {
//                        [allKey removeObject:key];
//                        [sortSourceDict removeObjectForKey:key];
//                    }
//                    break;
//                }
//            }
//        }
//        else {
//            CLog(@"删除失败");
//        }
//    }
//
//    WeakSelf
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (weakSortSourceDict.count == 0) {
//            self->isSelected = NO;
//            [weakSelf leftBarItemBtnClick:self->leftBarItemBtn];
//        }
//        [weakContentTB setContentOffset:weakContentTB.contentOffset animated:YES];
//        [weakContentTB reloadData];
//    });
//}

- (void)leftBarItemBtnClick:(UIButton *)btn
{
    if(isEdit) {
        if(!isSelected) {
            [leftBarItemBtn setTitle:KHJLocalizedString(@"filtrate", nil) forState:UIControlStateNormal];
        }
        else {
            [leftBarItemBtn setTitle:KHJLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
        }
        isEdit = !isEdit;
        rightBar_deleteBtn.hidden = YES;
        [rightBar_editBtn setTitle:KHJLocalizedString(@"select", nil) forState:UIControlStateNormal];
        [leftBarItemBtn setBackgroundImage:nil forState:UIControlStateNormal];
        [editArray removeAllObjects];
        [contentTableView setContentOffset:contentTableView.contentOffset animated:YES];
        [contentTableView reloadData];
    }
    else {
        if (isSelected) {
            [leftBarItemBtn setTitle:KHJLocalizedString(@"filtrate", nil) forState:UIControlStateNormal];
            [dateBtn        setTitle:KHJLocalizedString(@"allDate", nil) forState:UIControlStateNormal];
            [devBtn         setTitle:KHJLocalizedString(@"allDevice", nil) forState:UIControlStateNormal];
        }
        else {
            [leftBarItemBtn setTitle:KHJLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
        }
        [self setAnimationView];
    }
}

- (void)setAnimationView
{
    if(!isSelected) {
        [self showSelectView];
    }
    else {
        [self hiddenSelectView];
    }
    isSelected = !isSelected;
}

- (void)showSelectView
{
    __weak typeof(selectBGView) weakSelectBGView        =   selectBGView;
    __weak typeof(collectBGView) weakCollectBGView      =   collectBGView;
    __weak typeof(contentTableView) weakCcontentTV      =   contentTableView;
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect rect = weakSelectBGView.frame;
        rect.origin.y       += 44;
        weakSelectBGView.frame = rect;
        
        rect = weakCollectBGView.frame;
        rect.origin.y       += 44;
        rect.size.height    -= 44;
        weakCollectBGView.frame = rect;
        
        rect = weakCcontentTV.frame;
        rect.origin.y       += 44;
        rect.size.height    -= 44;
        weakCcontentTV.frame = rect;
    }];
}

- (void)hiddenSelectView
{
    __weak typeof(selectBGView) weakSelectBGView        =   selectBGView;
    __weak typeof(collectBGView) weakCollectBGView      =   collectBGView;
    __weak typeof(contentTableView) weakCcontentTV      =   contentTableView;

    [UIView animateWithDuration:0.25 animations:^{
        CGRect rect = weakSelectBGView.frame;
        rect.origin.y       = -44;
        weakSelectBGView.frame = rect;
        
        rect = weakCollectBGView.frame;
        rect.origin.y       = 0;
        rect.size.height    = SCREEN_HEIGHT - 64 - 10 - 44;
        weakCollectBGView.frame = rect;
        
        rect = weakCcontentTV.frame;
        rect.origin.y       = 0;
        rect.size.height    = SCREEN_HEIGHT - 64 - 10 - 44;
        weakCcontentTV.frame = rect;
    } completion:^(BOOL finished) {
        weakSelectBGView.alpha  = 1;
        weakCollectBGView.alpha = 1;
        
    }];
}

#pragma mark - SETBgView

- (void)setSelectBgView
{
    selectBGView = [self getSelectBgView];
    [self.view addSubview:selectBGView];
    [self.view bringSubviewToFront:selectBGView];
    
    dateBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2, 44)];
    [dateBtn setTitle:KHJLocalizedString(@"allDate", nil) forState:UIControlStateNormal];
    dateBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [dateBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [dateBtn addTarget:self action:@selector(clickDate:) forControlEvents:UIControlEventTouchUpInside];
    
    devBtn = [[UIButton alloc] initWithFrame:CGRectMake( SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2, 44)];
    [devBtn setTitle:KHJLocalizedString(@"allDevice", nil) forState:UIControlStateNormal];
    devBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [devBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [devBtn addTarget:self action:@selector(clickCate:) forControlEvents:UIControlEventTouchUpInside];
    
    [selectBGView addSubview:dateBtn];
    [selectBGView addSubview:devBtn];
    
    CGFloat xx          = dateBtn.frame.size.width - 42;
    UIImageView *imgV1  = [[UIImageView alloc] initWithFrame:CGRectMake(xx, 6, 32, 32)];
    imgV1.image         = [UIImage imageNamed:@"arrowdown"];
    [dateBtn addSubview:imgV1];
    UIImageView *imgV2  = [[UIImageView alloc] initWithFrame:CGRectMake(xx, 6, 32, 32)];
    imgV2.image         = [UIImage imageNamed:@"arrowdown"];
    [devBtn addSubview:imgV2];
}

//日期选择
- (void)clickDate:(UIButton *)btn
{
    WeakSelf
    __weak typeof(dateBtn) weakDateBtn = dateBtn;
    JKUIPickDate *pickdate = [JKUIPickDate setDate];
    [pickdate passvalue:^(NSString *str) {
        [weakDateBtn setTitle:str forState:UIControlStateNormal];
        [weakSelf hiddenSelectView];
        [weakSelf checkFileWithDate:str];
    }];
    pickdate.cancelBlock = ^{
        [weakSelf hiddenSelectView];
        [weakDateBtn setTitle:KHJLocalizedString(@"allDate", nil) forState:UIControlStateNormal];
        [weakSelf getRefreshData];
    };
}


/**
 指定设备查询设备

 @param deviceName 设备名称
 */
- (void)checkFileWithDevName:(NSString *)deviceName
{
    checkDevName = deviceName;
    NSString *checkDateStr = dateBtn.titleLabel.text;
    checkDateStr = [checkDateStr stringByReplacingOccurrencesOfString:@"_" withString:@""];
    //逻辑分析，设备不限
    if([deviceName isEqualToString:KHJLocalizedString(@"allDevice", nil)]) {
        if ([checkDateStr isEqualToString:KHJLocalizedString(@"allDate", nil)]) {
            [self getRefreshData];
        }
        else {
            [self getRefreshDataWithDate:checkDateStr];
        }
    }
    else {
        if ([checkDateStr isEqualToString:KHJLocalizedString(@"allDate", nil)]) {
            [self getRefreshDataWithDevName:deviceName];
        }
        else {
            [self getRefreshDataWithDevName:deviceName andWithDate:checkDateStr];
        }
    }
}


/**
 指定日期查询数据

 @param dateStr 日期
 */
- (void)checkFileWithDate:(NSString *)dateStr
{
    checkDateStr            = [dateStr stringByReplacingOccurrencesOfString:@"_" withString:@""];
    NSString *checkDevName  = devBtn.titleLabel.text;
    
    if ([checkDateStr isEqualToString:KHJLocalizedString(@"allDate", nil)]) {
        if ([checkDevName isEqualToString:KHJLocalizedString(@"allDevice", nil)]) {
            [self getRefreshData];
        }
        else {
            [self getRefreshDataWithDevName:checkDevName];
        }
    }
    else {
        if ([checkDevName isEqualToString:KHJLocalizedString(@"allDevice", nil)]) {
            [self getRefreshDataWithDate:checkDateStr];
        }
        else {
            [self getRefreshDataWithDevName:checkDevName andWithDate:checkDateStr];
        }
    }
}


/**
 指定设备，指定日期查找数据

 @param devName 设备名称
 @param dateStr 日期
 */
- (void)getRefreshDataWithDevName:(NSString *)devName andWithDate:(NSString *)dateStr
{
    
}
//{
//    [_sourceArr removeAllObjects];
//    NSArray *allFileArr = [[KHJHelpCameraData sharedModel] getAllFile];
//    NSMutableArray *tarr = [NSMutableArray array];
//    for (NSString *ss in allFileArr) {
//        if ([ss containsString:devName] && [ss containsString:dateStr]) {
//            [tarr addObject:ss];
//        }
//    }
//    if ([tarr count] == 0) {
//        collectBGView.hidden = NO;
//    }
//    else {
//        [_sourceArr addObjectsFromArray:tarr];
//        [self sortFile];
//    }
//}

- (void)getRefreshDataWithDevName:(NSString *)devName//获取数据刷新界面
{
    
}
//{
//    [_sourceArr removeAllObjects];
//    NSArray *allFileArr = [[KHJHelpCameraData sharedModel] getAllFile];
//    NSMutableArray *tarr = [NSMutableArray array];
//    for (NSString *ss in allFileArr) {
//        if ([ss containsString:devName]) {
//            [tarr addObject:ss];
//        }
//    }
//    if ([tarr count] == 0) {
//        collectBGView.hidden = NO;
//    }
//    else {
//        [_sourceArr addObjectsFromArray:tarr];
//        CLog(@"_sourceArr = %@",_sourceArr);
//        [self sortFile];
//    }
//}

- (void)getRefreshDataWithDate:(NSString *)dateStr//获取数据刷新界面
{
    
}
//{
//    [_sourceArr removeAllObjects];
//    NSArray *allFileArr = [[KHJHelpCameraData sharedModel] getAllFile];
//    NSMutableArray *tarr = [NSMutableArray array];
//    for (NSString *ss in allFileArr) {
//        if ([ss containsString:dateStr]) {
//            [tarr addObject:ss];
//        }
//    }
//    if ([tarr count] == 0) {
//        isSelected = NO;
//        collectBGView.hidden = NO;
//        [leftBarItemBtn setTitle:KHJLocalizedString(@"filtrate", nil) forState:UIControlStateNormal];
//    }
//    else {
//        [_sourceArr addObjectsFromArray:tarr];
//        [self sortFile];
//    }
//}

- (RemberUserListView *)getRemUserList
{
    if (remListView == nil) {
        remListView = [[RemberUserListView alloc] init];
    }
    return remListView;
}

- (void)clickCate:(UIButton *)btn//类别选择
{
    NSArray * dvArr = [[NSUserDefaults standardUserDefaults] objectForKey:@"AllDevices"];
    [deviceArr removeAllObjects];
    [deviceArr addObject:KHJLocalizedString(@"allDevice", nil)];
    
    if (dvArr && [dvArr count] != 0) {
        [deviceArr addObjectsFromArray:dvArr];
    }
    if (deviceArr && [deviceArr count] != 0) {
        remListView = [self getRemUserList];
        remListView.dataArray = deviceArr;
        [self handleListView];
    }
}

- (void)handleListView
{
    UIWindow *desWindow = [UIApplication sharedApplication].keyWindow;
    CGRect frame        = [selectBGView convertRect:selectBGView.bounds toView:desWindow];
    CGFloat rWidth      = 240;
    CGRect rg           = remListView.frame;
    rg.origin           = CGPointMake(frame.size.width +frame.origin.x - rWidth-20,frame.size.height+frame.origin.y);
    if ([deviceArr count] < 3) {
        rg.size = CGSizeMake(rWidth, [deviceArr count] * 40);
    }
    else {
        rg.size = CGSizeMake(rWidth, 3 * 40);
    }
    remListView.frame = rg;
    [remListView show];
    [remListView refreshTable];
    __block NSString *currentTitle      = devBtn.currentTitle ;
    __weak typeof(devBtn) weakDevBtn    = devBtn;
    WeakSelf
    [remListView setTableClickBlock:^(NSString * str ) {
        CLog(@"setTableClickBlock");
        if (![str isEqualToString:currentTitle]) {
            [weakDevBtn setTitle:str forState:UIControlStateNormal];
            [weakSelf checkFileWithDevName:str];
        }
    }];
}

- (UIView *)getSelectBgView
{
    if (selectBGView == nil) {
        selectBGView = [[UIView alloc] initWithFrame:CGRectMake(0, -44, SCREEN_WIDTH, 44)];
        selectBGView.backgroundColor = UIColor.whiteColor;
    }
    return selectBGView;
}

- (void)setColletBGView
{
    collectBGView   = [self getColletGBview];
    UILabel *tipLabel       = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    tipLabel.text           = KHJLocalizedString(@"noLocalVideos", nil);
    tipLabel.font           = [UIFont systemFontOfSize:15];
    tipLabel.textColor      = UIColor.grayColor;
    tipLabel.textAlignment  = NSTextAlignmentCenter;
    tipLabel.center         = collectBGView.center;
    [collectBGView addSubview:tipLabel];
    [self.view addSubview:collectBGView];
    [self.view bringSubviewToFront:collectBGView];
}

- (UIView *)getColletGBview
{
    if (collectBGView == nil) {
        collectBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 10 - 44)];
        collectBGView.backgroundColor = bgVCcolor;
        collectBGView.userInteractionEnabled = YES;
    }
    return collectBGView;
}

- (void)getRefreshData//获取数据刷新界面
{
    
}
//{
//    [_sourceArr removeAllObjects];
//    NSArray *allFileArr = [[KHJHelpCameraData sharedModel] getAllFile];
//    __weak typeof(collectBGView) weakCollectBGView = collectBGView;
//    if ([allFileArr count] == 0) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            weakCollectBGView.hidden = NO;
//        });
//        return;
//    }
//    else {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            weakCollectBGView.hidden = YES;
//        });
//    }
//    [_sourceArr addObjectsFromArray:allFileArr];
//    CLog(@"_sourceArr = %@",_sourceArr);
//    [self sortFile];
//}

- (void)sortFile
{
    [sortSourceArr removeAllObjects];
    [sortSourceDict removeAllObjects];

    NSMutableArray *arr1 = [NSMutableArray array];
    for (NSString *s  in self.sourceArr) {
        NSArray *aa     = [s componentsSeparatedByString:@"-"];
        NSString *bs    = [aa objectAtIndex:0];
        NSArray *bb     = [bs componentsSeparatedByString:@"/"];
        [arr1 addObject:[bb lastObject]];
    }
    arr1            = [Calculate bubbleDescendingOrderSortWithArray:arr1];
    sortSourceArr   = [Calculate calCategoryArray:arr1];
    
    NSMutableArray *subSourceArray = [NSMutableArray array];
    [subSourceArray addObjectsFromArray:self.sourceArr];
    for(int j = 0; j < [sortSourceArr count]; j++){
        
        NSNumber *numDate       = [sortSourceArr objectAtIndex:j];
        NSString *singleDate    = [NSString stringWithFormat:@"%ld",(long)[numDate integerValue]];
        NSMutableArray *singlDaySourceArr   = [NSMutableArray array];
        
        for(int i = 0; i < [subSourceArray count]; i++) {
            NSString *obj = subSourceArray[i];
            if ([obj containsString:singleDate]) {
                [singlDaySourceArr addObject:obj];
                [subSourceArray removeObjectAtIndex:i];
                i--;
            }
        }
        [sortSourceDict setObject:singlDaySourceArr forKey:singleDate];
    }
    
    WeakSelf
    __weak typeof(selectBGView) weakSelectBGView        = selectBGView;
    __weak typeof(collectBGView) weakCollectBGView      = collectBGView;
    __weak typeof(leftBarItemBtn) weakLeftBarItemBtn    = leftBarItemBtn;
    __weak typeof(contentTableView) weakContentTB       = contentTableView;
    
    if (sortSourceArr.count > 0) {
        collectBGView.hidden    = YES;
        isSelected              = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakContentTB.estimatedRowHeight = 0;
            [weakContentTB reloadData];
            [weakLeftBarItemBtn setTitle:KHJLocalizedString(@"filtrate", nil) forState:UIControlStateNormal];
        });
    }
    else {
        weakCollectBGView.hidden    = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{
                weakSelectBGView.alpha  = 1;
                weakCollectBGView.alpha = 1;
            }];
        });
    }
}

#pragma mark - UITableViewDataSource && UITabelViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[sortSourceDict allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSNumber *sectionKey    = sortSourceArr[section];
    NSInteger countt        = (NSInteger)[sortSourceDict[[sectionKey stringValue]] count];
    return countt%3 == 0 ? countt/3 : countt/3 + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (SCREEN_WIDTH - 20)/3.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView        = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 25)];
    headView.backgroundColor= [UIColor whiteColor];
    UILabel *label          = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, SCREEN_WIDTH - 24, 20)];
    NSString *sectionKey    = [sortSourceArr[section] stringValue];
    label.text              = sectionKey;
    label.textColor         = [UIColor grayColor];
    label.font              = [UIFont systemFontOfSize:14];
    [headView addSubview:label];
    return headView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellID     = @"KHJVideoTBCell";
    KHJVideoTBCell *videoTBCell = [contentTableView dequeueReusableCellWithIdentifier:CellID];
    if (!videoTBCell) {
        videoTBCell = [[NSBundle mainBundle] loadNibNamed:CellID owner:nil options:nil][0];
    }
    
    //路径
    NSString *khjwant       = [NSString stringWithFormat:@"KHJFileName_%@",SaveManager.userID];
    NSString *docPath       = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSNumber *sectionKey    = sortSourceArr[indexPath.section];
    NSArray  *valueArr      = [sortSourceDict[[sectionKey stringValue]] copy];
    
    NSString *leftString    = @"";
    NSString *centerString  = @"";
    NSString *rightString   = @"";
    if (indexPath.row == valueArr.count/3) {
        if (valueArr.count%3 > 0) {
            if (valueArr.count%3        == 1) { /*余1张*/
                leftString      = valueArr[indexPath.row * 3];
            }
            else if (valueArr.count%3   == 2) { /*余2张*/
                leftString      = valueArr[indexPath.row * 3];
                centerString    = valueArr[indexPath.row * 3 + 1];
            }
        }
    }
    else {
        leftString      = valueArr[indexPath.row * 3];
        centerString    = valueArr[indexPath.row * 3 + 1];
        rightString     = valueArr[indexPath.row * 3 + 2];
    }
    
    if (isEdit) {
        // 处于：编辑状态
        videoTBCell.leftChooseIMGV.hidden   = NO;
        videoTBCell.rightChooseIMGV.hidden  = NO;
        videoTBCell.centerChooseIMGV.hidden = NO;

        if (!isAllSelect) {
            // 初始化选择状态
            if (leftString.length > 0   && [editArray containsObject:leftString])   {   videoTBCell.leftChooseIMGV.highlighted   = YES; }
            if (centerString.length > 0 && [editArray containsObject:centerString]) {   videoTBCell.centerChooseIMGV.highlighted = YES; }
            if (rightString.length > 0  && [editArray containsObject:rightString])  {   videoTBCell.rightChooseIMGV.highlighted  = YES; }
        }
        else {
            // 全选处理
            videoTBCell.leftChooseIMGV.highlighted      = YES;
            videoTBCell.rightChooseIMGV.highlighted     = YES;
            videoTBCell.centerChooseIMGV.highlighted    = YES;
        }
    }
    else {
        // 处于：非编辑状态
        videoTBCell.leftChooseIMGV.hidden   = YES;
        videoTBCell.rightChooseIMGV.hidden  = YES;
        videoTBCell.centerChooseIMGV.hidden = YES;
        // 取消全选
        isAllSelect = NO;
    }

    if (indexPath.row == valueArr.count/3) {
#pragma mark - 无法整除3
        if (valueArr.count%3 > 0) {
            if (valueArr.count%3               == 1) { /*余1张*/
                videoTBCell.centerItemView.alpha    = 0;
                videoTBCell.rightItemView.alpha     = 0;
                [self leftCellAddTask:videoTBCell   indexPath:indexPath imagePath:String(@"%@/%@/%@",docPath,khjwant,leftString)];
            }
            else if (valueArr.count%3          == 2) { /*余2张*/
                videoTBCell.rightItemView.alpha     = 0;
                [self leftCellAddTask:videoTBCell   indexPath:indexPath imagePath:String(@"%@/%@/%@",docPath,khjwant,leftString)];
                [self centerCellAddTask:videoTBCell indexPath:indexPath imagePath:String(@"%@/%@/%@",docPath,khjwant,centerString)];
            }
        }
    }
    else {
#pragma mark - 整除3
        [self setItemViewAlpa:videoTBCell];
        [self leftCellAddTask:videoTBCell   indexPath:indexPath imagePath:String(@"%@/%@/%@",docPath,khjwant,leftString)];
        [self centerCellAddTask:videoTBCell indexPath:indexPath imagePath:String(@"%@/%@/%@",docPath,khjwant,centerString)];
        [self rightCellAddTask:videoTBCell  indexPath:indexPath imagePath:String(@"%@/%@/%@",docPath,khjwant,rightString)];
    }
    return videoTBCell;
}

- (void)leftCellAddTask:(KHJVideoTBCell *)cell indexPath:(NSIndexPath *)indexPath imagePath:(NSString *)imagePath
{
    __weak typeof(cell) weakCell = cell;
    if([imagePath containsString:@".mp4"]) {
        [UIView transitionWithView:cell.leftIMGV duration:0.1 options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionTransitionCrossDissolve) animations:^{
            weakCell.leftIMGV.image    = [Calculate getFristImageInmp4Video:imagePath];
        } completion:nil];
    }
    else {
        // 读取沙盒路径图片
        [UIView transitionWithView:cell.leftIMGV duration:0.1 options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionTransitionCrossDissolve) animations:^{
            weakCell.leftIMGV.image    = [[UIImage alloc] initWithContentsOfFile:imagePath];
        } completion:nil];
    }

    WeakSelf
    cell.leftBlock = ^{
        weakCell.leftChooseIMGV.highlighted = !weakCell.leftChooseIMGV.isHighlighted;
        [weakSelf selectCell:weakCell indexPath:indexPath postion:0];
    };
}

- (void)centerCellAddTask:(KHJVideoTBCell *)cell indexPath:(NSIndexPath *)indexPath imagePath:(NSString *)imagePath
{
    __weak typeof(cell) weakCell = cell;
    if([imagePath containsString:@".mp4"]) {
        [UIView transitionWithView:cell.centerIMGV duration:0.1 options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionTransitionCrossDissolve) animations:^{
            weakCell.centerIMGV.image    = [Calculate getFristImageInmp4Video:imagePath];
        } completion:nil];
    }
    else {
        // 读取沙盒路径图片
        [UIView transitionWithView:cell.centerIMGV duration:0.1 options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionTransitionCrossDissolve) animations:^{
            weakCell.centerIMGV.image    = [[UIImage alloc] initWithContentsOfFile:imagePath];
        } completion:nil];
    }

    WeakSelf
    cell.centerBlock = ^{
        weakCell.centerChooseIMGV.highlighted = !weakCell.centerChooseIMGV.isHighlighted;
        [weakSelf selectCell:weakCell indexPath:indexPath postion:1];
    };
}

- (void)rightCellAddTask:(KHJVideoTBCell *)cell indexPath:(NSIndexPath *)indexPath imagePath:(NSString *)imagePath
{
    __weak typeof(cell) weakCell = cell;
    if([imagePath containsString:@".mp4"]) {
        [UIView transitionWithView:cell.rightIMGV duration:0.1 options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionTransitionCrossDissolve) animations:^{
            weakCell.rightIMGV.image    = [Calculate getFristImageInmp4Video:imagePath];
        } completion:nil];
    }
    else {
        // 读取沙盒路径图片
        [UIView transitionWithView:cell.rightIMGV duration:0.1 options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionTransitionCrossDissolve) animations:^{
            weakCell.rightIMGV.image    = [[UIImage alloc] initWithContentsOfFile:imagePath];
        } completion:nil];
    }

    WeakSelf
    cell.rightBlock = ^{
        weakCell.rightChooseIMGV.highlighted = !weakCell.rightChooseIMGV.isHighlighted;
        [weakSelf selectCell:weakCell indexPath:indexPath postion:2];
    };
}

- (void)selectCell:(KHJVideoTBCell *)cell indexPath:(NSIndexPath *)indexPath postion:(NSInteger)postion
{
    if (self->isEdit) {
        // 编辑状态
        [self selectCell_isEdit:cell indexPath:indexPath postion:postion];
    }
    else {
        // 非编辑状态
        [self selectCell_editing:cell indexPath:indexPath postion:postion];
    }
}

/**
 编辑状态 - cell
 */
- (void)selectCell_isEdit:(KHJVideoTBCell *)cell indexPath:(NSIndexPath *)indexPath postion:(NSInteger)postion
{
    NSNumber *num       = [sortSourceArr objectAtIndex:indexPath.section];
    NSArray *sectionArr = [sortSourceDict objectForKey:[num stringValue]];
    NSString *rowPath   = [sectionArr objectAtIndex:indexPath.row*3 + postion];
    UIImageView *titleImageView = nil;
    switch (postion) {
        case 0:
            titleImageView = cell.leftChooseIMGV;
            break;
        case 1:
            titleImageView = cell.centerChooseIMGV;
            break;
        case 2:
            titleImageView = cell.rightChooseIMGV;
            break;
            break;
        default:
            break;
    }
    
    CLog(@"rowPath = %@，section = %ld，row = %ld，postion = %ld",rowPath,(long)indexPath.section,(long)indexPath.row,postion);
    
    if (titleImageView.isHighlighted) {
        //选中则加入数组，直接保存path
        if (![editArray containsObject:rowPath]) {
            [editArray addObject:rowPath];
        }
    }
    else {
        [editArray removeObject:rowPath];
    }
}

/**
 正常状态 - cell
 */
- (void)selectCell_editing:(KHJVideoTBCell *)cell indexPath:(NSIndexPath *)indexPath postion:(NSInteger)postion
{
    //修改图片浏览界面
    NSInteger toShowIndex   = 0;
    for (int i = 0; i < indexPath.section; i++) {
        NSInteger num = [contentTableView numberOfRowsInSection:i];
        toShowIndex += num;
    }
    toShowIndex += indexPath.row*3 + postion;
    
    NSString * docPath      = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *khjFileName   = [NSString stringWithFormat:@"KHJFileName_%@",SaveManager.userID];//关联账户
    khjFileName             = [docPath stringByAppendingPathComponent:khjFileName];
    
    __weak typeof(contentTableView) weakTableView       = contentTableView;
    __weak typeof(sortSourceDict) weakSortSourceDict    = sortSourceDict;
    __block NSMutableArray *valueArr                    = [NSMutableArray array];
    __block NSMutableArray *allKey                      = [NSMutableArray arrayWithArray:[sortSourceDict allKeys]];
    
    LvedioViewController *lv = [[LvedioViewController alloc] init];
    lv.deleteBlock = ^(NSString *path) {
        
        NSArray *_subAllKey = [allKey copy];
        for (NSString *key in _subAllKey) {
            
            valueArr = [weakSortSourceDict[key] mutableCopy];
            bool isDelete = NO;
            for (NSString *pathaa in valueArr) {
                
                NSString * pathaaa = [khjFileName stringByAppendingPathComponent:pathaa];
                if ([pathaaa isEqualToString:path]) {
                    isDelete = YES;
                    [valueArr removeObject:pathaa];
                    [weakSortSourceDict setObject:valueArr forKey:key];
                    break;
                }
            }
            if (isDelete) {
                if (valueArr.count == 0) {
                    [allKey removeObject:key];
                    [weakSortSourceDict removeObjectForKey:key];
                }
                break;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakTableView setContentOffset:weakTableView.contentOffset animated:YES];
            [weakTableView reloadData];
        });
    };
    lv.Datadic = sortSourceDict;
    lv.currentIndex = toShowIndex;
    lv.hidesBottomBarWhenPushed  = YES;
    [self.navigationController pushViewController:lv animated:YES];
}

- (void)setItemViewAlpa:(KHJVideoTBCell *)cell
{
    if (cell.leftItemView.alpha     == 0)   {   cell.leftItemView.alpha     = 1;    }
    if (cell.centerItemView.alpha   == 0)   {   cell.centerItemView.alpha   = 1;    }
    if (cell.rightItemView.alpha    == 0)   {   cell.rightItemView.alpha    = 1;    }
}

@end
