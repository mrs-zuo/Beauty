//
//  OrderListViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-1-7.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"

@interface OrderListViewController : ZXBaseViewController<UIPickerViewDataSource, UIPickerViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *orderArray;
@property (nonatomic,retain) UIActionSheet* actionSheet;

@property (assign, nonatomic) NSInteger requestStatus;              //-1：全部、0：进行中、1：已完成、2：已取消。
@property (assign, nonatomic) NSInteger requestType;                //-1：全部、0：服务、1：商品
@property (assign, nonatomic) NSInteger requestIsPaid;              //-1：全部、1：未支付、2：部分付、 3：已支付

@end
