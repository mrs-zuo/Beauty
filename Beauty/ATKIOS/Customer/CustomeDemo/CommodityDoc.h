//
//  CommodityDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-27.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommodityDoc : NSObject

@property (assign, nonatomic) long long comm_Code;           //商品编号
@property (assign, nonatomic) NSInteger comm_ID;             //商品ID，相当于编号下的版本号
@property (assign, nonatomic) NSInteger comm_ObjectID;
@property (assign, nonatomic) NSInteger comm_Type;
@property (copy,   nonatomic) NSString *comm_CommodityName;  //商品名称
@property (copy,   nonatomic) NSString *comm_Describe;       //商品描述
@property (copy,   nonatomic) NSString *comm_Specification;  //商品规格
@property (assign, nonatomic) long double comm_UnitPrice;        //商品单价(原价)
@property (assign, nonatomic) long double comm_PromotionPrice;   //商品 促销价or优惠价 (当MarketingPolicy=1为UnitPrice*Discount 当MarketingPolicy=2由后台传)
@property (assign, nonatomic) NSInteger comm_BranchID;       //商品所在门店
@property (copy,   nonatomic) NSString *comm_BranchName;     //商品所在门店
@property (assign, nonatomic) NSInteger comm_StockQuantity;  //商品库存
@property (assign, nonatomic) NSInteger comm_ImageCount;     //商品描述图片数量
@property (assign, nonatomic) NSInteger comm_MarketingPolicy;//商品减价类型：0原价 1按等级打折 2促销价
@property (strong, nonatomic) NSArray *comm_DisplayImgArray; //商品图片数组
@property (assign, nonatomic) NSInteger comm_New;            //商品属性：0为新商品 1新商品
@property (assign, nonatomic) NSInteger comm_Recommended;    //商品属性：0未推荐   1推荐
@property (copy,   nonatomic) NSString *comm_Thumbnail;      //商品缩略图


@property (copy, nonatomic) NSString *cart_ID;             //订单中一条的ID(订单专用)
@property (assign, nonatomic) NSInteger comm_Quantity;       //订单中一条商品数量(订单专用)
@property (assign, nonatomic) long double comm_TotalMoney;       //订单中一条商品总价(订单专用)
@property (assign, nonatomic) long double comm_DiscountMoney;    //订单中一条商品优惠总价(订单专用)
@property (copy, nonatomic) NSString *   comm_CardName;
@property (assign, nonatomic) NSInteger comm_CardID;
@property (assign, nonatomic) BOOL comm_Available;           //商品是否有效

@property (assign, nonatomic) double status;
@property (assign, nonatomic) BOOL comm_isShowDiscountMoney;
@property (assign, nonatomic, readonly) CGFloat comm_HeightForName;
@property (assign, nonatomic, readonly) CGFloat comm_HeightForDescribe;

- (long double)retTotalMoney;
- (long double)retDiscountMoney;

@end
