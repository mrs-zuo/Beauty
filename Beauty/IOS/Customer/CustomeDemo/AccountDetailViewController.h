//
//  AccountDetailViewController.h
//  CustomeDemo
//
//  Created by macmini on 13-7-5.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"

@class AccountDoc;

@interface AccountDetailViewController : ZXBaseViewController<UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate>
@property (weak,nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) NSInteger accountId;
@property (weak,nonatomic) IBOutlet UIImageView *imageView;
@property (weak,nonatomic) IBOutlet UILabel *nameLabel;

-(IBAction)SendMessage:(id)sender;
@end
