//
//  LoginDoc.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-3-10.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, GPCompanyScale) {
    GPCompanyScaleSmall = 0,
    GPCompanyScaleBig = 1,
};

@interface LoginDoc : NSObject <NSCoding>

//顾客相关
@property (assign, nonatomic) NSInteger login_CustomerID;       //顾客ID
@property (copy  , nonatomic) NSString *login_CustomerName;     //顾客名称
@property (copy  , nonatomic) NSString *login_LevelName;        //顾客等级名称
@property (assign, nonatomic) double    login_Discount;         //顾客折扣率
@property (copy  , nonatomic) NSString *login_HeadImageURL;          //顾客头像
@property (assign, nonatomic) NSInteger login_LoginTime;        //？

//公司相关
@property (assign, nonatomic) GPCompanyScale login_CompanyScale;//公司规模：0小 1大（小店没有咨询记录）
@property (copy  , nonatomic) NSString *login_CompanyCode;      //公司code
@property (assign, nonatomic) NSInteger login_CompanyID;        //公司ID
@property (copy  , nonatomic) NSString *login_CompanyName;      //公司名称
@property (copy  , nonatomic) NSString *login_CompanyAbbreviation; //公司简称
@property (assign, nonatomic) NSInteger login_BranchCount;      //分店数量
@property (assign, nonatomic) NSInteger login_BranchID;         //分店ID
@property (copy, nonatomic) NSString *login_BranchName;
@property (copy, nonatomic) NSString *login_CurrencySymbol; //货币符号
@property (copy, nonatomic) NSString *login_Advanced; //货币符号
//顾客相关数量
@property (assign, nonatomic) NSInteger login_PromotionCount;   //促销数量
@property (assign, nonatomic) NSInteger login_RemindCount;      //提醒数量
@property (assign, nonatomic) NSInteger login_NewMessageCount;  //未读消息数量
@property (assign, nonatomic) NSInteger login_UnpaidOrderCount;     //待付款数量
@property (assign, nonatomic) NSInteger login_UnconfirmedOrderCount; //待确认数量

@end
