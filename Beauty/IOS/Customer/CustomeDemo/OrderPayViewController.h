//
//  OrderPayViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-1-10.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderListCell.h"
#import "ZXBaseViewController.h"

@interface OrderPayViewController : ZXBaseViewController<OrderListCellDelete, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic)NSMutableArray * payDetaiDelectedOrderArr;
@end
