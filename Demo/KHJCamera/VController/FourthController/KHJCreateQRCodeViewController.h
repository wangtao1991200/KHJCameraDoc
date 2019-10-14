//
//  DeCreateQRCodeViewController.h
//
//
//
//
//
#import <UIKit/UIKit.h>

@interface KHJCreateQRCodeViewController : UIViewController

@property (strong, nonatomic) UIImageView *erImageview;

@property (nonatomic,strong) NSString *ssidString;
@property (nonatomic,strong) NSString *ssidPwd;

- (IBAction)listenSuccessBtn:(UIButton *)sender;
@end
