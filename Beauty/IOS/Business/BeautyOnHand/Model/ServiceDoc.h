//
//  proverDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-9.
//  Copyright (c) 2013年 ace-009. All rights reproved.
//

#import <Foundation/Foundation.h>

@interface SubServiceDoc : NSObject
@property (assign, nonatomic) NSInteger service_subServiceCode;
@property (copy, nonatomic) NSString *service_subServiceName;
@property (copy, nonatomic) NSString *service_subServiceTime;
@end

@interface ServiceDoc : NSObject

// --basic info
@property (nonatomic, assign) NSInteger customer_ID;
@property (assign, nonatomic) long long service_Code;
@property (assign, nonatomic) NSInteger service_ID;
@property (assign, nonatomic) NSInteger service_FavouriteID;//收藏专用
@property (assign, nonatomic) BOOL service_Available; //收藏专用
@property (assign, nonatomic) NSInteger service_CategoryID;
@property (copy, nonatomic) NSString *service_ServiceName;
@property (copy, nonatomic) NSString *service_ServiceSearchField; //搜索域
@property (copy, nonatomic) NSString *service_ImgURL;
@property (copy, nonatomic) NSString *service_ExpirationTime;//服务有效期
@property (assign, nonatomic) NSInteger service_NewBrand;    // 0为非
@property (assign, nonatomic) NSInteger service_Recommended; // 0为非
@property (assign, nonatomic) long double service_UnitPrice;
@property (assign, nonatomic) long double service_PromotionPrice;
@property (assign, nonatomic) long double service_CalculatePrice;

/* 0 只显示UnitePrice  calculatePrice = unitPrice
 * 1 显示UnitePrice    calculatePrice = unitPrice * discount
 * 2 显示UnitePrice    calculatePrice = promotionPrice
 */
@property (assign, nonatomic) NSInteger service_MarketingPolicy;//1:单价*折扣率  2:促销价（由后台传）

// --describle
@property (assign, nonatomic) NSInteger service_CourseFrequency;
@property (assign, nonatomic) NSInteger service_SpendTime;  // 单位:分钟
@property (copy, nonatomic) NSString *service_Describe;
@property (strong, nonatomic) NSArray *service_DisplayImgArray;


// -- temporary property
@property (assign, nonatomic) NSInteger service_Quantity;
@property (assign, nonatomic) CGFloat service_TotalMoney;
@property (assign, nonatomic) CGFloat service_DiscountMoney;

// -- layout property
@property (assign, nonatomic) BOOL  service_isShowDiscountMoney;
@property (assign, nonatomic) CGFloat service_HeightForProductName;
@property (assign, nonatomic) CGFloat service_HeightForDescribe;
@property (assign, nonatomic) BOOL service_hasSubService;
@property (strong, nonatomic) NSMutableArray *service_subService;   //自服务数组

- (id)initWithDictionary:(NSDictionary *)dictionary;
@end
