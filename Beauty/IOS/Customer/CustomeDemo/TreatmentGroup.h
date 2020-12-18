//
//  TreatmentGroup.h
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/8/25.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TreatmentGroup : NSObject
@property (nonatomic, copy) NSString *ServicePicName;
@property (nonatomic, copy) NSString *StartTime;
@property (nonatomic, assign) long long GroupNo;
@property (nonatomic, assign) NSInteger ServicePicID;
@property (nonatomic, assign) NSInteger Status;
@property (nonatomic, assign) NSInteger Quantity;

@property (nonatomic, assign) BOOL IsDesignated;
@property (nonatomic, copy) NSArray *TreatmentList;
@property (nonatomic, assign) NSInteger treatCount;


- (instancetype)initWithDic:(NSDictionary *)dic;

@end
