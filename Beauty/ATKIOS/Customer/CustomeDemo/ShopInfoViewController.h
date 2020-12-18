//
//  ShopInfoViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/2.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"
@class ShopInfoModel;

@interface ShopInfoViewController : ZXBaseViewController

@property (nonatomic, strong) ShopInfoModel *currentShop;
@property (nonatomic ,assign) NSInteger BranchID ;
@end
