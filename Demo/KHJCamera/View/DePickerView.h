//
//  DePickerView.h

#import <UIKit/UIKit.h>

typedef void(^dateChanged)(NSString *str);

@interface DePickerView : UIView

-(void)dateChanged:(dateChanged)block;
- (UIButton *)getShowButton;
- (void)changeRightBtnState:(BOOL)isH;

@end
