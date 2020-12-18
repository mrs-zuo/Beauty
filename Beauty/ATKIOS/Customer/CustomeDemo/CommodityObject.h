//
//  CommodityObject.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-5-28.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "ProductObject.h"

typedef NS_ENUM(NSInteger, GPCommoditySalesAttribute) {
    GPCommoditySalesAttributeNone = 0,              //无
    GPCommoditySalesAttributeNew = 1 << 0,          //新品
    GPCommoditySalesAttributeRecommended = 1 << 1,  //推荐
};

@interface CommodityObject : ProductObject

@property (retain, nonatomic) NSString *commodity_specification;                    //商品规格
@property (assign, nonatomic) NSInteger commodity_stockQuantity;                    //商品库存
@property (assign, nonatomic) GPCommoditySalesAttribute commodity_salesAttribute;   //商品销售属性
@property (assign, nonatomic) NSInteger commodity_stockCalcType;                    //1,普通库存，2，不计库存，3，超卖库存
@end
