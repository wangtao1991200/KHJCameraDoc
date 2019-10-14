//
//  DownLoadView.h

#import <UIKit/UIKit.h>

@interface DownLoadView : UIView

@property(nonatomic,copy)void(^BtnClickBlock)(NSString *);

@property(nonatomic,strong)UILabel *vNameLab;
@property(nonatomic,strong)UIProgressView *proView;
@property(nonatomic,strong)UILabel *gLabel;
@property(nonatomic,strong)UILabel *bLabel;
@property(nonatomic,strong)UIButton *canCelBtn;

- (void)refreshFrame;

@end
