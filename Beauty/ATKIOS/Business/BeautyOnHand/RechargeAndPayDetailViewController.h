//
//  RechargeAndPayDetailViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-8-1.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "BaseViewController.h"

@interface RechargeAndPayDetailViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate,UITextViewDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) NSInteger paymentID;
@end
