//
//  ReportListDoc.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-20.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReportListDoc : NSObject

@property (assign, nonatomic) NSInteger ObjectID;
@property (copy, nonatomic) NSString *ObjectName;
@property (assign, nonatomic) double SalesAmount;
@property (assign, nonatomic) double RechargeAmount;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
