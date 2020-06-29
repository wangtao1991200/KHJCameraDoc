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

// -1 为增加计划，其他0-，1，2···则是修改计划，值对应修改的数组下标

// -1 is to increase the plan, other 0-, 1, 2, ··· is to modify the plan, the value corresponds to the modified array index

@property (nonatomic,assign) NSInteger sIndex;

@property (nonatomic,copy) NSString *uuidStr;

// 0，定时开关 1，定时录像
// 0, timer switch 1, timer recording
@property (nonatomic,assign) NSInteger vIndex;

@end
