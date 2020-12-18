//
//  PurchasedCommodityObject.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-5-28.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "PurchasedCommodityObject.h"

#define CUSTOMER_DISCOUNT [[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_DISCOUNT"] floatValue]

@implementation PurchasedCommodityObject

- (id)init
{
    self = [super init];
    if (self) {
        self.purchasedCommodity_count = 1;
    }
    return self;
}

- (void)valuationPurchasedCommodityMoney
{
    _purchasedCommodity_totalMoney = self.product_originalPrice * _purchasedCommodity_count;
    _purchasedCommodity_totalSalesMoney = self.product_salesPrice * _purchasedCommodity_count;
}


@end
