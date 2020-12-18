//
//  ProductAndPriceDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-10-9.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "ProductAndPriceDoc.h"
#import "DEFINE.h"

@implementation ProductAndPriceDoc

- (id)init
{
    self = [super init];
    if (self) {
        _serviceArray = [NSArray array];
        _commodityArray = [NSArray array];
    }
    return self;
}

// 未实现深copy 只是实现了初始化isShowDiscountMoney
- (id)copyWithZone:(NSZone *)zone
{
    ProductAndPriceDoc *productAndPriceDoc = [ProductAndPriceDoc allocWithZone:zone];
    for (ServiceDoc *serviceDoc in _serviceArray) {
        if (serviceDoc.service_TotalMoney == serviceDoc.service_DiscountMoney)
            serviceDoc.service_isShowDiscountMoney = NO;
    }
    
    for (CommodityDoc *commdityDoc in _commodityArray) {
        if (commdityDoc.comm_TotalMoney == commdityDoc.comm_DiscountMoney)
            commdityDoc.comm_isShowDiscountMoney = NO;
    }
    [productAndPriceDoc setServiceArray:_serviceArray];
    [productAndPriceDoc setCommodityArray:_commodityArray];
    [productAndPriceDoc setFlag:_flag];
    [productAndPriceDoc setTotalMoney:_totalMoney];
    [productAndPriceDoc setDiscountMoney:_discountMoney];
    [productAndPriceDoc setIsShowDiscountMoney:_totalMoney != _discountMoney];
    return productAndPriceDoc;
}


- (CGFloat)table_Height
{
    CGFloat tableHeight = 0.0f;
    if (_flag == 0 && [_serviceArray count] > 0) {
        
        //--其对象的高度
        for (ServiceDoc *service in _serviceArray)
        {
            tableHeight += service.service_HeightForProductName ;
            if (service.service_isShowDiscountMoney) {
                tableHeight += 3 * kTableView_HeightOfRow;
            } else {
                tableHeight += 2 * kTableView_HeightOfRow;
            }
            tableHeight += (kTableView_Margin_Bottom + kTableView_Margin_TOP);
            
            if (IOS6) tableHeight += 2;
        }
        
        //--总价和优惠价
        if ([_serviceArray count] > 1)
        {
            tableHeight += (kTableView_HeightOfRow + kTableView_Margin_TOP + kTableView_Margin_Bottom) ;
            if (_isShowDiscountMoney == YES) {
                tableHeight += (kTableView_HeightOfRow + kTableView_Margin_TOP + kTableView_Margin_Bottom);
            }
            if (IOS6) tableHeight += 2;
        }
        
    } else if (_flag == 1 && [_commodityArray count] > 0) {
        //--其对象的高度
        for (CommodityDoc *commodity in _commodityArray)
        {
            tableHeight += commodity.comm_HeightForName;
            if (commodity.comm_isShowDiscountMoney) {
                tableHeight += 3 * kTableView_HeightOfRow;
            } else {
                tableHeight += 2 * kTableView_HeightOfRow;
            }
            tableHeight += (kTableView_Margin_Bottom + kTableView_Margin_TOP);
            
            if (IOS6) tableHeight += 2;
        }
        
        //--总价和优惠价
        if ([_commodityArray count] > 1) {
            tableHeight += (kTableView_HeightOfRow + kTableView_Margin_TOP + kTableView_Margin_Bottom);
            
            if (_isShowDiscountMoney == YES) {
                tableHeight +=  (kTableView_HeightOfRow + kTableView_Margin_TOP + kTableView_Margin_Bottom);
            }
            if (IOS6) tableHeight += 2;
        }
    }
    tableHeight += kTableView_Margin_TOP;
    
    return tableHeight;
}

- (CGFloat)retDiscountMoney
{
    CGFloat  allDiscountMoney = 0.0f;
    if (_flag == 0 && [_serviceArray count] > 0) {
        for (ServiceDoc *service in _serviceArray) {
            allDiscountMoney += service.service_DiscountMoney;
        }
    } else if (_flag == 1 && [_commodityArray count] > 0) {
        for (CommodityDoc *commodity in _commodityArray) {
            allDiscountMoney += commodity.comm_DiscountMoney;
        }
    }
    return allDiscountMoney;
}


- (CGFloat)retTotalMoeny
{
    CGFloat totalMoney = 0.0f;
    if (_flag == 0 && [_serviceArray count] > 0) {
        for (ServiceDoc *service in _serviceArray) {
            totalMoney += service.service_TotalMoney;
        }
    } else if (_flag == 1 && [_commodityArray count] > 0) {
        for (CommodityDoc *commodity in _commodityArray) {
            totalMoney += commodity.comm_TotalMoney;
        }
    }
    return totalMoney;
}
@end
