//
//  AppDelegate.h
//
//
//
//
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
/**
 是否允许转向
 */
@property(nonatomic,assign) BOOL allowRotation ;

@end

