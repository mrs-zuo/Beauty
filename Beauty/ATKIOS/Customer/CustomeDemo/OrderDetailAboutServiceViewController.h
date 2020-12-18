//
//  OrderDetailAboutServiceViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-1-13.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"

@class OrderDoc;
@interface OrderDetailAboutServiceViewController : ZXBaseViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) OrderDoc *orderDoc;
@end
