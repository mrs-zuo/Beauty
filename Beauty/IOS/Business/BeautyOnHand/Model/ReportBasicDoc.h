//
//  ReportBasicDoc.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-20.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReportBasicDoc : NSObject

//@property (nonatomic, assign) double sale_All;
//@property (assign, nonatomic) double sale_Cash;
//@property (assign, nonatomic) double sale_BankCard;
//@property (assign, nonatomic) double sale_Ecard;
//@property (assign, nonatomic) double sale_Other;
//@property (assign, nonatomic) double sale_Service;
//@property (assign, nonatomic) double sale_Commodity;
//@property (assign, nonatomic) NSInteger sale_ServiceQuantity;
//@property (assign, nonatomic) NSInteger sale_CommodityQuantity;
//
//@property (assign, nonatomic) NSInteger sale_AllServiceCount;
//
//@property (nonatomic, assign) double recharge_All;
//@property (assign, nonatomic) double recharge_Cash;
//@property (assign, nonatomic) double recharge_BankCard;
//
//@property (nonatomic, assign) NSInteger customer_NewAdd;
//@property (nonatomic, assign) NSInteger customer_NewAddEffect;
//@property (nonatomic, assign) NSInteger customer_OldEffect;


@property (nonatomic, assign) double ServiceRevenueAll;
@property (nonatomic, assign) double ServiceRevenueCash;
@property (nonatomic, assign) double ServiceRevenueBank;
@property (nonatomic, assign) double ServiceRevenueWeChat ;
@property (nonatomic, assign) double ServiceRevenueAlipay ;
@property (nonatomic, assign) double ServiceRevenueECard;
@property (nonatomic, assign) double ServiceRevenueOther;

@property (nonatomic, assign) double ServiceRevenuePoint;
@property (nonatomic, assign) double ServiceRevenueCoupon;

@property (nonatomic, assign) double ServiceRevenueLoan;
@property (nonatomic, assign) double ServiceRevenueThird;


@property (nonatomic, assign) double CommodityRevenueAll;
@property (nonatomic, assign) double CommodityRevenueCash;
@property (nonatomic, assign) double CommodityRevenueBank;
@property (nonatomic, assign) double CommodityRevenueWeChat;
@property (nonatomic, assign) double CommodityRevenueAlipay;
@property (nonatomic, assign) double CommodityRevenueECard;
@property (nonatomic, assign) double CommodityRevenueOther;

@property (nonatomic, assign) double CommodityRevenuePoint;
@property (nonatomic, assign) double CommodityRevenueCoupon;

@property (nonatomic, assign) double CommodityRevenueLoan;
@property (nonatomic, assign) double CommodityRevenueThird;


@property (nonatomic, assign) double SalesAllIncome;
@property (nonatomic, assign) double SalesCashIncome;
@property (nonatomic, assign) double SalesBankIncome;
@property (nonatomic, assign) double SalesWeChatIncome;
@property (nonatomic, assign) double SalesAlipayIncome;

@property (nonatomic, assign) double SalesRevenueLoan;
@property (nonatomic, assign) double SalesRevenueThird;


@property (nonatomic, assign) double ECardBalance;
@property (nonatomic, assign) double ECardSales;
@property (nonatomic, assign) double ECardConsume;

@property (nonatomic, assign) double ServiceAchievementAll;
@property (nonatomic, assign) double ServiceAchievementDesigned;
@property (nonatomic, assign) double ServiceAchievementNotDesigned;

@property (nonatomic, assign) NSInteger TreatmentTimesAll;
@property (nonatomic, assign) NSInteger TreatmentTimesDesigned;
@property (nonatomic, assign) NSInteger TreatmentTimesNotDesigned;

@property (nonatomic, assign) NSInteger ServiceCustomerCountAll;
@property (nonatomic, assign) NSInteger ServiceCustomerCountFemale;
@property (nonatomic, assign) NSInteger ServiceCustomerCountMale;

@property (nonatomic, assign) NSInteger NewAddCustomer;
@property (nonatomic, assign) NSInteger NewAddEffectCustomer;
@property (nonatomic, assign) NSInteger OldEffectCustomer;


@property (nonatomic, assign) double ServiceRevenue;
@property (nonatomic, assign) NSInteger ServiceTimes;


@property (nonatomic, assign) double CommodityRevenue;
@property (nonatomic, assign) NSInteger CommodityTimes;




@property (nonatomic, assign) double ECardAll;
@property (nonatomic, assign) double ECardCash;
@property (nonatomic, assign) double ECardBankCard;
@property (nonatomic, assign) double TreatmentTimes;
@property (nonatomic, assign) double ServiceCustomerCountUnknow;

//储值卡
@property (nonatomic, assign) double EcardSalesAllIncome;
@property (nonatomic, assign) double EcardSalesCashIncome;
@property (nonatomic, assign) double EcardSalesBankIncome;
@property (nonatomic, assign) double EcardWeChatIncome;
@property (nonatomic, assign) double EcardAlipayIncome;


- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
