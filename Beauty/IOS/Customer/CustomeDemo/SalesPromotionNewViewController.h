//
//  SalesPromotionNewViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/9/24.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"

@interface SalesPromotionNewViewController : ZXBaseViewController
@property (strong,nonatomic) NSMutableArray *salesPromotionList;
@property (assign, nonatomic) NSInteger promotionSource; //1 登录 0 查看促销
@end
