//
//  DownLoadView.m

#import "DownLoadView.h"

#define cWidth (10)

@interface DownLoadView()
{
    UIView * bgView;
    UILabel *label;
    UIView *bLine;
    UIView *blin;
}
@end


@implementation DownLoadView
@synthesize  vNameLab;
@synthesize  proView;
@synthesize  gLabel;
@synthesize  bLabel;
@synthesize  canCelBtn;


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setMain];
        self.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.7];
    }
    return self;
}
- (void)setMain//
{
//    NSInteger cWidth = 10;
    bgView =[[UIView alloc] initWithFrame:CGRectMake(20, 0, SCREENWIDTH-40, 220-6)];
    bgView.backgroundColor = UIColor.whiteColor;
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(cWidth, 10, bgView.frame.size.width-2*cWidth, 20)];
    label.text = KHJLocalizedString(@"downloading", nil);
    label.font = [UIFont systemFontOfSize:20];
    label.textColor = ssRGB(100, 181, 225);
    [bgView addSubview:label];
    
    CGFloat heightt = label.frame.size.height+label.frame.origin.y+10;
    vNameLab = [[UILabel alloc] initWithFrame:CGRectMake(10, heightt, label.frame.size.width, 20)];
    vNameLab.textColor = label.textColor;
    vNameLab.font = label.font;
    [bgView addSubview:vNameLab];
    
    heightt = vNameLab.frame.size.height+vNameLab.frame.origin.y + 20;
    bLine = [[UIView alloc] initWithFrame:CGRectMake(0, heightt, bgView.frame.size.width, 2)];
    bLine.backgroundColor= label.textColor;
    [bgView addSubview:bLine];
    
    heightt = bLine.frame.size.height+bLine.frame.origin.y + 40;
    proView = [[UIProgressView alloc] initWithFrame:CGRectMake(cWidth, heightt, bgView.frame.size.width-2*cWidth, 1)];
    proView.progressTintColor= label.textColor;
    proView.trackTintColor= [UIColor lightGrayColor];
    proView.transform = CGAffineTransformMakeScale(1.0f, 2.0f);
        proView.progress=0;
    [bgView addSubview:proView];
    
    heightt = proView.frame.size.height+proView.frame.origin.y;
    gLabel = [[UILabel alloc] initWithFrame:CGRectMake(cWidth, heightt, proView.frame.size.width/2, 44)];
    gLabel.textColor = UIColor.blackColor;
    gLabel.text = @"0%";

    bLabel = [[UILabel alloc] initWithFrame:CGRectMake(cWidth+proView.frame.size.width/2, heightt, proView.frame.size.width/2, 44)];
    bLabel.textAlignment = NSTextAlignmentRight;
    bLabel.textColor = UIColor.blackColor;
    bLabel.text = @"0/100";
    [bgView addSubview:gLabel];
    [bgView addSubview:bLabel];
    
    heightt = bLabel.frame.size.height+bLabel.frame.origin.y ;
    blin = [[UIView alloc] initWithFrame:CGRectMake(0, heightt, bgView.frame.size.width, 1)];
    blin.backgroundColor = UIColor.lightGrayColor;
    [bgView addSubview:blin];
    
    heightt = blin.frame.size.height+blin.frame.origin.y;
    canCelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, heightt, bgView.frame.size.width, 44)];
    [canCelBtn addTarget:self action:@selector(clickCancel:) forControlEvents:UIControlEventTouchUpInside];
    [canCelBtn setTitle:KHJLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [canCelBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [canCelBtn setBackgroundColor:[UIColor purpleColor]];
    [canCelBtn setBackgroundImage:[UIImage imageNamed:@"whiteBNg"] forState:UIControlStateNormal];
    canCelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [bgView addSubview:canCelBtn];
    
    bgView.userInteractionEnabled = YES;
    bgView.clipsToBounds = YES;
    bgView.layer.cornerRadius = 10;
    [self addSubview:bgView];
    bgView.center = self.center;
}

- (void)refreshFrame
{
    bgView.frame = CGRectMake(20, 0, SCREENWIDTH-40, 220-6);
    
    label.frame =CGRectMake(cWidth, 10, bgView.frame.size.width-2*cWidth, 20);
   
    
    CGFloat heightt = label.frame.size.height+label.frame.origin.y+10;
    vNameLab.frame = CGRectMake(10, heightt, label.frame.size.width, 20);
   
    
    heightt = vNameLab.frame.size.height+vNameLab.frame.origin.y + 20;
    bLine.frame = CGRectMake(0, heightt, bgView.frame.size.width, 2);
    
    heightt = bLine.frame.size.height+bLine.frame.origin.y + 40;
    proView.frame = CGRectMake(cWidth, heightt, bgView.frame.size.width-2*cWidth, 1);
    
    heightt = proView.frame.size.height+proView.frame.origin.y;
    gLabel.frame = CGRectMake(cWidth, heightt, proView.frame.size.width/2, 44);
    
    bLabel.frame = CGRectMake(cWidth+proView.frame.size.width/2, heightt, proView.frame.size.width/2, 44);
    heightt = bLabel.frame.size.height+bLabel.frame.origin.y ;
    blin.frame = CGRectMake(0, heightt, bgView.frame.size.width, 1);
    
    heightt = blin.frame.size.height+blin.frame.origin.y;
    canCelBtn.frame = CGRectMake(0, heightt, bgView.frame.size.width, 44);
    bgView.center = self.center;

}

- (void)clickCancel:(UIButton *)btn
{
    NSLog(@"clickCancel");
    
    if (self.BtnClickBlock){
        self.BtnClickBlock(KHJLocalizedString(@"cancel", nil));

    }
    [self removeFromSuperview];
}
@end


















