//
//  PlanCell.m

#import "PlanCell.h"

@implementation PlanCell
@synthesize closeLab;
@synthesize openLab;

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
        
        // 固定各个控件的frame，以及相关属性。
        // Fix the frame of each control and related properties.
        UILabel *cShowLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
        cShowLab.text = [NSString stringWithFormat:@"    %@",KHJLocalizedString(@"closeTime", nil)];
        cShowLab.textAlignment =NSTextAlignmentLeft;
        
        UILabel *oShowLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 120, 40)];
        oShowLab.text = [NSString stringWithFormat:@"    %@",KHJLocalizedString(@"openTime", nil)];
        oShowLab.textAlignment =NSTextAlignmentLeft;
        
        closeLab = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH-140, 0, 120, 40)];
        openLab = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH-140, 40, 120, 40)];

        
        closeLab.font  = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
        openLab.font  = [UIFont fontWithName:@"Helvetica Neue" size:17.f];

        
        closeLab.textAlignment =NSTextAlignmentRight;
        openLab.textAlignment = NSTextAlignmentRight;

        
        
        [self.contentView addSubview:cShowLab];
        [self.contentView addSubview:oShowLab];
        [self.contentView addSubview:closeLab];
        [self.contentView addSubview:openLab];

        
    }
    return self;
}
@end
