//
//  Calculate.m

#import "Calculate.h"
#import <AVFoundation/AVFoundation.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>
#import <KHJCameraLib/KHJCameraLib.h>
//#import "KHJVideoModel.h"

@interface Calculate()
{
  
}
@end

@implementation Calculate

+ (CGFloat)getAnglesWithThreePoint:(CGPoint)pointA pointB:(CGPoint)pointB pointC:(CGPoint)pointC {
    
    CGFloat x1 = pointA.x - pointB.x;
    CGFloat y1 = pointA.y - pointB.y;
    CGFloat x2 = pointC.x - pointB.x;
    CGFloat y2 = pointC.y - pointB.y;
    
    CGFloat x = x1 * x2 + y1 * y2;
    CGFloat y = x1 * y2 - x2 * y1;
    
    CGFloat angle = acos(x/sqrt(x*x+y*y));
    if (pointA.y > pointB.y) {
        angle = M_PI*2 - angle;
    }
    return angle;
    
}

+ (NSInteger)isBelongPart:(CGFloat)agle
{
    
    if ((agle>=0 && agle<M_PI/4) ||(agle>=7*M_PI/4 && agle<M_PI*2)) {
        
        NSLog(@"右边");
        return 0;

    }else if((agle>=M_PI/4 && agle<3*M_PI/4)){
        
        NSLog(@"上边");
        return 1;

    }else if((agle>=3*M_PI/4 && agle<5*M_PI/4)){
        NSLog(@"左边");
        return 2;

    }else if((agle>=5*M_PI/4 && agle<7*M_PI/4)){
        
        NSLog(@"下边");
        return 3;

    }
    return 100;
}
//计算数组去重个数
+(NSMutableArray *)calCategoryArray:(NSArray *)arr
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableArray * marr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSString *s  in arr) {
        
        NSNumber *dd = [NSNumber numberWithInteger:[s integerValue]];
        [dict setObject:dd forKey:dd];
        
    }
    [marr addObjectsFromArray:[dict allValues]];
    marr = [self bubbleDescendingOrderSortWithArray:marr];
    return marr;
}

+ (NSMutableArray *)bubbleDescendingOrderSortWithArray:(NSMutableArray *)descendingArr
{
    for (int i = 0; i < descendingArr.count; i++) {
        
        for (int j = 0; j < descendingArr.count - 1 - i; j++) {
            
            if ([descendingArr[j] longLongValue] < [descendingArr[j + 1] longLongValue]) {
                
                long long  tmp = [descendingArr[j] longLongValue];
                
                descendingArr[j] = descendingArr[j + 1];
                
                descendingArr[j + 1] = [NSNumber numberWithLongLong:tmp];
            }
            
            
        }
    }
//    NSLog(@"冒泡降序排序后结果：%@", descendingArr);
    
    return descendingArr;
    
}

+ (UIImage *)getFristImageInmp4Video:(NSString *)filePath
{
    UIImage *shotImage = nil;;
    //视频路径URL
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    shotImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return shotImage;
}

+ (UIImage*)getCoverImage:(NSURL *)_outMovieURL
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:_outMovieURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    CGImageRef thumbnailImageRef = NULL;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(1, 12) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    return thumbnailImage;
}
//字符串转时间戳 如：2017-4-10 17:15:10
+ (long)getTimeStrWithString:(NSString *)str{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
    [dateFormatter setDateFormat:@"YYYY_MM_dd"]; //设定时间的格式
    
    NSDate *tempDate = [dateFormatter dateFromString:str];//将字符串转换为时间对象
    
    return (long)[tempDate timeIntervalSince1970];
}

+(NSString *)getVedioNameFromTimes:(NSTimeInterval)timeInterval{
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy_MM_dd_HH_mm_ss"];
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSince1970:timeInterval];
    NSString *currentDateString = [format stringFromDate:newDate];
    return currentDateString;
}
+(NSString *)prevDay:(NSString *) dateString{
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy_MM_dd"];
    NSDate *date = [format dateFromString:dateString];
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([date timeIntervalSinceReferenceDate] - 24*3600)];
    
    NSString *currentDateString = [format stringFromDate:newDate];
    return currentDateString;
}

+(NSString *)nextDay:(NSString *) dateString{
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy_MM_dd"];
    NSDate *date = [format dateFromString:dateString];
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([date timeIntervalSinceReferenceDate] + 24*3600)];
    
    NSString *currentDateString = [format stringFromDate:newDate];
    return currentDateString;
    //    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    //    [format setDateFormat:@"yyyy-MM-dd"];
    //    NSString *reportDate = [format stringFromDate:self.m_dataPicker.date];
    //    NSDate *date = [format dateFromString:reportDate];
    //    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([date timeIntervalSinceReferenceDate] + 24*3600)];
    //    reportDate = [format stringFromDate:newDate];
    //
    ////    [m_pickerButton setTitle:[[NSString alloc] initWithString:reportDate] forState:UIControlStateNormal];
    ////    [m_dataPicker setDate:newDate animated:NO];
    
    
}


