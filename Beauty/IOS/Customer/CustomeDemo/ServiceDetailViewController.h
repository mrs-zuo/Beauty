//
//  ServiceDetailViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-6-20.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"

@interface ServiceDetailViewController : ZXBaseViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) long long commodityCode;
@property (assign, nonatomic) CGFloat commodityDiscount;
@end
