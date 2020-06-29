//
//  RemberUserListView.h

#import <UIKit/UIKit.h>

@interface RemberUserListView : UIView

@property(nonatomic,copy)void(^TableClickBlock)(NSString * str);

@property (nonatomic,copy)NSMutableArray *dataArray;

@property (nonatomic,assign)BOOL isDelete;

- (void)refreshTable;
- (void)show;
@end
