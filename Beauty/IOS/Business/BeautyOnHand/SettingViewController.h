//
//  SettingViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-29.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
