//
//  CourseTableViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/6/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "AwaitFinishTableViewController.h"
#import "GPBHTTPClient.h"
#import "AppDelegate.h"
#import "CustomerOrderCell.h"
#import "AwaitFinishOrder.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "CusMainViewController.h"
#import "OrderDetailViewController.h"
#import "ColorImage.h"
#import "PermissionDoc.h"   
#import "MJRefresh.h"   
#import "ComputerSginViewController.h"

@interface AwaitFinishTableViewController ()<UITableViewDelegate, UITableViewDataSource, AwaitFinishOrderDelegate>
@property (nonatomic, weak) AFHTTPRequestOperation *requestOrderList;
@property (nonatomic, weak) AFHTTPRequestOperation *requestFinishOrder;
@property (nonatomic, strong) NSMutableArray *orderList;
@property (nonatomic, strong) NSMutableArray *awaitOrderList;

// 是否需要签名
@property (nonatomic,assign) BOOL isAllowSign;
@property (nonatomic,copy) NSString *signImgStr;

@end

@implementation AwaitFinishTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self.firstButton setTitle:@"撤销" forState:UIControlStateNormal];
    [self.secondButton setTitle:@"结单" forState:UIControlStateNormal];
    
    [self.firstButton addTarget:self action:@selector(cancleOrder) forControlEvents:UIControlEventTouchUpInside];
    [self.secondButton addTarget:self action:@selector(CompletionOrderVC) forControlEvents:UIControlEventTouchUpInside];
    
    [self.firstButton setBackgroundImage:[ColorImage redBackgroudImage] forState:UIControlStateNormal];
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomerOrderCell" bundle:nil] forCellReuseIdentifier:@"ceshi"];
    self.tableView.rowHeight = 69;
    
    [self.tableView addHeaderWithTarget:self action:@selector(headerRefresh)];
    
    _signImgStr = @"";

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestAwaitList) name:CustomerChildViewRefreshNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CustomerChildViewRefreshNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_requestOrderList && [_requestOrderList isExecuting]) {
        [_requestOrderList cancel];
    }
    if (_requestFinishOrder && [_requestFinishOrder isExecuting]) {
        [_requestFinishOrder cancel];
    }

    _requestOrderList = nil;
    _requestFinishOrder = nil;
}

- (void)headerRefresh
{
    [self.awaitOrderList removeAllObjects];
    [self requestAwaitList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancleOrder
{
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected == nil) {
        [SVProgressHUD showErrorWithStatus2:@"请选择顾客!" touchEventHandle:^{}];
        return;
    }
    if (self.awaitOrderList.count == 0) {
        [SVProgressHUD showErrorWithStatus2:@"请选择订单!" touchEventHandle:^{}];
        return;
    }
    
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"操作确认" message:@"是否撤销该次服务？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alter showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self requestCancleOrder];
        }
    }];

}

- (void)requestCancleOrder
{
    NSArray *array = [self.awaitOrderList valueForKeyPath:@"@unionOfObjects.tgDetail"];
    NSString *par = [NSString stringWithFormat:@"{\"TGDetailList\":[%@]}", [array componentsJoinedByString:@","]];
    
    [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/CancelTreatGroup" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [self.awaitOrderList removeAllObjects];
            [self requestAwaitList];
            [SVProgressHUD showSuccessWithStatus2:@"撤销成功" duration:kSvhudtimer touchEventHandle:^{
                
            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{
            }];
        }];
    } failure:^(NSError *error) {
        
    }];
}

