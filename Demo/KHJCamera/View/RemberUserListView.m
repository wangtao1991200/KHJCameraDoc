//
//  RemberUserListView.m

#import "RemberUserListView.h"


@interface RemberUserListView()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *mTab;
    UIView *backgroundView;

}
@end

@implementation RemberUserListView
@synthesize dataArray;

- (instancetype)init
{
    self = [super init];
    if (self) {
        dataArray = [NSMutableArray array];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        [self setMain];
        self.backgroundColor=[UIColor whiteColor];
    }
    return self;
}
- (void)setMain
{
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 8;
    self.layer.borderWidth = 1.f;
    self.layer.borderColor = UIColor.lightGrayColor.CGColor;
    mTab = [self getTable];
    mTab.dataSource = self;
    mTab.delegate = self;
    [self addSubview:mTab];
}
- (void)show{
    
    [self addShadow];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
}
- (UITableView *)getTable
{
    CGRect frame = self.frame;

    if (mTab == nil) {
        mTab = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0)];
    }
    return mTab;
}
- (void)refreshTable
{
    CGRect fg = mTab.frame;
    fg.size.width = self.frame.size.width;
    if ([self.dataArray count]<3) {
        fg.size.height =  [self.dataArray count]*40;
    }else{
        fg.size.height = 3*40;
    }
    
    mTab.frame = fg;
    CGRect ffg = self.frame;
    ffg.size.height = fg.size.height;
    self.frame = ffg;
    
    
    [mTab reloadData];
}
#pragma mark - UITableViewDelegate, UITableViewDataSource
- (UIButton *)getDeleteBtn
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(mTab.frame.size.width-40, 0, 40, 40)];
    [btn setBackgroundImage:[UIImage imageNamed:@"deleteUser"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
- (void)deleteClick:(UIButton *)btn{

    [self.dataArray removeObjectAtIndex:(btn.tag-330)];
    [[NSUserDefaults standardUserDefaults] setObject:self.dataArray forKey:@"AllUserAccount"];
    [self refreshTable];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.dataArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath//增加删除功能
{
    
    static NSString *Identifier = @"sCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:Identifier];
    }
    
    if (self.isDelete) {
        UIButton *btn = [cell viewWithTag:330+indexPath.row];
        if (!btn) {
            btn = [self getDeleteBtn];
            btn.tag = 330+indexPath.row;
            [cell addSubview:btn];
        }
    }
    cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str = [self.dataArray objectAtIndex:indexPath.row];
    
    self.TableClickBlock(str);
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    [self tapBgview];
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
}
//添加遮罩
- (void)addShadow
{
    backgroundView = [[UIView alloc] init];
    backgroundView.frame = CGRectMake(0, 1,SCREENWIDTH,SCREENHEIGHT);
    backgroundView.backgroundColor = [UIColor colorWithRed:(40/255.0f) green:(40/255.0f) blue:(40/255.0f) alpha:1.0f];
    backgroundView.alpha = 0.6;
    [[[UIApplication sharedApplication] keyWindow] addSubview:backgroundView];
    
    UITapGestureRecognizer *gest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgview)];
    backgroundView.userInteractionEnabled = YES;
    [backgroundView addGestureRecognizer:gest];
    
}
- (void)tapBgview
{
    [backgroundView removeFromSuperview];
    [self removeFromSuperview];
}

@end

























