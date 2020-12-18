//
//  ProductAndPriceDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-10-9.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceDoc.h"
#import "CommodityDoc.h"

@interface ProductAndPriceDoc : NSObject<NSCopying>

@property (strong, nonatomic) NSArray *serviceArray;    // 保存service对象
@property (strong, nonatomic) NSArray *commodityArray;  // 保存commodity对象
@property (assign, nonatomic) NSInteger flag;                 // flag=0 显示的service  |  flag=1 显示的commodity

@property (assign, nonatomic) CGFloat totalMoney;
@property (assign, nonatomic) CGFloat discountMoney;
@property (assign, nonatomic) BOOL  isShowDiscountMoney;

@property (assign, readonly, nonatomic) CGFloat table_Height;

- (CGFloat)retDiscountMoney;
- (CGFloat)retTotalMoeny;
@end
