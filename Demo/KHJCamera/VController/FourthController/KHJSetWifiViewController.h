//
//  CreTwoCodeViewController.h
//
//
//
//
//

#import <UIKit/UIKit.h>

@interface KHJSetWifiViewController : UIViewController
@property (nonatomic,assign) NSInteger vIndex;//区分是二维码还是热点连接
@property (nonatomic,assign) BOOL isAP;//当前连接了设备热点

@property (weak, nonatomic) IBOutlet UIButton *showBtn;

@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;

@property (weak, nonatomic) IBOutlet UIButton *wifiBtn;

@property (weak, nonatomic) IBOutlet UITextField *wifiPwd;
@property (weak, nonatomic) IBOutlet UIButton *sheildBtn;

- (IBAction)sheild1:(UIButton *)sender;

- (IBAction)createTwoCode:(UIButton *)sender;

@end
