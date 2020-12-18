//
//  OperatingInfo.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/6/24.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AFHTTPRequestOperation;
typedef NS_ENUM(NSInteger, OperatingOrderEdit) {
    OperatingOrderEditNone = 1,
    OperatingOrderEditExist
};

@interface OperatingOrder : NSObject
@property (nonatomic, copy) NSString *ProductName;
@property (nonatomic, copy) NSString *TGStartTime;
@property (nonatomic, copy) NSString *AccountName;
@property (nonatomic, strong) NSString *displayAccountName;
@property (nonatomic, assign) NSInteger AccountID;
@property (nonatomic, assign) NSInteger PaymentStatus;
@property (nonatomic, copy) NSString *paymentStatusText;

@property (nonatomic, assign) NSInteger FinishedCount;
@property (nonatomic, assign) NSInteger TotalCount;
@property (nonatomic, assign) double GroupNo;
@property (nonatomic, assign) NSInteger OrderID;
@property (nonatomic, assign) NSInteger OrderObjectID;
@property (nonatomic, assign) NSInteger ProductType;
@property (nonatomic, strong) NSString *progressText;

@property (nonatomic, assign) NSInteger Status;
@property (nonatomic, copy) NSString *statusText;
@property (nonatomic, copy) NSString *HeadImageURL;
@property (nonatomic, copy) NSString *CustomerName;
@property (nonatomic, assign) NSInteger CustomerID;
@property (nonatomic, assign) BOOL IsDesignated;
@property (nonatomic, strong) NSString *tgDetail;
@property (nonatomic, assign) BOOL isSelect;

//是否签名
@property (nonatomic,assign) NSInteger IsConfirmed;

@property (nonatomic, strong) NSString *designateAccountName;

@property (nonatomic, assign) OperatingOrderEdit editStatus;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

+ (AFHTTPRequestOperation *)requestGetUnfinishListCompletionBlock:(void(^)(NSArray *, NSString *, NSInteger ))block;
+ (AFHTTPRequestOperation *)requestGetCustomerUnfinishListCompletionBlock:(void(^)(NSArray *, NSString *, NSInteger ))block;

+ (NSArray *)test;
@end
