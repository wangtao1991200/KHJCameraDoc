//
//  AddSensorVController.m
//
//
//
//
//

#import "AddSensorVController.h"
#import "AddSensorCell.h"

@interface AddSensorVController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *nTable;
    NSArray *senSorArr;
    NSArray *remarkArr;
    NSArray *exaArr;
    NSArray *colorArray;
}
@end

@implementation AddSensorVController
- (instancetype)init
{
    self = [super init];
    if (self) {
        senSorArr = [NSArray arrayWithObjects:KHJLocalizedString(@"commonSensor", nil),KHJLocalizedString(@"controllerSensor", nil),KHJLocalizedString(@"specialSensor", nil), nil];
        remarkArr = [NSArray arrayWithObjects:KHJLocalizedString(@"takeEffectWhenDefence", nil),KHJLocalizedString(@"canSetDefence", nil),@"", nil];
        exaArr = [NSArray arrayWithObjects:KHJLocalizedString(@"addSensorTipA", nil),KHJLocalizedString(@"addSensorTipB", nil),KHJLocalizedString(@"addSensorTipC", nil), nil];
        colorArray = [NSArray arrayWithObjects:UIColor.redColor,UIColor.purpleColor,ssRGB(82, 158, 154), nil];

    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = KHJLocalizedString(@"addSensor", nil);
    self.view.backgroundColor = bgVCcolor;
    
    [self setbackBtn];
    [self setMain];
    
}
#pragma mark - setMain
- (void)setMain 
{
    nTable = [self getNtabel];
    [self.view addSubview:nTable];
}
#pragma mark - getTable
- (UITableView *)getNtabel
{
    if (nTable == nil) {
        nTable = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, SCREENWIDTH-20, 88*3+60)];
        nTable.delegate = self;
        nTable.dataSource = self;
        nTable.backgroundColor = bgVCcolor;
    }
    return nTable;
}
#pragma mark - setbackBtn
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [senSorArr count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"addSensorCell";
    
    AddSensorCell *cell = (AddSensorCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if(nil == cell) {
        
        cell = [AddSensorCell xibTableViewCell];
    }
    cell.showBgView.backgroundColor = [colorArray objectAtIndex:indexPath.section];
    cell.sensorNameLab.text = [senSorArr objectAtIndex:indexPath.section];
    cell.remarkLabel.text = [remarkArr objectAtIndex:indexPath.section];
    
    cell.examLabel.text = [exaArr objectAtIndex:indexPath.section];
    [cell.examLabel sizeToFit];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 88;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH-20, 20)];
    v.backgroundColor = bgVCcolor;
    return v;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end











