//
//  MarkingReport.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/21.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "MarkingReport.h"
#import "GPBHTTPClient.h"

@implementation MarkingReport

- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

@end
