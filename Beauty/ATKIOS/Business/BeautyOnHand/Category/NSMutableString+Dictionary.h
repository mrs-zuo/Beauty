//
//  NSMutableString+Dictionary.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15-3-5.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (Dictionary)
- (NSMutableString *)stringFromDictionary:(NSDictionary *)dict;
- (NSMutableString *)stringFromArray:(NSArray *)array;
@end
