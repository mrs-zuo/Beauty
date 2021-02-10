//
//  StatustucsProductSurplus.h
//  GlamourPromise.Beauty.Business
//
//  Created by scs_zhouyt on 2021/02/07.
//  Copyright © 2021 ace-009. All rights reserved.
//

#ifndef StatustucsProductSurplus_h
#define StatustucsProductSurplus_h


#endif /* StatustucsProductSurplus_h */

#import <Foundation/Foundation.h>

@interface StatustucsProductSurplus : NSObject
@property (nonatomic) NSString *productNo; //序号
@property (nonatomic) NSString *orderNumber; //订单编号
@property (nonatomic) NSString *productName; //项目名称
@property (nonatomic) NSString *productSurPlusNumDisplay; //剩余
@property (nonatomic) NSNumber *productSurPlusNum;
@property (nonatomic) NSString *productSurplusPriceDisplay; // 剩余金额
@property (nonatomic) NSNumber *productSurplusPrice;
@property (nonatomic) NSInteger *productType; // 项目类型（0:服务|1:商品）
@property (nonatomic) NSNumber *productServiceType; // 服务方式（1:时间卡|2:服务次数）

@end

