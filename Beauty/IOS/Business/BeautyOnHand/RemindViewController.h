//
//  RemindViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by MAC_Lion on 13-8-9.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface RemindViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (strong) NSMutableArray *remindList;
@end
