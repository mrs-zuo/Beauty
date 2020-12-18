//
//  SetViewController.h
//  CustomeDemo
//
//  Created by macmini on 13-9-9.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "ZXBaseViewController.h"

@interface SetViewController : ZXBaseViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
