//
//  ReportPersonAnalyzeDetailsViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/4/8.
//  Copyright © 2016年 ace-009. All rights reserved.
//
#define kBtn_WitheColor   [UIColor colorWithRed:251.0/255.0 green:251.0/255.0 blue:251.0/255.0 alpha:1]

#define kBtn_BuleColor   [UIColor colorWithRed:2.0 /225.0 green:87.0 /255.0 blue:155.0/255 alpha:1]
#define kBackgroundColor [UIColor colorWithRed:208.0/255.0 green:235.0/255.0 blue:245.0/255 alpha:1]

#define kLineViewColor [UIColor colorWithRed:196.0/255.0 green:230.0/255.0 blue:244.0/255 alpha:1]

#define kKindView_Width kSCREN_BOUNDS.size.width / 2
#define kKindView_Height 20

#import "ReportPersonAnalyzeDetailsViewController.h"
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
#import "NSDate+Convert.h"
#include <stdlib.h>

@interface ReportPersonAnalyzeDetailsViewController () <UUChartDataSource>
{
    
    UUChart *chartView_1;
    
    AFHTTPRequestOperation *_requestBranchDataStatisticsListOperation;
    NSMutableArray *periodData;
    
    UIView *subView_1;
    
    NSMutableArray *chartData_1;
    
    NSMutableArray *xTitles;
    
    double  max_Count;
    
    NSMutableArray *btnTitleData;
    NSMutableArray *btnData;
}
@end

@implementation ReportPersonAnalyzeDetailsViewController
@synthesize startDateBasic, endDateBasic;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initView];
    [self requestWithObjectType:self.currentSelectButtonTag];
}
- (void)initData
{
    btnTitleData = [NSMutableArray arrayWithObjects:@"操作",@"销售",@"充值", nil];
    btnData = [NSMutableArray array];
    chartData_1 = [NSMutableArray array];
    xTitles = [NSMutableArray array];
}
- (void)initView
{
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,  5.0f) title:[NSString stringWithFormat:@"个人业绩分类统计(%@)", self.personName]];
    [self.view addSubview:navigationView];
    
    subView_1 = [[UIView alloc]initWithFrame:CGRectMake(5, navigationView.frame.origin.y + navigationView.frame.size.height + 5, kSCREN_BOUNDS.size.width - 10, kSCREN_BOUNDS.size.height - (navigationView.frame.origin.y + navigationView.frame.size.height) - 5 - 40 - 5  - 5 - 64)];
    subView_1.backgroundColor = [UIColor whiteColor];
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, subView_1.frame.size.width, 40)];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = KColor_Blue;
    [lab setText:@"个人业绩统计"];
    lab.backgroundColor = [UIColor whiteColor];
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(5, 40.5, kSCREN_BOUNDS.size.width - 10 , 0.5)];
    viewLine.backgroundColor = kLineViewColor;
    [subView_1 addSubview:viewLine];
    [subView_1 addSubview:lab];
    [self.view addSubview:subView_1];

    //底部按钮
    UIView *btnView = [[UIView alloc]initWithFrame:CGRectMake(0, kSCREN_BOUNDS.size.height - 40 - 64 - 5 , kSCREN_BOUNDS.size.width , 40)];
    [self.view addSubview:btnView];
    
    CGFloat btnWidth = (btnView.frame.size.width - 10) / 3;
    for (int i = 0; i < btnTitleData.count; i ++) {
        UIButton *button  = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame =  CGRectMake(5 + (btnWidth * i), 0 , btnWidth, 40);
        [button setTitle:btnTitleData[i] forState:UIControlStateNormal];
        button.tag = i + 1;
        if (button.tag == self.currentSelectButtonTag) {
            [button setTitleColor:kColor_White forState:UIControlStateNormal];
            button.backgroundColor = kBtn_BuleColor;
        }else{
            [button setTitleColor:kColor_ButtonBlue forState:UIControlStateNormal];
            button.backgroundColor = kBtn_WitheColor;
        }
        [button addTarget:self action:@selector(performanceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [btnView addSubview:button];
        [btnData addObject:button];
    }

}
#pragma mark - 改变button样式
- (void)changeButtonStyle
{
    [btnData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)obj;
            if (button.tag == self.currentSelectButtonTag) {
                [button setTitleColor:kColor_White forState:UIControlStateNormal];
                button.backgroundColor = kBtn_BuleColor;
            }else{
                [button setTitleColor:kColor_ButtonBlue forState:UIControlStateNormal];
                button.backgroundColor = kBtn_WitheColor;
            }
        }
    }];
}
#pragma mark - 按钮事件
- (void)performanceBtnClick:(UIButton *)sender
{
    self.currentSelectButtonTag = sender.tag;
    [self changeButtonStyle];
    [self requestWithObjectType:sender.tag];
}


