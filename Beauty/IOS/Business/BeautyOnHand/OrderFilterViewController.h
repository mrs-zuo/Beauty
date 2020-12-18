//
//  OrderFilterViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-12-23.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderFilterDoc.h"
#import "SelectCustomersViewController.h"

@protocol  OrderFilterViewControllerDelegate<NSObject>

@required
- (void)dismissViewControllerWithDoc:(OrderFilterDoc *)orderFilter;
- (void)donotRefresh;
@optional
- (UITableViewCell *)numberOfRow:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath andData:(id)data;
@end

@interface OrderFilterViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate ,SelectCustomersViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) id<OrderFilterViewControllerDelegate> delegate;
@property (strong, nonatomic) OrderFilterDoc *orderFilterDoc;
@end
