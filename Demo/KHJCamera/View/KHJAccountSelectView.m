//
//  KHJAccountSelectView.m

#import "DeAccountSelectView.h"
@interface DeAccountSelectView()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *myTable;
}
@property (nonatomic, weak) UIView *becloudView;//蒙板

@end
@implementation DeAccountSelectView

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
    UILabel *sLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, DeWindow.frame.size.width*0.8, 44)];
    sLab.text = DeLocalizedString(@"addAlarmPushAccout", nil);
    //    sLab.font = [UIFont systemFontOfSize:15];
    
    myTable = [[UITableView alloc] initWithFrame:CGRectMake(0, sLab.frame.size.height+sLab.frame.origin.y, DeWindow.frame.size.width*0.8, 3*44)];
    myTable.delegate = self;
    myTable.dataSource = self;
    
    [self addSubview:sLab];
    [self addSubview:myTable];
    
}
#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"salarmCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if(nil == cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    cell.textLabel.text = [self.dArray objectAtIndex:indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.selBlock([self.dArray objectAtIndex:indexPath.row]);
    [self dismiss];
    
    //查找本地音乐文件路径
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
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 44;
//}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
//    lab.text = @"添加报警推送账号";
//    return lab;
//
//}

#pragma mark - show
- (void)show
{
    // 蒙版
    UIView *becloudView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    becloudView.backgroundColor = [UIColor blackColor];
    becloudView.layer.opacity = 0.6;
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAlertView:)];
    [becloudView addGestureRecognizer:tapGR];
    
    [myTable reloadData];

    [DeWindow addSubview:becloudView];
    self.becloudView = becloudView;
    
    if ([self.dArray count] <4) {
        self.frame = CGRectMake(becloudView.frame.size.width * 0.1, 0, becloudView.frame.size.width * 0.8, 44+44*[self.dArray count]);

    }else
        self.frame = CGRectMake(becloudView.frame.size.width * 0.1, 0, becloudView.frame.size.width * 0.8, 44+44*3);

    self.center = self.becloudView.center;
    //    self.center = CGPointMake(becloudView.center.x, becloudView.frame.size.height * 0.4);
    [DeWindow addSubview:self];
    
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
