//
//  RechargeDetailViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-11-11.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"

@interface RechargeDetailViewController : ZXBaseViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *rechargeTitle;
@property (strong, nonatomic) NSString *rechargeMode;
@property (assign, nonatomic) NSInteger rechargeId;
@property (copy, nonatomic) NSString *rechargeTime;
@property (copy, nonatomic) NSString *rechargeOperator;
@property (copy, nonatomic) NSString *rechargeMoney;
@property (copy, nonatomic) NSString *moneyLeft;
@property (assign, nonatomic) NSInteger mode;
@end
