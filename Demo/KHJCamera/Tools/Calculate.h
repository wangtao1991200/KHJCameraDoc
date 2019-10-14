//
//  Calculate.h
//  test111
//
//  Created by hezewen on 2018/5/30.
//  Copyright © 2018年 khj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
@interface Calculate : NSObject

+ (CGFloat)getAnglesWithThreePoint:(CGPoint)pointA pointB:(CGPoint)pointB pointC:(CGPoint)pointC;
+ (NSInteger)isBelongPart:(CGFloat)angle;

//计算数组去重个数,并且排序
+(NSMutableArray *)calCategoryArray:(NSArray *)arr;
//排序
+ (NSMutableArray *)bubbleDescendingOrderSortWithArray:(NSMutableArray *)descendingArr;

+(UIImage *)getFristImageInmp4Video:(NSString *)filePath;
+(UIImage*)getCoverImage:(NSURL *)_outMovieURL;


+(NSString *)nextDay:(NSString *) dateString;
+(NSString *)prevDay:(NSString *) dateString;
+(long)getTimeStrWithString:(NSString *)str;
//日期比较
+ (NSInteger)compareDate:(NSString*)aDate withDate:(NSString*)bDate;
//获取当前时间
+(NSString*)getCurrentTimes;
//根据返回的时间戳字符串，获取指定的格式的时间
+(NSString*)getTimeFormat:(NSString *)timeStampString;

//根据返回的时间戳字符串，获取指定的格式的时间
+(NSString*)formateTimeStamp:(NSString *)timeStampString;
//获取时间戳进行比较
+(NSInteger)getUTCTime:(NSString *)string;
//邮箱验证
+ (BOOL)isAvailableEmail:(NSString *)email;
//手机号验证
+ (BOOL)valiMobile:(NSString *)mobile;
//uicode转汉字
+ (NSString *)replaceUnicode:(NSString *)unicodeStr;
//判断密码合法性
+ (BOOL) validatePassword:(NSString *)passWord;
+ (NSString*)formatNetWork:(long long int)rate;
//设置锚点
+ (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;
//转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
//根据返回的时间戳字符串，获取指定的格式的时间
+(NSString*)getSureTimeFormat:(NSString *)timeStampString;
//2分查找
+ (NSInteger)binarySearch:(NSArray *)source target:(NSInteger)target;

+(NSString *)getVedioNameFromTimes:(NSTimeInterval)timeInterval;

+(NSTimeInterval )UTCDateFromLocalString2:(NSString *)localString;

+ (long long)fileSizeAtPath:(NSString*)filePath;
+(NSString *)valueImageSize:(NSString *)path;

@end






