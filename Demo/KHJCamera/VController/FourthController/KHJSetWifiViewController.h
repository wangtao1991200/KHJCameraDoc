//
//  CreTwoCodeViewController.h
//
//
//
//
//

#import <UIKit/UIKit.h>

@interface KHJSetWifiViewController : UIViewController
// 区分是二维码还是热点连接
// Distinguish between QR code and hotspot connection
@property (nonatomic,assign) NSInteger vIndex;
// 当前连接了设备热点
// Device hotspot is currently connected
@property (nonatomic,assign) BOOL isAP;

@property (weak, nonatomic) IBOutlet UIButton *showBtn;

@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;

@property (weak, nonatomic) IBOutlet UIButton *wifiBtn;

@property (weak, nonatomic) IBOutlet UITextField *wifiPwd;
@property (weak, nonatomic) IBOutlet UIButton *sheildBtn;

- (IBAction)sheild1:(UIButton *)sender;

- (IBAction)createTwoCode:(UIButton *)sender;

@end
