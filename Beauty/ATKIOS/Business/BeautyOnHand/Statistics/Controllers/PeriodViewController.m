//
//  PeriodViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by Bizapper VM MacOS  on 15/11/24.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#define kBtn_WitheColor   [UIColor colorWithRed:251.0/255.0 green:251.0/255.0 blue:251.0/255.0 alpha:1]

#define kBtn_BuleColor   [UIColor colorWithRed:2.0 /225.0 green:87.0 /255.0 blue:155.0/255 alpha:1]
#define kBackgroundColor [UIColor colorWithRed:208.0/255.0 green:235.0/255.0 blue:245.0/255 alpha:1]

#define kLineViewColor [UIColor colorWithRed:196.0/255.0 green:230.0/255.0 blue:244.0/255 alpha:1]

#define kKindView_Width kSCREN_BOUNDS.size.width / 2
#define kKindView_Height 20

#import "PeriodViewController.h"
#import "NavigationView.h"
#import "AppDelegate.h"
#import "EColumnDataModel.h"
#import "EColumnChartLabel.h"
#import "EFloatBox.h"
#import "EColor.h"
#import "EColumn.h"
#import "EColumnChart.h"
#import "SVProgressHUD.h"
#import "GPBHTTPClient.h"
#import "ChartModel.h"
#import "DEFINE.h"
#import "UUChart.h"
#import "PeriodDetailViewController.h"
#include <stdlib.h>

@interface PeriodViewController () <UUChartDataSource>
{
    
     UUChart *chartView_1;
    UUChart *chartView_2;

    
    AFHTTPRequestOperation *_requestPeriodOperation;
    NSMutableArray *periodData;

    UIView *subView_1;
    UIView *subView_2;

    NSMutableArray *chartData_1;
    NSMutableArray *chartData_2;
    
    NSMutableArray *xTitles;
    
    NSInteger  max_Count;
    double max_Amout;
}
@end

@implementation PeriodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,  5.0f) title:[NSString stringWithFormat:@"消费倾向分析(%@)", ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_Name]];
    UIImage *img = [UIImage imageNamed:@"pop_chart"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame =  CGRectMake(navigationView.frame.size.width - navigationView.frame.size.height - 5.0f, 0, navigationView.frame.size.height,navigationView.frame.size.height);
    [button setImage:img forState:UIControlStateNormal];
    [navigationView addSubview:button];
    [button addTarget:self action:@selector(enterDetail:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:navigationView];

    subView_1 = [[UIView alloc]initWithFrame:CGRectMake(5, navigationView.frame.origin.y + navigationView.frame.size.height + 5, kSCREN_BOUNDS.size.width - 10, (kSCREN_BOUNDS.size.height - 64 -navigationView.frame.origin.y - navigationView.frame.size.height - 5) / 2)];
    subView_1.backgroundColor = [UIColor whiteColor];
    
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, subView_1.frame.size.width, 40)];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = KColor_Blue;
    [lab setText:@"每月到店次数"];
    lab.backgroundColor = [UIColor whiteColor];
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(5,   40.5, kSCREN_BOUNDS.size.width - 10 , 0.5)];
    viewLine.backgroundColor = kLineViewColor;
    [subView_1 addSubview:viewLine];
    [subView_1 addSubview:lab];
    [self.view addSubview:subView_1];
    
    subView_2 = [[UIView alloc]initWithFrame:CGRectMake(5, subView_1.frame.origin.y + subView_1.frame.size.height + 5, kSCREN_BOUNDS.size.width - 10,(kSCREN_BOUNDS.size.height - 64 -navigationView.frame.origin.y - navigationView.frame.size.height - 5) / 2 - 10)];
    UILabel *lab2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, subView_1.frame.size.width, 40)];
    lab2.textAlignment = NSTextAlignmentCenter;
    lab2.textColor = KColor_Blue;
    [lab2 setText:@"每月消费金额"];
    lab.backgroundColor = [UIColor whiteColor];
    UIView *viewLine2 = [[UIView alloc]initWithFrame:CGRectMake(5, 40.5, kSCREN_BOUNDS.size.width - 10 , 0.5)];
    viewLine2.backgroundColor = kLineViewColor;
    [subView_2 addSubview:viewLine2];
    [subView_2 addSubview:lab2];
    subView_2.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:subView_2];
    
    chartData_1 = [NSMutableArray array];
    chartData_2 = [NSMutableArray array];
    xTitles = [NSMutableArray array];
    [self requestWithExtractItemType:3];
}

