//
//  OrderPaymentDetailViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-11-19.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderPaymentDetailViewController : UIViewController<UITableViewDataSource , UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *paymentHistoryArray;
@property (assign, nonatomic) NSInteger orderID;
@property (assign, nonatomic) NSInteger paymentId;

@end
