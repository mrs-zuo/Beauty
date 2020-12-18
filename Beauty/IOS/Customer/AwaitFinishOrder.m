//
//  AwaitFinishOrder.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/9.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "AwaitFinishOrder.h"

@implementation AwaitFinishOrder

- (instancetype)initWithDic:(NSDictionary *)dic type:(AwaitOrderType)Type
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
        self.awaitType = Type;
    }
    return self;
}

- (instancetype)initWithDic:(NSDictionary *)dic type:(AwaitOrderType)Type customerID:(NSInteger)cusID
{
    self = [self initWithDic:dic type:Type];
    if (self) {
        _customerID = cusID;
    }
    return self;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

- (AwaitOrderEdit)editStatus
{
  
    _editStatus = AwaitOrderEditNone;
    
    return _editStatus;
}

//待结
//存单
- (NSString *)processString
{
    if (_processString == nil) {
        if (_awaitType == AwaitOrderBill) {
            if (self.ProductType == 1) {
                _processString = [NSString stringWithFormat:@"交付%ld件/共%ld件",(long)_FinishedCount, (long)_TotalCount];
            } else {
                if (_TotalCount == 0) {
                    _processString = [NSString stringWithFormat:@"服务%ld次/不限次",(long)_FinishedCount];
                } else {
                    _processString = [NSString stringWithFormat:@"服务%ld次/共%ld次",(long)_FinishedCount, (long)_TotalCount];
                }
            }
        } else {
            if (self.ProductType == 1) {
                _processString = [NSString stringWithFormat:@"已交%ld件/共%ld件",(long)_FinishedCount, (long)_TotalCount];
            } else {
                if (_TotalCount == 0) {
                    _processString = [NSString stringWithFormat:@"完成%ld次/不限次",(long)_FinishedCount];
                } else {
                    _processString = [NSString stringWithFormat:@"完成%ld次/共%ld次",(long)_FinishedCount, (long)_TotalCount];
                }
            }
        }
    }
    return _processString;
}

- (NSString *)statusText
{
    if (_statusText == nil) {
        _statusText = [NSString stringWithFormat:@"完成%ld次/共%ld次", (long)_FinishedCount, (long)_TotalCount];
    }
    return _statusText;
}

- (NSString *)paymentString
{//1:未支付 2:部分付、3:已支付 //5 免支付
    switch (_PaymentStatus) {
        case 1:
            _paymentString = @"未支付";
            break;
        case 2:
            _paymentString = @"部分付";
            break;
        case 3:
            _paymentString = @"已支付";
            break;
        case 4:
            _paymentString = @"已退款";
            break;
        case 5:
            _paymentString = @"免支付";
            break;
    }
    return _paymentString;
}

- (NSString *)executingString
{
    if (self.ExecutingCount == 0) {
        _executingString = @"";
    } else {
        _executingString = [NSString stringWithFormat:@"进行中%ld次", (long)_ExecutingCount];
    }
    return _executingString;
}

- (NSString *)tgDetail
{
    if (_tgDetail == nil) {
        _tgDetail = [NSString stringWithFormat:@"{\"OrderType\":%ld,\"OrderID\":%ld,\"OrderObjectID\":%ld,\"GroupNo\":%lld}", (long)self.ProductType, (long)self.OrderID, (long)self.OrderObjectID, self.GroupNo];
    }
    return _tgDetail;
}

@end
