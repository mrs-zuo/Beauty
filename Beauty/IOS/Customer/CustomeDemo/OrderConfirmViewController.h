//
//  OrderConfirmViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-5-6.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderConfirmCell.h"
#import "ZXBaseViewController.h"

@interface OrderConfirmViewController : ZXBaseViewController<OrderConfirmCellDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
