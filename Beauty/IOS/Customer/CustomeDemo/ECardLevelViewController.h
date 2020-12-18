//
//  ECardLevelViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-11-28.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECardLevel.h"
#import "ZXBaseViewController.h"

@interface ECardLevelViewController : ZXBaseViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *eCardLevel;
@end

