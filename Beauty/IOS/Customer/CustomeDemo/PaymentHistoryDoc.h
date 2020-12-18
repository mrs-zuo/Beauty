//
//  PaymentHistoryDoc.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-11-7.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderPaymentDoc : NSObject

@property (copy , nonatomic) NSString *orderNumber;
@property (copy , nonatomic) NSString *orderPaymentName;
@property (nonatomic) long double orderPaymentMoney;
@property (nonatomic) NSInteger orderId;
@property (nonatomic) NSInteger orderType;
@end

//支付列表及详情 Model

@interface PaymentHistoryDoc : NSObject
@property (copy ,nonatomic) NSString *branchName;
@property (strong, nonatomic)NSMutableArray *paymentDetailArray;
@property (copy ,nonatomic) NSString *paymentCode;
@property (nonatomic) NSInteger paymentId;
@property (nonatomic) NSInteger paymentOrderCount;
@property (copy ,nonatomic) NSString *paymentTitle;
@property (copy, nonatomic) NSString *paymentTime;
@property (strong, nonatomic) NSMutableArray *paymentMode;  //支付方式数组
@property (nonatomic) long double paymentTotalMoney; //总共支付金额
@property (nonatomic) BOOL isRemark;
@property (copy,nonatomic) NSString *paymentOperator;
@property (nonatomic, copy) NSString *paymentCodeString;
@property (nonatomic, assign) NSInteger paymentNumber;
@property (nonatomic) long double paymentBalanceLeft;
@property (copy, nonatomic) NSString *paymentRemark;
@property (nonatomic, strong) NSMutableArray *accArray;
@property (strong, nonatomic) NSMutableArray *paymentArray;
@property (strong, nonatomic) NSMutableArray *paymentDispalyArray; //显示时的数据来源，在解析数据的时候就准备好需要显示的数据，能减少cellForRowAtIndexPath的逻辑难度和变更难度。
@end
