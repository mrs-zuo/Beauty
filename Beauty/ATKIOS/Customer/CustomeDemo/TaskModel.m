
//
//  TaskModel.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/8/25.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "TaskModel.h"

@implementation TaskModel
- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

//- (void)setValue:(id)value forKey:(NSString *)key
//{
//    if ([key isEqualToString:@""]) {
//        
//    } else {
//        [super setValue:value forKey:key];
//    }
//}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

@end
