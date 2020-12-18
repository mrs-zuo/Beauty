//
//  GetDetailPayNewViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by 楊婉菱 on 2015/8/16.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"

@interface GetDetailPayNewViewController : ZXBaseViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic)NSMutableArray *cardInfo;
@property (assign,nonatomic)NSInteger cardType;
@end
