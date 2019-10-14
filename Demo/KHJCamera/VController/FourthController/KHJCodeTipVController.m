//
//  CodeTipVController.m
//
//
//
//
//

#import "KHJCodeTipVController.h"

@interface KHJCodeTipVController ()

@end

@implementation KHJCodeTipVController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = KHJLocalizedString(@"learnMe", nil);
    self.view.backgroundColor = bgVCcolor;
    [self setbackBtn];
    
    [self setImageView];
    [self setTipLabel];
}
- (void)setbackBtn
{
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    but.frame =CGRectMake(0,0, 66, 44);
    but.imageEdgeInsets = UIEdgeInsetsMake(0,-40, 0, 0);//解决按钮不能靠左问题
    
    [but setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(popMainViewCtrl) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem  *barBut = [[UIBarButtonItem alloc]initWithCustomView:but];
    self.navigationItem.leftBarButtonItem = barBut;
}
- (void)setImageView
{
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-Height_NavBar)];
    imgV.image = [UIImage imageNamed:@"syt"];
    [self.view addSubview:imgV];
}
- (void)setTipLabel
{
    //请将手机屏幕中的二维码朝向摄像机,并保持20-30厘米的距离,等待摄像机扫描手机的二维码
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, SCREENWIDTH, 66)];
    lab.text = KHJLocalizedString(@"tipLearn", nil);
    lab.numberOfLines = 3;
    lab.font = [UIFont systemFontOfSize:15];
    lab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lab];
    
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, SCREENHEIGHT-Height_NavBar-Height_StatusBar-44, SCREENWIDTH-40, 44)];
    [btn setTitle:KHJLocalizedString(@"", nil) forState:UIControlStateNormal];
    btn.clipsToBounds = YES;
    btn.layer.cornerRadius = 8;
    [btn setBackgroundImage:[UIImage imageNamed:@"bgN"] forState:UIControlStateNormal];
    [btn setTitle:KHJLocalizedString(@"getIt", nil) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(popMainViewCtrl) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
- (void)popMainViewCtrl
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
