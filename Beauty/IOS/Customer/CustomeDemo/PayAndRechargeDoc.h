//
//  PayAndRechargeDoc.h
//  CustomeDemo
//
//  Created by MAC_Lion on 13-8-20.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, GPRechargeMode) {
    GPRechargeModeByCash = 0,
    GPRechargeModeByBankCard = 1,
    GPRechargeModeByPresented = 2,
    GPRechargeModeByBalance = 3,        //余额转入
};

@interface PayAndRechargeDoc : NSObject
@property (copy, nonatomic) NSString *p_Date;//*
@property (copy, nonatomic) NSString *p_Title;
@property (copy, nonatomic) NSString *p_Amount;
@property (copy, nonatomic) NSString *p_Balance; //储值卡余额
@property (assign, nonatomic) GPRechargeMode p_RechargeMode;//充值方式 0:现金、1:银行卡
@property (assign, nonatomic) NSInteger p_Type;
@property (assign, nonatomic) NSInteger p_PaymentID;
@property (assign, nonatomic) NSInteger p_OrderCount;
@property (assign, nonatomic) NSInteger p_ID;
@property (assign, nonatomic) NSInteger p_Mode;
@property (copy, nonatomic) NSString *p_Remark;
@end
