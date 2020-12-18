//
//  ProductObject.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-5-28.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "ProductObject.h"

#define CUSTOMER_DISCOUNT [[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_DISCOUNT"] floatValue]

@implementation ProductSold
- (void)setProduct_storageType:(NSInteger)product_storageType
{
    _product_storageType = product_storageType;
    switch (product_storageType) {
        case 1: _product_storageTypeStr = @"普通库存"; break;
        case 2: _product_storageTypeStr = @"不计库存"; break;
        case 3: _product_storageTypeStr = @"超卖库存"; break;
        default: _product_storageTypeStr = @"普通库存";
    }
}
@end

@implementation ProductObject

- (id)init
{
    self = [super init];
    if (self) {
        self.product_pictureURLArray = [NSArray array];
    }
    return self;
}

- (void)setProduct_originalPrice:(CGFloat)product_originalPrice
{
    _product_originalPrice = product_originalPrice;
    _product_originalPriceStr = [NSString stringWithFormat:@"%.2f", product_originalPrice];
}

- (void)setProduct_promotionPrice:(CGFloat)product_promotionPrice
{
    _product_promotionPrice = product_promotionPrice;
    _product_promotionPriceStr = [NSString stringWithFormat:@"%.2f", product_promotionPrice];
}

- (void)setProduct_salesPrice:(CGFloat)product_salesPrice
{
    _product_salesPrice = product_salesPrice;
    _product_salesPriceStr = [NSString stringWithFormat:@"%.2f", product_salesPrice];
}

- (void)setProduct_discountPrice:(CGFloat)product_discountPrice
{
    _product_discountPrice = product_discountPrice;
    _product_discountPriceStr = [NSString stringWithFormat:@"%.2f", _product_discountPrice];
}

- (CGFloat)valuationProductNameHeightWithFont:(UIFont *)font
{
    CGFloat currentHeight = [self.product_name sizeWithFont:font constrainedToSize:CGSizeMake(300, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height + 20;
    self.product_nameHeight = currentHeight;
    return currentHeight;
}

- (CGFloat)valuationProductDescribeHeightWithFont:(UIFont *)font
{
    CGFloat currentHeight = [self.product_describe sizeWithFont:font constrainedToSize:CGSizeMake(300, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height + 20;
    _product_describeHeight = currentHeight;
    return currentHeight;
}

- (void)valuationProductSalesPrice
{
    switch (self.product_sellingWay) {
        case GPProductSellingWayOriginalPrice:
            self.product_salesPrice = _product_originalPrice;
            break;
        case GPProductSellingWayDiscountPrice:
            self.product_salesPrice = _product_discountPrice;//_product_originalPrice * CUSTOMER_DISCOUNT;
            break;
        case GPProductSellingWayPromotionPrice:
            self.product_salesPrice = _product_promotionPrice;
            break;
        default:
            break;
    }
}
@end
