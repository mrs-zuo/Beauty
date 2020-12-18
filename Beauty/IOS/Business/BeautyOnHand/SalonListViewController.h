//
//  SalonListViewController.h
//  CustomeDemo
//
//  Created by macmini on 13-9-13.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SalonListViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *myListView;
@property (strong) NSMutableArray *salonList;
@end
