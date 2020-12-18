//
//  TGListRes.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/3/17.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGListRes : NSObject
@property (nonatomic,copy) NSString *ProductName;
@property (nonatomic,copy) NSString *TGStartTime;
@property (nonatomic,copy) NSString *GroupNo;
@property (nonatomic,assign) NSInteger OrderID;
@property (nonatomic,assign) NSInteger OrderObjectID;
@property (nonatomic,assign) NSInteger ProductType;
@property (nonatomic,assign) NSInteger Status;
@property (nonatomic,copy) NSString *CustomerName;
@property (nonatomic,copy) NSString *CustomerID;
@property (nonatomic,assign) NSInteger PaymentStatus;
@property (nonatomic,assign) NSInteger TotalCount;
@property (nonatomic,assign) NSInteger FinishedCount;

@property (nonatomic,copy) NSString *PaymentStatusStr;
@property (nonatomic,copy) NSString *StatusStr;

@end
