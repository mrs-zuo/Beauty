//
//  OrderViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-1-10.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"
@interface OrderViewController : ZXBaseViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
