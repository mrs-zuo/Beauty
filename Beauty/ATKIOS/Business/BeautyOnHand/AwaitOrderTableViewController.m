//
//  FirstTableViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/6/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "AwaitOrderTableViewController.h"
#import "DFUITableView.h"
#import "CusMainViewController.h"
#import "AppDelegate.h"
#import "AwaitFinishOrder.h"
#import "GPUniqueArray.h"
#import "AwaitOrderCell.h"
#import "OrderConfirmViewController.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "SubOrderViewController.h"
#import "SVProgressHUD.h"   
#import "ColorImage.h"

@interface AwaitOrderTableViewController ()

@property (nonatomic, strong) NSMutableArray *orderArray;
@property (nonatomic, weak) NSMutableArray *olderArray;
@end

@implementation AwaitOrderTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self hideSecondButton];
    [self initData];
    
    [self.firstButton setBackgroundImage:[ColorImage blueBackgroudImage] forState:UIControlStateNormal];
    [self.firstButton setTitle:@"开单" forState:UIControlStateNormal];
    [self.firstButton addTarget:self action:@selector(commitOrder:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updatetitle];
    [self.tableView reloadData];
}

static NSString *awaitIdentifier = @"awaitOrderCell";

- (void)initData
{
    self.orderArray = [[NSMutableArray alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:@"AwaitOrderCell" bundle:nil] forCellReuseIdentifier:awaitIdentifier];
}

- (void)commitOrder:(UIButton *)sender
{
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected == nil) {
        [SVProgressHUD showErrorWithStatus2:@"请选择顾客!" touchEventHandle:^{}];
        return;
    }

    if (self.orderArray.count == 0 && self.olderArray.count == 0) {
        [SVProgressHUD showErrorWithStatus2:@"请选择订单!" touchEventHandle:^{ }];
        [self updatetitle];
        [self.tableView reloadData];
        return;
    }
    /*
     *新开订单不论是否有老订单 跳转到大订单页面
     *只有老订单 跳转到开小单页面
     *
     */
    if (self.orderArray.count == 0 ) {
        SubOrderViewController *subOrderVC = [[SubOrderViewController alloc] init];
        NSArray *orderList = [self.olderArray valueForKeyPath:@"OrderID"];
        subOrderVC.orderList = [orderList componentsJoinedByString:@","];
        subOrderVC.customerName = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_Name;
        subOrderVC.customerID = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID;
        [self.navigationController pushViewController:subOrderVC animated:YES];
    } else {
        OrderConfirmViewController *orderCon = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"OrderConfirmViewController"];
        orderCon.pastOrderArray = [self.olderArray mutableCopy];
        [self.navigationController pushViewController:orderCon animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateData
{
    [self updatetitle];
    [self.tableView reloadData];
    NSLog(@"%s", __FUNCTION__);
}

- (void)updatetitle
{
    [self.parentViewController performSelector:@selector(updateButtonFieldTitle)];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.olderArray.count + self.orderArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AwaitOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:awaitIdentifier];
    cell.productNameLabel.textColor = kColor_DarkBlue;
    cell.detailLabel.font = kFont_Light_16;
    if (indexPath.row < self.olderArray.count) {
        AwaitFinishOrder *older = self.olderArray[indexPath.row];
        cell.productNameLabel.text = older.ProductName;
        cell.detailLabel.text = older.AccountName;
    } else {
        id order = self.orderArray[indexPath.row - self.olderArray.count];
        if ([order isKindOfClass:[ServiceDoc class]]) {
            
            cell.productNameLabel.text = ((ServiceDoc *)order).service_ServiceName;
            cell.detailLabel.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, ((ServiceDoc *)order).service_UnitPrice];
        } else {
            cell.productNameLabel.text = ((CommodityDoc *)order).comm_CommodityName;
            cell.detailLabel.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, ((CommodityDoc *)order).comm_UnitPrice];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
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
    [self deleteOrder:indexPath];
}

- (void)deleteOrder:(NSIndexPath *)index
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"操作确认" message:@"确定删除订单？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alter showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            if(index.row < self.olderArray.count) {
                [self.olderArray removeObjectAtIndex:index.row];
            } else {
                NSInteger orderIndex = index.row - self.olderArray.count;
                if (orderIndex >= self.orderArray.count) {
                    return ;
                }
                id deleOrder = [self.orderArray objectAtIndex:orderIndex];
                [self removeOrderFromArray:deleOrder];
            }
            [self updatetitle];

            [self.tableView reloadData];
        }
    }];
}

- (void)removeOrderFromArray:(id)order
{
    if ([order isKindOfClass:[ServiceDoc class]]) {
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]).serviceArray_Selected removeObject:order];
    } else {
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]).commodityArray_Selected removeObject:order];
    }
}

- (NSMutableArray *)orderArray
{
    /*
     *初始化OrderArray 从全局的服务商品数组获取订单
     */
    if (_orderArray) {
        [_orderArray removeAllObjects];
    } else {
        _orderArray = [[NSMutableArray alloc] init];
    }
    NSArray *serviceArray    = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).serviceArray_Selected;
    NSArray *commodityArray  = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).commodityArray_Selected;
    [_orderArray addObjectsFromArray:serviceArray];
    [_orderArray addObjectsFromArray:commodityArray];
    
    return _orderArray;
}

- (NSMutableArray *)olderArray
{
    if (_olderArray == nil) {
        CusMainViewController *cusMain = (CusMainViewController *)[self parentViewController];
        _olderArray = cusMain.oldOrderList;
    }
    return _olderArray;
}

@end
