//
//  PaymentHistoryDetailViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-11-7.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaymentHistoryDoc.h"
#import "ZXBaseViewController.h"
@interface PaymentHistoryDetailViewController : ZXBaseViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) PaymentHistoryDoc *paymentHistoryDoc;
@property (assign, nonatomic) NSInteger page;
@end
