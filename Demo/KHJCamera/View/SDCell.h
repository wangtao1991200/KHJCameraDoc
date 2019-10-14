//
//  SDCell.h

#import <UIKit/UIKit.h>
@protocol clickPlayAndDownLoad<NSObject>

- (void)clickPlay:(UIButton *)btn;
- (void)clickDownLoad:(UIButton *)btn;
@end

@interface SDCell : UITableViewCell

@property (nonatomic,weak)id<clickPlayAndDownLoad> delegete;

@property (nonatomic,strong)UIButton *playButton;
@property (nonatomic,strong)UIButton *downButton;


@end
