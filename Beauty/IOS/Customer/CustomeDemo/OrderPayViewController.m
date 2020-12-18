//
//  OrderPayViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-1-10.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "OrderPayViewController.h"
#import "GDataXMLNode.h"
#import "GDataXMLDocument+ParseXML.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "TitleView.h"
#import "OrderDoc.h"
#import "ProductAndPriceDoc.h"
#import "AppDelegate.h"
#import "UIButton+InitButton.h"
#import "OrderListCell.h"
#import "TGList.h"
#import "NormalEditCell.h"
#import "OrderDetailAboutCommodityViewController.h"
#import "OrderDetailAboutServiceViewController.h"
#import "PayInfo_ViewController.h"

static CGFloat const kCell_Height = 100;


@interface OrderPayViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestPaymentInfo;
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetOrderUnpaidListOperation;
@property (strong, nonatomic) NSMutableArray *orderArray;
@property (strong, nonatomic) NSMutableArray *orderArray_Selected;//进入PayInfoViewController所需要的参数
@property (nonatomic, retain) UIButton *stateButton;
@property (nonatomic, strong) NSDictionary *paymentInfo;
@end

@implementation OrderPayViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
        self.title = @"待付款";
    
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = nil;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.separatorColor = kTableView_LineColor;
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    _tableView.frame = CGRectMake(0, 0, kSCREN_BOUNDS.size.width,kSCREN_BOUNDS.size.height - kNavigationBar_Height + 20 - 49.0f);

    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kSCREN_BOUNDS.size.height - kNavigationBar_Height + 20 - 49.0f, kSCREN_BOUNDS.size.width, 49.0f)];
    footView.backgroundColor = kColor_FootView;
    [self.view addSubview:footView];
    UIImageView *footViewImage = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, kSCREN_BOUNDS.size.width, 49.0f)];
    [footViewImage setImage:[UIImage imageNamed:@"common_footImage"]];
    [footView addSubview:footViewImage];
    
    UIButton *add_Button = [UIButton buttonWithTitle:@"确认付款"
                                          target:self
                                        selector:@selector(payAction)
                                           frame:CGRectMake(5,5,kSCREN_BOUNDS.size.width - 10,39.0f)
                                   backgroundImg:nil
                                highlightedImage:nil];
    add_Button.backgroundColor = [UIColor colorWithRed:182/255. green:165/255. blue:145/255. alpha:1.];
    add_Button.titleLabel.font=kNormalFont_14;
    [footView addSubview:add_Button];
    [self initbgView];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
    
    if (_orderArray_Selected) {
        [_orderArray_Selected removeAllObjects];
    }
    
    [_stateButton setSelected:NO];
    
    [self requestOrderListUnpaid];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestGetOrderUnpaidListOperation || [_requestGetOrderUnpaidListOperation isExecuting]) {
        [_requestGetOrderUnpaidListOperation cancel];
        _requestGetOrderUnpaidListOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}
- (void)initbgView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"coverView" object:nil];
}

#pragma mark - addAction

- (void)selectAllAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [button setSelected:!button.selected];
    
    if (button.selected) {
        [_orderArray_Selected removeAllObjects];
        _orderArray_Selected = [_orderArray mutableCopy];
        for (OrderDoc *orderDoc in _orderArray) {
            orderDoc.status = 1;
        }
        [_tableView reloadData];
    } else {
        [_orderArray_Selected removeAllObjects];
        for (OrderDoc *orderDoc in _orderArray) {
            orderDoc.status = 0;
        }
        [_tableView reloadData];
    }
}

