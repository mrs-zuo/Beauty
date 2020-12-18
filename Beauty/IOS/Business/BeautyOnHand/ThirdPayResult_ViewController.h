//
//  ThirdPayResult_ViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/10/28.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayThirdForWeiXin_ViewController.h"

@interface ThirdPayResult_ViewController : BaseViewController
@property (nonatomic, strong) NSString * productName;
@property (nonatomic ,strong) NSString * NetTradeNo;
@property (nonatomic,assign)long double payPrice;
/**
 * 1 来自订单详情页完成支付直接返回订单详情
 * 2 返回到结账列表页
 * 3 返回账户详情页
 */
@property (nonatomic ,assign) NSInteger orderComeFrom;

@property (nonatomic,assign) PayType payType;

@end
