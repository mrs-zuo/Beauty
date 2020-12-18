//
//  PaymentHistoryViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-11-17.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "BaseViewController.h"

@interface PaymentHistoryViewController : BaseViewController <UITableViewDataSource ,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
