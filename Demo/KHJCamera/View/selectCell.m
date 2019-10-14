//
//  selectCell.m

#import "selectCell.h"

@implementation selectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+(instancetype)xibTableViewCell {
    //在类方法中加载xib文件,注意:loadNibNamed:owner:options:这个方法返回的是NSArray,所以在后面加上firstObject或者lastObject或者[0]都可以;因为我们的Xib文件中,只有一个cell
    return [[[NSBundle mainBundle] loadNibNamed:@"selectCell" owner:nil options:nil] lastObject];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
