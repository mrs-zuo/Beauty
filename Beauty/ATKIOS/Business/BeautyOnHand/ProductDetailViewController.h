//
//  ProductDetailViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-8.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductDetailViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) UITableView *tableView;

@property (assign, nonatomic) long long commodityCode;
@property (assign, nonatomic) NSInteger favouriteID;
@property (assign, nonatomic) BOOL isShowFavourites;
@end