//
//  KHJUdpHelper.h

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KHJUdpHelper : UIView
+ (KHJUdpHelper*)getinstance;
- (void)openUDPServer;
- (void)closeUpdServer;
@end

NS_ASSUME_NONNULL_END
