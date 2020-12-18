//
//  OpportunityDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-31.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProductAndPriceDoc;
@interface OpportunityDoc : NSObject
@property (assign, nonatomic) NSInteger customerId;
@property (copy, nonatomic)   NSString *customerName;
@property (assign, nonatomic) float discount;

// --Oppuratunity Info
@property (assign, nonatomic) NSInteger opp_ID;
@property (copy, nonatomic) NSString   *opp_ProgressRate; // 达成率
@property (copy, nonatomic) NSString   *opp_UpdateTime;

@property (assign, nonatomic) BOOL   opp_Invalid; // 是否有效
@property (assign, nonatomic) NSInteger  opp_ProgressID;
@property (assign, nonatomic) NSInteger opp_Progress;      // 从1为起点
@property (copy, nonatomic) NSString   *opp_ProgressStr;
@property (copy, nonatomic) NSString   *opp_StepContent;   // 以“|“隔开

@property (copy, nonatomic) NSString *opp_Describe;

@property (assign, nonatomic) NSInteger opp_BranchID;    //订单创建者的BranchID
// --Product Info
// 保存着serviceDoc或者commodityDoc对象的集合、totalMoeny、discountMoney、flag所有信息 （包含了Product中的所有信息）
@property (strong, nonatomic) ProductAndPriceDoc *productAndPriceDoc;

@property (copy, nonatomic) NSString *strProductDetail;


@property (assign, nonatomic) CGFloat height_Prg_Describle;


@end
