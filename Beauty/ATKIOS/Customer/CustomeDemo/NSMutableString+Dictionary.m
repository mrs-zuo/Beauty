//
//  NSMutableString+Dictionary.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15-3-5.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.

// 

#import "NSMutableString+Dictionary.h"

@implementation NSMutableString (Dictionary)
- (NSMutableString *)stringFromArray:(NSArray *)array
{
    if ([array count] <= 0){
        [self appendString:@"[]"];//递归跳出条件
        return self;
    }
    
    [self appendString:@"["];
    
    for (id obj in array) {
        if ([obj isKindOfClass:[NSDictionary class]]){
            [self stringFromDictionary:obj];
            [self appendString:@","];
        }
        else if ([obj isKindOfClass:[NSArray class]]){
            [self stringFromArray:obj];
            [self appendString:@","];
        }
        else if ([obj isKindOfClass:[NSString class]])
            [self appendFormat:@"\"%@\",",obj];

        else if ([obj isKindOfClass:[NSNumber class]])
            [self appendFormat:@"%@,",obj];
    }

    if ([[self substringFromIndex:self.length - 1] isEqualToString:@","])
        [self replaceCharactersInRange:NSMakeRange(self.length - 1, 1) withString:@"]"];
    else
        [self appendString:@"]"];
    return self;
}
- (NSMutableString *)stringFromDictionary:(NSDictionary *)dict
{
    if ([dict count] <= 0){
        [self appendString:@"{}"];//递归跳出条件
        return self;
    }
    
    [self appendString:@"{"];
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [self appendFormat:@"\"%@\":",key];
            [self stringFromDictionary:obj];
            [self appendString:@","];
        }else if ([obj isKindOfClass:[NSArray class]]){
            [self appendFormat:@"\"%@\":",key];
            [self stringFromArray:obj];
            [self appendString:@","];
        }else if ([obj isKindOfClass:[NSString class]]){
            if ([obj length] > 0)
                [self appendFormat:@"\"%@\":\"%@\",",key,obj];
            else
                [self appendFormat:@"\"%@\":\"\",",key];
        }else if ([obj isKindOfClass:[NSNumber class]]){
            [self appendFormat:@"\"%@\":%@,",key,obj];
        }
    }];
    
    if ([[self substringFromIndex:self.length - 1] isEqualToString:@","])
        [self replaceCharactersInRange:NSMakeRange(self.length - 1, 1) withString:@"}"];
    else
        [self appendString:@"}"];
    
    return self;
}
@end
