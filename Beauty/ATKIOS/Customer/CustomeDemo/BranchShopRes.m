//
//  BranchShopRes.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/3/1.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import "BranchShopRes.h"

@implementation BranchShopRes
- (instancetype)init
{
    if (self = [super init]) {
        _imageURLArrs = [NSMutableArray array];
        _rowDatas = [NSMutableArray array];
    }return self;
}
-(void)setTGStartTime:(NSString *)TGStartTime
{
    if (TGStartTime.length > 10) {
        _TGStartTime = [TGStartTime substringToIndex:10];
    }
}

@end
