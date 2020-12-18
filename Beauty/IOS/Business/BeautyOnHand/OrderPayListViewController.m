//
//  OrderPayViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-1-10.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "OrderPayListViewController.h"
#import "GDataXMLNode.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "NavigationView.h"
#import "OrderDoc.h"
#import "ProductAndPriceDoc.h"
#import "AppDelegate.h"
#import "UIButton+InitButton.h"
#import "PayInfoViewController.h"
#import "CheckOutListCell.h"
#import "OrderDetailViewController.h"
#import "DEFINE.h"
#import "GPBHTTPClient.h"
#import "NormalEditCell.h"
#import "PayConfirmViewController.h"
#import "CustomerListViewController.h"
#import "PerformanceTableViewCell.h"

@interface OrderPayListViewController ()<SelectCustomerDelegate>
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetOrderUnpaidListOperation;
@property (strong, nonatomic) NSMutableArray *orderArray;
@property (strong, nonatomic) NSMutableArray *orderArray_Selected;  //进入PayInfoViewController所需要的参数

@property (strong, nonatomic) UIButton *checkAllButton;
@property (nonatomic ,assign) NSInteger flag;
@end

@implementation OrderPayListViewController
@synthesize orderArray;
@synthesize orderArray_Selected;
@synthesize checkAllButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestOrderListUnpaid];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestGetOrderUnpaidListOperation && [_requestGetOrderUnpaidListOperation isExecuting]) {
        [_requestGetOrderUnpaidListOperation cancel];
    }
    _requestGetOrderUnpaidListOperation = nil;
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    checkAllButton = [UIButton buttonWithTitle:@""
                                        target:self
                                      selector:@selector(checkAllAction)
                                         frame:CGRectMake(316 - HEIGHT_NAVIGATION_VIEW, 0, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                 backgroundImg:[UIImage imageNamed:@"icon_unCheckedTitle"]
                              highlightedImage:[UIImage imageNamed:@""]];
    [checkAllButton setBackgroundImage:[UIImage imageNamed:@"icon_CheckedTitle"] forState:UIControlStateSelected];
    
    [self initTitle];
    
    _tableView.frame = CGRectMake(5.0f, 5.0f + HEIGHT_NAVIGATION_VIEW, 310.0f, kSCREN_BOUNDS.size.height - 64.0f - ( 5.0f + HEIGHT_NAVIGATION_VIEW)  - 49.0f);
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor clearColor];
    if ((IOS7 || IOS8)) _tableView.separatorInset = UIEdgeInsetsZero;
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kSCREN_BOUNDS.size.height - 64.0f - 49.0f, 320.0f, 49.0f)];
    footView.backgroundColor = kColor_Background_View;
    [self.view addSubview:footView];
    
    UIButton *add_Button = [UIButton buttonWithTitle:@"结账" target:self selector:@selector(payAction) frame:CGRectMake(5.0f, 5.0f, 310.0f, 39.0f) backgroundImg:ButtonStyleBlue];
    
    [footView addSubview:add_Button];
    
    _flag = 0;// 1从转换顾客进来
}

-(void)initTitle
{
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,  5.0f) title:[NSString stringWithFormat:@"结账(%@)",self.customerName]];
    [navigationView addSubview:checkAllButton];
    [self.view addSubview:navigationView];
    
    UIButton * endButton = [UIButton buttonWithTitle:nil target:self selector:@selector(UpdateOrderCustomerID) frame:CGRectMake(315- HEIGHT_NAVIGATION_VIEW -30,5,28,28) backgroundImg:[UIImage imageNamed:@"customerChange"] highlightedImage:nil];
    [navigationView addSubview:endButton];
}

-(void)initSelcte
{
    orderArray_Selected= [NSMutableArray array];
    checkAllButton.selected = NO;
}

-(void)UpdateOrderCustomerID//顾客转换
{
    if (orderArray_Selected.count ==0) {
//        [SVProgressHUD showErrorWithStatus2:@"请选择要转换的订单!" touchEventHandle:^{}];
        [SVProgressHUD showErrorWithStatus2:@"请选择要转换的订单!"  duration:kSvhudtimer touchEventHandle:^{
        }];
        return;
    }
    for (OrderDoc *ord in orderArray_Selected) {
        if (ord.order_Ispaid == 2) {
            [SVProgressHUD showErrorWithStatus2:@"已经部分支付订单不能进行转换!"  duration:kSvhudtimer touchEventHandle:^{
                
            }];
            return;
        }
        if (ord.order_Ispaid == 2) {
            [SVProgressHUD showErrorWithStatus2:@"已经部分支付订单不能进行转换!"  duration:kSvhudtimer touchEventHandle:^{
                
            }];
            return;
        }
    }
    
    CustomerListViewController * customer =  [self.storyboard instantiateViewControllerWithIdentifier:@"CustomerListViewController"];
    customer.delegate = self;
    customer.returnViewTag = 1;
    customer.OrderArr = orderArray_Selected;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:customer];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:^{}];
    
}

