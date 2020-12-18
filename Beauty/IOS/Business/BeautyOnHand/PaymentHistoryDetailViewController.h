//
//  PaymentHistoryDetailViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-11-17.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "BaseViewController.h"
#import "PaymentHistoryDoc.h"

@interface PaymentHistoryDetailViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) PaymentHistoryDoc *paymentHistoryDoc;
@property (assign, nonatomic) NSInteger page;
@end
