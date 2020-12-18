//
//  proverDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-9.
//  Copyright (c) 2013年 ace-009. All rights reproved.
//

#import <Foundation/Foundation.h>

@interface ServiceDoc : NSObject
@property (assign, nonatomic) long long service_ID;
@property (copy, nonatomic) NSString *service_ProductName;
@property (copy, nonatomic) NSString *service_SpendTime;
@property (assign, nonatomic) NSInteger service_CourseFrequency;
@property (strong, nonatomic) NSString *service_ExpirationTime;
@property (assign, nonatomic) CGFloat service_UnitPrice;            //服务单价(原价)
@property (assign, nonatomic) CGFloat service_PromotionPrice;       //服务 促销价or优惠价 (当MarketingPolicy=1为UnitPrice*Discount 当MarketingPolicy=2由后台传)
@property (assign, nonatomic) NSInteger service_MarketingPolicy;    //服务减价类型：0原价 1按等级打折 2促销价

@property (assign, nonatomic) NSInteger service_Quantity;
@property (assign, nonatomic) long double service_TotalMoney;           //订单中一条商品总价(订单专用)
@property (assign, nonatomic) long double service_DiscountMoney;        //订单中一条商品优惠总价(订单专用)

@property (assign, nonatomic) BOOL service_isShowDiscountMoney;

@property (assign, nonatomic, readonly) CGFloat service_HeightForProductName;

- (CGFloat)retTotalMoney;
- (CGFloat)retDiscountMoney;
@end
