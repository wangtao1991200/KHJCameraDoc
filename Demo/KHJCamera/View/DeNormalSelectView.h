//
//  DeNormalSelectView.h

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef void(^selCallback)(int intS);


@interface DeNormalSelectView : UIView

@property (nonatomic, copy)selCallback selBlock;
@property (nonatomic, assign)NSInteger cateStrIn;
@property (nonatomic, copy)NSArray *dArray;
@property (nonatomic, copy)NSString *titleStr;


- (void)show;
- (void)refreshData;
@end


NS_ASSUME_NONNULL_END
