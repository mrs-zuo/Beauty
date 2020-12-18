//
//  NSDate+Additional.m
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-8-7.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "NSDate+Additional.h"

@implementation NSDate (Additional)

+ (NSString *)getDate:(NSDate *)date  dateFormat:(NSString *)dateFormat
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = dateFormat;
    return [format stringFromDate:date];
}
@end
