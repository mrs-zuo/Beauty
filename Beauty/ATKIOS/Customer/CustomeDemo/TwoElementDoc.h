//
//  TwoElementDoc.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-11-7.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwoElementDoc : NSObject
@property (copy, nonatomic) NSString *firstElement;
@property (copy, nonatomic) NSString *secondElement;

- (id)initWithValue:(NSString *)value forKey:(NSString *)key;
@end
