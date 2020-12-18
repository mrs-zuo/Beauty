//
//  BusinessViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-3-27.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusinessViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
