//
//  AddSensorCell.h

#import <UIKit/UIKit.h>

@interface AddSensorCell : UITableViewCell

//@property (weak, nonatomic) IBOutlet UIView *showBgView;
@property (weak, nonatomic) IBOutlet UIView *showBgView;
@property (weak, nonatomic) IBOutlet UILabel *sensorNameLab;
@property (weak, nonatomic) IBOutlet UILabel *remarkLabel;
@property (weak, nonatomic) IBOutlet UILabel *examLabel;
- (IBAction)addClick:(UIButton *)sender;


+(instancetype)xibTableViewCell;

@end
