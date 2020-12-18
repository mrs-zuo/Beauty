//
//  OriginViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/6/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OriginViewController : UIViewController//<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIButton *firstButton;
@property (nonatomic, weak) UIButton *secondButton;

- (void)hideSecondButton;
- (void)updateData;
@end
