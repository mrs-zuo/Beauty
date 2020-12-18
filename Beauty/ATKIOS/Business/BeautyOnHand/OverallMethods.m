//
//  OverallMethods.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-4-21.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "OverallMethods.h"

@implementation OverallMethods

+ (NSString *)EscapingString:(NSString *)string
{
//    string = [string stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
//    string = [string stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
//    string = [string stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    //string = [string stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
//    string = [string stringByReplacingOccurrencesOfString:@"\" withString:@"\\\\"];
//    string = [string stringByReplacingOccurrencesOfString:@"/" withString:@"\/"];
//    string = [string stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];

    return string;
}

+ (NSString *)FormatTimeWithDate:(NSDate *)date andFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    
    return [dateFormatter stringFromDate:date];
}

+ (double)notRounding:(double)price afterPoint:(NSInteger)position
{
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    
    ouncesDecimal = [[NSDecimalNumber alloc] initWithDouble:price];
    
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    
    return [roundedOunces doubleValue];
}



@end
