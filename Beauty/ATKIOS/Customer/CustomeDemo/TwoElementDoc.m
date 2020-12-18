//
//  TwoElementDoc.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-11-7.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "TwoElementDoc.h"

@implementation TwoElementDoc
- (id)initWithValue:(NSString *)value forKey:(NSString *)key{
    self = [super init];
    if(self){
        self.firstElement = key;
        self.secondElement = value;
    }
    return self;
}
@end
