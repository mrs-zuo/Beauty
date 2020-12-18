//
//  ProductAndPriceDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-10-9.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OppStepObject;
@class EcardInfo;
@class WelfareRes;
// 组建service、commodity结构
@interface ProductDoc : NSObject
@property (assign, nonatomic) NSInteger pro_ID;
@property (assign, nonatomic) long long pro_Code;
@property (copy, nonatomic) NSString *pro_Name;
@property (assign, nonatomic) NSInteger pro_Type;  // 0服务 1商品
@property (copy, nonatomic) NSString *pro_ExpirationTime; //服务专用
@property (copy, nonatomic) NSString *pro_SubServicesCode; //服务专用

@property (nonatomic, assign) BOOL  isCount;  //是否计入统计
@property (nonatomic, strong) OppStepObject *oppStep; //暂存时，添加商机模板

/**
 *  订单销售策略 0:原价 1:折扣价 2:促销价
 */
@property (assign, nonatomic) NSInteger pro_MarketingPolicy;
@property (assign, nonatomic) double pro_Discount;

@property(assign ,nonatomic) NSInteger pro_TotalCount;//总数
@property(assign ,nonatomic) NSInteger pro_SurplusCount;//剩余
@property (assign, nonatomic) NSInteger pro_PastCount;  //过去完成数量
@property (assign, nonatomic) NSInteger pro_FinishedCount; //已完成数量

/**
 *  商品的单价(原价)
 */
@property (assign, nonatomic) long double pro_Unitprice;       //单价


/**
 *  折扣价(会员价)=单价*会员卡折扣率
 */
@property (assign, nonatomic) long double pro_PromotionPrice;  //折扣价

@property (assign, nonatomic) long double pro_BPrice;  //折扣价用来计算促销价格

/**
 *  修改优惠价后对应的单价	
 */
@property (assign, nonatomic) long double pro_CalculatePrice; //修改优惠价后对应的单价

/**
 *  订单数量
 */
@property (assign, nonatomic) NSInteger   pro_quantity;   //数量

/**
 *  订单总价 =  原价 * 数量
 */
@property (assign, nonatomic) long double pro_TotalMoney;      //订单总价 =  原价 * 数量

/**
 *  订单折扣总价(会员价) = 折扣价 * 数量
 */
@property (nonatomic, assign) long double pro_TotalCalcPrice;  //订单折扣总价 = 折扣价 * 数量

/**
 *  订单最终销售价格(成交价) = calulateprice * 数量
 */
@property (assign, nonatomic)long double pro_TotalSaleMoney;  //订单最终销售价格 = calulateprice * 数量

/**
 *  订单未支付价格
 */
@property (nonatomic, assign) long double pro_UnPaidPrice;  //订单未支付价格
@property (nonatomic, assign) NSInteger pro_Status;    //订单支付状态
@property (nonatomic, assign) long double pro_refundPrice; //退款总额

/**
 *  订单过去支付金额
 */
@property (nonatomic, assign) long double pro_HaveToPay;     //过去支付

@property (assign, nonatomic) CGFloat pro_HeightOfProductName;
@property (assign, nonatomic) BOOL  pro_IsShowDiscountMoney;
/// 是否有优惠券说明
@property (assign, nonatomic) BOOL  pro_IsShowWelfareInfo;

@property (strong, nonatomic) NSString *pro_ResponsiblePersonName;
@property (assign, nonatomic) NSInteger pro_ResponsiblePersonID;

//销售顾问
@property (nonatomic, assign) NSInteger pro_SalesID;
@property (nonatomic, strong) NSString *pro_SalesName;

@property (strong, nonatomic) NSString *pro_Remark;
@property (assign, nonatomic) CGFloat pro_RemarkHeight;

@property (nonatomic, strong) EcardInfo *currentCard;
@property (nonatomic, strong) NSMutableArray *cardArray;
@property (nonatomic, assign) NSInteger cardID;
@property (nonatomic, strong) NSString *cardName;

@property (nonatomic, strong) WelfareRes *welfareRes;

/**
 * 过去完成次数(可以为0)
 */
@property (nonatomic, assign) NSInteger TgPastCount;  //过去完成

/**
 * 一个服务的规定服务次数(后台)
 */
@property (nonatomic, assign) NSInteger pro_UnitCourseCount;   //一个服务的次数

/**
 * 服务次数(不能为0)
 */
@property (nonatomic, assign) NSInteger courseCount;

//数据源
@property (nonatomic,strong) NSMutableArray *orderConfirmServerDatas;
@property (nonatomic,strong) NSMutableArray *orderConfirmProductDatas;


- (double)retCalculatePrice;
@end


@interface ProductAndPriceDoc : NSObject

// 一对多
@property (strong, nonatomic) NSMutableArray *productArray;
@property (assign, nonatomic) long double totalMoney;
@property (assign, nonatomic) long double discountMoney;

@property (strong, nonatomic) ProductDoc *productDoc; // Opp(或者Order) 一对一

@property (assign, readonly, nonatomic) CGFloat table_Height;

- (double)retDiscountMoney;
- (double)retTotalMoney;

- (void)initIsShowDiscountMoney; // 初始化ProductDoc的isShowDiscountMoney
@end
