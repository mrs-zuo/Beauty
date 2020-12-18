//
//  OrderListViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-1-7.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//


#import "OrderListViewController.h"
#import "OrderDetailViewController.h"
#import "OrderDetailAboutCommodityViewController.h"
#import "GDataXMLNode.h"
#import "GDataXMLDocument+ParseXML.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "OrderDoc.h"
#import "ProductAndPriceDoc.h"
#import "AppDelegate.h"
#import "UIButton+InitButton.h"
#import "TitleView.h"
#import "UILabel+InitLabel.h"
#import "OrderListCell.h"
#import "ReusableArray.h"
#import "FilterOrderView.h"

static CGFloat const kFilterOrderView_Height = 359;


@interface OrderListViewController () <ReusableArrayDelegate,FilterOrderViewDelegate>
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetOrderListOperation;
@property (strong, nonatomic) OrderDoc *orderDoc_Selected;          //进入OrderDetailViewController所需要的参数
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) UIToolbar *accessoryInputView;
@property (strong, nonatomic) NSMutableArray *orderStatus;
@property (strong, nonatomic) NSMutableArray *orderType;
@property (strong, nonatomic) NSMutableArray *orderIsPaid;
@property (strong, nonatomic) ReusableArray *orderList;
@property (strong, nonatomic) id dataArray;
@property (strong, nonatomic) NSDictionary *dataDict;

@property (nonatomic,strong)FilterOrderView *filterView;
@property (nonatomic,strong)UIView *grayView;

@property (nonatomic,assign)BOOL isExpanted;

@end

@implementation OrderListViewController
@synthesize orderArray;
@synthesize orderDoc_Selected;
@synthesize requestStatus;
@synthesize requestType;
@synthesize requestIsPaid;
@synthesize pickerView;
@synthesize accessoryInputView;
@synthesize orderStatus;
@synthesize orderType;
@synthesize orderIsPaid;
@synthesize actionSheet;


- (void)initNavigationItem
{
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 20.0f, 30.0f, 30.0f)];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(kSCREN_BOUNDS.size.width - 50.0f, 0 , 44, 44)];
    rightBtn.titleEdgeInsets = UIEdgeInsetsMake(-15, 0, 0, 0);
    rightBtn.titleLabel.font = kNormalFont_28;
    [rightBtn setTitle:@"..." forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(filterAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
}

- (void)removeFilterView
{
    _isExpanted = NO;
    if (_filterView) {
        [_filterView removeFromSuperview];
        _filterView = nil;
    }
    if (_grayView) {
        [_grayView removeFromSuperview];
        _grayView = nil;
    }
}
- (void)filterAction
{
    if (_isExpanted) {
        [self removeFilterView];
    }else{
        //灰色背景
        _grayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height)];
        _grayView.backgroundColor =RGBA(184, 184, 184, 0.5);
        [self.view addSubview:_grayView];
        
        _isExpanted = YES;
        _filterView= [[FilterOrderView alloc]initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kFilterOrderView_Height)];
        _filterView.delegate = self;
        _filterView.type = requestType;
        _filterView.orderState = requestStatus;
        _filterView.payState = requestIsPaid;
        [self.view addSubview:_filterView];
    }
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    self.isShowButton = NO;
    [super viewDidLoad];
    [self initNavigationItem];
    self.view.backgroundColor = kDefaultBackgroundColor;
    _isExpanted = NO;
    
    _orderList = [[ReusableArray alloc] init];
    _orderList.delegate = self;
    _dataDict = @{@"order_ID":@"OrderID",
                  @"order_AccountName":@"ResponsiblePersonName",
                  @"order_OrderTime":@"OrderTime",
                  @"order_Status":@"Status",
                  @"order_Type":@"ProductType",
                  @"order_Ispaid":@"PaymentStatus",
                  @"order_UnPaidPrice":@"UnPaidPrice",
                  @"order_ProductName":@"ProductName",
                  @"order_ProductNumber":@"Quantity",
                  @"order_ObjectID":@"OrderObjectID"};
    
    
    orderType = [NSMutableArray arrayWithObjects: @"全部", @"服务", @"商品", nil];
    orderStatus = [NSMutableArray arrayWithObjects: @"全部", @"未完成", @"已完成", @"已取消", @"已终止", nil];
    orderIsPaid = [NSMutableArray arrayWithObjects: @"全部", @"未支付", @"部分付", @"已支付",@"免支付",nil];
    self.title = @"我的订单";
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.separatorColor = kTableView_LineColor;
    [_tableView setFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height + 20)];

  
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    requestType = -1;
    requestStatus = -1;
    requestIsPaid = -1;
    [self requestOrderList];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestGetOrderListOperation || [_requestGetOrderListOperation isExecuting]) {
        [_requestGetOrderListOperation cancel];
        _requestGetOrderListOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}
#pragma mark - UITableViewDataSource && UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_ThirdCellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_orderList Count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"MyCell";
    OrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[OrderListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.tag = indexPath.row;
    }
    OrderDoc *orderDoc = [_orderList getObjectWithClass:[OrderDoc class] indexPath:indexPath];
    [self getOrderDocWithIndex:indexPath.row andObject:orderDoc];
    [cell updateData:orderDoc];
    cell.selectButton.hidden = YES;
    return cell;
}
#pragma mark -  UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.hidesBottomBarWhenPushed = YES;
    orderDoc_Selected = [_orderList getObjectWithIndexPath:indexPath];
    if (orderDoc_Selected.order_Type == 0) {
        [self performSegueWithIdentifier:@"gotoOrderDetailAboutServiceViewFromOrderListView" sender:self];
    } else if(orderDoc_Selected.order_Type == 1) {
        [self performSegueWithIdentifier:@"gotoOrderDetailAboutCommodityViewFromOrderListView" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gotoOrderDetailAboutServiceViewFromOrderListView"]) {
        OrderDetailViewController *detailController = segue.destinationViewController;
        detailController.orderDoc = orderDoc_Selected;
    } else if ([segue.identifier isEqualToString:@"gotoOrderDetailAboutCommodityViewFromOrderListView"]) {
        OrderDetailAboutCommodityViewController *detailController = segue.destinationViewController;
        detailController.orderDoc = orderDoc_Selected;
    }
}

