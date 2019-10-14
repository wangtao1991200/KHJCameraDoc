//
//  SCell.m

#import "SCell.h"

@implementation SCell

@synthesize userLab;
@synthesize dateLab;
@synthesize uImgView;
@synthesize deletebtn;


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
        
        
        uImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 50,50)];
        uImgView.clipsToBounds = YES;
        uImgView.layer.cornerRadius = 25;
        uImgView.image = [UIImage imageNamed:@"icon_head"];
        [self.contentView addSubview:uImgView];
        
        userLab = [[UILabel alloc] initWithFrame:CGRectMake(10+uImgView.frame.size.height+uImgView.frame.origin.x, 6, 180, 20)];
        userLab.textColor = UIColor.blackColor;
        [self.contentView addSubview:userLab];
        
        
        dateLab = [[UILabel alloc] initWithFrame:CGRectMake(10+uImgView.frame.size.height+uImgView.frame.origin.x, 38, 200, 20)];
        dateLab.textColor= UIColor.lightGrayColor;
        dateLab.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:dateLab];
        CLog(@"self.frame.size.width = %d",(int)self.frame.size.width);
        deletebtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH-40-40-10, 12, 36, 36)];
        [deletebtn setBackgroundImage:[UIImage imageNamed:@"screenshot_delete_press"] forState:UIControlStateNormal];
        [deletebtn addTarget:self.delegete action:@selector(clickDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:deletebtn];
        
    }
    return self;
}
@end










