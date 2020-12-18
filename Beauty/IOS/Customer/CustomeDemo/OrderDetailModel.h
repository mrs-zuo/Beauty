//
//  OrderDetailModel.h
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/8/25.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TreatmentGroup.h"
#import "TaskModel.h"

@interface OrderDetailModel : NSObject

@property (nonatomic, assign) NSInteger OrderID;
@property (nonatomic, assign) NSInteger OrderObjectID;
@property (nonatomic, assign) NSInteger ProductType;
@property (nonatomic, assign) long long ProductCode;
@property (nonatomic, assign) NSInteger Status;
@property (nonatomic, assign) NSInteger PaymentStatus;

@property (nonatomic, assign) NSInteger BranchID;
@property (nonatomic, assign) double TotalOrigPrice;
@property (nonatomic, assign) double TotalSalePrice;
@property (nonatomic, assign) double TotalCalcPrice;
@property (nonatomic, assign) double UnPaidPrice;
@property (nonatomic, assign) NSInteger ResponsiblePersonID;
@property (nonatomic, assign) NSInteger SalesPersonID;
@property (nonatomic, assign) NSInteger CustomerID;
@property (nonatomic, assign) NSInteger CreatorID;
@property (nonatomic, assign) BOOL IsPast;

@property (nonatomic, assign) BOOL Flag;
@property (nonatomic, assign) NSInteger FinishedCount;
@property (nonatomic, assign) NSInteger TotalCount;
@property (nonatomic, assign) NSInteger SurplusCount;
@property (nonatomic, assign) NSInteger PastCount;
@property (nonatomic, assign) NSInteger Quantity;
@property (nonatomic, assign) NSInteger ScdlCount;


@property (nonatomic, copy) NSString *OrderNumber;
@property (nonatomic, copy) NSString *OrderTime;
@property (nonatomic, copy) NSString *ProductName;
@property (nonatomic, copy) NSString *BranchName;
@property (nonatomic, copy) NSString *SubServiceIDs;
@property (nonatomic, copy) NSString *ResponsiblePersonName;
@property (nonatomic, copy) NSString *SalesName;
@property (nonatomic, copy) NSString *CustomerName;
@property (nonatomic, copy) NSString *CreatorName;
@property (nonatomic, copy) NSString *CreateTime;
@property (nonatomic, copy) NSString *Remark;
@property (nonatomic, assign) CGFloat remarkHeight;
@property (nonatomic, copy) NSString *ExpirationTime;

@property (nonatomic, copy) NSArray *GroupList;
@property (nonatomic, assign) NSInteger groupCount;
@property (nonatomic, copy) NSArray *ScdlList;

@property (nonatomic, copy) NSArray *CompletionGroupList;
@property (nonatomic, assign) NSInteger completionCount;
@property (nonatomic, assign) NSInteger treatmentCount;

@property (nonatomic, assign) BOOL isShowFirst;
@property (nonatomic, assign) BOOL isShowSecond;
@property (nonatomic, assign) BOOL isShowTask;
@property (nonatomic, assign) BOOL isShowCompletion;

@property (nonatomic, copy) NSString *progressStatus;
@property (nonatomic, copy) NSString *payStatus;

@property (nonatomic, copy) NSString *orderProgressInfo;
- (instancetype)initWithDic:(NSDictionary *)dic;

- (TreatmentGroup *)fetchTreatmentGroupIndex:(NSIndexPath *)index;

+ (NSString *)orderProgressStatus:(NSInteger)status;
@end
