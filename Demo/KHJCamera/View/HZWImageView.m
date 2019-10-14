//
//  HZWImageView.m


#import "HZWImageView.h"

@implementation HZWImageView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initMyself];
    }
    return self;
}


- (void)initMyself
{
    self.layer.cornerRadius  = 75;
    self.layer.masksToBounds = YES;
    self.image = [UIImage imageNamed:@"direction_default"];
    self.userInteractionEnabled = YES;
}


@end
