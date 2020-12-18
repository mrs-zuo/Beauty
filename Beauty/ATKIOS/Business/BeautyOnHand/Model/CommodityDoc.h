//
//  CommodityDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-27.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommodityDoc : NSObject

// --basic Info
@property (nonatomic, assign) NSInteger customer_ID;
@property (assign, nonatomic) long long comm_Code;
@property (assign, nonatomic) NSInteger comm_ID;
@property (assign, nonatomic) NSInteger comm_FavouriteID; //收藏专用
@property (assign, nonatomic) BOOL comm_Available; //收藏专用 
@property (assign, nonatomic) NSInteger comm_CategoryID;
@property (copy, nonatomic) NSString *comm_CommodityName;
@property (copy, nonatomic) NSString *comm_CommoditySearchField;//搜索域
@property (copy, nonatomic) NSString *comm_ImgURL;
@property (assign, nonatomic) NSInteger comm_NewBrand;    // 0为非
@property (assign, nonatomic) NSInteger comm_Recommended; // 0为非

@property (assign, nonatomic) long double comm_UnitPrice;
@property (assign, nonatomic) long double comm_PromotionPrice;
@property (assign, nonatomic) long double comm_CalculatePrice;
@property (nonatomic, strong) NSString *comm_StockCalc;

/* 0 只显示UnitePrice
 * 1 显示UnitePrice promotionPrice = UnitePrice * discount
 * 2 显示UnitePrice promotionPrice
 */
@property (assign, nonatomic) NSInteger comm_MarketingPolicy;

// -- describle
@property (copy, nonatomic) NSString *comm_Specification;
@property (copy, nonatomic) NSString *comm_Describe;
@property (assign, nonatomic) NSInteger comm_StockQuantity;
@property (strong, nonatomic) NSArray *comm_DisplayImgArray;

// -- temporary property
@property (assign, nonatomic) NSInteger comm_Quantity;
@property (assign, nonatomic) CGFloat comm_TotalMoney;
@property (assign, nonatomic) CGFloat comm_DiscountMoney;

// -- layout property
@property (assign, nonatomic) BOOL  comm_isShowDiscountMoney;
@property (assign, nonatomic) CGFloat comm_HeightForName;
@property (assign, nonatomic) CGFloat comm_HeightForDescribe;

- (id)initWithDictionary:(NSDictionary *)dictionary;

- (id)initWithSpecialDictionary:(NSDictionary *)dictionary;
@end
