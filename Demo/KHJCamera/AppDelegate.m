//
//  AppDelegate.m

#import "AppDelegate.h"

#import "DevieceViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
 
    DevieceViewController *dVctl    = [[DevieceViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:dVctl];
    
    UINavigationBar *navBar = nav.navigationBar;
    UIImage *image = [UIImage imageNamed:@"bgN"];
    [navBar setTranslucent:false];
    [navBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [navBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];
    return YES;
}
@end












