//
//  OperatingInfo.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/6/24.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "OperatingOrder.h"
#import "GPBHTTPClient.h"
#import "AppDelegate.h" 

@implementation OperatingOrder
- (instancetype)initWithDictionary:(NSDictionary *)dic
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

- (BOOL)isMyOrder
{
    if (self.AccountID == ACC_ACCOUNTID) {
        return YES;
    } else {
        return NO;
    }
}

- (OperatingOrderEdit)editStatus
{
    if  (_editStatus == 0) {
        if ([[PermissionDoc sharePermission] rule_MyOrder_Write]) {
            if ([self isMyOrder]) {
                _editStatus = OperatingOrderEditExist;
            } else {
                if ([[PermissionDoc sharePermission] rule_AllOrder_Write]) {
                    _editStatus = OperatingOrderEditExist;
                } else {
                    _editStatus = OperatingOrderEditNone;
                }
            }
        } else {
            _editStatus = OperatingOrderEditNone;
        }
    }
    return _editStatus;
}

- (NSString *)displayAccountName
{
    if (_displayAccountName == nil) {
        _displayAccountName = [NSString stringWithFormat:@"|%@",self.AccountName];
    }
    return _displayAccountName;
}

- (NSString *)statusText
{
    switch (_Status) {
        case 1:
            _statusText = @"进行中";
            break;
        case 2:
            _statusText = @"已完成";
            break;
        case 3:
            _statusText = @"已取消";
            break;
        case 4:
            _statusText = @"已终止";
            break;
        case 5:
            _statusText = @"待确认";
            break;
    }
    return _statusText;
}

- (NSString *)paymentStatusText
{
    switch (_PaymentStatus) {
        case 1:
            _paymentStatusText = @"未支付";
            break;
        case 2:
            _paymentStatusText = @"部分付";
            break;
        case 3:
            _paymentStatusText = @"已支付";
            break;
        case 4:
            _paymentStatusText = @"已退款";
            break;
        case 5:
            _paymentStatusText = @"免支付";
            break;
    }
    return _paymentStatusText;
}

- (NSString *)designateAccountName
{
//    if (_IsDesignated) {
//        _designateAccountName = [[NSString alloc] initWithFormat:@"指定:%@", self.AccountName];
//    } else {
        _designateAccountName = _AccountName;
//    }
    return _designateAccountName;
}


- (NSString *)progressText
{
    if (self.ProductType == 0) {
        if (_TotalCount == 0) {
            _progressText = [NSString stringWithFormat:@"服务%ld次/不限次", (long)_FinishedCount];
        } else {
            _progressText = [NSString stringWithFormat:@"服务%ld次/共%ld次", (long)_FinishedCount, (long)_TotalCount];
        }
    } else {
        _progressText = [NSString stringWithFormat:@"交付%ld件/共%ld件", (long)_FinishedCount, (long)_TotalCount];
        
    }
    return _progressText;
}

- (NSString *)tgDetail
{
    if (_tgDetail == nil) {
        _tgDetail = [NSString stringWithFormat:@"{\"OrderType\":%ld,\"OrderID\":%ld,\"OrderObjectID\":%ld,\"GroupNo\":%f}", (long)self.ProductType, (long)self.OrderID, (long)self.OrderObjectID, self.GroupNo];
    }
    return _tgDetail;
}



+ (AFHTTPRequestOperation *)requestGetUnfinishListCompletionBlock:(void (^)(NSArray *, NSString *, NSInteger))block
{
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":0,\"IsToday\":1,\"ProductType\":0}"];
    return [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/GetUnfinishTGList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [tmpArray addObject:[[OperatingOrder alloc] initWithDictionary:obj]];
            }];
            block(tmpArray, message, code);
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{
                block(nil, error, code);
            }];
        }];
    } failure:^(NSError *error) {
        
    }];
}

+ (AFHTTPRequestOperation *)requestGetCustomerUnfinishListCompletionBlock:(void (^)(NSArray *, NSString *, NSInteger))block
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":0,\"IsToday\":0,\"ProductType\":-1}"];
    return [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/GetUnfinishTGList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [tmpArray addObject:[[OperatingOrder alloc] initWithDictionary:obj]];
            }];
            if (![[PermissionDoc sharePermission] rule_BranchOrder_Read]) { //没有查看所有订单的权限时，过滤掉其他美丽顾问的订单
                NSPredicate *pre = [NSPredicate predicateWithFormat:@"AccountID==%ld", ACC_ACCOUNTID];
                [tmpArray filterUsingPredicate:pre];
            }
            block(tmpArray, message, code);
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{
                block(nil, error, code);
            }];
        }];
    } failure:^(NSError *error) {
        
    }];
}

+ (NSArray *)test
{
    NSDictionary *dic = @{
                          @"customerName":@"Test1",
                          @"serveName":@"洗头",
                          @"serveTime":@"2015-12-03 12:11",
                          @"personName":@"分店三",
                          @"imageUrl":@""
                          };
    NSDictionary *dic1 = @{
                          @"customerName":@"测试数据",
                          @"serveName":@"美发",
                          @"serveTime":@"2014-02-03 12:11",
                          @"personName":@"分店三",
                          @"imageUrl":@""
                          };
    NSDictionary *dic2 = @{
                          @"customerName":@"测试数据3",
                          @"serveName":@"跳帧",
                          @"serveTime":@"2011-12-03 12:11",
                          @"personName":@"分店三",
                          @"imageUrl":@""
                          };
    NSDictionary *dic3 = @{
                          @"customerName":@"测试数据2",
                          @"serveName":@"打头",
                          @"serveTime":@"2012-12-03 12:11",
                          @"personName":@"分店六",
                          @"imageUrl":@""
                          };
    NSDictionary *dic4 = @{
                          @"customerName":@"测试数据4",
                          @"serveName":@"洗头",
                          @"serveTime":@"2014-12-03 12:11",
                          @"personName":@"分店无",
                          @"imageUrl":@""
                          };

    NSArray *tmp = @[dic, dic1, dic2, dic3, dic4];
    NSMutableArray *tmpArray = [NSMutableArray array];
    [tmp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [tmpArray addObject:[[self alloc] initWithDictionary:obj]];
    }];
    return [tmpArray copy];
}
@end
