//
//  OrderFilterDoc.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-12-23.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "OrderFilterDoc.h"

@implementation OrderFilterDoc

- (id)init{
    self = [super init];
    if(self){
        _startTime = nil;
        _endTime = nil;
        _account_Id = 0;              // 美丽顾问
        _user_Id = 0;                       //顾客
        _user_Name = nil;
        _account_Name = nil;
        _OrderSource = -1;                      //订单来源
        _orderType = -1;                       //订单类型
        _orderStatus = -1;                        //订单状态
        _orderIsPaid = -1;                      //支付状态
        _accountArray = [NSMutableArray array];
    }
    return self;
}

- (NSString *)account_Name
{
    NSArray *nameArray = [_accountArray valueForKeyPath:@"@unionOfObjects.user_Name"];
    _account_Name = [nameArray componentsJoinedByString:@"、"];
    return _account_Name;
}

- (NSString *)account_IDs
{
    _account_IDs = @"";
    
    NSArray *idArray = [_accountArray valueForKeyPath:@"@unionOfObjects.user_Id"];
    if (idArray.count) {
        _account_IDs = [idArray componentsJoinedByString:@","];
    }
    return _account_IDs;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_startTime forKey:@"startTime"];
    [aCoder encodeObject:_endTime forKey:@"endTime"];
//    [aCoder encodeObject:_account_Name forKey:@"account_Name"];
    [aCoder encodeObject:_user_Name forKey:@"user_Name"];
    [aCoder encodeInteger:_OrderSource forKey:@"OrderSource"];
    [aCoder encodeInteger:_orderType forKey:@"orderType"];
    [aCoder encodeInteger:_orderStatus forKey:@"orderStatus"];
    [aCoder encodeInteger:_orderIsPaid forKey:@"orderIsPaid"];
//    [aCoder encodeInteger:_account_Id forKey:@"account_Id"];
    [aCoder encodeInteger:_user_Id forKey:@"user_Id"];
    [aCoder encodeObject:_accountArray forKey:@"accountArray"];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]){
        _startTime = [aDecoder decodeObjectForKey:@"startTime"];
        _endTime = [aDecoder decodeObjectForKey:@"endTime"];
//        _account_Name = [aDecoder decodeObjectForKey:@"account_Name"];              // 美丽顾问
        _user_Name = [aDecoder decodeObjectForKey:@"user_Name"];                       //顾客
        _orderType = [aDecoder decodeIntegerForKey:@"orderType"];                      //订单类型
        _OrderSource = [aDecoder decodeIntegerForKey:@"OrderSource"];                       //订单来源

        _orderStatus = [aDecoder decodeIntegerForKey:@"orderStatus"];                       //订单状态
        _orderIsPaid = [aDecoder decodeIntegerForKey:@"orderIsPaid"];                      //支付状态
//        _account_Id = [aDecoder decodeIntegerForKey:@"account_Id"];                      
        _user_Id = [aDecoder decodeIntegerForKey:@"user_Id"];
        _accountArray = [aDecoder decodeObjectForKey:@"accountArray"];
    }
    return  self;
}

@end
