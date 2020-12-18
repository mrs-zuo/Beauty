//
//  PurchasedCommodityObject.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-5-28.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "CommodityObject.h"

@interface PurchasedCommodityObject : CommodityObject

@property (assign, nonatomic) long long purchasedCommodity_cartID;        //已购商品在购物车中的ID
@property (assign, nonatomic) NSInteger purchasedCommodity_count;         //已购商品数量
@property (assign, nonatomic) CGFloat purchasedCommodity_totalMoney;      //已购商品总价
@property (assign, nonatomic) CGFloat purchasedCommodity_totalSalesMoney; //已购商品总销售价

//计算已购买商品的总价和总销售价
- (void)valuationPurchasedCommodityMoney;

@end
