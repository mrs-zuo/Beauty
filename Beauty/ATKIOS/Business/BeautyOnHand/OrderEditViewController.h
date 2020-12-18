//
//  OrderEditViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-11.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderAddCell.h"

#import "WorkSheetViewController.h"
#import "SelectCustomersViewController.h"


@protocol OrderDateCellDelete <NSObject>
- (void)chickOperateRowButton:(UITableViewCell *)cell;
@end

@class OrderDoc;
@class ProductAndPriceDoc;
@interface OrderEditViewController : BaseViewController<UIGestureRecognizerDelegate, UITextFieldDelegate,  OrderAddCellDelegate, OrderDateCellDelete, WorkSheetViewControllerDelegate, SelectCustomersViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) OrderDoc *theOrderDoc;

- (void)setTheOrderDoc:(OrderDoc *)orderDoc;
- (void)dismissKeyBoard;
@end
