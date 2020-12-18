//
//  ProfessionInfoViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-11-26.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfessionInfoViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