#pragma mark - 刷新图表
- (void)readDataWithObjectType:(NSInteger)ObjectType
{
    max_Count = 0; // 默认值
    for (int  i = 0 ; i < chartData_1.count; i ++) {
        NSNumber *tempNum = chartData_1[i];
        if (max_Count < tempNum.doubleValue) {
            max_Count = tempNum.doubleValue;
        }
    }
    chartView_1 = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(0, 41, subView_1.frame.size.width, subView_1.frame.size.height - 41) withSource:self withStyle:UUChartBarStyle];
    [chartView_1 showInView:subView_1];
    
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
#pragma mark - @required
//横坐标标题数组
- (NSArray *)UUChart_xLableArray:(UUChart *)chart
{
    return [self getXTitles:0 chart:chart];
}
//数值多重数组
- (NSArray *)UUChart_yValueArray:(UUChart *)chart
{
    return @[chartData_1];
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
    return CGRangeMake(max_Count, 0);
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
#pragma mark - 接口

-(void)requestWithObjectType:(NSInteger)ObjectType
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    NSInteger ExtractItemType = 2;
    NSInteger MonthCount = 6;
    //->Ver.010
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dayComponents = [gregorian components:NSCalendarUnitMonth fromDate:self.startDateBasic toDate:self.endDateBasic options:0];
    if (dayComponents.month >= 6){
        MonthCount = dayComponents.month;
    }
    NSInteger TimeChooseFlag = 5;
    
    //<-Ver.010
    //NSString *par = [NSString stringWithFormat:@"{\"AccountID\":%ld,\"ObjectType\":%ld,\"MonthCount\":%ld,\"ExtractItemType\":%ld}",(long)self.accountID,(long)ObjectType,(long)MonthCount,(long)ExtractItemType];
    NSString *par = [NSString stringWithFormat:@"{\"AccountID\":%ld,\"ObjectType\":%ld,\"MonthCount\":%ld,\"ExtractItemType\":%ld,\"StartTime\":\"%@\",\"EndTime\":\"%@\",\"TimeChooseFlag\":%ld}",(long)self.accountID,(long)ObjectType,(long)MonthCount,(long)ExtractItemType,[NSDate dateToString:self.startDateBasic dateFormat:@"yyyy-MM-dd"],[NSDate dateToString:self.endDateBasic dateFormat:@"yyyy-MM-dd"],(long)TimeChooseFlag];
    
    _requestBranchDataStatisticsListOperation = [[GPBHTTPClient sharedClient]requestUrlPath:@"/Statistics/GetBranchDataStatisticsList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [chartData_1 removeAllObjects];
            [xTitles removeAllObjects];
            NSArray *arr = data;
            for (int i = 0; i < arr.count; i++) {
                NSDictionary *dic = arr[i];
                NSNumber *count = [dic objectForKey:@"ObjectCount"];
                NSNumber *consume = [dic objectForKey:@"ConsumeAmout"];
                NSNumber *recharge = [dic objectForKey:@"RechargeAmout"];
                NSString *tempString = [dic objectForKey:@"ObjectName"];
                switch (ObjectType) {
                    case 1:
                    {
                        [chartData_1 addObject:count.stringValue];
                    }
                        break;
                    case 2:
                    {
                        [chartData_1 addObject:consume.stringValue];
                    }
                        break;
                    case 3:
                    {
                        [chartData_1 addObject:recharge.stringValue];
                    }
                        break;
                        
                    default:
                        break;
                }
                [xTitles addObject:tempString];
            }
            [self readDataWithObjectType:ObjectType];
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
    
}

@end
