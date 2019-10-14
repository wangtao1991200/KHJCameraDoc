//
//  RecordPlanCell.m
#import "RecordPlanCell.h"

@implementation RecordPlanCell

@synthesize closeLab;
@synthesize openLab;
@synthesize timeLab;

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
        UILabel *cShowLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
        cShowLab.text = [NSString stringWithFormat:@"    %@",KHJLocalizedString(@"RecordPeriod", nil)];
        cShowLab.textAlignment =NSTextAlignmentLeft;
        cShowLab.font = [UIFont systemFontOfSize:15];
        
        timeLab = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH-140, 0, 120, 40)];
        
        closeLab = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH-140, 0, 120, 40)];
        openLab = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH-140, 40, 120, 40)];
        

        timeLab.font  = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
        timeLab.textColor = UIColor.blueColor;
        
        closeLab.textAlignment =NSTextAlignmentRight;
        openLab.textAlignment = NSTextAlignmentRight;
        timeLab.textAlignment = NSTextAlignmentRight;
        
        [self.contentView addSubview:cShowLab];
        [self.contentView addSubview:timeLab];
        
        
    }
    return self;
}

@end
