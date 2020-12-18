//
//  NSString+Additional.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-6-28.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "NSString+Additional.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Additional)

//过滤特殊字符
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

+ (NSString *)md5String:(NSString *)string {
    const char* str = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];//
    CC_MD5(str, strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH ];
    
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02X",result[i]];
    }
    return ret;
}
@end
