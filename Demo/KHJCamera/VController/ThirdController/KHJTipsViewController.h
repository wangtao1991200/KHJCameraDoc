//
//  TipsViewController.h
//
//
//
//
//

#import <UIKit/UIKit.h>

@interface KHJTipsViewController : UIViewController

// 区分是二维码还是热点连接
// Distinguish between QR code and hotspot connection
@property (nonatomic,assign) NSInteger vIndex;

@property (weak, nonatomic) IBOutlet UIImageView *ttImageview;
- (IBAction)unListenBtn:(UIButton *)sender;
- (IBAction)listenBtn:(UIButton *)sender;

@end
