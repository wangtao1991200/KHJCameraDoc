//
//  SDVedioPhotoVController.m
//
//  设备相册
//
//
//

#import "KHJSDVedioPhotoVController.h"
#import "DeUIPickDate.h"
#import "KHJAllBaseManager.h"
#import "SDCell.h"
#import "DownLoadView.h"

@interface KHJSDVedioPhotoVController ()<UITableViewDelegate,UITableViewDataSource,clickPlayAndDownLoad>
{
    UIButton *leftBtn;
    UIButton *rightBtn;
    UIButton *showButton;
    //视频或者图片保存
    NSMutableArray *fArray;
    UIView * dateBgView;
    NSInteger selectSeg;
    UITableView *mTable;
    //当前下载的文件名
    NSString *currentFileName;

    DownLoadView *downLoadPopView;
    NSFileHandle *fileHandle;
    BOOL isClickDown;
    BOOL isDownLoading;
    UILabel *tipLabel;
}
@end

@implementation KHJSDVedioPhotoVController

- (instancetype)init
{
    self = [super init];
    if (self) {
        fArray = [NSMutableArray array];
        selectSeg =  0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[KHJAllBaseManager sharedBaseManager] KHJSingleCheckDeviceOnline:self.uuidStr] != 1) {
        [[KHJToast share] showOKBtnToastWith:KHJLocalizedString(@"tips", nil) content:KHJLocalizedString(@"deviceDropLine", nil)];    
    }
    
    
    self.view.backgroundColor = bgVCcolor;
    [self initSetNav];
    [self setbackBtn];
    [self setTipLab];
    [self setDatePicker];
    
    mTable = [self getMtable];
    mTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:mTable];
    [self getData];
    [self addNoti];
}

- (void)addNoti
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)setTipLab
{
    tipLabel = [self getTipsLabel];
    tipLabel.center = CGPointMake(SCREENWIDTH/2, SCREENHEIGHT/2-64);
    [self.view addSubview:tipLabel];
    tipLabel.hidden = YES;
}
- (UILabel *)getTipsLabel
{
    if (tipLabel==nil) {
        tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 44)];
        if(selectSeg == 0){
            tipLabel.text = KHJLocalizedString(@"noRecorderVideo", nil);
        }
        else {
            tipLabel.text = KHJLocalizedString(@"noPictureToday", nil);
        }
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.textColor = [UIColor grayColor];
        tipLabel.font = [UIFont systemFontOfSize:17];

    }
    return tipLabel;
}

- (void)applicationEnterBackground
{
    if (isDownLoading) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self cancelDownLoad];
        });
    }
}

- (void)getData
{
    //第一次查询当天视频
    NSString *currentDate = [Calculate getCurrentTimes];
    WeakSelf
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [weakSelf checkSDFile:currentDate];//当前从第一页开始
    });
}

- (UITableView *)getMtable;
{
    if (!mTable) {
        mTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 40+1, SCREENWIDTH, SCREENHEIGHT-64-40-1) style:UITableViewStylePlain];
        mTable.delegate = self;
        mTable.dataSource = self;
//        [mTable setBackgroundColor:UIColor.redColor];
    }
    return mTable;
}

- (DownLoadView *)getDownLoadPopView
{
    if (!downLoadPopView) {
        downLoadPopView = [[DownLoadView alloc] initWithFrame:CGRectMake(0, 1, SCREENWIDTH, SCREENHEIGHT-1)];
    }
    return downLoadPopView;
}

- (void)initSetNav
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 10, SCREENWIDTH*0.52, 44)];
    view.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = view;
    
    UISegmentedControl* segment = [[UISegmentedControl alloc]initWithFrame:CGRectMake(0, 4, SCREENWIDTH*0.52, 34)];
    //在索引值为0的位置上插入一个标题为red的按钮，第三个参数为是否开启动画
    [segment insertSegmentWithTitle:KHJLocalizedString(@"video", nil) atIndex:0 animated:YES];
    [segment insertSegmentWithTitle:KHJLocalizedString(@"picture", nil) atIndex:1 animated:YES];
    segment.clipsToBounds = YES;
    segment.layer.borderWidth = 1;
    segment.layer.borderColor = DeCcolor.CGColor;
    segment.layer.cornerRadius = 18;
    segment.backgroundColor = [UIColor whiteColor];
    segment.tintColor = DeCcolor;
    
    NSDictionary * normalTextAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:16.0f],NSForegroundColorAttributeName : DeCcolor};
    [segment setTitleTextAttributes:normalTextAttributes forState:UIControlStateNormal];
    NSDictionary * selctedTextAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:20.0f],NSForegroundColorAttributeName : [UIColor whiteColor]};
    [segment setTitleTextAttributes:selctedTextAttributes forState:UIControlStateSelected];
    segment.selectedSegmentIndex = 0;
    selectSeg =  0;
    //绑定事件
    [segment addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:segment];
}

