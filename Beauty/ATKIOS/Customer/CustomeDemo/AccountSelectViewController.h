//
//  AccountSelectViewController.h
//  CustomeDemo
//
//  Created by macmini on 13-7-18.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AccountSelectListCell.h"
#import "ZXBaseViewController.h"

@interface AccountSelectViewController : ZXBaseViewController <UITableViewDataSource,UITableViewDelegate,AccountListCellDelete>
@property (weak,nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *accountListArray;
@property (strong, nonatomic) NSMutableArray *selectedArray; 

@end
