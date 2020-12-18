//
//  RechargeAndPayDetailViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-8-1.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "RechargeAndPayDetailViewController.h"
#import "NavigationView.h"
#import "RechargeAndPayCell.h"
#import "DEFINE.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "OrderDoc.h"
#import "OrderListCell.h"

@interface RechargeAndPayDetailViewController ()
@property (strong, nonatomic) AFHTTPRequestOperation *getPayAndRechargeDetailOperation;
@property (strong, nonatomic) NSMutableArray *orderArray;

@end

@implementation RechargeAndPayDetailViewController
@synthesize orderArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"消费记录详情"];
    [self.view addSubview:navigationView];
    [self requestPayAndRechargeDetailWithPaymentID:self.paymentID];
    
    if ((IOS7 || IOS8)) {
        _tableView.separatorInset = UIEdgeInsetsZero;
    }
    _tableView.allowsSelection = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor whiteColor];
    
    _tableView.frame = CGRectMake( 5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        cell = [[OrderListCell alloc] initWithStyleAlignRight:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
       // cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    OrderDoc *orderDoc = [orderArray objectAtIndex:indexPath.row];
    [cell updateData:orderDoc];

    
    cell.selectButton.hidden = YES;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.0f;
}

#pragma mark - 接口

- (void)requestPayAndRechargeDetailWithPaymentID:(NSInteger)paymentID
{
    [SVProgressHUD setStatus:@"Loading"];
    _getPayAndRechargeDetailOperation = [[GPHTTPClient shareClient] requestGetOrderListByPaymentID:paymentID success:^(id xml) {
        if (orderArray) {
            [orderArray removeAllObjects];
        } else {
            orderArray = [NSMutableArray array];
        }
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            
            [SVProgressHUD dismiss];
            for (GDataXMLElement *data in [contentData elementsForName:@"Order"]) {
                OrderDoc *orderDoc = [[OrderDoc alloc] init];
                [orderDoc setOrder_ID:[[[[data elementsForName:@"OrderID"] objectAtIndex:0] stringValue] integerValue]];
                [orderDoc setOrder_ProductType:[[[[data elementsForName:@"ProductType"] objectAtIndex:0] stringValue] integerValue]];
                [orderDoc setOrder_CustomerName:[[[data elementsForName:@"CustomerName"] objectAtIndex:0] stringValue]];
                [orderDoc setOrder_ResponsiblePersonName:[[[data elementsForName:@"ResponsiblePersonName"] objectAtIndex:0] stringValue]];
                [orderDoc setOrder_OrderTime:[[[data elementsForName:@"OrderTime"] objectAtIndex:0] stringValue]];
                [orderDoc setOrder_Status:[[[[data elementsForName:@"Status"] objectAtIndex:0] stringValue] intValue]];
                [orderDoc setOrder_Ispaid:[[[[data elementsForName:@"IsPaid"] objectAtIndex:0] stringValue] intValue]];
                
                orderDoc.productAndPriceDoc.productDoc.pro_Name     = [[[data elementsForName:@"ProductName"] objectAtIndex:0] stringValue];
                orderDoc.productAndPriceDoc.productDoc.pro_Type     = [[[[data elementsForName:@"ProductType"] objectAtIndex:0] stringValue] integerValue];
                orderDoc.productAndPriceDoc.productDoc.pro_quantity = [[[[data elementsForName:@"Quantity"] objectAtIndex:0] stringValue] integerValue];
                orderDoc.productAndPriceDoc.productDoc.pro_TotalMoney     = [[[[data elementsForName:@"TotalOrigPrice"] objectAtIndex:0] stringValue] floatValue];
                orderDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney = [[[[data elementsForName:@"TotalSalePrice"] objectAtIndex:0] stringValue] floatValue];
                [orderArray addObject:orderDoc];
            }
            [_tableView reloadData];
            [SVProgressHUD dismiss];
        } failure:^{
             [SVProgressHUD dismiss];
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}
@end
