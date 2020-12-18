//
//  RechargeAndPayViewController.m
//  CustomeDemo
//
//  Created by MAC_Lion on 13-8-20.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//
#import "RechargeAndPayViewController.h"
#import "RechargeAndPayCell.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "PayAndRechargeDoc.h"
#import "GDataXMLDocument+ParseXML.h"
#import "PaymentHistoryDetailViewController.h"
#import "RechargeDetailViewController.h"
#import "PaymentHistoryDoc.h"
#import "PayInfoDoc.h"

@interface RechargeAndPayViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *getPayAndRechargeOperation;
@property (strong, nonatomic) NSMutableArray *rechargePayList;
@end

@implementation RechargeAndPayViewController

#pragma mark -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}
-(void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self requesCustomertList];
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    
//    TitleView *titleView = [[TitleView alloc] init];
//    [self.view addSubview:[titleView getTitleView:@"充值消费记录"]];
    self.title = @"充值消费记录";
    
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorColor = kTableView_LineColor;
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_getPayAndRechargeOperation || [_getPayAndRechargeOperation isExecuting]) {
        [_getPayAndRechargeOperation cancel];
        _getPayAndRechargeOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_rechargePayList count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PayAndRechargeDoc *list =[self.rechargePayList objectAtIndex:indexPath.row];
    RechargeAndPayCell *cell = nil;
    if(list.p_Type == 1 && list.p_OrderCount != 0){
        NSString *cellindity =@"ConsumeCell";
        cell=[tableView dequeueReusableCellWithIdentifier:cellindity];
        if (cell == nil ) {
            cell=[[RechargeAndPayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellindity];
        }
    }else{
        
        NSString *cellindity =@"RechargeCell";
        cell=[tableView dequeueReusableCellWithIdentifier:cellindity];
        if (cell == nil ) {
            cell=[[RechargeAndPayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellindity];
        }
    }
    [cell.dateLabel setFont:kFont_Light_14];
    [cell.titleNameLabel setTextColor:kColor_TitlePink];
    
    [cell.titleNameLabel setText:list.p_Title];
    [cell.titleNameLabel setFont:kFont_Light_16];
    [cell.balanceLabel setText:[NSString stringWithFormat:@"%@ %@",CUS_CURRENCYTOKEN, list.p_Balance]];
    [cell.balanceLabel setFont:kFont_Light_14];
    [cell.dateLabel setText:list.p_Date];
    
    if(list.p_Type==0){
        [cell.contentText setTextColor:[UIColor greenColor]];
        [cell.contentText setFont:kFont_Light_14];
        [cell.contentText setText:[NSString stringWithFormat:@"+%@",list.p_Amount]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else{
        [cell.contentText setTextColor:[UIColor redColor]];
        [cell.contentText setFont:kFont_Light_14];
        [cell.contentText setText:list.p_Amount];
        if(list.p_OrderCount > 1)
           [cell.titleNameLabel setText:[NSString stringWithFormat:@"%@...等",list.p_Title]];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_HeightOfRow_Single + 3;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PayAndRechargeDoc *payAndRechargeDoc = [_rechargePayList objectAtIndex:indexPath.row];
    if(payAndRechargeDoc.p_Type == 1 && payAndRechargeDoc.p_OrderCount != 0)
    {
        PaymentHistoryDetailViewController *PayDetail = [[self storyboard] instantiateViewControllerWithIdentifier:@"PaymentHistoryDetailViewController"];
        PaymentHistoryDoc *paymentHistory = [[PaymentHistoryDoc alloc] init];
        paymentHistory.paymentId = payAndRechargeDoc.p_PaymentID;
        paymentHistory.paymentBalanceLeft = [payAndRechargeDoc.p_Balance doubleValue];
        paymentHistory.paymentMode = [NSMutableArray array];
        PayInfoDoc *pay = [[PayInfoDoc alloc] init];
        pay.pay_Mode = [NSString stringWithFormat:@"%ld",(long)1];
        [paymentHistory.paymentMode  addObject:pay];
        PayDetail.page = 1;
        PayDetail.paymentHistoryDoc = paymentHistory;
        [self.navigationController pushViewController:PayDetail animated:YES];
    } else {
        RechargeDetailViewController *rechargeDetail = [[self storyboard] instantiateViewControllerWithIdentifier:@"RechargeDetailViewController"];
        rechargeDetail.rechargeTitle = [payAndRechargeDoc.p_Title substringToIndex:2];
        rechargeDetail.rechargeId = payAndRechargeDoc.p_ID;
        rechargeDetail.mode = payAndRechargeDoc.p_Mode;
        [self.navigationController pushViewController:rechargeDetail animated:YES];
    }
}
#pragma mark - 接口

- (void)requesCustomertList
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary *para = @{@"CustomerID":@(CUS_CUSTOMERID)};
    _getPayAndRechargeOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/ECard/getBalanceHistory"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        if (!_rechargePayList){
            _rechargePayList = [NSMutableArray array];
        } else {
            [_rechargePayList removeAllObjects];
        }
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            NSDictionary *dict = @{@"p_Date":@"Time",
                                   @"p_Type":@"Type",
                                   @"p_Mode":@"Mode",
                                   @"p_Title":@"RechargeText",
                                   @"p_PaymentID":@"PaymentID",
                                   @"p_ID":@"ID",
                                   @"p_OrderCount":@"OrderCount",
                                   @"p_Remark":@"Remark"};
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                PayAndRechargeDoc *customer = [[PayAndRechargeDoc alloc] init];
                [customer assignObjectPropertyWithDictionary:obj andObjectPropertyAssociatedDictionary:dict];
                customer.p_Amount = [NSString stringWithFormat:@"%.2f",[obj[@"Amount"] doubleValue]];
                customer.p_Balance = [NSString stringWithFormat:@"%.2f",[obj[@"Balance"] doubleValue]];
                [_rechargePayList addObject:customer];
            }];

            [_tableView reloadData];
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {

        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}


@end
