//
//  KHJVideoModel.h

#import <Foundation/Foundation.h>

@interface KHJVideoModel : NSObject

@property(nonatomic,assign)NSTimeInterval  startTime;//起始时间 时间戳
@property(nonatomic,assign)int durationTime;//时长 秒为单位
@property(nonatomic,assign)int recType;//0,1全天录制，2移动侦测，4是声音侦测，6移动和声音同时

//private int colorAll = 0xffafafaf;//视频全天录制背景颜色  灰色
//private Paint vMovePaint= new Paint();//移动录制画笔
//private int colorMove = 0xffeb855d;//移动录制背景颜色 橙色
//private Paint voicePaint = new Paint();//声音录制画笔
//private int colorVoice = 0xff2ab9b7;//青绿色
//private Paint doublePaint = new Paint();//声音加移动录制画笔
//private int colordouble = 0xffd64949;//声音加移动录制背景颜色 红色
 @property(nonatomic,copy)NSString *videoUrl;//时长 秒为单位


///////////////////////////////////////////////////////////////////////////////////////////////

@end




























