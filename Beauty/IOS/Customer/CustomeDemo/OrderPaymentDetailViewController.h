//
//  OrderPaymentDetailViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-11-19.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"

@interface OrderPaymentDetailViewController : ZXBaseViewController<UITableViewDataSource , UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *paymentHistoryArray;
@property (assign, nonatomic) NSInteger orderID;
@property (assign, nonatomic) CGFloat totalMoney;
@end