#pragma mark - 按钮事件
- (void)enterDetail:(UIButton *)sender
{
    PeriodDetailViewController *periodDetailVC = [[PeriodDetailViewController alloc]init];
    
    [self.navigationController pushViewController:periodDetailVC animated:YES];
}

#pragma mark - 
- (void)readDataWithExtractItemType:(NSInteger)ExtractItemType
{
        for (int  i = 0 ; i < chartData_1.count; i ++) {
            NSNumber *tempNum = chartData_1[i];
            if (max_Count < tempNum.integerValue) {
                max_Count = tempNum.integerValue;
            }
        }
        chartView_1 = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(0, 41, subView_1.frame.size.width, subView_1.frame.size.height - 41) withSource:self withStyle:UUChartBarStyle];
        [chartView_1 showInView:subView_1];
    
        for (int  i = 0 ; i < chartData_2.count; i ++) {
            NSNumber *tempNum = chartData_2[i];
            if (max_Amout < tempNum.doubleValue) {
                max_Amout = tempNum.doubleValue;
            }
        }
        chartView_2 = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(0, 41, subView_2.frame.size.width, subView_2.frame.size.height - 41) withSource:self withStyle:UUChartBarStyle];
        [chartView_2 showInView:subView_2];
}
- (NSArray *)getXTitles:(int)num chart:(UUChart *)chart
{
    NSMutableArray *tempTitles = [NSMutableArray array];
    for (int i=0; i<xTitles.count; i++) {
        NSString * str = [xTitles objectAtIndex:i];;
        [tempTitles addObject:str];
    }
    return tempTitles;

}
-(void)requestWithExtractItemType:(NSInteger)ExtractItemType
{
    CustomerDoc *customer = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected;
    [SVProgressHUD showWithStatus:@"Loading..."];
    NSInteger ObjectType = 0;
    NSInteger MonthCount = 0;
    
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld,\"ObjectType\":%ld,\"StartTime\":\"%@\",\"EndTime\":\"%@\",\"MonthCount\":%ld,\"ExtractItemType\":%ld}", (long)customer.cus_ID,  (long)ObjectType,@"",@"",(long)MonthCount,(long)ExtractItemType];
    _requestPeriodOperation = [[GPBHTTPClient sharedClient]requestUrlPath:@"Statistics/GetDataStatisticsList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            NSArray *arr = data;
            for (int i = 0; i < arr.count; i++) {
                NSDictionary *dic = arr[i];
                NSNumber *count = [dic objectForKey:@"ObjectCount"];
                NSNumber *amout = [dic objectForKey:@"TotalAmout"];
                NSString *tempString = [dic objectForKey:@"ObjectName"];
                [chartData_1 addObject:count.stringValue];
                [chartData_2 addObject:amout.stringValue];
                [xTitles addObject:tempString];
            }
            [self readDataWithExtractItemType:ExtractItemType];
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
    
}

#pragma mark - @required
//横坐标标题数组
- (NSArray *)UUChart_xLableArray:(UUChart *)chart
{
    return [self getXTitles:0 chart:chart];
}
//数值多重数组
- (NSArray *)UUChart_yValueArray:(UUChart *)chart
{
    if (chart  == chartView_1) {
        NSArray *ary1 = chartData_1;
        return @[ary1];
    }else{
        NSArray *ary2 = chartData_2;
        return @[ary2];
    }
}

#pragma mark - @optional
//颜色数组
- (NSArray *)UUChart_ColorArray:(UUChart *)chart
{
    return @[UUGreen];
}
//显示数值范围
- (CGRange)UUChartChooseRangeInLineChart:(UUChart *)chart
{
    if (chart == chartView_1) {
        return CGRangeMake(max_Count, 0);
    }else{
        return CGRangeMake(max_Amout, 0);
    }
}
#pragma mark 折线图专享功能

//标记数值区域
- (CGRange)UUChartMarkRangeInLineChart:(UUChart *)chart
{
    //        return CGRangeMake(0, 100);
    return CGRangeZero;
}

//判断显示横线条
- (BOOL)UUChart:(UUChart *)chart ShowHorizonLineAtIndex:(NSInteger)index
{
    return YES;
}

//判断显示最大最小值
- (BOOL)UUChart:(UUChart *)chart ShowMaxMinAtIndex:(NSInteger)index
{
    return YES;
}
@end
