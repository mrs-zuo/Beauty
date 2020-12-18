//
//  OrderViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-1-10.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "OrderRootViewController.h"
#import "GDataXMLNode.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "NavigationView.h"
#import "OrderListViewController.h"
#import "NormalEditCell.h"
#import "AppDelegate.h"
#import "DEFINE.h"
#import "PermissionDoc.h"
#import "PaymentHistoryViewController.h"
#import "GPNavigationController.h"
#import "GPBHTTPClient.h"

#define GO_TO_CUSTOMER [[[NSUserDefaults standardUserDefaults] objectForKey:@"GO_TO_CUSTOMER"] intValue]
#define PAYFLAG     [[PermissionDoc sharePermission] rule_Payment_Use] && ACC_BRANCHID != 0

@interface OrderRootViewController ()
@property(weak, nonatomic) AFHTTPRequestOperation *requestGetOrderCountOperation;
@property(assign, nonatomic) NSInteger order_TotalCount;
@property(assign, nonatomic) NSInteger order_UnpaidCount;
@property(assign, nonatomic) NSInteger order_UncompletedService;
@property(assign, nonatomic) NSInteger order_UndeliveredCommodity;
@property (strong, nonatomic) NSIndexPath *indexPath_Selected;
@end

@implementation OrderRootViewController
@synthesize order_TotalCount;
@synthesize order_UnpaidCount;
@synthesize order_UncompletedService;
@synthesize order_UndeliveredCommodity;
@synthesize indexPath_Selected;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    if(self.clearStack){
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        NSInteger count = array.count;
        for(int i = 0; i < count - 1 ; i++) {
            [array removeObjectAtIndex:0];
        }
        [self.navigationController setViewControllers:array];
        self.clearStack = NO;
        GPNavigationController *navigation = (GPNavigationController *)self.navigationController;
        navigation.canDragBack = YES;
    }
    if (kMenu_Type == 0) {
        if (self.menue == 1) {
            [self requestGetOrderCount];
        }else{
            [self performSegueWithIdentifier:@"goOrderListViewFromOrderRootView" sender:self];
            
            NSMutableArray *newViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
            [newViewControllers removeObjectAtIndex:0];
            [self.navigationController setViewControllers:newViewControllers];
        }
    } else if (kMenu_Type == 1) {
        [self requestGetOrderCount];
    }
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    if (GO_TO_CUSTOMER) {
//        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"GO_TO_CUSTOMER"];
//        [self tableView:_tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestGetOrderCountOperation && [_requestGetOrderCountOperation isExecuting]) {
        [_requestGetOrderCountOperation cancel];
    }
    _requestGetOrderCountOperation = nil;
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self requestGetOrderCount];
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,  5.0f) title:(kMenu_Type == 0 ? @"订单" :[NSString stringWithFormat:@"%@的订单", ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_Name])];
    
    [self.view addSubview:navigationView];

    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - 64.0f - ( 5.0f + navigationView.frame.size.height) - 5.0f);
    } else {
        _tableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - 64.0f - ( 5.0f + navigationView.frame.size.height) - 5.0f);
    }
    
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = nil;
    
    if ((IOS7 || IOS8)) _tableView.separatorInset = UIEdgeInsetsZero;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_HeightOfRow;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    NSLog(@"%ld", (long)ACC_BRANCHID);
//    if (PAYFLAG)
//        return 5;
//    else
        return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentity = @"NormalEditCell";
    NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (cell ==  nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentity];
        UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
        arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
        [cell.contentView addSubview:arrowsImage];
    }
    if (indexPath.section == 0) {
        cell.titleLabel.text = @"所有订单";
        cell.valueText.text = [NSString stringWithFormat:@"(%ld)", (long)order_TotalCount];
        cell.valueText.textColor = [UIColor blackColor];
        cell.valueText.enabled = NO;
        [cell setAccessoryText:@"   "];
    }
    else  if (indexPath.section == 1) {
        cell.titleLabel.text = @"未完成的服务订单";
        cell.valueText.text = [NSString stringWithFormat:@"(%ld)", (long)order_UncompletedService];
        cell.valueText.textColor = [UIColor blackColor];
        cell.valueText.enabled = NO;
        [cell setAccessoryText:@"   "];
    }
    else  if (indexPath.section == 2) {
        cell.titleLabel.text = @"未完成的商品订单";
        cell.valueText.text = [NSString stringWithFormat:@"(%ld)", (long)order_UndeliveredCommodity];
        cell.valueText.textColor = [UIColor blackColor];
        cell.valueText.enabled = NO;
        [cell setAccessoryText:@"   "];
    }