- (void)payAction
{
    if (_orderArray_Selected.count != 0) {
        CGFloat totalPrice = 0.0f;
        CGFloat totalSalePrice = 0.0f;
        
        NSInteger unPaid = 0; //未支付订单数
        NSInteger paidPart = 0; //部分付订单数
        NSInteger branchSame = 0 ; //有不同门店
        NSInteger cardSame = 0 ; //有不同卡
        NSInteger cardIDNil = 0 ; //未使用e账户购买的订单数
        
        OrderDoc *orderBrachDoc = [_orderArray_Selected objectAtIndex:0];
        NSInteger cardID = orderBrachDoc.cardID;
        NSInteger branchID = orderBrachDoc.order_BranchId;
        
        for (OrderDoc *orderDoc in _orderArray_Selected) {
            ProductAndPriceDoc *productAndPriceDoc = orderDoc.productAndPriceDoc;
            totalPrice += productAndPriceDoc.totalMoney;
            totalSalePrice += productAndPriceDoc.discountMoney;
            if (orderDoc.order_Ispaid == 1) {
                unPaid ++;
            }
            else if (orderDoc.order_Ispaid == 2) {
                paidPart ++;
            }
            
            if (orderDoc.order_BranchId != branchID) {
                branchSame ++ ;
            }
            
            if (orderDoc.cardID != cardID) {
                cardSame ++;
            }
            
            if (orderDoc.cardID <=0) {
                cardIDNil ++ ;
            }
        }
        
        if (branchSame>0 || cardSame>0) {
            [SVProgressHUD showErrorWithStatus2:@"请选择同一门店同一种卡订单支付！"];
            return;
        } else if (cardIDNil) {
            [SVProgressHUD showErrorWithStatus2:@"未使用e账户购买的订单，不能进行支付！"];
            return;
        } else if (_orderArray_Selected.count > 1 && paidPart > 0){
            [SVProgressHUD showErrorWithStatus2:@"部分付的订单请单独支付！"];
            return;
        }
        
        totalSalePrice = [[_orderArray_Selected objectAtIndex:0] order_UnPaidPrice];

    
        
        self.hidesBottomBarWhenPushed = YES;
        PayInfo_ViewController *payInfoController = [[PayInfo_ViewController alloc] init];
        payInfoController.selectOrderPayArr = _orderArray_Selected;
        payInfoController.BranchId = branchID;
        [self.navigationController pushViewController:payInfoController animated:YES];
        
    } else {
        [SVProgressHUD showErrorWithStatus2:@"请选择需要支付的订单"];
        return;
    }
}

#pragma mark - OrderListCellDelete

