//
//  TipsViewController.m
//
//
//
//
//

#import "KHJTipsViewController.h"
#import "KHJSetWifiViewController.h"
#import "KHJHotConnectTypeVController.h"

@interface KHJTipsViewController ()
{
    NSTimer *mmTimer;
}
@end

@implementation KHJTipsViewController

@synthesize vIndex;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = KHJLocalizedString(@"deviceprepared", nil);
    [self setbackBtn];
}

- (void)setbackBtn
{
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    but.frame =CGRectMake(0,0, 66, 44);
    but.imageEdgeInsets = UIEdgeInsetsMake(0,-40, 0, 0);

    [but setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(popMainViewCtrl) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem  *barBut = [[UIBarButtonItem alloc]initWithCustomView:but];
    self.navigationItem.leftBarButtonItem = barBut;
}
- (void)popMainViewCtrl
{
    NSInteger index=[[self.navigationController viewControllers]indexOfObject:self];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index-2] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)unListenBtn:(UIButton *)sender {
    
    
    UIAlertController *alertview=[UIAlertController alertControllerWithTitle:KHJLocalizedString(@"havenotlistenedvoice", nil) message:KHJLocalizedString(@"pressresetbutton", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel=[UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *defult = [UIAlertAction actionWithTitle:KHJLocalizedString(@"commit", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        

    }];
    [alertview addAction:cancel];
    [alertview addAction:defult];
    [self presentViewController:alertview animated:YES completion:nil];
    
}

- (IBAction)listenBtn:(UIButton *)sender
{
    // 停止定时器
    // Stop timer
    [mmTimer invalidate];
    mmTimer = nil;
    if (self.vIndex == 0) {
        KHJSetWifiViewController *codeCtrl = [[KHJSetWifiViewController alloc] init];
        codeCtrl.vIndex = self.vIndex;
        [self.navigationController pushViewController:codeCtrl animated:YES];
    }
    else {
        KHJHotConnectTypeVController *selAPVC = [[KHJHotConnectTypeVController alloc] init];
        [self.navigationController pushViewController:selAPVC animated:YES];
    }
}
@end













