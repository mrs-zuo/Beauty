//
//  NSString+Additional.h
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-6-28.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additional)

// 去除首尾空字符串
- (NSString *)stringByTrimmingTrailEmpty;

- (BOOL)containsString:(NSString *)otherString;



@end