- (void)selectedTheOrderListCell:(OrderListCell *)cell
{
    if (!_orderArray_Selected) {
        _orderArray_Selected = [NSMutableArray array];
    }
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    OrderDoc *tmpOrderDoc = [_orderArray objectAtIndex:indexPath.row];
    
    if (![_orderArray_Selected containsObject:tmpOrderDoc]) {
        [_orderArray_Selected addObject:tmpOrderDoc];
        if (_orderArray_Selected.count == _orderArray.count) {
            [_stateButton setSelected:YES];
        }
    } else {
        [_orderArray_Selected removeObject:tmpOrderDoc];
        [_stateButton setSelected:NO];
    }
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCell_Height;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_orderArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"payCell";
        OrderListCell *cell = [[OrderListCell alloc]init];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
        if (cell == nil) {
            cell = [[OrderListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        OrderDoc *orderDoc = [_orderArray objectAtIndex:indexPath.row];
        [cell updateData:orderDoc];
        [cell setDelegate:self];

        [cell.stateLabel setText:[NSString stringWithFormat:@"%@|%@", orderDoc.order_StatusStrForCommodity,orderDoc.order_IspaidStr]];
        cell.accessoryType = UITableViewCellAccessoryNone;
        if ([_orderArray_Selected containsObject:orderDoc] ) {
            [cell.selectButton setSelected:YES];
        } else {
            [cell.selectButton setSelected:NO];
        }

        return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.hidesBottomBarWhenPushed = YES;

    OrderDoc *orderDoc = [_orderArray objectAtIndex:indexPath.row];

    if ([orderDoc order_Type] ==1) {//商品
        
        OrderDetailAboutCommodityViewController *commod = (OrderDetailAboutCommodityViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetailAboutCommodityViewController"];
        commod.orderDoc = orderDoc;
        
        [self.navigationController pushViewController:commod animated:YES];
        
    }else
    {
        OrderDetailAboutServiceViewController *serve =  (OrderDetailAboutServiceViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetailAboutServiceViewController"];
        serve.orderDoc = orderDoc;
        [self.navigationController pushViewController:serve animated:YES];
    }
}

#pragma mark - 接口

- (void)requestOrderListUnpaid
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    NSDictionary *para = @{@"CustomerID":@(CUS_CUSTOMERID),
                           @"ProductType":@(-1),
                           @"Status":@9,
                           @"PaymentStatus":@0,
                           @"PageIndex":@1,
                           @"PageSize":@(INT32_MAX)};
    _requestGetOrderUnpaidListOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Payment/UnPaidListByCustomerID"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        self.view.userInteractionEnabled = NO;
        if (_orderArray) {
            [_orderArray removeAllObjects];
        } else {
            _orderArray = [NSMutableArray array];
        }
        if (_orderArray_Selected) {
            [_orderArray_Selected removeAllObjects];
        } else {
            _orderArray_Selected = [NSMutableArray array];
        }
        
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            [SVProgressHUD dismiss];
            
            NSArray *orderList = [json objectForKey:@"Data"];
            orderList = (NSNull *)orderList == [NSNull null] ? nil : orderList;
          
            NSDictionary  *dict2 = @{@"service_PICName":@"ServicePICName",
                                     @"start_time":@"StartTime",
                                     @"status_0":@"Status"};
            
            NSDictionary  *dict =  @{@"order_ID":@"OrderID",
                                     @"order_AccountName":@"ResponsiblePersonName",
                                     @"order_OrderTime":@"OrderTime",
                                     @"order_Status":@"Status",
                                     @"order_ObjectID":@"OrderObjectID",
                                     @"order_Type":@"ProductType",
                                     @"order_Ispaid":@"PaymentStatus",
                                     @"order_UnPaidPrice":@"UnPaidPrice",
                                     @"order_ProductName":@"ProductName",
                                     @"order_ProductNumber":@"Quantity",
                                     @"order_BranchId":@"BranchID",
                                     @"cardID":@"CardID",
                                     @"order_cardName":@"CardName",
                                     @"order_BranchName":@"BranchName"
                                     };
            
            NSDictionary  *dict1 = @{@"discountMoney":@"TotalSalePrice"};
           

            for (NSDictionary *obj in orderList) {
                OrderDoc *orderDoc = [[OrderDoc alloc] init];
                [orderDoc assignObjectPropertyWithDictionary:obj andObjectPropertyAssociatedDictionary:dict];

                
                NSArray *tgList0 = [obj objectForKey:@"TGList"];
                
                orderDoc.tgListMuArray = [[NSMutableArray alloc]init];
               
                    for (NSDictionary *obj1 in tgList0)
                    {
                        TGList *tgList = [[TGList alloc]init];
                        
                        [tgList assignObjectPropertyWithDictionary:obj1 andObjectPropertyAssociatedDictionary:dict2];
                        
                        [orderDoc.tgListMuArray addObject:tgList];
                    }
                
                ProductAndPriceDoc *productAndPriceDoc = [[ProductAndPriceDoc alloc] init];
                productAndPriceDoc.flag = orderDoc.order_Type;
                [productAndPriceDoc assignObjectPropertyWithDictionary:obj andObjectPropertyAssociatedDictionary:dict1];

                
                if (orderDoc.order_Type == 0) {
                    ServiceDoc *serDoc = [[ServiceDoc alloc] init];
                    
                    [serDoc setService_ProductName:obj[@"ProductName"]];
                    [serDoc setService_Quantity:[obj[@"Quantity"] intValue]];
                    productAndPriceDoc.serviceArray = @[serDoc];
                    orderDoc.productAndPriceDoc = productAndPriceDoc;
                    [_orderArray addObject:orderDoc];
                    
                    for (OrderDoc * detaiOrderDoc in self.payDetaiDelectedOrderArr) {
                        
                        if (orderDoc.order_ID == detaiOrderDoc.order_ID) {
                            [_orderArray_Selected addObject:orderDoc];
                        }
                    }
                }
                
                if (orderDoc.order_Type == 1) {
                    NSMutableArray *tmpServiceArray = [NSMutableArray array];
                    CommodityDoc *commDoc = [[CommodityDoc alloc] init];
                    [commDoc setComm_CommodityName:obj[@"ProductName"]];
                    [commDoc setComm_Quantity:[obj[@"Quantity"] intValue]];
                    [tmpServiceArray addObject:commDoc];
                    productAndPriceDoc.commodityArray = tmpServiceArray;
                    orderDoc.productAndPriceDoc = productAndPriceDoc;
                    [_orderArray addObject:orderDoc];
                    
                    for (OrderDoc * detaiOrderDoc in self.payDetaiDelectedOrderArr) {

                        if (orderDoc.order_ID == detaiOrderDoc.order_ID) {
                            [_orderArray_Selected addObject:orderDoc];
                        }
                    }
                }
            }
            
            if (_orderArray_Selected.count == _orderArray.count) {
                [_stateButton setSelected:YES];
            }

            
            [_tableView reloadData];
            
        } failure:^(NSInteger code ,NSString *error ) {
           
        }];
        [SVProgressHUD dismiss];
        self.view.userInteractionEnabled = YES;
    } failure:^(NSError *error) {
        
    }];
}


@end
