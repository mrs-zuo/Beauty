//
//  OverallMethods.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-4-21.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "OverallMethods.h"

@implementation OverallMethods

//字符转义
+ (NSString *)EscapingString:(NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    string = [string stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    string = [string stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    //string = [string stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    
    return string;
}

//按输入格式获取时间
+ (NSString *)FormatTimeWithDate:(NSDate *)date andFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    
    return [dateFormatter stringFromDate:date];
}

//字符串检测，如果是nil就将传入值赋予
+ (NSString *)DetectionString:(NSString *)string ifNil:(NSString *)initString
{
    if (string == nil) {
        return initString;
    } else {
        return string;
    }
}
+ (NSString *)notRounding:(double)price afterPoint:(NSInteger)position
{
     NSLog(@"price1 =%f",price);
      NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
        NSDecimalNumber *ouncesDecimal;
        NSDecimalNumber *roundedOunces;
        ouncesDecimal = [[NSDecimalNumber alloc] initWithDouble:price]; NSLog(@"NSDecimalNumber =%@",ouncesDecimal);
         roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
         return [NSString stringWithFormat:@"%@",roundedOunces];
    
}
+ (CGRect)relativeFrameForScreenWithView:(UIView *)v
{
    BOOL iOS7 = [[[UIDevice currentDevice] systemVersion] floatValue] >= 7;
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (!iOS7) {
        screenHeight -= 20;
    }
    UIView *view = v;
    CGFloat x = .0;
    CGFloat y = .0;
    while (view.frame.size.width != 320 || view.frame.size.height != screenHeight) {
        x += view.frame.origin.x;
        y += view.frame.origin.y;
        view = view.superview;
        if ([view isKindOfClass:[UIScrollView class]]) {
            x -= ((UIScrollView *) view).contentOffset.x;
            y -= ((UIScrollView *) view).contentOffset.y;
        }
    }
    return CGRectMake(x, y, v.frame.size.width, v.frame.size.height);
}
@end
