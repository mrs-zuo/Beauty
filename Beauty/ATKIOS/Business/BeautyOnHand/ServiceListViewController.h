//
//  ServiceListViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-8.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSListTableViewCell.h"

@protocol SelectServiceControllerDelegate <NSObject>
@optional
- (void)dismissServiceViewControllerWithSelectedService:(NSString *)serviceName userID:(NSDictionary *)serviceDic;
@end

@class CategoryDoc;

@interface ServiceListViewController : BaseViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, PSListTableViewCellDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (assign, nonatomic) CategoryDoc *categoryDoc;
@property (nonatomic ,assign)NSInteger returnViewTag; // 1预约

@property (assign, nonatomic) id<SelectServiceControllerDelegate> delegate;
@end
