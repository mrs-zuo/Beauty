//
//  NSString+MD5.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15-3-4.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "NSString+MD5.h"

#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5)
- (NSString *) getMD5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr),result);
    NSMutableString *hash =[NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash uppercaseString];
}
@end
