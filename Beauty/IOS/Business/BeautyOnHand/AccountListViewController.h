//
//  AccountListViewController.h
//  CustomeDemo
//
//  Created by MAC_Lion on 13-7-3.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AccountDoc;

@interface AccountListViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *myListView;
@property (weak,nonatomic) IBOutlet UILabel *companyLabel;
@property (strong, nonatomic) NSMutableArray *accounts;

@property (nonatomic) NSInteger branchId;
@property (nonatomic) NSInteger requestType;    //0全部  1总店  2分店  3用户ID
@property (copy, nonatomic) NSString *businessName;
@end
