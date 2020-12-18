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

//字符串检测，如果是nil就将传入值赋予
+ (NSString *)DetectionString:(NSString *)string ifNil:(NSString *)initString;
+ (NSString *)notRounding:(double)price afterPoint:(NSInteger)position;
/**
 *  计算一个view相对于屏幕(去除顶部statusbar的20像素)的坐标
 *  iOS7下UIViewController.view是默认全屏的，要把这20像素考虑进去
 */
+ (CGRect)relativeFrameForScreenWithView:(UIView *)v;
@end
