//
//  KHJpath choice  DePathChoseView.h

#import <UIKit/UIKit.h>

typedef void(^selectCallback)(int intS);

@interface DePathChoseView : UIView

@property (nonatomic, copy)selectCallback selectBlock;
@property (nonatomic, assign)NSInteger cateStrIn;
- (void)show;
@end
