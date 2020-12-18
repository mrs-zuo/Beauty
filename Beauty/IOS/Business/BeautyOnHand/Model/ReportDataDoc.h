//
//  ReportDataDoc.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-10-21.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReportDataDoc : NSObject

@property (nonatomic, assign) NSInteger  AllCustomerCount;//customer_Quantity; //顾客数量
@property (nonatomic, assign) NSInteger  AllAccountCount;//account_Quantity;  //账号数量
@property (nonatomic, assign) NSInteger  AllBranchCount;//shop_Quantity;     //门店数量
@property (nonatomic, assign) NSInteger  CompleteOrderCount;//complete_Order;    //完成订单数量
@property (nonatomic, assign) NSInteger  EffectOrderCount;//effect_Order;      //有效订单数量
@property (nonatomic, assign) NSInteger  AllCardCount;//总数量
@property (nonatomic, assign) NSInteger  ClientCount;//顾客端用户
@property (nonatomic, assign) NSInteger  WeChatCount;//公众号用户

@property (nonatomic, assign) double  OrderTotalSalePrice;//revenue_All;          //订单总金额数量
@property (nonatomic, assign) double  AllECardRechargeCount;//ecard_recharge;       //e卡总充值
@property (nonatomic, assign) double  AllECardBalanceCount;//ecard_Balances;       //e卡总余额



- (id)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic,strong) NSMutableArray *sectionDatas;

@property (nonatomic,strong) NSMutableArray *personRowDatas;
@property (nonatomic,strong) NSMutableArray *orderRowDatas;

@property (nonatomic,strong) NSMutableArray *personRowValueDatas;
@property (nonatomic,strong) NSMutableArray *orderRowValueDatas;

@end