//代理返回方法 刷新列表数据
- (void)dismissViewControllerWithSelectedCustomerName:(NSString *)customerName customerId:(NSInteger)customerI{
    _flag = 1 ;
}

- (void)checkAllAction
{
    if (checkAllButton.isSelected) {
        checkAllButton.selected = NO;
        
        [orderArray_Selected removeAllObjects];
        [_tableView reloadData];
        
    } else {
        checkAllButton.selected = YES;
        
        [orderArray_Selected removeAllObjects];
        orderArray_Selected = [orderArray mutableCopy];
        [_tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - addAction

- (void)payAction
{
    if (orderArray_Selected.count != 0) {
        if (orderArray_Selected.count > 1) {
            for (OrderDoc *ord in orderArray_Selected) {
                if (ord.order_Ispaid == 2) {
                    [SVProgressHUD showErrorWithStatus2:@"部分支付订单只能单独进行支付" touchEventHandle:^{}];
                    return;
                }
            }
        }
        double totalPrice = 0.0f;
        double totalSalePrice = 0.0f;
        NSInteger payStatus = 0;
        NSInteger orderObjectId = 0;
        
        for (OrderDoc *orderDoc in orderArray_Selected) {
            ProductAndPriceDoc *productAndPriceDoc = orderDoc.productAndPriceDoc;
            totalPrice += productAndPriceDoc.productDoc.pro_TotalMoney;
            totalSalePrice += productAndPriceDoc.productDoc.pro_TotalSaleMoney;
            payStatus = orderDoc.order_Ispaid;
            orderObjectId = orderDoc.order_ObjectID;
        }
        
        if (orderArray_Selected.count == 1) {//单一订单支付完成后跳转到详情页
            if (payStatus == 2) {//部分付
                PayInfoViewController *payInfoController = [self.storyboard instantiateViewControllerWithIdentifier:@"PayInfoViewController"];
                payInfoController.orderNumbers = 1;
                payInfoController.makeStateComplete = 0;
                payInfoController.paymentOrderArray = orderArray_Selected;
                payInfoController.productType = [[[[orderArray_Selected objectAtIndex:0] productAndPriceDoc] productDoc] pro_Type];
                payInfoController.customerId = self.customerId;
                payInfoController.comeFrom = 2;
                [self.navigationController pushViewController:payInfoController animated:YES];
            }else{
                PayConfirmViewController * confirm = [[PayConfirmViewController alloc] init];
                confirm.orderNumbers = [orderArray_Selected count];
                confirm.paymentOrderArray = orderArray_Selected;
                confirm.makeStateComplete = 0;
                confirm.customerId = self.customerId;
                confirm.productType = [[[[orderArray_Selected objectAtIndex:0] productAndPriceDoc] productDoc] pro_Type];
                confirm.pageToGo = 3;
                confirm.payStatus = payStatus;
                confirm.comeFrom = 2;
                [self.navigationController pushViewController:confirm animated:YES];
            }
        }else{
            PayInfoViewController *payInfoController = [self.storyboard instantiateViewControllerWithIdentifier:@"PayInfoViewController"];
            payInfoController.orderNumbers = [orderArray_Selected count];
            payInfoController.paymentOrderArray = orderArray_Selected;
            payInfoController.makeStateComplete = 0;
            payInfoController.comeFrom = 2;
            payInfoController.customerId = self.customerId;
            
//            if (orderArray_Selected.count > 1){
//                payInfoController.pageToGo = 5; //结账后跳转到order root
//            }
//            if (_pageFrom == 2){
//                payInfoController.comeFrom = 3; //完成后返回check out view controller
//                payInfoController.customerId = _customerId;
//            }
            [self.navigationController pushViewController:payInfoController animated:YES];
        }
    } else {
        [SVProgressHUD showErrorWithStatus2:@"请选择需要结账的订单" touchEventHandle:^{}];
    }
}

#pragma mark - OrderListCellDelete

- (void)selectedTheOrderListCell:(CheckOutListCell *)cell
{
    if (!orderArray_Selected) {
        orderArray_Selected= [NSMutableArray array];
    }
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    OrderDoc *tmpOrderDoc = [orderArray objectAtIndex:indexPath.section];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.order_ID == %d", tmpOrderDoc.order_ID];
    NSArray *array = [orderArray_Selected filteredArrayUsingPredicate:predicate];
    
    if ([array count] > 0) {
        [orderArray_Selected removeObjectsInArray:array];
    } else {
        [orderArray_Selected addObject:tmpOrderDoc];
    }
    
    if ([orderArray_Selected count] == [orderArray count]) {
        checkAllButton.selected = YES;
    } else {
        checkAllButton.selected = NO;
    }
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [orderArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    OrderDoc *orderDoc = [orderArray objectAtIndex:section];
    NSArray * arr = orderDoc.order_TGListArr;
    return 1+ arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0) {
        static NSString *cellIndentify = @"MyCell";
        CheckOutListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
        if (cell == nil) {
            cell = [[CheckOutListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 30)];
        OrderDoc *orderDoc = [orderArray objectAtIndex:indexPath.section];
        [cell updateData:orderDoc];
        [cell setDelegate:self];
        
        //    [cell.stateLabel setText:[NSString stringWithFormat:@"%@", orderDoc.order_StatusStr]];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectButton.hidden = NO;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.order_ID == %d", orderDoc.order_ID];
        NSArray *array = [orderArray_Selected filteredArrayUsingPredicate:predicate];
        if ([array count] > 0) {
            [cell.selectButton setSelected:YES];
        } else {
            [cell.selectButton setSelected:NO];
        }
        DLOG(@"array:%lu", (unsigned long)[array count]);
        return cell;

    }else
    {
        NSString *cellIndentify =[NSString stringWithFormat: @"NormalEditCell1%ld%ld",(long)indexPath.row,(long)indexPath.section];
        NormalEditCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIndentify];
        if (cell == nil) {
            cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
            cell.titleLabel.frame = CGRectMake(20.0f, 30/2 - 20.0f/2, 100, 20.0f) ;
            cell.valueText.frame = CGRectMake(125.0f, 30/2 - 20.0f/2, 150, 20.0f);
            cell.titleLabel.font =kFont_Light_13;
            cell.valueText.font = kFont_Light_13;
            cell.titleLabel.textColor = kColor_Black;
            UIImageView * imageQuan = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 6, 6)];
            imageQuan.image = [UIImage imageNamed:@"yuan"];
            [cell.contentView addSubview:imageQuan];
        }
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 310, 0, 0)];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.backgroundColor = [UIColor whiteColor];
        
        [cell.valueText setEnabled:NO];
        [cell.valueText setTextColor:[UIColor blackColor]];
        [cell.valueText setUserInteractionEnabled:NO];
        [cell.accessoryLabel setHidden:YES];
        
        OrderDoc *orderDoc = [orderArray objectAtIndex:indexPath.section];
        NSDictionary * dicList = [orderDoc.order_TGListArr objectAtIndex:indexPath.row-1];
        
        [orderDoc setOrder_TGStatus:[[dicList objectForKey:@"Status"]intValue]];
        cell.titleLabel.text = [NSString stringWithFormat:@"%@",[dicList objectForKey:@"ServicePICName"]];
        cell.valueText.text = [NSString stringWithFormat:@"%@|%@",orderDoc.order_TGStatusStr,[dicList objectForKey:@"StartTime"]];
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        return 62.0f;
    }
    return kTableView_HeightOfRow-10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"product =%ld",(long)[[orderArray objectAtIndex:indexPath.section] order_ProductType]);
    OrderDetailViewController *orderDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetailViewController"];
    orderDetail.orderID = [[orderArray objectAtIndex:indexPath.section] order_ID];
    orderDetail.productType = [[orderArray objectAtIndex:indexPath.section] order_ProductType];
    orderDetail.objectID  = [[orderArray objectAtIndex:indexPath.section] order_ObjectID];
    [self.navigationController pushViewController:orderDetail animated:YES];
}

