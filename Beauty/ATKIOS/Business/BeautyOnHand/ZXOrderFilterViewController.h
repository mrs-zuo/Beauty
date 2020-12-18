//
//  ZXOrderFilterViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/12/30.
//  Copyright © 2015年 ace-009. All rights reserved.
//

#import "BaseViewController.h"
#import "OrderFilterDoc.h"
#import "SelectCustomersViewController.h"
@class ZXOrderFilterViewController;
@protocol ZXOrderFilterViewControllerDelegate <NSObject>

@required
- (void)dismissViewControllerWithDoc:(OrderFilterDoc *)orderFilter;
- (void)donotRefresh;
@optional
- (UITableViewCell *)numberOfRow:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath andData:(id)data;
@end

@interface ZXOrderFilterViewController : BaseViewController <SelectCustomersViewControllerDelegate>

@property (assign, nonatomic) id<ZXOrderFilterViewControllerDelegate> delegate;
@property (strong, nonatomic) OrderFilterDoc *orderFilterDoc;

@end


