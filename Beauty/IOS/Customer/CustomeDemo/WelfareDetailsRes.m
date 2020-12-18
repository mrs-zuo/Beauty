//
//  WelfareDetailsRes.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/2/24.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "WelfareDetailsRes.h"

@implementation WelfareDetailsRes
- (instancetype)init
{
    if (self = [super init]) {
        _BranchList = [NSMutableArray array];
    }
    return self;
}
-(NSString *)ValidDate
{
    if (_ValidDate.length >=10) {
        return  [_ValidDate substringToIndex:10];
    }
    return _ValidDate;
}
-(NSString *)GrantDate
{
    if (_GrantDate.length >=10) {
       return  [_GrantDate substringToIndex:10];
    }
    return _GrantDate;
}

@end