+ (NSInteger)compareDate:(NSString*)aDate withDate:(NSString*)bDate
{
    NSInteger aa = 0;;
    NSDateFormatter *dateformater = [[NSDateFormatter alloc] init];
    [dateformater setDateFormat:@"yyyy_MM_dd"];
    NSDate *dta = [[NSDate alloc] init];
    NSDate *dtb = [[NSDate alloc] init];
    
    dta = [dateformater dateFromString:aDate];
    dtb = [dateformater dateFromString:bDate];
    NSComparisonResult result = [dta compare:dtb];
    if (result == NSOrderedSame)
    {
        //        相等
        aa=0;
    }else if (result == NSOrderedAscending)
    {
        //bDate比aDate大
        aa=1;
    }else if (result == NSOrderedDescending)
    {
        //bDate比aDate小
        aa=-1;
        
    }
    
    return aa;
}
//获取当前的时间

+(NSString*)getCurrentTimes{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"YYYY_MM_dd"];
    //现在时间,你可以输出来看下是什么格式
    NSDate *datenow = [NSDate date];
    //----------将nsdate按formatter格式转成nsstring
    NSString *currentTimeString = [formatter stringFromDate:datenow];
//    NSLog(@"currentTimeString =  %@",currentTimeString);
    return currentTimeString;
}
//根据返回的时间戳字符串，获取指定的格式的时间
+(NSString*)getTimeFormat:(NSString *)timeStampString
{
    // iOS 生成的时间戳是10位
    NSTimeInterval interval  = [timeStampString doubleValue];
    
    NSDate *date  = [NSDate dateWithTimeIntervalSince1970:interval];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"HH:mm"];
//    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate: date];
    return dateString;
}
+(NSString*)getSureTimeFormat:(NSString *)timeStampString
{
    // iOS 生成的时间戳是10位
    NSTimeInterval interval  = [timeStampString doubleValue];
    
    NSDate *date  = [NSDate dateWithTimeIntervalSince1970:interval];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate: date];
    return dateString;
}

//根据返回的时间戳字符串，获取指定的格式的时间
+(NSString*)formateTimeStamp:(NSString *)timeStampStringd
{
//    NSString *string = @"1970-01-02 08:00";
    
    NSString *string = [NSString stringWithFormat:@"1970-01-02 %@",timeStampStringd];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];//创建一个时间格式化对象
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];//设定时间的格式
    NSDate *tempDate = [dateFormatter dateFromString:string];//将字符串转换为时间对象
    NSTimeInterval time1 =[tempDate timeIntervalSince1970];// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeStr = [NSString stringWithFormat:@"%ld", (long)time1];
    
    return timeStr;
}
+(NSInteger)getUTCTime:(NSString *)string;
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSDate *logDate = [formatter dateFromString:string];
    NSTimeInterval logDateInterval= [logDate timeIntervalSince1970];
    
    long logTime= logDateInterval;
    return logTime;
}

//利用正则表达式验证
+ (BOOL)isAvailableEmail:(NSString *)email {
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:email];
}
//手机号判断
+ (BOOL)valiMobile:(NSString *)mobile
{
    mobile = [mobile stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (mobile.length != 11)
    {
        return NO;
        
    }else{
        
//        NSString * CM_NUM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d|705)\\d{7}$";
        NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";

        NSString * CU_NUM = @"^1((3[0-2]|5[256]|8[56])\\d|709)\\d{7}$";
        NSString * CT_NUM = @"^1((33|77|53|80|81|89|8[09])\\d|349|700)\\d{7}$";

//        NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))|(198)\\d{8}|(1705)\\d{7}$";//移动号段正则表达式
//        NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))|(166)\\d{8}|(1709)\\d{7}$";//联通号段正则表达式
//        NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))|(199)\\d{8}$";//电信号段正则表达式
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
        BOOL isMatch1 = [pred1 evaluateWithObject:mobile];
        
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
        BOOL isMatch2 = [pred2 evaluateWithObject:mobile];
        
        NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
        BOOL isMatch3 = [pred3 evaluateWithObject:mobile];
        
        if (isMatch1 || isMatch2 || isMatch3) {
            return YES;
        }else{
            return NO;
        }
    }
}

+ (NSString *)replaceUnicode:(NSString *)unicodeStr {
    
    CLog(@"unicodeStr = %@",unicodeStr);
    unicodeStr = [unicodeStr lowercaseString];
    
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2]stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];

    NSString* returnStr = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}
//密码
+ (BOOL)validatePassword:(NSString *)passWord
{
    NSString *passWordRegex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,20}$";

    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];

    return [passWordPredicate evaluateWithObject:passWord];
}

