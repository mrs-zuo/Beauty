//
//  OrderRefund_ViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/11/24.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderRefund_ViewController : BaseViewController
@property (strong, nonatomic) NSMutableArray *paymentHistoryArray;
@property (assign, nonatomic) NSInteger orderID;
@property (assign, nonatomic) NSInteger paymentId;
@property (assign, nonatomic) NSInteger customerId;
@property (assign, nonatomic) NSInteger productType;
@end
