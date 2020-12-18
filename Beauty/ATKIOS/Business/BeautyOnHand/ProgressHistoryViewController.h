//
//  ProgressHistoryViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-31.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressHistoryViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) NSInteger opportunityID;
@property (assign, nonatomic) NSInteger productType;
@end
