//
//  RecordListViewController.h
//  CustomeDemo
//
//  Created by macmini on 13-7-30.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordListCell.h"
#import "ZXBaseViewController.h"

@interface RecordListViewController : ZXBaseViewController<UITableViewDataSource,UITableViewDelegate,RecordListCellDelegate>
@property (weak,nonatomic) IBOutlet UITableView *recordTableView;
@property (strong,nonatomic) NSMutableArray *recordArray;

@end
