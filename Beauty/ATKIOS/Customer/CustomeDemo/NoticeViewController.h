//
//  NoticeViewController.h
//  CustomeDemo
//
//  Created by MAC_Lion on 13-8-6.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"

@interface NoticeViewController : ZXBaseViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *myListView;
@end
