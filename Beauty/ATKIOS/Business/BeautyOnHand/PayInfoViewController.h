//
//  PayInfoViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-10-8.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PayEditCell.h"
#import "ContentEditCell.h"

@interface PayInfoViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, PayEditCellDelete, UITextFieldDelegate, UIGestureRecognizerDelegate, ContentEditCellDelegate>

@property (assign, nonatomic) NSInteger orderNumbers;
@property (strong, nonatomic) NSMutableArray *paymentOrderArray;
@property (assign, nonatomic) NSInteger makeStateComplete;// 是否将订单变为已完成: 0否  1是
@property (assign, nonatomic) NSInteger customerId;
@property (assign, nonatomic) NSInteger pageToGo; //--2 跳转到左侧订单列表  1 开单页立即支付 跳转到当前顾客的全部订单列表 3 一个订单时候调到详情
@property (assign, nonatomic) NSInteger orderId; //pageToGo = 3 时使用
@property (assign, nonatomic) NSInteger productType; //pageToGo = 3 时使用
@property (nonatomic, assign) NSInteger comeFrom; // 1：来自订单详情,支付完成后返回

///单订单 业绩参与人数组
@property (nonatomic ,strong) NSMutableArray * singleOrderSlaveArray;
@end
