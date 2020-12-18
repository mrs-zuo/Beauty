//
//  ProductListViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-4.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"

@class CategoryDoc;

@interface CategoryOneViewController : ZXBaseViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (copy, nonatomic) NSString *categoryName;
@property (nonatomic) CategoryDoc *parentCategory;

@end
