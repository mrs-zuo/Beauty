//
//  OrderListViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-1-7.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderFilterViewController.h"

@interface OrderListViewController : BaseViewController<UIActionSheetDelegate,UITextFieldDelegate,OrderFilterViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) NSInteger requestStatus;              //-1：全部、0：进行中、1：已完成、2：已取消、3：待确认
@property (assign, nonatomic) NSInteger requestType;                //-1：全部、0：服务、1：商品
@property (assign, nonatomic) NSInteger requestIsPaid;              //-1：全部、0：未支付、1、部分付、2：已支付
@property (assign, nonatomic) NSInteger orderID_Selected;          //进入OrderDetailViewController所需要的参数
@property (assign, nonatomic) NSInteger productType_Selected;
@property (assign, nonatomic) BOOL clearStack;                      //when jump (not pop) to order list from order detail page, use it
@property (strong, nonatomic) NSString *navTitle;

@property (assign, nonatomic) NSInteger lastView;              //0：Navigation、1：OrderRootView , 5 返回到 order root 
@property (nonatomic, assign) NSInteger comeFromOrderFilter;

@property (nonatomic ,assign) NSInteger viewTag; //1 tab
@end
