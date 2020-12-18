//
//  AwaitFinishOrder.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/9.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, AwaitOrderType) {
    AwaitOrderBill, //待结
    AwaitOrderFinish //存单
};

typedef NS_ENUM(NSInteger, AwaitOrderEdit) {
    AwaitOrderEditNone,
    AwaitOrderEditExist
};

@interface AwaitFinishOrder : NSObject
@property (nonatomic, strong) NSString *ProductName;
@property (nonatomic, assign) NSInteger ProductType;
@property (nonatomic, assign) NSInteger TotalCount; 
@property (nonatomic, assign) NSInteger FinishedCount;
@property (nonatomic, assign) NSInteger ExecutingCount;
@property (nonatomic, strong) NSString *OrderTime;
@property (nonatomic, strong) NSString *AccountName;
@property (nonatomic, assign) NSInteger AccountID;
@property (nonatomic, assign) NSInteger OrderID;
@property (nonatomic, assign) NSInteger OrderObjectID;

@property (nonatomic, assign) NSInteger PaymentStatus;
@property (nonatomic, assign) double GroupNo;
@property (nonatomic, strong) NSString *TGStartTime;
@property (nonatomic, strong) NSString *statusText;
@property (nonatomic, assign) AwaitOrderType awaitType;
@property (nonatomic, assign) BOOL      isSelect;
@property (nonatomic, strong) NSString *tgDetail;

@property (nonatomic, strong) NSString *executingString;
@property (nonatomic, strong) NSString *paymentString;
@property (nonatomic, strong) NSString *processString;//存单
@property (nonatomic, assign) AwaitOrderEdit editStatus;
@property (nonatomic, assign) NSInteger customerID;
@property (nonatomic, assign) NSInteger IsConfirmed;

- (instancetype)initWithDic:(NSDictionary *)dic type:(AwaitOrderType)Type;
- (instancetype)initWithDic:(NSDictionary *)dic type:(AwaitOrderType)Type customerID:(NSInteger)cusID;
@end
