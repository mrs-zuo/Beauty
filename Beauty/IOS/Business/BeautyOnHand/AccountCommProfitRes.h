//
//  AccountCommProfitRes.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/5/5.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountCommProfitRes : NSObject

@property (nonatomic,copy) NSString *ObjectName;
@property (nonatomic,strong) NSNumber *SalesProfit;
@property (nonatomic,strong) NSNumber *SalesComm;
@property (nonatomic,strong) NSNumber *OptProfit;
@property (nonatomic,strong) NSNumber *OptComm;
@property (nonatomic,strong) NSNumber *ECardProfit;
@property (nonatomic,strong) NSNumber *ECardComm;

@end
