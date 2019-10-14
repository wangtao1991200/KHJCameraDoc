//
//  AccCell.m
#import "AccCell.h"

@implementation AccCell

+(instancetype)xibTableViewCell {

    return [[[NSBundle mainBundle] loadNibNamed:@"AccCell" owner:nil options:nil] lastObject];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