- (NSArray *)getVisibleCells
{
    [_tableView indexPathsForVisibleRows];
    [_tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:12 inSection:0]];
    return [_tableView visibleCells];
}

-(NSUInteger)vitrualCount
{
    return [_dataArray count];
}

-(NSArray *)getObjectsOnShown
{
    return [_tableView indexPathsForVisibleRows];
}
#pragma mark -  FilterOrderViewDelegate
-(void)FilterOrderViewCance
{
    [self removeFilterView];
}
-(void)FilterOrderViewConfirmWithType:(NSInteger)aType orderState:(NSInteger)aOrderState payState:(NSInteger)aPayState
{
    [self convertTypeWithType:aType];
    [self convertTypeWithOrderState:aOrderState];
    [self convertTypeWithPayState:aPayState];
    [self removeFilterView];
    [self requestOrderList];
}
#pragma mark - 对应的tag 转化  参数
//全部 -1 服务 0 商品 1
- (void)convertTypeWithType:(NSInteger)aType
{
    switch (aType) {
        case 100:
        {
            requestType = -1;
        }
            break;
        case 101:
        {
            requestType = 0;
            
        }
            break;
        case 102:
        {
            requestType = 1;
        }
            break;
        default:
            break;
    }
}
//全部 -1 未完成 1 已完成 2 已终止 3 已取消 4
- (void)convertTypeWithOrderState:(NSInteger)aOrderState
{
    switch (aOrderState) {
        case 200:
        {
            requestStatus = -1;
        }
            break;
        case 201:
        {
            requestStatus = 1;
            
        }
            break;
        case 202:
        {
            requestStatus = 2;
        }
            break;
        case 203:
        {
            requestStatus = 3;
        }
            break;
        case 204:
        {
            requestStatus = 4;
        }
            break;
        default:
            break;
    }
}
//全部 -1 未支付 1 部分付 2 已支付 3 部分付 5
- (void)convertTypeWithPayState:(NSInteger)aPayState
{
    switch (aPayState) {
        case 300:
        {
            requestIsPaid = -1;
        }
            break;
        case 301:
        {
            requestIsPaid = 1;
        }
            break;
        case 302:
        {
            requestIsPaid = 2;
        }
            break;
        case 303:
        {
            requestIsPaid = 3;
        }
            break;
        case 304:
        {
            requestIsPaid = 5;
        }
            break;
        default:
            break;
    }
}
#pragma mark - 接口

-(OrderDoc *)getOrderDocWithIndex:(NSInteger)index andObject:(id)object{
    NSDictionary *obj = [_dataArray objectAtIndex:index];
    OrderDoc *orderDoc = object;
    [orderDoc assignObjectPropertyWithDictionary:obj andObjectPropertyAssociatedDictionary:_dataDict];
    
    ProductAndPriceDoc *productAndPriceDoc = [[ProductAndPriceDoc alloc] init];
    productAndPriceDoc.flag = orderDoc.order_Type;
    productAndPriceDoc.totalMoney = [obj[@"TotalOrigPrice"] doubleValue];
    productAndPriceDoc.discountMoney = [obj[@"TotalSalePrice"] doubleValue];

    if (orderDoc.order_Type == 0) {
        ServiceDoc *serDoc = [[ServiceDoc alloc] init];
        [serDoc setService_ProductName:obj[@"ProductName"]];
        [serDoc setService_Quantity:[obj[@"Quantity"] intValue]];
        productAndPriceDoc.serviceArray = @[serDoc];
        orderDoc.productAndPriceDoc = productAndPriceDoc;
    }
    
    if (orderDoc.order_Type == 1) {
        NSMutableArray *tmpServiceArray = [NSMutableArray array];
        CommodityDoc *commDoc = [[CommodityDoc alloc] init];
        [commDoc setComm_CommodityName:obj[@"ProductName"]];
        [commDoc setComm_Quantity:[obj[@"Quantity"] intValue]];
        [tmpServiceArray addObject:commDoc];
        productAndPriceDoc.commodityArray = tmpServiceArray;
        orderDoc.productAndPriceDoc = productAndPriceDoc;
    }
    return orderDoc;
}

- (void)requestOrderList
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    self.view.userInteractionEnabled = NO;
    if (orderArray)
        [orderArray removeAllObjects];
    else
        orderArray = [NSMutableArray array];
    
    NSDictionary *para = @{@"ProductType":@(requestType),
                           @"Status":@(requestStatus),
                           @"PaymentStatus":@(requestIsPaid),
                           @"CustomerID":@(CUS_CUSTOMERID),
                           @"BranchID":@(0),
                           @"PageIndex":@1,
                           @"PageSize":@(INT32_MAX)};

    _requestGetOrderListOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/order/GetOrderList"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            NSArray *array = data[@"OrderList"] == [NSNull null] ? nil : data[@"OrderList"];
            _dataArray = array;
            [SVProgressHUD dismiss];
            
        } failure:^(NSInteger code, NSString *error) { }];
        
        [_tableView reloadData];
        self.view.userInteractionEnabled = YES;
    } failure:^(NSError *error) {
        
    }];
}

@end
