//
//  PayAndRechargeDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-8-15.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayAndRechargeDoc : NSObject
@property (copy, nonatomic) NSString *Time;//*p_Date;//*
@property (copy, nonatomic) NSString *RechargeText;//*p_Title;//储值卡余额
@property (assign, nonatomic) long double Amount;//*pw_Amount;//*
@property (assign, nonatomic) long double Balance;//*pw_Balance;//储值卡余额
@property (assign, nonatomic) NSInteger RechargeMode;//p_RechargeMode;//充值方式 0:现金、1:银行卡
@property (assign, nonatomic) long double p_Amount;
@property (assign, nonatomic) long double p_Balance;
@property (assign, nonatomic) NSInteger Type;//p_Type;
@property (assign, nonatomic) NSInteger PaymentID;//p_PaymentID;
@property (assign, nonatomic) NSInteger ID;//p_ID;
@property (assign, nonatomic) NSInteger OrderCount;//p_OrderCount;
@property (assign, nonatomic) NSInteger Mode;//p_Mode;
- (id)initWithDictionary:(NSDictionary *)dictionary;
@end
