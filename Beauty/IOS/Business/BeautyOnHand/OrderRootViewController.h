//
//  OrderViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-1-10.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderRootViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) BOOL clearStack;//when jump (not pop) to order list from order detail page, use it
@property (assign, nonatomic) NSInteger menue ; // 1从左侧菜单直接进入
@end
