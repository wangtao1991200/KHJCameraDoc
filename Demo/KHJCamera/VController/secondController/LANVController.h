//
//  LANVController.h

#import <UIKit/UIKit.h>

@interface LANVController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *uidTextField;

- (IBAction)swipERClick:(UIButton *)sender;
- (IBAction)searchWifi:(UIButton *)sender;
- (IBAction)addDeviceClick:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIView *bgView;

@end



