//
//  ChooseCompanyViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-10-8.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseCompanyViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *loginArray;
@property (assign, nonatomic) BOOL switchCompany;
@property (nonatomic, assign) BOOL loginType;
@end
