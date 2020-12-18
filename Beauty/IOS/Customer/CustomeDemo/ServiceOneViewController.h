//
//  ServiceOneViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-6-19.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"

@class CategoryDoc;

@interface ServiceOneViewController : ZXBaseViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (copy, nonatomic) NSString *serviceName;
@property (nonatomic) CategoryDoc *parentCategory;

@end
