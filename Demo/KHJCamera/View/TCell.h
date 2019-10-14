//
//  TCell.h

#import <UIKit/UIKit.h>

@protocol clickProtoc<NSObject>

- (void)clickEditBtn:(UIButton *)btn;
- (void)shareClick:(UIButton *)btn;
- (void)openClick:(UISwitch *)sw;
//- (void)LongPressCell:(UILongPressGestureRecognizer *)gest;
@end


@interface TCell : UITableViewCell

@property (nonatomic,weak)id<clickProtoc> delegete;
@property (nonatomic,strong)UIImageView *contentImageView;
@property (nonatomic,strong)UIButton *editBtn;
@property (nonatomic,strong)UILabel *nikNameLab;
@property (nonatomic,strong)UILabel *ConnStatelab;
@property (nonatomic,strong)UILabel *apLab;
@property (nonatomic,strong)UIButton *shareBtn;
@property (nonatomic,strong)UISwitch *swithV;


@property (nonatomic,strong)UIImageView *playImageView;
//@property (nonatomic,strong)UIButton *shareBtn;

@property (nonatomic,assign)NSInteger connectState;//连接状态，0连接成功，1未连接，2正在连接

@end
