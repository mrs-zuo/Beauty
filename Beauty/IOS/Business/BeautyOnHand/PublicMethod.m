//
//  UrlCheck.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-11-21.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "PublicMethod.h"

@implementation PublicMethod







- (NSArray *)checkString:(NSString *)string
{
    
//    UrlCheck *check = [[UrlCheck alloc] init];
    NSMutableArray *array = [NSMutableArray array];

    NSError *error;
    NSString *regulaStr = @"(((http[s]{0,1}|ftp)://)?[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
     
                        
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                            error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    if ([arrayOfAllMatches count]){
//        check.containURL = YES;
        for (NSTextCheckingResult *resu in arrayOfAllMatches) {
            NSRange range = [resu rangeAtIndex:0];
//            NSURL *url = [NSURL URLWithString:[string substringWithRange:range]];
            NSValue *va = [NSValue valueWithRange:range];
            [array addObject:va];
            
        }
    }
    NSArray *ar = [NSArray arrayWithArray:array];
    
    return ar;
    
}


@end
