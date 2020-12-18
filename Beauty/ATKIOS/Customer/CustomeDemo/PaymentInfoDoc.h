//
//  PaymentInfoDoc.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/10/12.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaymentInfoDoc : NSObject
@property(nonatomic,assign) NSInteger orderNumber;//订单数量
@property(nonatomic,assign) NSInteger ProductCode;
@property(nonatomic,assign) long double totalOrigPrice;//总价
@property(nonatomic,assign) long double totalCalcPrice;//总会员价
@property(nonatomic,assign) long double totalSalePrice;//总出售价
@property(nonatomic,assign) long double unPaidPrice;//未支付价
@property(nonatomic,copy) NSString * expirationDate;//卡的有效使用期
@property(nonatomic,copy) NSString * giveCouponAmount;
@property(nonatomic,copy) NSString * givePointAmount;


/*
  支付卡的信息
 */

@property(nonatomic,copy) NSString * cardName;
@property(nonatomic,assign) NSInteger cardID;
@property(nonatomic,assign) NSInteger cardTypeID;
@property(nonatomic,copy) NSString * userCardNo;
@property (nonatomic,copy)NSString * balance;

@end
