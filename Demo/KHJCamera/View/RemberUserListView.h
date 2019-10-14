//
//  RemberUserListView.h

#import <UIKit/UIKit.h>

@interface RemberUserListView : UIView

@property(nonatomic,copy)void(^TableClickBlock)(NSString * str);

@property (nonatomic,copy)NSMutableArray *dataArray;//数据源

@property (nonatomic,assign)BOOL isDelete;//数据源

- (void)refreshTable;
- (void)show;
@end
