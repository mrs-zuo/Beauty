//
//  NSString+Additional.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-6-28.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additional)

// 去除首尾空字符串
- (NSString *)stringByTrimmingTrailEmpty;
- (BOOL)containsString:(NSString *)otherString;

+ (NSString *)md5String:(NSString *)string;

@end


@interface NSString (AppendXML)

// 去除首尾空字符串
- (NSString *)stringByTrimmingTrailEmpty;
@end

