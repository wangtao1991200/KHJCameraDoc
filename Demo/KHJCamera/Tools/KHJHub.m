//
//  KHJHub.m

#import "KHJHub.h"
#import "MBProgressHUD.h"


@implementation KHJHub
@synthesize hud;
+ (KHJHub *)shareHub
{
    static KHJHub *instanceManager = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instanceManager = [[super allocWithZone:NULL] init] ;
    }) ;
    
    return instanceManager ;
}

+(id) allocWithZone:(struct _NSZone *)zone
{
    return [KHJHub shareHub] ;
}

-(id) copyWithZone:(struct _NSZone *)zone
{
    return [KHJHub shareHub] ;
}

- (void)showText:(NSString *)string addToView:(UIView *)view
{
    if (self.hud.hidden == NO) {
        self.hud.hidden = YES;

    }
    self.hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    self.hud.mode = MBProgressHUDModeText;
//    self.hud.label.text = string;
    self.hud.detailsLabel.text = string;
    self.hud.detailsLabel.font = [UIFont boldSystemFontOfSize:14];
    self.hud.detailsLabel.numberOfLines = 2;
//    self.hud.hidden = NO;
    self.hud.margin = 10.f;
    self.hud.removeFromSuperViewOnHide = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       
        self.hud.hidden = YES;
        
    });
 
}
- (void)showText:(NSString *)string addToView:(UIView *)view andColor:(int)kind
{
    if (self.hud.hidden == NO) {
        self.hud.hidden = YES;
        
    }
    self.hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    self.hud.mode = MBProgressHUDModeText;
    self.hud.detailsLabel.text = string;
    self.hud.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.hud.hidden = YES;
    });
}

- (void)showText:(NSString *)string addToView:(UIView *)view type:(KHJHubType)type
{
    if (self.hud.hidden == NO) {
        self.hud.hidden = YES;
    }
    
    self.hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    [self.hud.superview bringSubviewToFront:self.hud];
    
    self.hud.hidden             = NO;
    self.hud.mode               = MBProgressHUDModeIndeterminate;
    self.hud.bezelView.style    = MBProgressHUDBackgroundStyleSolidColor;
    __weak typeof(hud) weakHub  = hud;
    switch (type) {
        case _default:
            weakHub.contentColor                = [UIColor blackColor];
            weakHub.bezelView.backgroundColor   = UIColor.clearColor;
            break;
        case _lightGray:
            weakHub.detailsLabel.text           = string;
            weakHub.contentColor                = [UIColor whiteColor];
            weakHub.bezelView.backgroundColor   = [UIColor lightGrayColor];
            break;
        default:
            break;
    }
}

@end









