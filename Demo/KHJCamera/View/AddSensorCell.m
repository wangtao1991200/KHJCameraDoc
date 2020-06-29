//
//  AddSensorCell.m
#import "AddSensorCell.h"

@implementation AddSensorCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

+ (instancetype)xibTableViewCell
{
    return [[[NSBundle mainBundle] loadNibNamed:@"AddSensorCell" owner:nil options:nil] lastObject];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (IBAction)addClick:(UIButton *)sender
{
    
}

@end
