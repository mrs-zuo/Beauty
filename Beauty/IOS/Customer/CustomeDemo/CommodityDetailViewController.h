//
//  ProductDetailViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-25.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"

@interface CommodityDetailViewController : ZXBaseViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) long long commodityCode;
@property (assign, nonatomic) CGFloat commodityDiscount;
@end
