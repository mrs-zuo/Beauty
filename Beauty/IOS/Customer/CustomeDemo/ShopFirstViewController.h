//
//  ShopFirstViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/2.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "OriginViewController.h"

@class ShopInfoModel;
@interface ShopFirstViewController : OriginViewController
@property (nonatomic, strong) ShopInfoModel *shopInfo;
@property (nonatomic ,assign) NSInteger  viewFor ;//1 促销详情
@end
