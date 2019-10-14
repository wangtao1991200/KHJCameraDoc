//
//  NetCell.m

#import "NetCell.h"

@interface NetCell()
{
//    UIImageView *imgLock;
//    UIImageView *imgNet;
}
@end

@implementation NetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    
        UIImageView *imgNet = [[UIImageView alloc] initWithFrame:CGRectMake(SCREENWIDTH-40, 10, 20,20)];
        imgNet.image = [UIImage imageNamed:@"ic_strength4"];
        UIImageView *imgLock = [[UIImageView alloc] initWithFrame:CGRectMake(SCREENWIDTH-50-20, 10, 20, 20)];
        imgLock.image = [UIImage imageNamed:@"modify_wifi_pwd"];
        [self.contentView addSubview:imgNet];
        [self.contentView addSubview:imgLock];
    }
    return self;
}
@end
