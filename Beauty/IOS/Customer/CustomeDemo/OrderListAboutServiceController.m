//
//  OrderListAboutServiceController.m
//  CustomeDemo
//
//  Created by TRY-MAC01 on 13-11-19.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "OrderListAboutServiceController.h"
#import "OrderDetailViewController.h"
#import "GDataXMLNode.h"
#import "GDataXMLDocument+ParseXML.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "OrderDoc.h"
#import "ProductAndPriceDoc.h"
#import "AppDelegate.h"
#import "UIButton+InitButton.h"
#import "UIActionSheet+AddBlockCallBacks.h"

#import "PayInfoViewController.h"

@interface OrderListAboutServiceController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetOrderListAboutServiceOperation;
@property (strong, nonatomic) OrderDoc *orderDoc_Selected; //  进入OrderDetailViewController所需要的参数
@property (strong, nonatomic) NSMutableArray *orderArray_Selected; //  进入PayInfoViewController所需要的参数
@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) UIButton *payButton;
@property (assign, nonatomic) NSInteger requestCode; // -1:全部 0:进行中、2:已完成、3:已取消。
@property (assign, nonatomic) NSInteger flag;//判断是否已经添加过footerView和button
@end

@implementation OrderListAboutServiceController
@synthesize orderArray;
@synthesize orderDoc_Selected;
@synthesize orderArray_Selected;
@synthesize requestCode;
@synthesize footerView;
@synthesize payButton;
@synthesize flag;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = kColor_BackgroundView;
    
    //初始化TitleView
    TitleView *titleView = [[TitleView alloc] init];
    [self.view addSubview:[titleView getTitleView:@"订单一览"]];
    _tableView.frame = CGRectMake(5.0f, 41.0f, 310.0f, kSCREN_BOUNDS.size.height  - 5.0f - (titleView.frame.origin.y + titleView.frame.size.height) );
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
        [_tableView setFrame:CGRectMake(5.0f, 41.0f, 310.0f, kSCREN_BOUNDS.size.height - 20.0f)];
    }

    UIButton *screenButton = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(screenButton)
                                                 frame:CGRectMake(270.0f, (titleView.frame.size.height - 40.0f)/2, 40.0f, 40.0f)
                                         backgroundImg:[UIImage imageNamed:@"order_select"]
                                      highlightedImage:nil];
    [titleView addSubview:screenButton];
    
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    requestCode = -1;
    flag = 0;
    [self requestOrderList:requestCode];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestGetOrderListAboutServiceOperation || [_requestGetOrderListAboutServiceOperation isExecuting]) {
        [_requestGetOrderListAboutServiceOperation cancel];
        _requestGetOrderListAboutServiceOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}


- (void)reloadData
{
    if (requestCode == 0) {
        if (flag == 0) {
            CGRect rect = self.tableView.frame;
            rect.size.height = kSCREN_BOUNDS.size.height - 36.0f - 44.0f - 49.0f - 10.0f - 44.0f;
            _tableView.frame = rect;
            
            footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, _tableView.frame.origin.y + _tableView.frame.size.height + 5.0f, 320.0f, 44.0f)];
            payButton = [UIButton buttonWithTitle:@""
                                           target:self
                                         selector:@selector(payAction)
                                            frame:CGRectMake(5.0f, (44.0f - 36.0f)/2, 310.0f, 36.0f)
                                    backgroundImg:[UIImage imageNamed:@"order-paybtn"]
                                 highlightedImage:nil];
            [footerView addSubview:payButton];
            footerView.backgroundColor = [UIColor clearColor];
            [self.view addSubview:footerView];
            flag = 1;
        }
    } else {
        CGRect rect = self.tableView.frame;
        rect.size.height = kSCREN_BOUNDS.size.height  - 36.0f - 44.0f - 49.0f - 10.0f;
        _tableView.frame = rect;
        
        [payButton removeFromSuperview]; payButton = nil;
        [footerView removeFromSuperview]; footerView = nil;
        flag = 0;
    }
    
    [_tableView reloadData];
}


- (void)payAction
{
    if (orderArray_Selected.count != 0) {
        CGFloat totalPrice = 0.0f;
        CGFloat totalSalePrice = 0.0f;
        
        for (OrderDoc *orderDoc in orderArray_Selected) {
            ProductAndPriceDoc *productAndPriceDoc = orderDoc.productAndPriceDoc;
            totalPrice += productAndPriceDoc.totalMoney;
            totalSalePrice += productAndPriceDoc.discountMoney;
        }
        
        PayInfoViewController *payInfoController = (PayInfoViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"PayInfoViewController"];
        payInfoController.totalMoney = totalPrice;
        payInfoController.favorable = totalSalePrice;
        payInfoController.orderNumbers = [orderArray_Selected count];
        payInfoController.paymentOrderArray = orderArray_Selected;
        [self.navigationController pushViewController:payInfoController animated:YES];
    } else {
        [SVProgressHUD showErrorWithStatus:@"请选择需要支付的订单"];
    }
}

