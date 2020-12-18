//
//  EcardReport.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-3-25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AFHTTPRequestOperation;
@interface EcardReport : NSObject
@property (nonatomic, strong) NSString *CustomerName;
@property (nonatomic, assign) double BalanceAmount;
@property (nonatomic, assign) double RechargeAmount;
@property (nonatomic, assign) double PayAmount;

- (id)initWithDictionary:(NSDictionary *)dictionary;
+ (AFHTTPRequestOperation *)getReportWithPar:(NSString *)par completionBlock:(void(^)(NSArray *array, NSInteger code, NSString *msg))block;
@end
