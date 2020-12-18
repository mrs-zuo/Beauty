//
//  RemindViewController.h
//  CustomeDemo
//
//  Created by MAC_Lion on 13-8-8.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"

@interface RemindViewController : ZXBaseViewController <UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@end