//格式化方法
+ (NSString*)formatNetWork:(long long int)rate {
    
    long long lr = rate;
    if(rate <1024) {
        
        return[NSString stringWithFormat:@"%lldb/s", lr];
        
    }else if(rate >=1024&& rate <1024*1024) {
        if( (double)rate/(1024) > 100.0){
            
            int i = rate /(1024)%10;
            int b = rate /(1024)%10%10;
            return [NSString stringWithFormat:@"%d%d.0kb/s", b,i];

        }else{
            return [NSString stringWithFormat:@"%.1fkb/s", (double)rate/(1024)];

        }
        
//        n/1%10，n/10%10
        
    }else if(rate >=1024*1024&& rate <1024*1024*1024){
        
//        return [NSString stringWithFormat:@"%.2fmb/s", (double)rate / (1024*1024)];
        
        if( (double)rate/(1024*1024) > 100.0){
            
            int i = rate/(1024*1024)%10;
            int b = rate/(1024*1024)%10%10;
            return [NSString stringWithFormat:@"%d%d.0kb/s", b,i];

        }else{
            return [NSString stringWithFormat:@"%.1fkb/s", (double)rate/ (1024*1024)];

        }

    }else{
        return @"0Kb/s";
    };
}

+ (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    //UIGestureRecognizerStateBegan意味着手势已经被识别
    if (gestureRecognizer.state ==UIGestureRecognizerStateBegan)
    {
        //手势发生在哪个view上
        UIView *piece = gestureRecognizer.view;
        //获得当前手势在view上的位置。
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        
        piece.layer.anchorPoint =CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        //根据在view上的位置设置锚点。
        //防止设置完锚点过后，view的位置发生变化，相当于把view的位置重新定位到原来的位置上。
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        piece.center = locationInSuperview;
    }
}
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
//2分查找
+ (NSInteger)binarySearch:(NSArray *)source target:(NSInteger)target {
    if (source.count == 0) {
        return -1;
    }
    NSInteger start = 0;
    NSInteger end = source.count - 1;
    NSInteger mid = 0;
    
    
    
    while (start + 1 < end) {
        
        mid = start + (end - start) / 2;
        KHJVideoModel *vModel = source[mid];
        if (vModel.startTime == target) { // 相邻就退出
            
            return mid;
            
        } else if (vModel.startTime < target) {
            
            start = mid;
            
        } else {
            
            end = mid;
            
        }
    }
    KHJVideoModel *vModel = source[start];

    if ( vModel.startTime <= target && (vModel.startTime+vModel.durationTime) >= target) {
        return start;
    }
    vModel = source[end];

    if (vModel.startTime <= target && (vModel.startTime+vModel.durationTime) >= target) {
        return end;
    }
    return -1;
}
//222将当前时间字符串转为UTCDate
+(NSTimeInterval )UTCDateFromLocalString2:(NSString *)localString{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy_MM_dd"];
    NSDate *date = [dateFormatter dateFromString:localString];
    return [date timeIntervalSince1970];
    
}
+ (long long)fileSizeAtPath:(NSString*)filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}
+(NSString *)valueImageSize:(NSString *)path
{
    
    NSArray *typeArray = @[@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB", @"EB",@"ZB",@"YB"];
    unsigned long long value = [Calculate fileSizeAtPath:path];
    NSString *tString = [Calculate imageSizeString:value];
    
    int index = 0;
    while (value > 1024) {
        value /= 1024.0;
        index ++;
    }
    NSString *str = [NSString stringWithFormat:@"%@%@",tString,typeArray[index]];
    return str;
}
//单位转换
+(NSString *)imageSizeString:(unsigned long long)size{
    
    if (size >= 1024*1024*1024) {
        return [NSString stringWithFormat:@"%.2f",size/(1024*1024*1024.0)];
    }else if (size >= 1024*1024) {
        return [NSString stringWithFormat:@"%.2f",size/(1024*1024.0)];
    }else if(size>1024){
        return [NSString stringWithFormat:@"%.2f",size/1024.0];
    }else{
        return @"";
    }
    
}



//- (void)showAction {
//    NSString *infoString = @"image 原大小：\n";
//    NSString *imageStr = [[NSBundle mainBundle] pathForResource:@"0021" ofType:@"jpg"];
//    NSData *data = [NSData dataWithContentsOfFile:imageStr];
//    infoString = [infoString stringByAppendingString:[self data:data value:0]];
//    infoString = [infoString stringByAppendingString:@"\n"];
//    float value = 1.0;
//    while (value > 0.01) {
//        infoString = [infoString stringByAppendingString:[self value:value]];
//        value -= 0.05;
//    }
//
//    self.infoLabel.text = infoString;
//}

+ (NSString *)value:(float)value andImage:(UIImage *)img {
    NSData *data = UIImageJPEGRepresentation(img, value);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    docDir = [docDir stringByAppendingString:[NSString stringWithFormat:@"/0021.%.3f.jpg",value]];
    NSLog(@"path = %@",docDir);
    [data writeToFile:docDir atomically:YES];
    return [self data:data value:value];
}

+ (NSString *)data:(NSData *)data value:(float)value {
    double dataLength = [data length] * 1.0;
    double orgrionLenght = dataLength;
    NSArray *typeArray = @[@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB", @"EB",@"ZB",@"YB"];
    NSInteger index = 0;
    while (dataLength > 1024) {
        dataLength /= 1024.0;
        index ++;
    }
    NSString *str = [NSString stringWithFormat:@"%.3f，%.1f字节，%.3f%@\n",value,orgrionLenght,dataLength,typeArray[index]];
    return str;
}


@end





















