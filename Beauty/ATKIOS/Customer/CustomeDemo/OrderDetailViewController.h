//
//  OrderDetailViewController.h
//  Customers
//
//  Created by MAC_Lion on 13-5-20.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrderDoc;

@interface OrderDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) OrderDoc *orderDoc;
@property (assign, nonatomic) NSInteger type;//0:服务  1:商品

@end
