//
//  ServiceObject.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-5-28.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "ProductObject.h"

@interface SubServiceObject : NSObject
@property (assign, nonatomic) long long service_subServiceCode;
@property (copy, nonatomic) NSString *service_subServiceName;
@property (assign, nonatomic) NSInteger  service_subServiceTime;
@end

@interface ServiceObject : ProductObject

@property (assign, nonatomic) NSInteger service_spendTime;          //服务所需时间
@property (assign, nonatomic) NSInteger service_courseFrequency;    //服务课程次数
@property (assign, nonatomic) BOOL service_hasSubService;
@property (strong, nonatomic) NSMutableArray *service_subService;   //自服务数组
@property (assign, nonatomic) BOOL service_haveExpiration;    //有无服务有效期
@end
