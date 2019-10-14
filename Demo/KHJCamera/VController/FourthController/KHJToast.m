//
//  KHJToastView.m
//
//
//
//
//

#import "KHJToast.h"

@interface KHJToast ()
{
    FFToast *toast;
}

@end

@implementation KHJToast

+ (instancetype)share
{
    static KHJToast *toastView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        toastView = [[KHJToast alloc] init];
    });
    return toastView;
}

/**
 底部 - 轻量级toast
 */
- (void)showSingleToastWithContent:(NSString *)content
{
    NSLog(@"轻量级toast");
    [self dismissToast];
    toast               = [[FFToast alloc] initToastWithTitle:nil message:content iconImage:nil];
    toast.toastAlpha    = 1;
    toast.duration      = 1.5;
    toast.toastType     = FFToastTypeDefault;
    toast.toastPosition = FFToastPositionBottomWithFillet;
    [toast show];
}

/**
 中部 - toast
 */
- (void)showOKBtnToastWith:(NSString *)tip content:(NSString *)content
{
    [self dismissToast];
    
    CGFloat topSpaceViewToView              = 5;
    CGFloat horizontalSpaceToScreen         = 90;
    CGFloat horizontalSpaceToContentView    = 10;
    CGFloat bottomSpaceToContentView        = 10;
    CGSize topImgSize                       = CGSizeMake(50, 50);
    
    //顶部图片
    CGFloat topImgViewY     = 0;
    CGFloat topImgViewX     = (SCREENWIDTH - 2*horizontalSpaceToScreen)/2 - topImgSize.width/2;
    UIImageView *topImgView = [[UIImageView alloc]initWithFrame:CGRectMake(topImgViewX, topImgViewY, topImgSize.width, topImgSize.height)];
    topImgView.image        = [UIImage imageWithName:@"test_ok"];
    
    //设置字体
    UIFont *titleFont       = [UIFont systemFontOfSize:15.f weight:UIFontWeightMedium];
    UIFont *messageFont     = [UIFont systemFontOfSize:13.f];
    
    CGFloat maxTextWidth    = SCREENWIDTH - 2*(horizontalSpaceToScreen) - 2 * horizontalSpaceToContentView;
    CGSize titleSize        = [NSString sizeForString:tip font:titleFont maxWidth:maxTextWidth];
    CGSize messageSize      = [NSString sizeForString:content font:messageFont maxWidth:maxTextWidth];
    
    //内容和标题
    CGFloat titleLabelX = (SCREENWIDTH - 2*horizontalSpaceToScreen - titleSize.width)/2;
    CGFloat titleLabelY = topSpaceViewToView;
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(titleLabelX, titleLabelY, titleSize.width, titleSize.height)];
    titleLabel.text     = tip;
    titleLabel.font     = titleFont;
    titleLabel.textColor        = [UIColor blackColor];
    titleLabel.textAlignment    = NSTextAlignmentCenter;
    titleLabel.numberOfLines    = 0;
    
    CGFloat messageLabelX   = (SCREENWIDTH - 2*horizontalSpaceToScreen - messageSize.width)/2;
    CGFloat messageLabelY   = titleLabelY + titleSize.height + topSpaceViewToView;
    UILabel *messageLabel   = [[UILabel alloc]initWithFrame:CGRectMake(messageLabelX, messageLabelY + 10, messageSize.width, messageSize.height)];
    messageLabel.text       = content;
    messageLabel.font       = messageFont;
    messageLabel.textColor      = [UIColor grayColor];
    messageLabel.textAlignment  = NSTextAlignmentCenter;
    messageLabel.numberOfLines  = 0;
    
    //OK按钮
    CGFloat okBtnX      = 40;
    CGFloat okBtnY      = messageLabelY + messageSize.height + topSpaceViewToView + 5 + 15;
    CGFloat okBtnW      = SCREENWIDTH - 2*horizontalSpaceToScreen - 80;
    CGFloat okBtnH      = 28;
    UIButton *okBtn     = [[UIButton alloc]initWithFrame:CGRectMake(okBtnX, okBtnY, okBtnW, okBtnH)];
    okBtn.backgroundColor       = [UIColor colorWithRed:0.17 green:0.69 blue:0.55 alpha:1.00];
    [okBtn setTitle:@"确定" forState:UIControlStateNormal];
    okBtn.titleLabel.font       = [UIFont systemFontOfSize:13];
    okBtn.layer.cornerRadius    = 2.f;
    okBtn.layer.masksToBounds   = YES;
    [okBtn addTarget:self action:@selector(dismissToast) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat customToastViewX    = 0;
    CGFloat customToastViewY    = topImgSize.height/2;
    CGFloat customToastViewW    = SCREENWIDTH - 2 * horizontalSpaceToScreen;
    CGFloat customToastViewH    = okBtnY + okBtnH + bottomSpaceToContentView;
    UIView *customToastView     = [[UIView alloc]initWithFrame:CGRectMake(customToastViewX, customToastViewY, customToastViewW, customToastViewH)];
    customToastView.backgroundColor = [UIColor whiteColor];
    
    [customToastView addSubview: titleLabel];
    [customToastView addSubview: messageLabel];
    [customToastView addSubview: okBtn];
    
    CGFloat customToastParentViewW  = SCREENWIDTH - 2*horizontalSpaceToScreen;
    CGFloat customToastParentViewH  = topImgSize.height/2 + customToastViewH;
    CGFloat customToastParentViewX  = (SCREENWIDTH - customToastParentViewW)/2;
    CGFloat customToastParentViewY  = (SCREENHEIGHT - customToastParentViewH)/2;
    UIView *customToastParentView   = [[UIView alloc]initWithFrame:CGRectMake(customToastParentViewX, customToastParentViewY, customToastParentViewW, customToastParentViewH)];
    
    [customToastParentView addSubview:customToastView];
    [customToastParentView addSubview: topImgView];
    customToastView.layer.cornerRadius = 5.f;
    customToastView.layer.masksToBounds = YES;
    
    toast               = [[FFToast alloc] initCentreToastWithView:customToastParentView autoDismiss:NO duration:0 enableDismissBtn:NO dismissBtnImage:nil];
    toast.toastAlpha    = 1;
    toast.duration      = 1.5;
    [toast show];
}

- (void)dismissToast
{
    [toast dismissCentreToast];
}

/**
 状态提示：成功，失败，警告，提示
 
 @param type    toast类型
 @param postion toast位置（顶，中，下）
 @param tip     提示信息
 @param content 内容信息
 */
- (void)showToastActionWithToastType:(KHJToastType)type
                        toastPostion:(KHJToastPosition)postion
                                 tip:(NSString *)tip
                             content:(NSString *)content
{
    [self dismissToast];
    toast                   = [[FFToast alloc] initToastWithTitle:tip message:content iconImage:nil];
    toast.toastAlpha        = 1;
    toast.duration          = 1.5;
    toast.toastType         = (int)type;
    switch (postion) {
        case _TopPostion:
            toast.toastPosition = FFToastPositionDefault;
            break;
        case _CenterPostion:
            toast.toastPosition = FFToastPositionCentreWithFillet;
            break;
        case _BottomPostion:
            toast.toastPosition = FFToastPositionBottomWithFillet;
            break;
        default:
            break;
    }
    [toast show];
}

@end
