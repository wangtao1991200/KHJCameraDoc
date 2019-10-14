//
//  SCell.h
#import <UIKit/UIKit.h>

@protocol clickProtoc1<NSObject>

- (void)clickDeleteBtn:(UIButton *)btn;

@end

@interface SCell : UITableViewCell
@property (nonatomic,weak)id<clickProtoc1> delegete;

@property (nonatomic,strong)UIImageView *uImgView;
@property (nonatomic,strong)UILabel *userLab;
@property (nonatomic,strong)UILabel *dateLab;
@property (nonatomic,strong)UIButton *deletebtn;


@end
