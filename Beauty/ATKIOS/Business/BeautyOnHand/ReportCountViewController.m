//
//  ReportCountViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-10-17.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "ReportCountViewController.h"
#import "SVProgressHUD.h"
#import "GPHTTPClient.h"
#import "NavigationView.h"
#import "DEFINE.h"
#import "NormalEditCell.h"
#import "ReportDataDoc.h"
#import "GPBHTTPClient.h"

@interface ReportCountViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetCompanyTotalReport;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ReportDataDoc *reportDataDoc;
@property (nonatomic, strong) NSString *todayDate;
@end
@implementation ReportCountViewController
@synthesize branchID;
@synthesize reportDataDoc;
@synthesize todayDate;

- (void)viewDidLoad {
    [super viewDidLoad];

    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"累计数据统计"];
    [self.view addSubview:navigationView];
    
    _tableView = [[ UITableView alloc] initWithFrame:CGRectMake(5.0f, navigationView.frame.origin.y,310.0f, kSCREN_BOUNDS.size.height) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = nil;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.sectionFooterHeight = 5.0f;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 40.0;
    _tableView.sectionFooterHeight = 5;
    _tableView.sectionHeaderHeight = 5;
    
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
        _tableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }

    [self.view addSubview:_tableView];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    todayDate = [formatter stringFromDate:[NSDate date]];
    
    [self requestCompanyTotalReport];
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestGetCompanyTotalReport && [_requestGetCompanyTotalReport isExecuting]) {
        [_requestGetCompanyTotalReport cancel];
    }
    _requestGetCompanyTotalReport = nil;
    
    if ([SVProgressHUD isVisible]) [SVProgressHUD dismiss];
}


#pragma makr - tableViewDelegate  && dataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_HeightOfRow;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = reportDataDoc.sectionDatas[section];
    UIView  *vi = [[UIView alloc]initWithFrame:CGRectMake(5, 0, kSCREN_BOUNDS.size.width - 10, kTableView_HeightOfRow)];
    vi.backgroundColor = BACKGROUND_COLOR_TITLE;
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(5, 0,vi.frame.size.width - 10, kTableView_HeightOfRow)];
    lab.font = kFont_Light_16;
    lab.textColor = [UIColor whiteColor];
    if ([title isEqualToString:@"截止日期"]) {
        lab.text = [NSString stringWithFormat:@"截止日期:%@", todayDate];
    }else{
        lab.text = title;
    }
    [vi addSubview:lab];
    return vi;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return reportDataDoc.sectionDatas.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *title = reportDataDoc.sectionDatas[section];
    if ([title isEqualToString:@"截止日期"]) {
        return 0;
    }else if ([title isEqualToString:@"人员"]) {
        return reportDataDoc.personRowDatas.count;
    }else if ([title isEqualToString:@"订单"]) {
        return reportDataDoc.orderRowDatas.count;
    }else{
        return 0;
    }
}

- (NSString *)valueTextWithReportDataDoc:(ReportDataDoc *)reprot detailsTitle:(NSString *)detailsTitle
{
        NSString *valueText;
    if([detailsTitle isEqualToString:@"有效顾客"]){
        valueText = [NSString stringWithFormat:@"%ld人", (long)reportDataDoc.AllCustomerCount];
    }else if([detailsTitle isEqualToString:@"顾客端用户"]){
        valueText = [NSString stringWithFormat:@"%ld人", (long)reprot.ClientCount];
    }else if([detailsTitle isEqualToString:@"公众号用户"]){
        valueText =[NSString stringWithFormat:@"%ld人", (long)reprot.WeChatCount];
    }else if([detailsTitle isEqualToString:@"总余额"]){
        valueText = MoneyFormat(reprot.AllECardBalanceCount);
    }else if([detailsTitle isEqualToString:@"总数量"]){
        valueText = [NSString stringWithFormat:@"%ld个", (long)reprot.AllCardCount];
    }else if([detailsTitle isEqualToString:@"明细"]){
        valueText = @"";
    }else if([detailsTitle isEqualToString:@"完成订单数量"]){
        valueText = [NSString stringWithFormat:@"%ld个", (long)reprot.CompleteOrderCount];
    }else if([detailsTitle isEqualToString:@"有效订单数量"]){
        valueText = [NSString stringWithFormat:@"%ld个", (long)reprot.EffectOrderCount];
    }else if([detailsTitle isEqualToString:@"订单总金额"]){
        valueText = MoneyFormat(reprot.OrderTotalSalePrice);
    }else{
        valueText = @"";
    }
    return valueText;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellInentifier = @"countCell";
    NormalEditCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellInentifier];
    
    if (!cell) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellInentifier];
        cell.valueText.enabled = NO;
        cell.valueText.textColor = kColor_Black;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.backgroundColor = [UIColor whiteColor];
    NSString *title = reportDataDoc.sectionDatas[indexPath.section];
    [self valueTextWithReportDataDoc:reportDataDoc detailsTitle:title];
    if ([title isEqualToString:@"人员"]) {
        cell.titleLabel.text  = reportDataDoc.personRowDatas[indexPath.row];
        if([cell.titleLabel.text isEqualToString:@"顾客端用户"] || [cell.titleLabel.text isEqualToString:@"公众号用户"]){
            cell.titleLabel.frame = CGRectMake(25.0f, kTableView_HeightOfRow/2 - 20.0f/2, 200 - 20, 20.0f);
        }
    }else if ([title isEqualToString:@"订单"]) {
        cell.titleLabel.text  = reportDataDoc.orderRowDatas[indexPath.row];
    }
   
    cell.valueText.text =  [self valueTextWithReportDataDoc:reportDataDoc detailsTitle:cell.titleLabel.text ];
    
