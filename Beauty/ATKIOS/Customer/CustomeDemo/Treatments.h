//
//  Treatments.h
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/8/25.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Treatments : NSObject
@property (nonatomic, assign) NSInteger SubServiceID;
@property (nonatomic, copy) NSString *SubServiceName;
@property (nonatomic, assign) NSInteger ExecutorID;
@property (nonatomic, copy) NSString *ExecutorName;
@property (nonatomic, assign) NSInteger TreatmentID;
@property (nonatomic, copy) NSString *StartTime;
@property (nonatomic, assign) NSInteger Status;

- (instancetype)initWithDic:(NSDictionary *)dic;
@end
