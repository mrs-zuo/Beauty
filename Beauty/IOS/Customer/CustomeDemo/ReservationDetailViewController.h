//
//  ReservationDetailViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by 楊婉菱 on 2015/9/6.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"

@interface ReservationDetailViewController : ZXBaseViewController<UITableViewDataSource,UITableViewDelegate>


@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic)long long taskID;
@end
