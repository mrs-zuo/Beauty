//
//  ChartModel.h
//  GlamourPromise.Beauty.Business
//
//  Created by Bizapper VM MacOS  on 15/11/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChartModel : NSObject
///服务次数或者商品个数
@property (nonatomic,strong) NSNumber *ObjectCount;
///抽取名
@property (nonatomic,copy) NSString *ObjectName;
///消费金额
@property (nonatomic,strong) NSNumber *ConsumeAmout;
///充值金额
@property (nonatomic,strong) NSNumber *RechargeAmout;
///TotalAmout
@property (nonatomic,strong) NSNumber *TotalAmout;
///ObjectId
@property (nonatomic,strong) NSNumber *ObjectId;

@end
