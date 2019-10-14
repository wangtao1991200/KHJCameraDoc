//
//  NSDate+JLZero.m

#import "NSDate+JLZero.h"

@implementation NSDate (JLZero)

+ (NSTimeInterval)getZeroWithTimeInterverl:(NSTimeInterval) timeInterval
{
    NSDate *originalDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFomater = [[NSDateFormatter alloc]init];
    dateFomater.dateFormat = @"yyyy_MM_dd";
    NSString *original = [dateFomater stringFromDate:originalDate];
    NSDate *ZeroDate = [dateFomater dateFromString:original];
    return [ZeroDate timeIntervalSince1970];
}

@end
