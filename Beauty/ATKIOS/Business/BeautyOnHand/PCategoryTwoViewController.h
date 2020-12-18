//
//  ProductDetailListViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-4.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CategoryDoc;
@interface PCategoryTwoViewController : BaseViewController<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) CategoryDoc *parentCategory;
@property (strong, nonatomic) UITableView *tableView;
@end