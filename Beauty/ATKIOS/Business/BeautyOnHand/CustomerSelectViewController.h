//
//  CustomerSelectViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-10.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SelectCustomersViewController.h"

@protocol CustomerSelectViewControllerDelegate <NSObject>
- (void)returnSelectedArrayWhenSelectedAgain:(NSMutableArray *)selectArray;  // 当再次选择聊天用户的时候 返回selectArray;
@end

@interface CustomerSelectViewController : BaseViewController<SelectCustomersViewControllerDelegate>
@property (assign, nonatomic) id<CustomerSelectViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
