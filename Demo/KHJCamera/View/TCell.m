//
//  TCell.m

#import "TCell.h"

@implementation TCell

@synthesize  contentImageView;

@synthesize  editBtn;
@synthesize  nikNameLab;
@synthesize  ConnStatelab;
@synthesize  playImageView;
@synthesize  shareBtn;
@synthesize  connectState;
@synthesize apLab;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        // Fix the frame of each control and related properties.
        contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 230)];
        playImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        playImageView.image = [UIImage imageNamed:@"header_icon_play_ap"];
        playImageView.center = contentImageView.center;
        
        nikNameLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 250, 20)];
        nikNameLab.backgroundColor = [UIColor blackColor];
        nikNameLab.font = [UIFont systemFontOfSize:14];
        nikNameLab.textColor = [UIColor whiteColor];
        nikNameLab.clipsToBounds = YES;
        nikNameLab.layer.cornerRadius = 5;
        nikNameLab.alpha = 0.5;
        
        ConnStatelab = [[UILabel alloc] initWithFrame:CGRectMake(10, contentImageView.bounds.size.height-30, 100, 20)];
        ConnStatelab.text = @"未连接";
        ConnStatelab.textColor = [UIColor whiteColor];
        ConnStatelab.backgroundColor = [UIColor blackColor];
        ConnStatelab.font = [UIFont systemFontOfSize:14];
        ConnStatelab.clipsToBounds = YES;
        ConnStatelab.layer.cornerRadius = 5;
        ConnStatelab.alpha = 0.5;
        
        [contentImageView addSubview:playImageView];
        [contentImageView addSubview:editBtn];
        [contentImageView addSubview:nikNameLab];
        [contentImageView addSubview:ConnStatelab];

        apLab = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH-80 , self.contentImageView.frame.size.height-40, 80, 40)];
        apLab.textColor = [UIColor redColor];
        apLab.text = @"AP模式  ";
        apLab.text = [NSString stringWithFormat:@"%@  ",KHJLocalizedString(@"ApMode", nil)];

        apLab.textAlignment = NSTextAlignmentRight;
        apLab.font = [UIFont systemFontOfSize:20];
        apLab.hidden = YES;
        [contentImageView addSubview:apLab];
        
        _swithV = [[UISwitch alloc] initWithFrame:CGRectMake(SCREENWIDTH-80, 10, 100, 100)];
        _swithV.on = YES;
        _swithV.transform = CGAffineTransformMakeScale( 0.75,0.75);
        _swithV.layer.anchorPoint=CGPointMake(0,0.5);
        [_swithV addTarget:self.delegete action:@selector(openClick:) forControlEvents:UIControlEventValueChanged];
        _swithV.tintColor = [UIColor whiteColor];
        _swithV.onTintColor = DeCcolor;
        [self addSubview:_swithV];
        
        UIButton *editBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 40, 40)];
        [editBtn setBackgroundImage:[UIImage imageNamed:@"editor"] forState:UIControlStateNormal];
        [editBtn addTarget:self.delegete action:@selector(clickEditBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:editBtn];
        editBtn.hidden = YES;
        
        self.userInteractionEnabled = YES;
        [self addSubview:shareBtn];
        [self.contentView addSubview:contentImageView];
      
    
    }
    return self;
}

@end






