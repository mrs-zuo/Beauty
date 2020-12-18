//
//  MarkingReport.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/21.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MarkingReport : NSObject
@property (nonatomic, assign) NSInteger CustomerCount;
@property (nonatomic, assign) NSInteger TGExecutingCount;
@property (nonatomic, assign) NSInteger TGFinishedCount;
@property (nonatomic, assign) NSInteger TGUnConfirmed;
@property (nonatomic, assign) NSInteger ServiceOrder;
@property (nonatomic, assign) NSInteger CommodityOrder;
@property (nonatomic, assign) NSInteger ServiceCancelCount;
@property (nonatomic, assign) NSInteger CommodityCancelCount;

@property (nonatomic, assign) double SalesAmount;

- (instancetype)initWithDic:(NSDictionary *)dic;
@end
