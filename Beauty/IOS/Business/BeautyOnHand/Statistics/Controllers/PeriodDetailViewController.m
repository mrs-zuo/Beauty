//
//  PeriodDetailViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by Bizapper VM MacOS  on 15/11/30.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//
#define kLineViewColor [UIColor colorWithRed:196.0/255.0 green:230.0/255.0 blue:244.0/255 alpha:1]


#import "PeriodDetailViewController.h"
#import "NavigationView.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "GPBHTTPClient.h"
#import "ChartModel.h"
#import "PeriodDetailTableViewCell.h"

@interface PeriodDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
     UITableView *periodDetailTableView;
    NSMutableArray *periodDetailData;
    AFHTTPRequestOperation *_requestPeriodDetailOperation;
}
@end

@implementation PeriodDetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,  5.0f) title:[NSString stringWithFormat:@"消费倾向分析(%@)", ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_Name]];
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
    [lab setText:@"顾客到店及消费统计"];
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
    
    if ((IOS7 || IOS8)) periodDetailTableView.separatorInset = UIEdgeInsetsZero;
    [self.view addSubview:periodDetailTableView];

    periodDetailData = [NSMutableArray array];
    [self requestWithObjectType:0];
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
-(void)requestWithObjectType:(NSInteger)ObjectType
{
    CustomerDoc *customer = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected;
    [SVProgressHUD showWithStatus:@"Loading..."];
    if (periodDetailData) {
        [periodDetailData removeAllObjects];
    } else {
        periodDetailData = [NSMutableArray array];
    }
    
    NSInteger ExtractItemType = 4;
    NSInteger MonthCount = 0;
    
    
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld,\"ObjectType\":%ld,\"StartTime\":\"%@\",\"EndTime\":\"%@\",\"MonthCount\":%ld,\"ExtractItemType\":%ld}", (long)customer.cus_ID,  (long)ObjectType,@"",@"",(long)MonthCount,(long)ExtractItemType];
    _requestPeriodDetailOperation = [[GPBHTTPClient sharedClient]requestUrlPath:@"Statistics/GetDataStatisticsList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
