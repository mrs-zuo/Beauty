//
//  PaymentTableViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/6/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "PaymentTableViewController.h"
#import "AwaitFinishOrder.h"
#import "CustomerOrderCell.h"
#import "GPBHTTPClient.h"   
#import "AppDelegate.h" 
#import "CusMainViewController.h"
#import "GPUniqueArray.h"
#import "SubOrderViewController.h"
#import "OrderDetailViewController.h"
#import "MJRefresh.h"

@interface PaymentTableViewController ()<AwaitFinishOrderDelegate>
@property (nonatomic, weak) AFHTTPRequestOperation *requestOrderList;
@property (nonatomic, strong) NSMutableArray *orderList;
@property (nonatomic, strong) NSMutableArray *selectList;
@property (nonatomic, strong) NSMutableArray *olderArray;
@end

@implementation PaymentTableViewController

- (NSMutableArray *)olderArray
{
    if (_olderArray == nil) {
        CusMainViewController *cusMain = (CusMainViewController *)[self parentViewController];
        _olderArray = cusMain.oldOrderList;
    }
    return _olderArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    
    [self.firstButton setTitle:@"加入开单列表" forState:UIControlStateNormal];
    [self.secondButton setTitle:@"立即开单" forState:UIControlStateNormal];

    [self.firstButton addTarget:self action:@selector(addOrderList) forControlEvents:UIControlEventTouchUpInside];
    [self.secondButton addTarget:self action:@selector(startOrder) forControlEvents:UIControlEventTouchUpInside];

    [self.tableView registerNib:[UINib nibWithNibName:@"CustomerOrderCell" bundle:nil] forCellReuseIdentifier:@"Payment"];
    self.tableView.rowHeight = 69;
    
    [self.tableView addHeaderWithTarget:self action:@selector(paymentRefresh)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestPaymentList) name:CustomerChildViewRefreshNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CustomerChildViewRefreshNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)paymentRefresh
{
    [self.selectList removeAllObjects];
    [self.selectList addObjectsFromArray:self.olderArray];
    [self requestPaymentList];
}

- (void)requestPaymentList
{
#pragma mark 权限 No.5 存单
    if (![[PermissionDoc sharePermission] rule_Order_Read]) {
        return;
    }
    
    if (!((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected) {
        return;
    }
    
    NSInteger customerID = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID;

    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld}", (long)customerID];
    _requestOrderList = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/GetExecutingOrderList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        self.orderList = [[NSMutableArray alloc] init];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(NSArray *data, NSInteger code, id message) {
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                AwaitFinishOrder *awOrder = [[AwaitFinishOrder alloc] initWithDic:obj type:AwaitOrderFinish customerID:customerID];
                if (!(awOrder.TotalCount != 0 && (awOrder.TotalCount ==(awOrder.FinishedCount + awOrder.ExecutingCount)))) {
                    [self.orderList addObject:awOrder];
                 }
            }];
            
            self.title = [NSString stringWithFormat:@"存单(%lu)", (unsigned long)self.orderList.count];
            [self.parentViewController performSelector:@selector(updateButtonFieldTitle)];
            [self.tableView headerEndRefreshing];
            [self.tableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
            [self.tableView headerEndRefreshing];
        }];
    } failure:^(NSError *error) {
        [self.tableView headerEndRefreshing];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)addOrderList
{
    if (self.selectList.count) {
        [self.olderArray removeAllObjects];
        [self.olderArray addObjectsFromArray:self.selectList];
        [SVProgressHUD showSuccessWithStatus2:@"添加成功!" touchEventHandle:^{
            if ([self.parentViewController respondsToSelector:@selector(gotoAwaitOrderView)]) {
                [self.parentViewController performSelector:@selector(gotoAwaitOrderView)];
            }
        }];
    } else {
        [self.olderArray removeAllObjects];
        [SVProgressHUD showErrorWithStatus2:@"请选择商品或服务！" touchEventHandle:^{}];
    }
}

- (void)startOrder
{
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected == nil) {
        [SVProgressHUD showErrorWithStatus2:@"请选择顾客!" touchEventHandle:^{}];
        return;
    }
    if (self.selectList.count == 0) {
        [SVProgressHUD showErrorWithStatus2:@"没有选择订单!" touchEventHandle:^{
        }];
        return;
    }
    
    SubOrderViewController *subOrderVC = [[SubOrderViewController alloc] init];
    
    NSArray *array = [self.selectList valueForKeyPath:@"OrderID"];
    subOrderVC.orderList = [array componentsJoinedByString:@","];
    subOrderVC.customerName = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_Name;
    subOrderVC.customerID = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID;
    [self.navigationController pushViewController:subOrderVC animated:YES];
}

- (void)updateData
{
    NSLog(@"%s", __FUNCTION__);
    [self.selectList removeAllObjects];
    [self.selectList addObjectsFromArray:self.olderArray];
    [self.tableView reloadData];
}

- (void)selectButton:(AwaitFinishOrder *)order
{
    if (order.isSelect) {
        [self.selectList addObject:order];
    } else {
        [self.selectList removeObject:order];
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
    CustomerOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Payment" forIndexPath:indexPath];
    AwaitFinishOrder *awOrder = self.orderList[indexPath.row];
    awOrder.isSelect = NO;
    if (self.selectList.count) {
        [self.selectList enumerateObjectsUsingBlock:^(AwaitFinishOrder *obj, NSUInteger idx, BOOL *stop) {
            if (obj.OrderID == awOrder.OrderID) {
                awOrder.isSelect = YES;
                *stop = YES;
            }
        }];
    }
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

- (NSMutableArray *)selectList
{
    if (_selectList == nil) {
        _selectList = [[NSMutableArray alloc] init];
    }
    return _selectList;
}
@end
