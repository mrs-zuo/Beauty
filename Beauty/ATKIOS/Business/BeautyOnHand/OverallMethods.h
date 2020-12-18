//
//  OverallMethods.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-4-21.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OverallMethods : NSObject

//字符转义（例：<--&lt;  >--&gt;）
+ (NSString *)EscapingString:(NSString *)string;

//按输入格式获取时间
+ (NSString *)FormatTimeWithDate:(NSDate *)date andFormat:(NSString *)format;

//四舍六入五取偶
+ (double)notRounding:(double)price afterPoint:(NSInteger)position;

@end