- (NSMutableArray *)selectOrderArrs
{
    NSMutableArray *selectArrs = [NSMutableArray array];
    if (self.awaitOrderList.count > 0) {
        for (int i = 0; i < self.awaitOrderList.count; i ++) {
            AwaitFinishOrder *finishOrder = self.awaitOrderList[i];
            if (finishOrder.isSelect) {
                [selectArrs addObject:finishOrder];
            }
        }
    }
    return selectArrs;
}
- (BOOL)isConfirmedWithSelectOrderArrs:(NSMutableArray *)theSelectOrderArrs
{
    BOOL isConfirmed = NO;
    for (int i = 0; i <theSelectOrderArrs.count; i ++ ) {
        AwaitFinishOrder *finishOrder = theSelectOrderArrs[i];
        if (finishOrder.IsConfirmed == 2) {
            isConfirmed = YES;
            break;
        }
    }
    return isConfirmed;
}
- (void)CompletionOrderVC
{
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected == nil) {
        [SVProgressHUD showErrorWithStatus2:@"请选择顾客!" touchEventHandle:^{}];
        return;
    }

    if (self.awaitOrderList.count == 0) {
        [SVProgressHUD showErrorWithStatus2:@"请选择订单!" touchEventHandle:^{}];
        return;
    }
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"操作确认" message:@"确定完结所选订单！" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alter showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {

            NSMutableArray *arrs = [self selectOrderArrs];
           _isAllowSign = [self isConfirmedWithSelectOrderArrs:arrs];
            
            if (_isAllowSign) { //签名
                ComputerSginViewController *signVC = [[ComputerSginViewController alloc]init];
               
                __weak typeof(self) weakSelf = self;
                signVC.computerConfirmSignBlock = ^(NSString *imgString){
                    _signImgStr = imgString;
                    [weakSelf dismissViewControllerAnimated:YES completion:^{
                    
                    }];
                    [weakSelf requestFinishOrderList];
                };
                signVC.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:signVC animated:YES completion:^{
                    
                }];
            }else{
                [self requestFinishOrderList];
            }
        }
    }];
}

- (void)requestFinishOrderList
{
    NSArray *array = [self.awaitOrderList valueForKeyPath:@"@unionOfObjects.tgDetail"];
    NSString *par;
    if (_isAllowSign) {
        par = [NSString stringWithFormat:@"{\"SignImg\":\"%@\",\"ImageFormat\":\".jpg\",\"CustomerID\":%ld,\"TGDetailList\":[%@]}", _signImgStr,(long)((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID, [array componentsJoinedByString:@","]];
    }else{
        par = [NSString stringWithFormat:@"{\"CustomerID\":%ld,\"TGDetailList\":[%@]}", (long)((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID, [array componentsJoinedByString:@","]];

    }
    _requestFinishOrder = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/CompleteTreatGroup" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            if (code == 1) {
                [self.awaitOrderList removeAllObjects];
                [self requestAwaitList];
                [SVProgressHUD showSuccessWithStatus2:@"操作成功!" duration:kSvhudtimer touchEventHandle:^{
                    
                }];

            }else{
               [SVProgressHUD showErrorWithStatus2:message duration:kSvhudtimer touchEventHandle:^{
                   
               }];
            }
            
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error  duration:kSvhudtimer touchEventHandle:^{
                
            }];
        }];
    } failure:^(NSError *error) {
        
    }];

}

- (void)requestAwaitList
{
#pragma mark 权限 No.5 待结
    if (![[PermissionDoc sharePermission] rule_Order_Read]) {
        return;
    }
    
    if (!((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected) {
        return;
    }

    NSInteger customerID = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID;
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld,\"IsToday\":0,\"ProductType\":-1}", (long)customerID];
    _requestOrderList = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/GetUnfinishTGList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        self.orderList = [[NSMutableArray alloc] init];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(NSArray *data, NSInteger code, id message) {
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [self.orderList addObject:[[AwaitFinishOrder alloc] initWithDic:obj type:AwaitOrderBill]];
            }];
            self.title = [NSString stringWithFormat:@"待结(%lu)", (unsigned long)self.orderList.count];
            [self.parentViewController performSelector:@selector(updateButtonFieldTitle)];
            [self.tableView headerEndRefreshing];
            [self.tableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            [self.tableView headerEndRefreshing];
        }];
    } failure:^(NSError *error) {
        [self.tableView headerEndRefreshing];
    }];
}

- (void)updateData
{
    NSLog(@"%s", __FUNCTION__);
    [self.tableView reloadData];
}

- (void)selectButton:(AwaitFinishOrder *)order
{
    if (order.isSelect) {
        [self.awaitOrderList addObject:order];
    } else {
        [self.awaitOrderList removeObject:order];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.orderList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomerOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ceshi" forIndexPath:indexPath];
    cell.awaitOrder = self.orderList[indexPath.row];
    cell.delegate = self;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OrderDetailViewController *orderDetail = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"OrderDetailViewController"];
    AwaitFinishOrder *awaitOrder = self.orderList[indexPath.row];
    
    orderDetail.orderID = awaitOrder.OrderID;
    orderDetail.productType = awaitOrder.ProductType;
    orderDetail.objectID = awaitOrder.OrderObjectID;
    [self.navigationController pushViewController:orderDetail animated:YES];
}

- (NSMutableArray *)awaitOrderList
{
    if (_awaitOrderList == nil) {
        _awaitOrderList = [[NSMutableArray alloc] init];
    }
    return _awaitOrderList;
}
@end
