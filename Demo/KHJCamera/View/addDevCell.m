//
//  addDevCell.m

#import "addDevCell.h"

@implementation addDevCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

+ (instancetype)xibTableViewCell
{
    return [[[NSBundle mainBundle] loadNibNamed:@"addDevCell" owner:nil options:nil] lastObject];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

@end
