//
//  ServiceListViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-6-20.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"


@protocol SelectServiceControllerDelegate <NSObject>
@optional
- (void)dismissServiceViewControllerWithSelectedService:(NSString *)serviceName userID:(NSDictionary *)serviceDic;
@end


@class CategoryDoc;

@interface ServiceListViewController : ZXBaseViewController<UITableViewDataSource,UITableViewDelegate , UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) CategoryDoc *parentCategory;
@property (nonatomic ,assign)NSInteger returnViewTag; // 1预约
@property (assign, nonatomic) id<SelectServiceControllerDelegate> delegate;
@end
