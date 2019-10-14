//
//  DePathChoseView.m

#import "DePathChoseView.h"
#import "selectCell.h"

@interface DePathChoseView()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *myTable;
    NSArray *dArray;
}
@property (nonatomic, weak) UIView *becloudView;//蒙板

@end

@implementation DePathChoseView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        dArray = [NSArray arrayWithObjects:KHJLocalizedString(@"deviceSD", nil),KHJLocalizedString(@"Cloud", nil),nil];
        
        
        
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
    sLab.text = KHJLocalizedString(@"recordPath", nil);
    
    myTable = [[UITableView alloc] initWithFrame:CGRectMake(0, sLab.frame.size.height+sLab.frame.origin.y, DeWindow.frame.size.width*0.8, [dArray count]*44)];
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
    
    NSLog(@"self.cateStrIn = %ld",self.cateStrIn);
    if (indexPath.row == self.cateStrIn) {
        
        cell.selectImageV.hidden = NO;
        
    }else{
        cell.selectImageV.hidden = YES;
        
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
//    self.selectBlock((int)indexPath.row);
    self.selectBlock((int)indexPath.row);
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
    
    self.frame = CGRectMake(becloudView.frame.size.width * 0.1, 0, becloudView.frame.size.width * 0.8, 44+44*[dArray count]+10);
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






