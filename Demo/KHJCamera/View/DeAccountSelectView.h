//
//  DeAccountSelectView.h

#import <UIKit/UIKit.h>

typedef void(^selectCallback)(NSString *inputString);

@interface DeAccountSelectView : UIView
@property (nonatomic, copy)selectCallback selBlock;
@property (nonatomic, strong)NSArray *dArray;
- (void)show;

@end
