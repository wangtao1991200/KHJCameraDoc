//
//  DeAlarmImageView.m

#import "DeAlarmImageView.h"

@implementation DeAlarmImageView
@synthesize fImageV;
@synthesize sImageV;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initView];
    }
    return self;
}
- (void)initView
{
    self.fImageV = [[UIImageView alloc] initWithFrame:CGRectMake(18, 5, 20, 20)];
    self.sImageV = [[UIImageView alloc] initWithFrame:CGRectMake(52, 5, 20, 20)];
    [self addSubview:self.fImageV];
    [self addSubview:self.sImageV];

}
@end







