//
//  KHJHub.h

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

typedef enum : NSUInteger {
    _default,
    _lightGray,
} KHJHubType;

@interface KHJHub : NSObject

@property (nonatomic,strong) MBProgressHUD *hud;
+ (KHJHub *)shareHub;

- (void)showText:(NSString *)string addToView:(UIView *)view;
- (void)showText:(NSString *)string addToView:(UIView *)view andColor:(int)kind;

//kind == 0 ,显示菊花
- (void)showText:(NSString *)string addToView:(UIView *)view type:(KHJHubType)type;

@end