#pragma mark - 接口
- (void)requestOrderListUnpaid
{
    CustomerDoc *customer = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected;
    NSString *CustomerName = customer.cus_Name;
    NSInteger customerId = customer.cus_ID;
    
    if (_flag) {//从顾客列表页跳转回来
        self.customerName = customer.cus_Name;
        self.customerId = customer.cus_ID;
    }else{
        if (_customerId > 0 ){
            customerId = _customerId;
            CustomerName = _customerName;
        }else
        {
            self.customerId = customerId;
            self.customerName = CustomerName;
        }
    }
    [self initTitle];
    
    [SVProgressHUD showWithStatus:@"Loading"];
     NSDictionary * par = @{@"CustomerID":@((long)customerId),
                           @"BranchID":@(self.branchID)};
    
    _requestGetOrderUnpaidListOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Payment/UnPaidListByCustomerID" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        if (orderArray) {
            [orderArray removeAllObjects];
        } else {
            orderArray = [NSMutableArray array];
        }
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {

            for (NSDictionary *obj in data) {
                OrderDoc *orderDoc = [[OrderDoc alloc] init];
                [orderDoc setOrder_ID:[[obj objectForKey:@"OrderID"] integerValue]];
                [orderDoc setOrder_ObjectID:[[obj objectForKey:@"OrderObjectID"] integerValue]];
                [orderDoc setOrder_ProductType:[[obj objectForKey:@"ProductType"] integerValue]];
                [orderDoc setOrder_ResponsiblePersonName:[obj objectForKey:@"ResponsiblePersonName"]];
                [orderDoc setOrder_OrderTime:[obj objectForKey:@"OrderTime"]];
                [orderDoc setOrder_Status:[[obj objectForKey:@"Status"] intValue]];
                [orderDoc setOrder_Ispaid:[[obj objectForKey:@"PaymentStatus"] intValue]];
                [orderDoc setOrder_CustomerName:CustomerName];
                [orderDoc setIsThisBranch:[[obj objectForKey:@"IsThisBranch"] integerValue]];
                [orderDoc setOrder_TGListArr:[obj objectForKey:@"TGList"]];
                
                orderDoc.productAndPriceDoc.productDoc.pro_Name     = [obj objectForKey:@"ProductName"];
                orderDoc.productAndPriceDoc.productDoc.pro_Type     = [[obj objectForKey:@"ProductType"] integerValue];
                orderDoc.productAndPriceDoc.productDoc.pro_quantity = [[obj objectForKey:@"Quantity"] integerValue];
                orderDoc.productAndPriceDoc.productDoc.pro_TotalMoney     = [[obj objectForKey:@"TotalOrigPrice"] doubleValue];
                orderDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney = [[obj objectForKey:@"TotalSalePrice"] doubleValue];
                 orderDoc.productAndPriceDoc.productDoc.pro_UnPaidPrice= [[obj objectForKey:@"UnPaidPrice"] doubleValue];
                orderDoc.productAndPriceDoc.productDoc.pro_HaveToPay =orderDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney - orderDoc.productAndPriceDoc.productDoc.pro_UnPaidPrice;
                [orderArray addObject:orderDoc];
            }
            
            [orderArray_Selected removeAllObjects];
            [_tableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
    
    /*
     _requestGetOrderUnpaidListOperation = [[GPHTTPClient shareClient] requestGetOrderListViaJsonByCustomerID:customerId productType:-1 status:9 isPaid:0 acccountId:0 startTime:nil endTime:nil success:^(id xml) {
     //    _requestGetOrderUnpaidListOperation = [[GPHTTPClient shareClient] requestGetOrderListByCustomerID:customerId productType:-1 status:9 isPaid:0 success:^(id xml) {
     [SVProgressHUD dismiss];
     if (orderArray) {
     [orderArray removeAllObjects];
     } else {
     orderArray = [NSMutableArray array];
     }
     
     [ZWJson parseJsonWithXML:xml viewController:nil showSuccessMsg:NO showErrorMsg:NO success:^(id data, id message) {
     [SVProgressHUD dismiss];
     NSArray *orderList = [data objectForKey:@"OrderList"];
     orderList = (NSNull *)orderList == [NSNull null] ? nil : orderList;
     
     for (NSDictionary *obj in orderList) {
     OrderDoc *orderDoc = [[OrderDoc alloc] init];
     [orderDoc setOrder_ID:[[obj objectForKey:@"OrderID"] integerValue]];
     [orderDoc setOrder_ProductType:[[obj objectForKey:@"ProductType"] integerValue]];
     [orderDoc setOrder_ResponsiblePersonName:[obj objectForKey:@"ResponsiblePersonName"]];
     [orderDoc setOrder_OrderTime:[obj objectForKey:@"OrderTime"]];
     [orderDoc setOrder_Status:[[obj objectForKey:@"Status"] intValue]];
     [orderDoc setOrder_Ispaid:[[obj objectForKey:@"PaymentStatus"] intValue]];
     [orderDoc setOrder_CustomerName:CustomerName];
     [orderDoc setIsThisBranch:[[obj objectForKey:@"IsThisBranch"] integerValue]];
     
     orderDoc.productAndPriceDoc.productDoc.pro_Name     = [obj objectForKey:@"ProductName"];
     orderDoc.productAndPriceDoc.productDoc.pro_Type     = [[obj objectForKey:@"ProductType"] integerValue];
     orderDoc.productAndPriceDoc.productDoc.pro_quantity = [[obj objectForKey:@"Quantity"] integerValue];
     orderDoc.productAndPriceDoc.productDoc.pro_TotalMoney     = [[obj objectForKey:@"TotalOrigPrice"] floatValue];
     orderDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney = [[obj objectForKey:@"TotalSalePrice"] floatValue];
     [orderArray addObject:orderDoc];
     }
     
     [_tableView reloadData];
     
     } failure:^(NSString *error){
     [SVProgressHUD dismiss];
     }];
     } failure:^(NSError *error) {
     [SVProgressHUD dismiss];
     }];
     */
}

@end
