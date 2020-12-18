//
//  CustomerListViewController.h
//  Customers
//
//  Created by MAC_Lion on 13-5-20.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomerAddViewController.h"
#import "OrderDoc.h"

@protocol SelectCustomerDelegate <NSObject>
@optional
- (void)dismissViewControllerWithSelectedCustomerName:(NSString *)customerName customerId:(NSInteger)customerId;
@end

@interface CustomerListViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate,SelectCustomerDelegate>

@property (assign, nonatomic) id<SelectCustomerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *myListView;
@property (strong, nonatomic)  UISearchBar *mySearchBar;
@property (nonatomic ,assign)NSInteger returnViewTag; // 1，来自结账列表页 2,来自开单页选择顾客
@property (nonatomic,strong)NSArray *OrderArr;
@property (nonatomic, strong) NSString *searchString;
@end

