//
//  NSString+Additional.m
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-6-28.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "NSString+Additional.h"

@implementation NSString (Additional)

- (NSString *)stringByTrimmingTrailEmpty
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL)containsString:(NSString *)otherString
{
    NSString *self_Str = [self uppercaseString];
    NSString *other_Str = [otherString uppercaseString];
    
    NSRange range = [self_Str rangeOfString:other_Str];
    if (range.location != NSNotFound) {
        return YES;
    } else {
        return NO;
    }
}


@end
