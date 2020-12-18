//
//  OrderEditViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-11.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"

@class ProductAndPriceDoc;
@interface OrderEditViewController : ZXBaseViewController<UIGestureRecognizerDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) ProductAndPriceDoc *productAndPriceDoc; // 订单编辑、确认(必传值)
@property (retain, nonatomic) NSString *titleName;
@end
