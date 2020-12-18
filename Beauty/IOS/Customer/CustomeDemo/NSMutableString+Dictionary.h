//
//  NSMutableString+Dictionary.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15-3-5.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.

// 字典转成NSString      by ZhangWei


#import <Foundation/Foundation.h>

@interface NSMutableString (Dictionary)

///#begin zh-cn
/**
 *      @brief   必须初始化好一个可变字符串，然后再调用该函数（接口设计的有点2...）
 */
///#end

- (NSMutableString *)stringFromDictionary:(NSDictionary *)dict;
@end
