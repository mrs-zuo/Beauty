//
//  SelectServicePersonnal_ViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/9/14.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"
@protocol SelectCustomersViewControllerDelegate;

@interface SelectServicePersonnal_ViewController : ZXBaseViewController<UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate>

@property (assign, nonatomic) id<SelectCustomersViewControllerDelegate> delegate;
@property (assign ,nonatomic) NSInteger BracnID;
@end


@protocol SelectCustomersViewControllerDelegate <NSObject>
@optional
- (void)dismissViewControllerWithSelectedSales:(NSArray *)userArray;


@end