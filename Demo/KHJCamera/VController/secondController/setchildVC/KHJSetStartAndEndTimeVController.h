//
//  SetStartAndEndTimeVController.h
//
//
//
//
//

#import <UIKit/UIKit.h>

@interface KHJSetStartAndEndTimeVController : UIViewController

@property (nonatomic,strong)NSMutableArray * planArray;
@property (nonatomic,assign)NSInteger sIndex;//-1 为增加计划，其他0-，1，2···则是修改计划，值对应修改的数组下标
@property (nonatomic,copy)NSString *uuidStr;

@property (nonatomic,assign)NSInteger vIndex;//0，定时开关 1，定时录像

@end
