//
//  TirdPatmentRecords_ViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/10/28.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayThirdForWeiXin_ViewController.h"

@interface ThirdPatmentRecords_ViewController : BaseViewController

@property (nonatomic ,assign) NSInteger orderId;
@property (nonatomic,assign) NSInteger NetTradeNo;
@property (nonatomic ,assign) NSInteger viewFor; //-- 1 订单详情  2 账户列表 3 账户详情
@property (nonatomic ,assign) NSString * userCardNO;
@property (nonatomic ,assign) NSInteger  customerID;


@end
