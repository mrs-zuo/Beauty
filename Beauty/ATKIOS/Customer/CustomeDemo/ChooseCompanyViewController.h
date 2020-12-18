//
//  ChooseCompanyViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-3-10.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseCompanyViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *loginArray;
@property (copy, nonatomic)NSString *nameBase64;
@property (copy, nonatomic)NSString *pwdBase64;
@property (nonatomic, assign) BOOL   loginType;
@property (nonatomic,getter= SettingEnter) BOOL isSettingEnter;
@end
