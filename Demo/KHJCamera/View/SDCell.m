//
//  SDCell.m

#import "SDCell.h"

@implementation SDCell

@synthesize playButton;
@synthesize downButton;

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];


}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
//        playButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH-44-44-10, 0, 44, 44)];
//        [playButton setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        downButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH-44-10-20, 0, 44, 44)];
        [downButton setBackgroundImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
        
        [playButton addTarget:self.delegete action:@selector(clickPlay:) forControlEvents:UIControlEventTouchUpInside];
        [downButton addTarget:self.delegete action:@selector(clickDownLoad:) forControlEvents:UIControlEventTouchUpInside];

//        playButton.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
//        downButton.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
        downButton.hidden = NO;

        
        [self addSubview:playButton];
        [self addSubview:downButton];
    }
    return self;
}
@end














