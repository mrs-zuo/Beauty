//
//  RechargeAndPayViewController.h
//  CustomeDemo
//
//  Created by MAC_Lion on 13-8-20.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"

@interface RechargeAndPayViewController : ZXBaseViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
