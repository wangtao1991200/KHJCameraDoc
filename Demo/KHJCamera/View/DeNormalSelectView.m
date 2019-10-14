//
//  KHJNormalSelectView.m
//  KHJCamera
//
//  Created by hezewen on 2018/9/21.
//  Copyright © 2018年 khj. All rights reserved.
//

#import "DeNormalSelectView.h"
#import "selectCell.h"



@interface DeNormalSelectView()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *myTable;
    UILabel *sLab;
}
@property (nonatomic, weak) UIView *becloudView;//蒙板

@end

@implementation DeNormalSelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initView];
    }
    return self;
}
- (void)initView
{
    
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 5;
    self.backgroundColor = UIColor.whiteColor;
    sLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH * 0.8, 44)];
    sLab.font = [UIFont systemFontOfSize:15];
    sLab.textColor = UIColor.orangeColor;
    sLab.textAlignment = NSTextAlignmentCenter;
    
    myTable = [[UITableView alloc] initWithFrame:CGRectMake(0, sLab.frame.size.height+sLab.frame.origin.y, DeWindow.frame.size.width*0.8, [_dArray count]*44)];
    myTable.delegate = self;
    myTable.dataSource = self;
    
    [self addSubview:sLab];
    [self addSubview:myTable];
    
}
#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"selectCell";
    selectCell *cell = (selectCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if(nil == cell) {
        
        cell = [selectCell xibTableViewCell];
    }
    cell.textLabel.text = [_dArray objectAtIndex:indexPath.row];
    
    
    if (indexPath.row == self.cateStrIn) {
        cell.selectImageV.hidden = NO;
        
    }else{
        cell.selectImageV.hidden = YES;
        
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *tcell = [tableView cellForRowAtIndexPath:indexPath];
    tcell.selected = NO;
    self.selBlock((int)indexPath.row);
    [self dismiss];
    
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
#pragma mark - 刷新数据
- (void)refreshData
{
    CGRect rect =  myTable.frame;
    rect.size.height = [_dArray count]*44;
    myTable.frame = rect;
//    [myTable reloadData];
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
    
    [DeWindow addSubview:becloudView];
    self.becloudView = becloudView;
    sLab.text = self.titleStr;
    self.frame = CGRectMake(becloudView.frame.size.width * 0.1, 0, becloudView.frame.size.width * 0.8, 44+44*[_dArray count]+5);
    self.center = self.becloudView.center;
    [DeWindow addSubview:self];
    [myTable reloadData];
    
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
