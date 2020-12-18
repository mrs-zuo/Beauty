//
//  OrderPayListViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-14.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckOutListCell.h"

@interface OrderPayListViewController : BaseViewController <OrderListCellDelete,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign ,nonatomic) NSInteger customerId;
@property (copy ,nonatomic) NSString *customerName;
@property (assign ,nonatomic) NSInteger pageFrom; //2 from  check out page
@property (nonatomic, assign) NSInteger branchID;

@end
