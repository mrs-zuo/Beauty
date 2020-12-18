//
//  RechargeViewControllerNewViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by 楊婉菱 on 2015/8/13.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"

@interface RechargeViewControllerNewViewController : ZXBaseViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