- (void)segmentAction:(UISegmentedControl *)seg
{
    if(seg.selectedSegmentIndex == 0) {
        selectSeg = 0;
    }
    else {
        selectSeg = 1;
    }
    WeakSelf
    [fArray removeAllObjects];
    __block NSString *stTile = showButton.currentTitle;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [weakSelf checkSDFile:stTile];//当前从第一页开始
    });
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

#pragma mark - setDataPicker

- (void)setDatePicker
{
    dateBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 40)];
    dateBgView.backgroundColor =  [UIColor whiteColor];
    [self.view addSubview:dateBgView];
    showButton = [self getShowButton];
    leftBtn = [self getLeftButton];
    [dateBgView addSubview:leftBtn];
    [dateBgView addSubview:showButton];
}

//懒加载
- (UIButton *)getShowButton
{
    if(!showButton){
        
        showButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH/2-60, 0, 120, 40)];
        [showButton setImage:[UIImage imageNamed:@"videotape_icon_calendar_nor"] forState:UIControlStateNormal];
        
        NSString *currentDateString = [Calculate getCurrentTimes];
        [showButton setTitle:currentDateString forState:UIControlStateNormal];
        [showButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        showButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [showButton addTarget:self action:@selector(clickCalendar) forControlEvents:UIControlEventTouchUpInside];
    }
    return showButton;
}
- (UIButton *)getLeftButton
{
    if(!leftBtn){
        leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(showButton.frame.origin.x-50, 4, 32, 32)];
        [leftBtn setBackgroundImage:[UIImage imageNamed:@"pre1"] forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(clickLeft:) forControlEvents:UIControlEventTouchUpInside];
    }
    return leftBtn;
}
- (UIButton *)getRightButton
{
    if(!rightBtn){
        rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(showButton.frame.origin.x+showButton.frame.size.width+18, 4, 32, 32)];
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(clickRight:) forControlEvents:UIControlEventTouchUpInside];
        [dateBgView addSubview:rightBtn];
    }
    return rightBtn;
}
- (void)clickCalendar
{
    [self setPiker];
}
- (void)clickLeft:(UIButton *)button//点击左翻按钮
{
    NSString *setDatestring = [Calculate prevDay:showButton.currentTitle];
    CLog(@"setDatestring = %@",setDatestring);
    [showButton setTitle:setDatestring forState:UIControlStateNormal];
    [self getRightButton];
    [fArray removeAllObjects];
    WeakSelf
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [weakSelf checkSDFile:setDatestring];//当前从第一页开始
    });
    
}
- (void)clickRight:(UIButton*)button//点击右翻按钮
{
    
    NSString *setDatestring = [Calculate nextDay:showButton.currentTitle];
    NSString *currentDate = [Calculate getCurrentTimes];
    if ([Calculate compareDate:setDatestring withDate:currentDate] == 0) {
        
        [rightBtn removeFromSuperview];
        rightBtn = nil;
    }
    [showButton setTitle:setDatestring forState:UIControlStateNormal];
    [fArray removeAllObjects];
    WeakSelf
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [weakSelf checkSDFile:setDatestring];//当前从第一页开始
    });
}
- (void)setPiker
{
    DeUIPickDate *pickdate = [DeUIPickDate setDate];
    __weak typeof(showButton) weekShowButton = showButton;
    WeakSelf
    __weak typeof(fArray) weakFarray = fArray;
    [pickdate passvalue:^(NSString *str) {
        [weakFarray removeAllObjects];

        NSLog(@"str==%@",str);//时间字符串需要转换 nsdate
        dispatch_async(dispatch_get_main_queue(), ^{//点击选择日期，确定按钮
            
            [weekShowButton setTitle:str forState:UIControlStateNormal];
            [weakSelf checkSDFile:str];
            
        });
    }];
}
- (void)checkSDFile:(NSString *)dateString//查询视频
{
    [fArray removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{//点击选择日期，确定按钮

        [[KHJHub shareHub] showText:KHJLocalizedString(@"loading", nil) addToView:self.view type:_lightGray];

    });

    NSString *currentDate = [Calculate getCurrentTimes];
    NSInteger ret = [Calculate compareDate:dateString withDate:currentDate];
    if (ret != 0) {
        [self getRightButton];
    }
    long inputDate = [Calculate getTimeStrWithString:dateString];
    CLog(@"inputDate = %ld",inputDate);
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
    WeakSelf
    if (dDevice) {
       
         if (selectSeg == 0) {
             [dDevice.mDeviceManager listVideoFileStart:inputDate withStart:true returnBlock:^(BOOL isContinue, NSMutableArray *mArray) {
                 [weakSelf backVedio:mArray andContinue:isContinue];
             }];
         }else{
             [dDevice.mDeviceManager listJpegFileStart:inputDate withStart:true returnBlock:^(BOOL isContinue, NSMutableArray *mArray) {
                 [weakSelf backPhoto:mArray andContinue:isContinue];
             }];
         }
    }

}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [fArray count];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"SDCell";
    SDCell *cell = (SDCell *)[tableView dequeueReusableCellWithIdentifier:Identifier];
    if (!cell) {
        cell = [[SDCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:Identifier];
        cell.delegete = self;
    }
    cell.downButton.hidden = NO;
    if ([fArray count] != 0) {
        
        NSString *tstring = fArray[indexPath.row];
        cell.textLabel.text = tstring;
        NSString *tempstr = nil;
        NSArray * fileArray = nil;
        if(selectSeg == 0){
            //视频
//            tempstr = [[KHJHelpCameraData sharedModel] changeName:tstring withType:0];
//            fileArray = [[KHJHelpCameraData sharedModel] getmp4VideoArray];
        }
        else {
//            tempstr = [[KHJHelpCameraData sharedModel] changeName:tstring withType:1];
//            fileArray = [[KHJHelpCameraData sharedModel] getPictureArray];
        }
        for (NSString *st  in fileArray) {
            if ([st isEqualToString:tempstr]) {
                cell.downButton.hidden = YES;;
                CLog(@"yes");
                break;
            }
        }
    }
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:15.f];//解决数字宽度不一样
    return cell;
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}
#pragma mark - KHJDeviceManagerDelegate
- (void)backVedio:(NSMutableArray *)mArray andContinue:(bool)b
{
    __weak typeof(mTable)  weeKMtable = mTable;
    dispatch_async(dispatch_get_main_queue(), ^{
        [KHJHub shareHub].hud.hidden = YES;
    });
    if (b) {//后面还有
        CLog(@"后面还有文件");
    }else{
        CLog(@"后面没有文件");
    }
    [fArray addObjectsFromArray:mArray];
    CLog(@"farray = %@",fArray);
    
    if ([fArray count] == 0) {
        
        CLog(@"farrayD1 = %ld",[fArray count]);
        dispatch_async(dispatch_get_main_queue(), ^{
            self->tipLabel.hidden = NO;
            weeKMtable.hidden = YES;
            [weeKMtable reloadData];
        });


    }else{
        CLog(@"farrayD2 = %ld",[fArray count]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [KHJHub shareHub].hud.hidden = YES;
            self->tipLabel.hidden = YES;
             weeKMtable.hidden = NO;
            CGRect re = weeKMtable.frame;
            NSInteger Theight = [mArray count] *44;
            if (Theight > SCREENHEIGHT-64-40-1-22) {
                Theight = SCREENHEIGHT-64-40-1;
            }
            re.size.height =  SCREENHEIGHT-64-40-1;
            weeKMtable.frame = re;
            [weeKMtable reloadData];
            
        });
    }
}
- (void)backPhoto:(NSMutableArray *)mArray  andContinue:(bool)b
{
    __weak typeof(mTable)  weeKMtable = mTable;
    dispatch_async(dispatch_get_main_queue(), ^{
        [KHJHub shareHub].hud.hidden = YES;
    });
    if (b) {//后面还有
        CLog(@"后面还有文件");
    }else{
        CLog(@"后面没有文件");
    }
    [fArray addObjectsFromArray:mArray];
    if ([fArray count] == 0) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self->tipLabel.hidden = NO;

            weeKMtable.hidden = YES;
            [weeKMtable reloadData];
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            self->tipLabel.hidden = YES;

            weeKMtable.hidden = NO;
            CGRect re = weeKMtable.frame;
            NSInteger Theight = [mArray count] *44;
            if (Theight > SCREENHEIGHT-64-40-1-22) {
                Theight = SCREENHEIGHT-64-40-1;
            }
            re.size.height =  SCREENHEIGHT-64-40-1;
            weeKMtable.frame = re;
            [weeKMtable reloadData];
        });
    }
}
- (void)loadMoreData{//加载更多数据
    
    __weak typeof(showButton) weakShowButton=  showButton;
    NSString *setDatestring = weakShowButton.titleLabel.text;
    dispatch_async(dispatch_get_main_queue(), ^{

        [[KHJHub shareHub] showText:KHJLocalizedString(@"loading", nil) addToView:self.view type:_lightGray];

    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{

        long inputDate = [Calculate getTimeStrWithString:setDatestring];
        KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
        WeakSelf
        if (dDevice) {
            
            if (self->selectSeg == 0) {
                [dDevice.mDeviceManager listVideoFileStart:inputDate withStart:false returnBlock:^(BOOL isContinue, NSMutableArray *mArray) {
                    [weakSelf backVedio:mArray andContinue:isContinue];
                }];
            }else{
                [dDevice.mDeviceManager listJpegFileStart:inputDate withStart:false returnBlock:^(BOOL isContinue, NSMutableArray *mArray) {
                    [weakSelf backPhoto:mArray andContinue:isContinue];
                }];
            }
        }
    });
}
- (void)backPhotoLoadFile:(NSData *)data withHSize:(NSUInteger)hSize andTotalSize:(NSUInteger)tSize
{
    
}

- (void)backVedioLoadFile:(NSData *)data withHSize:(NSUInteger)hSize andTotalSize:(NSUInteger)tSize
{
    
}

#pragma mark - clickPlayAndDownLoad
- (void)clickPlay:(UIButton *)btn
{
    CLog(@"clickPlay");

}
- (void)clickDownLoad:(UIButton *)btn
{
    
}

- (void)cancelDownLoad
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end













