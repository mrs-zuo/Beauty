//
//  PayConfirmViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/11/3.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "BaseViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PayEditCell.h"
#import "ContentEditCell.h"

@interface PayConfirmViewController : BaseViewController<UIGestureRecognizerDelegate>

@property (assign, nonatomic) NSInteger orderNumbers;
@property (strong, nonatomic) NSMutableArray *paymentOrderArray;
@property (strong, nonatomic)  UITableView *myTableView;
@property (assign, nonatomic) NSInteger makeStateComplete;// 是否将订单变为已完成: 0否  1是
@property (assign, nonatomic) NSInteger customerId;
@property (assign, nonatomic) NSInteger pageToGo; //2 跳转到左侧订单列表  1 开单页立即支付 跳转到当前顾客的全部订单列表 3 一个订单时候调到详情
@property (nonatomic, assign) NSInteger comeFrom; // 1：来自订单详情,支付完成后返回@end
@property (nonatomic ,assign) NSInteger payStatus; //支付状态 1未支付 2 部分付
@property (assign, nonatomic) NSInteger productType;

@end
