//
//  FavouritesListViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-8-11.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "BaseViewController.h"
#import "PSListTableViewCell.h"
#import "CommodityOrServiceDoc.h"


@interface FavouritesListViewController : BaseViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, PSListTableViewCellDelegate>

@property (strong, nonatomic) UITableView *tableView;


@end
