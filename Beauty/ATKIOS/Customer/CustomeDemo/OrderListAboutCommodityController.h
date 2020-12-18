//
//  OrderListAboutCommodityController.h
//  CustomeDemo
//
//  Created by TRY-MAC01 on 13-11-19.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderListCell.h"

@interface OrderListAboutCommodityController : UIViewController<OrderListCellDelete, UIActionSheetDelegate
>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *orderArray;

@end
