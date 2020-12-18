//
//  TwoElementDoc.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-11-17.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwoElementDoc : NSObject
@property (copy, nonatomic) NSString *firstElement;
@property (copy, nonatomic) NSString *secondElement;

- (id)initWithValue:(NSString *)value forKey:(NSString *)key;
@end
