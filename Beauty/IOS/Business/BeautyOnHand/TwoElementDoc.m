//
//  TwoElementDoc.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-11-17.
//  Copyright (c) 2014年 ace-009. All rights reserved.
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

