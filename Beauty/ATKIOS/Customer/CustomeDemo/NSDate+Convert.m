//
//  NSDate+Additional.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-7.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "NSDate+Convert.h"

@implementation NSDate (Convert)

static NSDateFormatter *dateFormator;
static NSDateFormatter *dateTimeFormator;
static NSDateFormatter *dateTimeLongFormator;
static NSDateFormatter *dateCNFormator;
static NSDateFormatter *dateLongTimeLongLongFormator;
+ (NSString *)stringFromDateCN:(NSDate *)date
{
    if(!dateCNFormator){
        dateCNFormator = [[NSDateFormatter alloc] init];
        dateCNFormator.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        dateCNFormator.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    
    return [dateCNFormator stringFromDate:date];
}

+ (NSDate *)dateCNFromString:(NSString *)dateStr
{
    if (!dateCNFormator){
        dateCNFormator = [[NSDateFormatter alloc] init];
        dateCNFormator.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        dateCNFormator.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    
    return [dateCNFormator dateFromString:dateStr];
}

+ (NSString *)stringFromDate:(NSDate *)date
{
    if(!dateFormator){
        dateFormator = [[NSDateFormatter alloc] init];
        dateFormator.dateFormat = @"yyyy-MM-dd";
    }

    return [dateFormator stringFromDate:date];
}

+ (NSDate *)dateFromString:(NSString *)dateStr
{
    if (!dateFormator){
        dateFormator = [[NSDateFormatter alloc] init];
        dateFormator.dateFormat = @"yyyy-MM-dd";
    }
    
    return [dateFormator dateFromString:dateStr];
}

+ (NSString *)stringFromDateTime:(NSDate *)date
{
    if(!dateTimeFormator){
        dateTimeFormator = [[NSDateFormatter alloc] init];
        dateTimeFormator.dateFormat = @"yyyy-MM-dd HH:mm";
    }
    
    return [dateTimeFormator stringFromDate:date];
}

+ (NSDate *)dateTimeFromString:(NSString *)dateStr
{
    if (!dateTimeFormator){
        dateTimeFormator = [[NSDateFormatter alloc] init];
        dateTimeFormator.dateFormat = @"yyyy-MM-dd HH:mm";
    }

    return [dateTimeFormator dateFromString:dateStr];
}

+ (NSString *)stringDateTimeLongFromDate:(NSDate *)date
{
    if(!dateTimeLongFormator){
        dateTimeLongFormator = [[NSDateFormatter alloc] init];
        dateTimeLongFormator.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    return [dateTimeLongFormator stringFromDate:date];
}

+ (NSDate *)dateTimeLongFromString:(NSString *)dateStr
{
    if (!dateTimeLongFormator){
        dateTimeLongFormator = [[NSDateFormatter alloc] init];
        dateTimeLongFormator.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    
    return [dateTimeLongFormator dateFromString:dateStr];
}

+ (NSString *)stringDateTimeLongLongFromDate:(NSDate*)date{
    
    if (!dateLongTimeLongLongFormator){
        dateLongTimeLongLongFormator = [[NSDateFormatter alloc] init];
        dateLongTimeLongLongFormator.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    }
    return [dateLongTimeLongLongFormator stringFromDate:[NSDate date]];
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

+ (NSString *)stringFromDateString:(NSString *)dateString
{
  
    NSDate *tempDate = [NSDate dateTimeFromString:dateString];
    NSString *tempString = [NSDate dateToString:tempDate dateFormat:@"yyyy-MM-dd"];
    return tempString;
}
@end
