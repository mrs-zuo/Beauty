//
//  CommodityOrServiceDoc.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-8-12.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

//收藏页列表项数据格式
@interface CommodityOrServiceDoc : NSObject
@property (assign, nonatomic)NSInteger productType;//0 商品，1服务
@property (strong, nonatomic) id commodityOrService;

@end
