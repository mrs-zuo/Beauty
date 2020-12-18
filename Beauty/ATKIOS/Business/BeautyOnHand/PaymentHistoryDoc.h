//
//  PaymentHistoryDoc.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-11-17.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderPaymentDoc : NSObject

@property (copy , nonatomic) NSString *orderNumber;
@property (copy , nonatomic) NSString *orderPaymentName;
@property (nonatomic) double orderPaymentMoney;
@property (nonatomic) NSInteger orderId;
@property (nonatomic) NSInteger orderType;
@end

//支付列表及详情 Model
@interface PaymentHistoryDoc : NSObject

@property (nonatomic,assign) NSInteger paymentId;
@property (copy ,nonatomic) NSString *paymentTitle;
@property (copy, nonatomic) NSString *paymentTime;
@property (copy, nonatomic) NSString * BranchName;
@property (copy, nonatomic) NSString *TypeName;//交易类型
@property (copy, nonatomic) NSString *paymentType;//交易类型
@property (strong, nonatomic) NSMutableArray *paymentMode;  //支付方式数组
@property (nonatomic) double paymentTotalMoney; //总共支付金额
@property (nonatomic) BOOL isRemark;
@property (copy,nonatomic) NSString *paymentOperator;
@property (copy,nonatomic) NSString *paymentTypeStr;
@property (nonatomic, copy) NSString *paymentCodeString;
@property (nonatomic, assign) NSInteger paymentNumber;
@property (nonatomic) double paymentOfCash;
@property (nonatomic) double paymentOfECard;
@property (nonatomic) double paymentOfCard;
@property (nonatomic) double paymentOfOthers;
@property (nonatomic) double paymentBalanceLeft;
@property (copy, nonatomic) NSString *paymentRemark;
//业绩提成
@property (nonatomic,strong)NSMutableArray *profitListArrs;
@property (nonatomic, strong) NSMutableArray *accArray;
@property (strong, nonatomic) NSMutableArray *paymentArray;
@property (strong, nonatomic) NSMutableArray *paymentDispalyArray; //显示时的数据来源，在解析数据的时候就准备好需要显示的数据，能减少cellForRowAtIndexPath的逻辑难度和变更难度。
@property (strong , nonatomic) NSMutableArray * PaymentOrderListArr;
@property (nonatomic,strong)NSMutableArray *salesConsultantListArrs;
/* 业绩参与金额 */
@property(nonatomic) double salesConsultantMonery;



@end

