//
//  ServiceRes.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/3/17.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "ServiceRes.h"

@implementation ServiceRes
-(instancetype)init
{
    if (self = [super init]) {

    }
    return self;
}
// 实现这个方法的目的：告诉MJExtension框架TGList数组里面装的是什么模型
+ (NSDictionary *)objectClassInArray{
    return @{
             @"TGList" : @"TGListRes"
            };
}

@end
