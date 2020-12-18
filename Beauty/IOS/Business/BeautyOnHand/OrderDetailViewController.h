//
//  OrderDetailViewController.h
//  Customers
//
//  Created by MAC_Lion on 13-5-20.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectCustomersViewController.h"
#import "OrderTreatmentCell.h"
#import "WorkSheetViewController.h"
#import "ContentEditCell.h"
#import "ProductAndPriceView.h"

@class OrderDoc;
@interface OrderDetailViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, SelectCustomersViewControllerDelegate, OrderTreatmentCellDelegate, WorkSheetViewControllerDelegate,ContentEditCellDelegate,UIActionSheetDelegate, UIGestureRecognizerDelegate, ProductAndPriceViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) NSInteger lastView;   //lastView = 1 ,clear the controller push stack  =3 返回服务页
@property (assign, nonatomic) NSInteger orderID;
@property (assign, nonatomic) NSInteger productType;//服务/商品
@property (nonatomic, assign) NSInteger isBranch;
@property (nonatomic ,assign) NSInteger objectID;
@end
