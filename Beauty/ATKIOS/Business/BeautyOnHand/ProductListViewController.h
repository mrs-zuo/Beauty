//
//  ProductListViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-8.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSListTableViewCell.h"

@class CategoryDoc;
@interface ProductListViewController : BaseViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, PSListTableViewCellDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (assign, nonatomic) CategoryDoc *categoryDoc;
@end