//    else if (indexPath.section == 3 && PAYFLAG) {
//        cell.titleLabel.text = @"结账";
//        cell.valueText.text = [NSString stringWithFormat:@"(%ld)", (long)order_UnpaidCount];
//        cell.valueText.textColor = [UIColor blackColor];
//        cell.valueText.enabled = NO;
//        [cell setAccessoryText:@"   "];
//    }
    else if (indexPath.section == 3 ) {//|| (indexPath.section == 3 && !PAYFLAG
        cell.titleLabel.text = @"支付记录";
        cell.valueText.text = @"";
        cell.valueText.textColor = [UIColor blackColor];
        cell.valueText.enabled = NO;
        [cell setAccessoryText:@"   "];

    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    indexPath_Selected = indexPath;
//    if(indexPath.section == 3 && PAYFLAG )
//        [self performSegueWithIdentifier:@"goOrderPayListViewFromOrderRootView" sender:self];
//    else
    if (indexPath.section == 3 ) {//|| (indexPath.section == 3 && !PAYFLAG)
        PaymentHistoryViewController *payment = [self.storyboard instantiateViewControllerWithIdentifier:@"PaymentHistoryViewController"];
        [self.navigationController pushViewController:payment animated:YES];
    }
    else
        [self performSegueWithIdentifier:@"goOrderListViewFromOrderRootView" sender:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goOrderListViewFromOrderRootView"]) {
        OrderListViewController *orderListVC = segue.destinationViewController;
        orderListVC.lastView = 1;
        
        switch (indexPath_Selected.section) {
            case 0:
                orderListVC.requestType = -1;
                orderListVC.requestStatus = -1;
                orderListVC.requestIsPaid = -1;
                //orderListVC.navTitle = @"所有订单";
                break;
            case 1:
                orderListVC.requestType = 0;
                orderListVC.requestStatus = 1;
                orderListVC.requestIsPaid = -1;
                //orderListVC.navTitle = @"进行中的服务";
                break;
            case 2:
                orderListVC.requestType = 1;
                orderListVC.requestStatus = 1;
                orderListVC.requestIsPaid = -1;
                //orderListVC.navTitle = @"待交付的商品";
                break;
        }
    }
}

#pragma mark - 接口
- (void)requestNoCustomer
{
    order_TotalCount = 0;
    order_UnpaidCount = 0;
    order_UncompletedService = 0;
    order_UndeliveredCommodity = 0;
    
    [_tableView reloadData];

    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateNoChooserCustomerNotification object:nil];
}

- (void)requestGetOrderCount
{
    CustomerDoc *customerDoc = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected;
    if (customerDoc.cus_ID == 0) {
        [self requestNoCustomer];
        return;
    }     [SVProgressHUD showWithStatus:@"Loading"];
    
    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"BranchID\":%ld,\"CustomerID\":%ld,\"IsBusiness\":%d}", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)customerDoc.cus_ID, 1];

    
    _requestGetOrderCountOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/GetOrderCount" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            order_TotalCount = [[data objectForKey:@"Total"] integerValue];
            order_UnpaidCount = [[data objectForKey:@"Unpaid"] integerValue];
            order_UncompletedService = [[data objectForKey:@"UncompletedService"] integerValue];
            order_UndeliveredCommodity = [[data objectForKey:@"UndeliveredCommodity"] integerValue];
            
            [_tableView reloadData];

        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
    
    /*
    _requestGetOrderCountOperation = [[GPHTTPClient shareClient] requestGetOrderCountWithCustomerID:customerDoc.cus_ID success:^(id xml) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithXML:xml viewController:nil showSuccessMsg:NO showErrorMsg:YES success:^(id data, id message) {
            order_TotalCount = [[data objectForKey:@"Total"] integerValue];
            order_UnpaidCount = [[data objectForKey:@"Unpaid"] integerValue];
            order_UncompletedService = [[data objectForKey:@"UncompletedService"] integerValue];
            order_UndeliveredCommodity = [[data objectForKey:@"UndeliveredCommodity"] integerValue];
            
            [_tableView reloadData];
            
        } failure:^(NSString *error) {
        }];
        */
        
        /*
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            order_TotalCount  = [[[[contentData elementsForName:@"Total"]  objectAtIndex:0] stringValue] intValue];
            order_UnpaidCount = [[[[contentData elementsForName:@"Unpaid"] objectAtIndex:0] stringValue] intValue];
            order_UncompletedService = [[[[contentData elementsForName:@"UncompletedService"] objectAtIndex:0] stringValue] intValue];
            order_UndeliveredCommodity = [[[[contentData elementsForName:@"UndeliveredCommodity"] objectAtIndex:0] stringValue] intValue];
            [_tableView reloadData];
        } failure:^{}];
         */
        /*
    } failure:^(NSError *error) {
        NSLog(@"error.localizedDescription  is %@", error.localizedDescription);
        NSLog(@"error.localizedFailureReason  is %@", error.localizedFailureReason);
        NSLog(@"error.localizedRecoveryOptions  is %@", error.localizedRecoveryOptions);
        NSLog(@"error.localizedRecoverySuggestion  is %@", error.localizedRecoverySuggestion);

        [SVProgressHUD dismiss];
    }];
         */
}

@end
