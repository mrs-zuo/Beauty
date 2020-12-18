//
//  ReportOperationAnalyzeDetailsViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/4/8.
//  Copyright © 2016年 ace-009. All rights reserved.
//
#define kLineViewColor [UIColor colorWithRed:196.0/255.0 green:230.0/255.0 blue:244.0/255 alpha:1]

#import "ReportOperationAnalyzeDetailsViewController.h"
#import "NavigationView.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "GPBHTTPClient.h"
#import "ChartModel.h"
#import "PeriodDetailTableViewCell.h"
#import "NSDate+Convert.h"


@interface ReportOperationAnalyzeDetailsViewController () <UITableViewDataSource,UITableViewDelegate>
{
    UITableView *periodDetailTableView;
    NSMutableArray *periodDetailData;
    AFHTTPRequestOperation *_requestBranchDataStatisticsOperation;
}
@end

@implementation ReportOperationAnalyzeDetailsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,  5.0f) title:@"营业状况统计"];
    UIImage *img = [UIImage imageNamed:@"enter_chart"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame =  CGRectMake(navigationView.frame.size.width - navigationView.frame.size.height - 5.0f, 0, navigationView.frame.size.height,navigationView.frame.size.height);
    [button setImage:img forState:UIControlStateNormal];
    [navigationView addSubview:button];
    [button addTarget:self action:@selector(enterDetail:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:navigationView];
    
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(5, navigationView.frame.origin.y + navigationView.frame.size.height + 5, self.view.frame.size.width - 10, 40)];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = KColor_Blue;
    //[lab setText:@"门店消费按月总览"];
    [lab setText:@"门店消费总览"];
    lab.backgroundColor = [UIColor whiteColor];
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(5,   40.5, kSCREN_BOUNDS.size.width - 10 , 0.5)];
    viewLine.backgroundColor = kLineViewColor;
    [self.view addSubview:viewLine];
    [self.view addSubview:lab];
    
    periodDetailTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    if ((IOS7 || IOS8)) {
        periodDetailTableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height + 41, 310.0f, kSCREN_BOUNDS.size.height -64.0f - ( 5.0f + navigationView.frame.size.height + navigationView.frame.origin.y) - 5.0f);
    } else {
        periodDetailTableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f,kSCREN_BOUNDS.size.height -64.0f - ( 5.0f + navigationView.frame.size.height + navigationView.frame.origin.y) - 5.0f);
    }
    
    periodDetailTableView.delegate = self;
    periodDetailTableView.dataSource = self;
    periodDetailTableView.separatorColor = kTableView_LineColor;
    periodDetailTableView.backgroundView = nil;
    periodDetailTableView.backgroundColor = nil;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone&&screenSize.height > screenSize.width&&screenSize.height == 568) {
        periodDetailTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN + 5 )];
    }
    if ((IOS7 || IOS8)) periodDetailTableView.separatorInset = UIEdgeInsetsZero;
    [self.view addSubview:periodDetailTableView];
    
    periodDetailData = [NSMutableArray array];
    [self requestGetBranchDataStatisticsList];
}
#pragma mark - 按钮事件
- (void)enterDetail:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - tableViewDelegate && dataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 140;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return periodDetailData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString *identifier = @"Cell";
    PeriodDetailTableViewCell *cell = (PeriodDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"PeriodDetailTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.data = periodDetailData[indexPath.row];
    return cell;
}
#pragma mark -  接口
-(void)requestGetBranchDataStatisticsList
{
    
    //    接口地址：/Statistics/GetBranchDataStatisticsList
    //    参数 {"ObjectType":0,"MonthCount": 6,"ExtractItemType":3,"AccountID" : 11761}
    //    MonthCount 抽取的月份数
    
//    [SVProgressHUD showWithStatus:@"Loading..."];
//    NSInteger ObjectType = 0;
//    NSInteger MonthCount = 0;
//    NSString *par = [NSString stringWithFormat:@"{\"ObjectType\":%ld,\"MonthCount\":%ld,\"ExtractItemType\":%ld}",(long)ObjectType,(long)MonthCount,(long)self.extractItemType];

    
    [SVProgressHUD showWithStatus:@"Loading..."];
    if (periodDetailData) {
        [periodDetailData removeAllObjects];
    } else {
        periodDetailData = [NSMutableArray array];
    }
    
    //->Ver.010
    //NSInteger MonthCount = 3;
    NSInteger MonthCount = 6;
    NSInteger ObjectType = 0;
    switch (self.cycleType) {
        case 1:
            MonthCount = 6;
            break;
        case 2:
            MonthCount = 6;
            break;
        case 3:
            MonthCount = 6;
            break;
        case 4:
            MonthCount = 6;
            break;
        default:
            MonthCount = 7;
            break;
    }
    //NSString *par = [NSString stringWithFormat:@"{\"ObjectType\":%ld,\"MonthCount\":%ld,\"ExtractItemType\":%ld}",(long)ObjectType,(long)MonthCount,(long)self.self.extractItemType];

    //NSString *par = [NSString stringWithFormat:@"{\"ObjectType\":%ld,\"MonthCount\":%ld,\"ExtractItemType\":%ld,\"TimeChooseFlag\":%d}",(long)ObjectType,(long)MonthCount,(long)self.self.extractItemType,6];
    
    NSString *par = [NSString stringWithFormat:@"{\"ObjectType\":%ld,\"MonthCount\":%ld,\"ExtractItemType\":%ld,\"StartTime\":\"%@\",\"EndTime\":\"%@\",\"TimeChooseFlag\":%ld}",(long)ObjectType,(long)MonthCount,(long)self.self.extractItemType,[NSDate dateToString:self.startDateBasic dateFormat:@"yyyy-MM-dd"],[NSDate dateToString:self.startDateBasic dateFormat:@"yyyy-MM-dd"],(long)self.cycleType];
    
    //<-Ver.010
    
    _requestBranchDataStatisticsOperation = [[GPBHTTPClient sharedClient]requestUrlPath:@"/Statistics/GetBranchDataStatisticsList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            NSArray *arr = data;
            for (int i = 0; i < arr.count; i++) {
                NSDictionary *dic = arr[i];
                ChartModel *chart = [[ChartModel alloc]init];
                if ([dic objectForKey:@"ObjectCount"]) {
                    chart.ObjectCount = [dic objectForKey:@"ObjectCount"];
                }
                if ([dic objectForKey:@"ObjectName"]) {
                    chart.ObjectName = [dic objectForKey:@"ObjectName"];
                }
                if ([dic objectForKey:@"ConsumeAmout"]) {
                    chart.ConsumeAmout = [dic objectForKey:@"ConsumeAmout"];
                }
                if ([dic objectForKey:@"RechargeAmout"]) {
                    chart.RechargeAmout = [dic objectForKey:@"RechargeAmout"];
                }
                if ([dic objectForKey:@"TotalAmout"]) {
                    chart.TotalAmout = [dic objectForKey:@"TotalAmout"];
                }
                [periodDetailData addObject:chart];
            }
            [periodDetailTableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
    
}

@end
