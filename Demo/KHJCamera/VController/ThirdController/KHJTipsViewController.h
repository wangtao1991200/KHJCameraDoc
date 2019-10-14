//
//  TipsViewController.h
//
//
//
//
//

#import <UIKit/UIKit.h>

@interface KHJTipsViewController : UIViewController

@property (nonatomic,assign) NSInteger vIndex;//区分是二维码还是热点连接

@property (weak, nonatomic) IBOutlet UIImageView *ttImageview;
- (IBAction)unListenBtn:(UIButton *)sender;
- (IBAction)listenBtn:(UIButton *)sender;

@end
