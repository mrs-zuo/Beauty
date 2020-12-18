//
//  RecordListViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-6-28.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordListCell.h"
@class CustomerDoc;
@interface RecordListViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, RecordListCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *recordTableView;
@property (strong, nonatomic) NSMutableArray *recordArray;
@end
