//
//  AddSuerVController.h
//
//
//
//
//

#import <UIKit/UIKit.h>

@interface KHJAddSuerVController : UIViewController
- (IBAction)clickSureListen:(UIButton *)sender;

@property(nonatomic, copy) NSString *ssidName;
@property(nonatomic, copy) NSString *ppPwd;
@property(nonatomic, copy) NSString *devUid;

@end
