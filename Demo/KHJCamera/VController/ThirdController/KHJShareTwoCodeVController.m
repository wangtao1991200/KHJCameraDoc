//
//  ShareTwoCodeVController.m
//
//
//
//
//

#import "KHJShareTwoCodeVController.h"
#import "CreateTwoCode.h"

@interface KHJShareTwoCodeVController ()

@property (weak, nonatomic) IBOutlet UILabel *TipsLabel;

@end

@implementation KHJShareTwoCodeVController

@synthesize devUid;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title  = KHJLocalizedString(@"shareDevice", nil);
    [self setbackBtn];
    [self  setTips];
}

- (void)setTips
{
    self.TipsLabel.text = KHJLocalizedString(@"erweiTips", nil);
    self.TipsLabel.numberOfLines = 0;
    self.TipsLabel.font = [UIFont systemFontOfSize:16.f];
}

- (void)createERcode:(NSString *)codeStr
{
    NSString *uString = [NSString stringWithFormat:@"{\"code\":\"%@\",\"deviceUid\":\"%@\"}",codeStr,self.devUid];
   UIImage *erImage = [CreateTwoCode createTCode:uString];
    
    // 显示二维码
    
    // Show QR code
    
    self.tImageview.image = erImage;
}

- (void)setbackBtn
{
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    but.frame =CGRectMake(0,0, 66, 44);
    but.imageEdgeInsets = UIEdgeInsetsMake(0,-40, 0, 0);
    [but setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem  *barBut = [[UIBarButtonItem alloc]initWithCustomView:but];
    self.navigationItem.leftBarButtonItem = barBut;
}

- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

//=========================================

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


