//    switch (indexPath.row) {
//        case 0:
//            cell.titleLabel.font = kFont_Light_16;
//            cell.titleLabel.textColor = [UIColor whiteColor];
//            cell.titleLabel.text = [NSString stringWithFormat:@"截止日期:%@", todayDate];
//            cell.backgroundColor = BACKGROUND_COLOR_TITLE;
//            break;
//        case 1:
//            cell.titleLabel.text = @"顾客数量";
//            cell.valueText.text = [NSString stringWithFormat:@"%ld个", (long)reportDataDoc.AllCustomerCount];
//            break;
//        case 2:
//            cell.titleLabel.text = @"账号数量";
//            cell.valueText.text = [NSString stringWithFormat:@"%ld个", (long)reportDataDoc.AllAccountCount];
//            break;
//
//        case 3:
//            cell.titleLabel.text = @"完成订单数量";
//            cell.valueText.text = [NSString stringWithFormat:@"%ld个", (long)reportDataDoc.CompleteOrderCount];
//            break;
//
//        case 4:
//            cell.titleLabel.text = @"有效订单数量";
//            cell.valueText.text = [NSString stringWithFormat:@"%ld个", (long)reportDataDoc.EffectOrderCount];
//            break;
//
//        case 5:
//            cell.titleLabel.text = @"订单总金额";
//            cell.valueText.text = MoneyFormat(reportDataDoc.OrderTotalSalePrice);
//            break;
//
//        case 6:
//            cell.titleLabel.text = @"储值卡总充值";
//            cell.valueText.text = MoneyFormat(reportDataDoc.AllECardRechargeCount);
//            break;
//
//        case 7:
//            cell.titleLabel.text = @"储值卡总余额";
//            cell.valueText.text = MoneyFormat(reportDataDoc.AllECardBalanceCount);
//            break;
//    }
    return cell;
}
- (void)requestCompanyTotalReport
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"BranchID\":%ld}", (long)ACC_COMPANTID, (long)ACC_BRANCHID];
    
    _requestGetCompanyTotalReport = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Report/getTotalCountReport" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD dismiss];
            reportDataDoc = [[ReportDataDoc alloc] initWithDictionary:data];
            [_tableView reloadData];

        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
        
    } failure:^(NSError *error) {
    }];
    
    /*
    _requestGetCompanyTotalReport = [[GPHTTPClient shareClient] requestGetCompanyTotalReportWithCompanyID:ACC_COMPANTID BranchID:branchID success:^(id xml) {
        
        [SVProgressHUD dismiss];
        
        
        NSString *origalString = (NSString*)xml;
        NSString *regexString = @"[{*}]";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *array = [regex matchesInString:origalString options:0 range:NSMakeRange(0,origalString.length)];
        if(!array || [array count] < 2)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"获取统计失败!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];;
            [alertView show];
            return;
        }
        origalString = [origalString substringWithRange:NSMakeRange(((NSTextCheckingResult *)[array objectAtIndex:0]).range.location,  ((NSTextCheckingResult *)[array objectAtIndex:[array count]-1]).range.location + 1)];
        NSData *origalData = [origalString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:origalData options:NSJSONReadingMutableLeaves error:nil];
        NSDictionary *obj = [dataDic objectForKey:@"Data"];
        
        if ([[dataDic objectForKey:@"Code"] integerValue] != 1) {
            [SVProgressHUD showErrorWithStatus2:[dataDic objectForKey:@"Message"] touchEventHandle:^{}];
            return;
        }
        
        
//        for (NSDictionary *obj in data) {
        if((NSNull *)obj != [NSNull null]) {
            reportDataDoc = [[ReportDataDoc alloc] init];
            
            reportDataDoc.customer_Quantity = [[obj objectForKey:@"AllCustomerCount"] integerValue];
            
            reportDataDoc.account_Quantity = [[obj objectForKey:@"AllAccountCount"] integerValue];
//            reportDataDoc.shop_Quantity = [[obj objectForKey:@"AllBranchCount"] integerValue];
            reportDataDoc.complete_Order = [[obj objectForKey:@"CompleteOrderCount"] integerValue];
            reportDataDoc.effect_Order = [[obj objectForKey:@"EffectOrderCount"] integerValue];
            
            
            reportDataDoc.revenue_All = [[obj objectForKey:@"OrderTotalSalePrice"] doubleValue];
            
            reportDataDoc.ecard_recharge = [[obj objectForKey:@"AllECardRechargeCount"] doubleValue];
            reportDataDoc.ecard_Balances = [[obj objectForKey:@"AllECardBalanceCount"] doubleValue];
            
//        }
        [_tableView reloadData];
        }
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];

    }];
            */
    
}


@end
