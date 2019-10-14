//
//  HZWPicker.h

#import <UIKit/UIKit.h>

typedef void (^CDZConfirmBlock)(NSString *strings);

@interface HZWPicker : UIView

@property (nonatomic, copy) CDZConfirmBlock confirmBlock;

//- (void)getTimeSting:(CDZConfirmBlock)dd;
@end
