//
//  NSDate+Additional.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-7.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

// NSDate  初始化和更改属性是很耗时的操作，所以都使用静态变量
#import <Foundation/Foundation.h>

@interface NSDate (Convert)

+ (NSString *)stringFromDateCN:(NSDate *)date;
+ (NSDate *)dateCNFromString:(NSString *)dateStr;

+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSDate *)dateFromString:(NSString *)dateStr;

+ (NSString *)stringFromDateTime:(NSDate *)date;
+ (NSDate *)dateTimeFromString:(NSString *)dateStr;

+ (NSString *)stringDateTimeLongFromDate:(NSDate *)date;
+ (NSDate *)dateTimeLongFromString:(NSString *)dateStr;

+ (NSString *)stringDateTimeLongLongFromDate:(NSDate*)date;

+ (NSString *)dateToString:(NSDate *)date dateFormat:(NSString *)dateFormat;
+ (NSDate *)stringToDate:(NSString *)dateStr dateFormat:(NSString *)dateFormate;

/** @brief 日期string 格式化
 *
 * @param dateString 日期类型的string
 *
 * @return 年-月-日 2016-05-01
 */
+ (NSString *)stringFromDateString:(NSString *)dateString;



@end
