//
//  NSDate+Additional.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-7.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "NSDate+Convert.h"

@implementation NSDate (Convert)

+ (NSString *)dateToString:(NSDate *)date
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd HH:mm";
    return [format stringFromDate:date];
}

+ (NSDate *)stringToDate:(NSString *)dateStr 
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd HH:mm";
    return [format dateFromString:dateStr];
}

+ (NSString *)dateToString:(NSDate *)date dateFormat:(NSString *)dateFormat
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = dateFormat;
    return [format stringFromDate:date];
}

+ (NSDate *)stringToDate:(NSString *)dateStr dateFormat:(NSString *)dateFormate
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = dateFormate;
    return [format dateFromString:dateStr];

}
+ (BOOL)isDateWithString:(NSString *)dateStr
{    
    NSString *regex = @"(([0-9]{3}[1-9]|[0-9]{2}[1-9][0-9]{1}|[0-9]{1}[1-9][0-9]{2}|[1-9][0-9]{3})-(((0[13578]|1[02])-(0[1-9]|[12][0-9]|3[01]))|((0[469]|11)-(0[1-9]|[12][0-9]|30))|(02-(0[1-9]|[1][0-9]|2[0-8]))))|((([0-9]{2})(0[48]|[2468][048]|[13579][26])|((0[48]|[2468][048]|[3579][26])00))-02-29)";

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];

    BOOL isDate = [pred evaluateWithObject:dateStr];
    
    return isDate;
}

// 获取日
- (NSUInteger)getDay{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dayComponents = [calendar components:(NSDayCalendarUnit) fromDate:self];
    return [dayComponents day];
    
}

// 获取月
- (NSUInteger)getMonth
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dayComponents = [calendar components:(NSMonthCalendarUnit) fromDate:self];
    return [dayComponents month];
}

// 获取年
- (NSUInteger)getYear
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dayComponents = [calendar components:(NSYearCalendarUnit) fromDate:self];
    return [dayComponents year];
}





@end
