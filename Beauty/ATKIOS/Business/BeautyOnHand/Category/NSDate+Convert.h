//
//  NSDate+Additional.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-7.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

//\d{4}-(0[1-9]|1[1-2])-(0[1-9]|2[0-9]|3[0-1])

#import <Foundation/Foundation.h>

@interface NSDate (Convert)

+ (NSString *)dateToString:(NSDate *)date;   // default dateFormat yyyy-MM-dd HH:mm

+ (NSString *)dateToString:(NSDate *)date  dateFormat:(NSString *)dateFormat;

+ (NSDate *)stringToDate:(NSString *)dateStr; // default dateFormat yyyy-MM-dd HH:mm

+ (NSDate *)stringToDate:(NSString *)dateStr dateFormat:(NSString *)dateFormate;

+ (BOOL)isDateWithString:(NSString *)dateStr; //default dateFormat yyyy-MM-dd

/**
 *  @brief  获取日
 *
 *  @param
 *
 *  @return
 */
- (NSUInteger)getDay;

/**
 *  @brief  获取月
 *
 *  @param
 *
 *  @return
 */
- (NSUInteger)getMonth;

/**
 *  @brief  获取年
 *
 *  @param
 *
 *  @return
 */
- (NSUInteger)getYear;



@end
