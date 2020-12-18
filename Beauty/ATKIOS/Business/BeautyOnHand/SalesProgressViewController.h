//
//  SalesProcessViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-31.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SalesProgressCell.h"

@interface SalesProgressViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource, SalesProgressCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) NSInteger opportunityID;
@property (assign, nonatomic) NSInteger productType;

//GPB-1402 追加 上一层传入美丽顾问及ID
@property (nonatomic, strong) NSString *responsibleName;
@property (nonatomic, assign) NSInteger responsibleID;
@property (nonatomic, assign) BOOL opportunityInvalid;
@end
