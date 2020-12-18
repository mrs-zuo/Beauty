//
//  ReportDetailDoc.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-20.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReportDetailDoc : NSObject
@property (copy, nonatomic) NSString *objectName;

@property (assign, nonatomic) CGFloat flag;  // flag=0 amount | flag=0 case
@property (assign, nonatomic) long double amount;  // 销售额
@property (assign, nonatomic) NSInteger cases;     // 件数

@property (assign, nonatomic) long double amountRatio;
@property (assign, nonatomic) long double casesRatio;
@property (assign, nonatomic) long double viewRatio;
@end
