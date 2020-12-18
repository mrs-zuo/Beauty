//
//  PayDoc.h
//  test1
//
//  Created by macmini on 13-8-9.
//  Copyright (c) 2013年 macmini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayDoc : NSObject

@property (assign, nonatomic) long double pay_TotalPrice;//*
@property (copy, nonatomic) NSString *pay_Balance;  //储值卡余额
@property (copy, nonatomic) NSString *pay_PayPrice;
@property (copy, nonatomic) NSString *pay_PayByCrash;
@property (copy ,nonatomic) NSString *Pay_PayByBankCard;
@property (copy ,nonatomic) NSString *Pay_PayByStoredValueCard;
@property (copy ,nonatomic) NSString *Pay_Model; //
@property (copy ,nonatomic) NSString *Pay_AmountByModel;
@property (copy ,nonatomic) NSString *Pay_Level;
@property (copy, nonatomic) NSString *OrderIdList;
@property (copy, nonatomic) NSString *Pay_Remark;
@property (assign, nonatomic) CGFloat Pay_RemarkHeight;
@property (assign, nonatomic) NSInteger OrderNumber;
@property (nonatomic, assign) NSInteger pay_peoplecount;
@end