//
//  KHJVideoModel.h

#import <Foundation/Foundation.h>

@interface KHJVideoModel : NSObject

@property(nonatomic,assign)NSTimeInterval  startTime;//起始时间 时间戳
@property(nonatomic,assign)int durationTime;//时长 秒为单位
@property(nonatomic,assign)int recType;//0,1全天录制，2移动侦测，4是声音侦测，6移动和声音同时
@property(nonatomic,copy)NSString *videoUrl;//时长 秒为单位


///////////////////////////////////////////////////////////////////////////////////////////////

@end




























