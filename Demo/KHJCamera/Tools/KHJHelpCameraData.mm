 //
//  KHJHelpCameraData.m
//  khj
//
//  Created by lxl on 2018/4/10.
//  Copyright © 2018年 lzy. All rights reserved.
//

#import "KHJHelpCameraData.h"

@interface KHJHelpCameraData()
{
    NSFileManager *fileManager ;
    NSString *docPath;
}

@end

@implementation KHJHelpCameraData

+ (KHJHelpCameraData *)sharedModel {
    static KHJHelpCameraData *sharedInstance;
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [[KHJHelpCameraData alloc] init];
        }
        return sharedInstance;
    }
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        
        fileManager = [NSFileManager defaultManager];
        docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
    }
    return self;
}

// 获取视频路径
- (NSString *)getTakeVideoDocPath
{
    NSString *userID = @"userID";
    NSString *khjwant = [NSString stringWithFormat:@"KHJFileName_%@",userID];
    NSString *userDeviceUID = @"userDeviceUID";
    NSString *khjdeviceuid = userDeviceUID;
    NSString *videoPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/Video", khjwant,khjdeviceuid]];   // 关联账户 account 文件夹
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:videoPath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        [fileManager createDirectoryAtPath:videoPath withIntermediateDirectories:YES attributes:nil error:nil];  // 创建路径
    }
    return videoPath;
}

// 获取视频或图片的名称
- (NSString *)getVideoNameWithType:(NSString *)fileType
{
    // 获取年月日
    NSDictionary *dicDay = [self getTodayDate] ;
    NSString *khjtoday = [NSString stringWithFormat:@"%@%@%@",dicDay[@"year"],dicDay[@"month"],dicDay[@"day"]] ;

    NSString *userID = @"userID";
    NSString *khjwant = [NSString stringWithFormat:@"KHJFileName_%@",userID];
    NSString *picOrVideoName  = [NSString stringWithFormat:@"%@-%@",khjtoday,khjwant] ;
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate * NowDate = [NSDate dateWithTimeIntervalSince1970:now];
    
    NSString * timeStr = [formatter stringFromDate:NowDate];
    NSString *allStr = [NSString stringWithFormat:@"%@-%@",picOrVideoName,timeStr] ;
    NSString *fileName = [NSString stringWithFormat:@"/%@.%@",allStr,fileType];
    return fileName;
}

#pragma  mark - 获取当天的日期：年月日
- (NSDictionary *)getTodayDate
{
    //获取今天的日期
    NSDate *today = [NSDate date];
    // 日历类
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // 日历构成的格式
    NSCalendarUnit unit = kCFCalendarUnitYear|kCFCalendarUnitMonth|kCFCalendarUnitDay;
    // 获取对应的时间点
    NSDateComponents *components = [calendar components:unit fromDate:today];
    
    NSString *year = [NSString stringWithFormat:@"%ld", [components year]];
    NSString *month = [NSString stringWithFormat:@"%02ld", [components month]];
    NSString *day = [NSString stringWithFormat:@"%02ld", [components day]];
    
    NSMutableDictionary *todayDic = [[NSMutableDictionary alloc] init];
    [todayDic setObject:year forKey:@"year"];
    [todayDic setObject:month forKey:@"month"];
    [todayDic setObject:day forKey:@"day"];
    return todayDic;
}

// 转换路径（sd卡命名不同）
- (NSString *)changeName:(NSString *)fileName withType:(NSInteger) type
{
    if (type ==0) {
        fileName = [fileName stringByReplacingOccurrencesOfString:@".mp4" withString:@""];
    }else{
        fileName = [fileName stringByReplacingOccurrencesOfString:@".jpg" withString:@""];

    }
    fileName = [fileName stringByReplacingOccurrencesOfString:@".mp4" withString:@""];
    NSArray *dArr = [fileName componentsSeparatedByString:@"_"];
    NSString *dateStr = [NSString stringWithFormat:@"%@%@%@",dArr[0],dArr[1],dArr[2]];
    NSString *timeStr = [NSString stringWithFormat:@"%@%@%@",dArr[3],dArr[4],dArr[5]];
    if(type == 0){
        return [self getVideoNameWithType:@"mp4" withDate:dateStr andTime:timeStr];
    }else
    {
        return [self getVideoNameWithType:@"jpg" withDate:dateStr andTime:timeStr];
    }
}

// 取得一个目录下得所有图片文件名
- (NSArray *)getPictureArray
{
    NSArray *files = [fileManager subpathsAtPath:[self getTakeCameraDocPath]];
    NSArray *reversedArray = [[files reverseObjectEnumerator] allObjects];       //倒序输出，最新的在最前面
    return reversedArray;
}

// 取得一个目录下得所有mp4视频文件名
- (NSArray *)getmp4VideoArray
{
    NSArray *files = [fileManager subpathsAtPath:[self getTakeVideoDocPath]];
    NSArray *reversedArray = [[files reverseObjectEnumerator] allObjects];       //倒序输出，最新的在最前面
    return reversedArray;
}

@end
