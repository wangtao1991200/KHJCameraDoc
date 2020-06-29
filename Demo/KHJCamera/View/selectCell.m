//
//  selectCell.m

#import "selectCell.h"

@implementation selectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (instancetype)xibTableViewCell
{
    return [[[NSBundle mainBundle] loadNibNamed:@"selectCell" owner:nil options:nil] lastObject];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
