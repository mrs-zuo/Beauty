//
//  FirstPageFilter.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/21.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "FirstPageFilter.h"
#import "UserDoc.h"

@implementation FirstPageFilter
- (instancetype)init
{
    self = [super init];
    if (self) {
        _type = 1;
        _accountName = nil;
    }
    return self;
}

- (void)setType:(FilterOrderType)num
{
    if (num > 3 || num < 1) {
        num = 1;
    }
    _type = num;
}

/*
 *  Status=1：进行中
 *  Status=2：已完成
 *  Status=3：已取消
 *  Status=4：已终止
 *  Status=5：完成待确认
 */
- (NSString *)Status
{
    switch (_type) {
        case FilterOrderAll:
            _Status = @"进行中";
            break;
        case FilterOrderOne:
            _Status = @"已完成";
            break;
        case FilterOrderTwo:
            _Status = @"全部";
            break;
    }
    return _Status;
}

- (NSString *)displayName
{
    if (_accountName == nil) {
        _displayName = @"服务顾问";
    } else if ([_displayName isEqualToString:@""])
    {
        _displayName = @"无";
    } else {
        _displayName = _accountName;
    }
    return _displayName;
}

- (NSPredicate *)filterPred
{
    if (self.type == 3 && self.accountName == nil) {
        _filterPred = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
    } else if (self.type == 3 || self.accountName == nil) {
        if (self.type == 3) {
            _filterPred = [NSPredicate predicateWithFormat:@"AccountName==%@", self.accountName];
        } else {
            if (self.type == 2) {
                _filterPred = [NSPredicate predicateWithFormat:@"(Status in %@)", @[@2,@5]];

            } else {
                _filterPred = [NSPredicate predicateWithFormat:@"Status==%d",self.type];
            }
        }
    } else if (self.type == 2) {
        _filterPred = [NSPredicate predicateWithFormat:@"(Status in %@) AND AccountName==%@", @[@2,@5], self.accountName];
    } else {
        _filterPred = [NSPredicate predicateWithFormat:@"Status==%d AND AccountName==%@", self.type, self.accountName];
    }
    return _filterPred;
}
@end
