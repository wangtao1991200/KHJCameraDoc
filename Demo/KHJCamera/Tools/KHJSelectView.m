//
//  KHJSelectView.m
//  KHJCamera
//
//  Created by hezewen on 2018/7/18.
//  Copyright © 2018年 khj. All rights reserved.
//

#import "KHJSelectView.h"
#import "selectCell.h"
#import "PlayLocalMusic.h"

@interface KHJSelectView()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *myTable;
    NSArray *dArray;
    NSArray *mArray;
}
@property (nonatomic, weak) UIView *becloudView;//蒙板

@end

@implementation KHJSelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        dArray = [NSArray arrayWithObjects:@"经典",@"警铃",@"清晨", nil];
        mArray = [NSArray arrayWithObjects:@"classical",@"alarmbell",@"moming", nil];
        [self initView];
    }
    return self;
}
- (void)initView
{
    
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 5;
    self.backgroundColor = UIColor.whiteColor;
    UILabel *sLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, KHJWindow.frame.size.width*0.8, 44)];
    sLab.text = @"选择报警铃声";
//    sLab.font = [UIFont systemFontOfSize:15];
    
    myTable = [[UITableView alloc] initWithFrame:CGRectMake(0, sLab.frame.size.height+sLab.frame.origin.y, KHJWindow.frame.size.width*0.8, 3*44)];
    myTable.delegate = self;
    myTable.dataSource = self;
    
    [self addSubview:sLab];
    [self addSubview:myTable];
    
}
#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"selectCell";
    selectCell *cell = (selectCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if(nil == cell) {
        
        cell = [selectCell xibTableViewCell];
    }
    cell.textLabel.text = [dArray objectAtIndex:indexPath.row];

    if ([cell.textLabel.text isEqualToString:self.cateStr]) {
        cell.selectImageV.hidden = NO;

    }else{
        cell.selectImageV.hidden = YES;

    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    self.selBlock([dArray objectAtIndex:indexPath.row]);
    [self dismiss];
    
    //查找本地音乐文件路径
    NSString *sName = [mArray objectAtIndex:indexPath.row];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:sName ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    [[PlayLocalMusic shareInstance] play:url repeates:0];
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
#pragma mark - show
- (void)show
{
    // 蒙版
    UIView *becloudView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    becloudView.backgroundColor = [UIColor blackColor];
    becloudView.layer.opacity = 0.6;
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAlertView:)];
    [becloudView addGestureRecognizer:tapGR];
    
    [KHJWindow addSubview:becloudView];
    self.becloudView = becloudView;
    
    self.frame = CGRectMake(becloudView.frame.size.width * 0.1, 0, becloudView.frame.size.width * 0.8, 44+44*3);
    self.center = self.becloudView.center;
//    self.center = CGPointMake(becloudView.center.x, becloudView.frame.size.height * 0.4);
    [KHJWindow addSubview:self];
    
}
- (void)closeAlertView:(UITapGestureRecognizer *)tap{
    
    [self dismiss];
}
- (void)dismiss
{
    [self removeFromSuperview];
    [self.becloudView removeFromSuperview];
}

@end