- (void)screenButton
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"订单分类"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:@"全部订单"
                                                    otherButtonTitles:@"进行中的订单", @"已完成的订单", @"已取消的订单",nil];
    [actionSheet showActionSheetWithInView:self.view handler:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        requestCode = buttonIndex - 1;
        [self requestOrderList:requestCode];
    }];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [orderArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"MyCell";
    OrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[OrderListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    OrderDoc *orderDoc = [orderArray objectAtIndex:indexPath.row];
    [cell updateData:orderDoc];
    [cell setDelegate:self];
    
    if (orderDoc.order_Status == 0  && requestCode == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectButton.hidden = NO;
        
        if ([orderArray_Selected containsObject:orderDoc]) {
            [cell.selectButton setSelected:YES];
        } else {
            [cell.selectButton setSelected:NO];
        }
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectButton.hidden = YES;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_HeightOfRow_Multiline;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    orderDoc_Selected =[orderArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"gotoOrderDetailViewFromOrderListViewAboutServiceView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gotoOrderDetailViewFromOrderListViewAboutServiceView"]) {
        OrderDetailViewController *detailController = segue.destinationViewController;
        detailController.orderDoc = orderDoc_Selected;
        detailController.type = 0;//type: 0服务  1商品
    }
}

#pragma mark - OrderListCellDelete

- (void)selectedTheOrderListCell:(OrderListCell *)cell
{
    if (!orderArray_Selected)
        orderArray_Selected= [NSMutableArray array];
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    OrderDoc *tmpOrderDoc = [orderArray objectAtIndex:indexPath.row];
    
    if (![orderArray_Selected containsObject:tmpOrderDoc]) {
        [orderArray_Selected addObject:tmpOrderDoc];
    } else {
        [orderArray_Selected removeObject:tmpOrderDoc];
    }
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - 接口

- (void)requestOrderList:(NSInteger)requstCode
{
    [SVProgressHUD showWithStatus:@"Loading"];
    _requestGetOrderListAboutServiceOperation = [[GPHTTPClient shareClient] requestGetOrderListAboutServiceWithType:requstCode success:^(id xml) {
        _tableView.userInteractionEnabled = NO;
        if (orderArray_Selected) {
            [orderArray_Selected removeAllObjects];
        }
        [SVProgressHUD dismiss];
        [GDataXMLDocument parseXML:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData) {
            if (orderArray) {
                [orderArray removeAllObjects];
            } else {
                orderArray = [NSMutableArray array];
            }
            
            for (GDataXMLElement *data in [contentData elementsForName:@"Order"]) {
                OrderDoc *orderDoc = [[OrderDoc alloc] init];
                
                [orderDoc setOrder_ID:[[[[data elementsForName:@"OrderID"] objectAtIndex:0] stringValue] integerValue]];
                [orderDoc setOrder_OrderTime:[[[data elementsForName:@"OrderTime"] objectAtIndex:0] stringValue]];
                [orderDoc setOrder_Status:[[[[data elementsForName:@"Status"] objectAtIndex:0] stringValue] intValue]];
                
                ProductAndPriceDoc *productAndPriceDoc = [[ProductAndPriceDoc alloc] init];
                productAndPriceDoc.flag = 0;
                productAndPriceDoc.totalMoney = [[[[data elementsForName:@"TotalPrice"] objectAtIndex:0] stringValue] floatValue];
                productAndPriceDoc.discountMoney = [[[[data elementsForName:@"TotalSalePrice"] objectAtIndex:0] stringValue] floatValue];
                
                ServiceDoc *serDoc = [[ServiceDoc alloc] init];
                [serDoc setService_ProductName:[[[data elementsForName:@"ProductName"] objectAtIndex:0] stringValue]];
                [serDoc setService_Quantity:[[[[data elementsForName:@"Quantity"] objectAtIndex:0] stringValue] intValue]];
                
                productAndPriceDoc.serviceArray = @[serDoc];
                orderDoc.productAndPriceDoc = productAndPriceDoc;
                [orderArray addObject:orderDoc];
            }
            
            [self reloadData];
        } failure:^{}];
        _tableView.userInteractionEnabled = YES;
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

@end

